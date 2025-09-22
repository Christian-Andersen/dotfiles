#!/usr/bin/env python3

import os
import sys
import errno
import logging
import argparse
from threading import Lock
from typing import (
    Any,
    Dict,
    Iterator,
    Optional,
    Set,
    Union,
)

# We need to install fusepy: pip install fusepy
try:
    from fuse import FUSE, FuseOSError, Operations
except ImportError:
    sys.exit(
        "Please install the 'fusepy' library: pip install fusepy"
    )

# 1. Set up a dedicated logger, not the root logger.
logger = logging.getLogger("SimpleCacheFS")
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)


class SimpleCacheFS(Operations):
    """
    A FUSE caching filesystem that overlays a simulated remote storage backend
    using a local disk cache.
    """
    def __init__(
        self,
        remote_dir: str,
        cache_dir: str,
        write_mode: str,
        metadata_cache: bool
    ) -> None:
        if not os.path.isdir(remote_dir) or not os.path.isdir(cache_dir):
            raise ValueError("Both remote and cache directories must exist and be directories.")

        self.remote_dir: str = os.path.realpath(remote_dir)
        self.cache_dir: str = os.path.realpath(cache_dir)
        self.write_mode: str = write_mode
        self.metadata_cache: bool = metadata_cache

        # In-memory state with type hints
        self.rwlock: Lock = Lock()
        self.dirty_files: Set[str] = set()
        self.open_files: Dict[int, int] = {}
        self.next_fh: int = 0

        # 2. Use the dedicated logger with lazy formatting
        logger.info("🚀 SimpleCacheFS initialized.")
        logger.info("   Remote Dir: %s", self.remote_dir)
        logger.info("   Cache Dir:  %s", self.cache_dir)
        logger.info("   Write Mode: %s", self.write_mode)
        logger.info("   Metadata Cache: %s", 'Enabled' if self.metadata_cache else 'Disabled')

    # --- Helper Methods ---
    def _remote_path(self, partial_path: str) -> str:
        """Translate a FUSE path to its remote backend storage path."""
        if partial_path.startswith("/"):
            partial_path = partial_path[1:]
        return os.path.join(self.remote_dir, partial_path)

    def _cache_path(self, partial_path: str) -> str:
        """Translate a FUSE path to its local cache path."""
        if partial_path.startswith("/"):
            partial_path = partial_path[1:]
        return os.path.join(self.cache_dir, partial_path)

    def _ensure_cached(self, path: str) -> None:
        """
        Ensure a file from the remote exists in the cache.
        Streams the file if it doesn't.
        """
        cache_p = self._cache_path(path)
        if os.path.exists(cache_p):
            return

        remote_p = self._remote_path(path)
        if not os.path.exists(remote_p):
            raise FuseOSError(errno.ENOENT)

        logger.info("CACHE MISS: Streaming '%s' from remote to cache.", path)
        os.makedirs(os.path.dirname(cache_p), exist_ok=True)

        try:
            with open(remote_p, 'rb') as remote_f, open(cache_p, 'wb') as cache_f:
                while True:
                    chunk = remote_f.read(64 * 1024)
                    if not chunk:
                        break
                    cache_f.write(chunk)
        except IOError as e:
            logger.error("Failed to stream file %s: %s", path, e)
            raise FuseOSError(errno.EIO) from e

    def _sync_to_remote(self, path: str) -> None:
        """Streams a file from the cache to the remote backend."""
        cache_p = self._cache_path(path)
        remote_p = self._remote_path(path)

        logger.info("SYNC: Streaming '%s' from cache to remote.", path)
        os.makedirs(os.path.dirname(remote_p), exist_ok=True)

        try:
            with open(cache_p, 'rb') as cache_f, open(remote_p, 'wb') as remote_f:
                while True:
                    chunk = cache_f.read(64 * 1024)
                    if not chunk:
                        break
                    remote_f.write(chunk)
        except IOError as e:
            logger.error("Failed to sync file %s to remote: %s", path, e)
            raise FuseOSError(errno.EIO) from e

    # --- FUSE Method Overrides ---
    def getattr(
        self, path: str, fh: Optional[int] = None
    ) -> Dict[str, Union[int, float]]:
        """Get file attributes."""
        cache_p = self._cache_path(path)

        if self.metadata_cache and os.path.exists(cache_p):
            st = os.lstat(cache_p)
        else:
            remote_p = self._remote_path(path)
            if not os.path.exists(remote_p):
                raise FuseOSError(errno.ENOENT)
            st = os.lstat(remote_p)

        # Explicitly create dict to satisfy mypy --strict
        attrs: Dict[str, Union[int, float]] = {}
        for key in (
            'st_atime', 'st_ctime', 'st_gid', 'st_mode', 'st_mtime',
            'st_nlink', 'st_size', 'st_uid'
        ):
            attrs[key] = getattr(st, key)
        return attrs

    def readdir(self, path: str, fh: int) -> Iterator[str]:
        """Read directory contents."""
        dirents = ['.', '..']
        remote_p = self._remote_path(path)
        cache_p = self._cache_path(path)
        content_set: Set[str] = set()

        if os.path.isdir(remote_p):
            content_set.update(os.listdir(remote_p))

        if os.path.isdir(cache_p):
            content_set.update(os.listdir(cache_p))

        dirents.extend(list(content_set))
        for r in dirents:
            yield r

    def open(self, path: str, flags: int) -> int:
        """Open a file. This triggers caching on first read."""
        with self.rwlock:
            self._ensure_cached(path)
            cache_p = self._cache_path(path)
            fd = os.open(cache_p, flags)
            fh = self.next_fh
            self.next_fh += 1
            self.open_files[fh] = fd
            return fh

    def create(self, path: str, mode: int, _fi: Optional[Any] = None) -> int:
        """Create a new file."""
        with self.rwlock:
            cache_p = self._cache_path(path)
            fd = os.open(cache_p, os.O_WRONLY | os.O_CREAT, mode)
            fh = self.next_fh
            self.next_fh += 1
            self.open_files[fh] = fd

            if self.write_mode == 'write-back':
                self.dirty_files.add(path)
                logger.info("WRITE-BACK: New file '%s' created and marked as dirty.", path)
            elif self.write_mode == 'write-through':
                self._sync_to_remote(path)
            return fh

    def read(self, path: str, length: int, offset: int, fh: int) -> bytes:
        """Read from an open file from the cache."""
        with self.rwlock:
            if fh not in self.open_files:
                raise FuseOSError(errno.EBADF)
            fd = self.open_files[fh]
            os.lseek(fd, offset, os.SEEK_SET)
            return os.read(fd, length)

    def write(self, path: str, data: bytes, offset: int, fh: int) -> int:
        """Write to an open file in the cache."""
        with self.rwlock:
            if fh not in self.open_files:
                raise FuseOSError(errno.EBADF)
            fd = self.open_files[fh]

            os.lseek(fd, offset, os.SEEK_SET)
            bytes_written = os.write(fd, data)

            if self.write_mode == 'write-through':
                logger.info("WRITE-THROUGH: Synchronizing '%s' to remote after write.", path)
                self._sync_to_remote(path)
            elif self.write_mode == 'write-back' and path not in self.dirty_files:
                logger.info("WRITE-BACK: Marking '%s' as dirty.", path)
                self.dirty_files.add(path)
        return bytes_written

    def release(self, path: str, fh: int) -> int:
        """Close a file. This triggers flushing for write-back mode."""
        with self.rwlock:
            if fh not in self.open_files:
                return -errno.EBADF

            fd = self.open_files.pop(fh)
            os.close(fd)

            if self.write_mode == 'write-back' and path in self.dirty_files:
                logger.info("WRITE-BACK: Flushing dirty file '%s' to remote on release.", path)
                try:
                    self._sync_to_remote(path)
                    self.dirty_files.remove(path)
                except Exception as e:
                    logger.error("Error during write-back flush for %s: %s", path, e)
        return 0

    def truncate(self, path: str, length: int, fh: Optional[int] = None) -> None:
        """Truncate a file."""
        with self.rwlock:
            self._ensure_cached(path)
            cache_p = self._cache_path(path)
            with open(cache_p, 'r+') as f:
                f.truncate(length)

            if self.write_mode == 'write-through':
                self._sync_to_remote(path)
            elif self.write_mode == 'write-back' and path not in self.dirty_files:
                logger.info("WRITE-BACK: Marking '%s' as dirty due to truncate.", path)
                self.dirty_files.add(path)

    def unlink(self, path: str) -> None:
        """Delete a file from both cache and remote."""
        with self.rwlock:
            cache_p = self._cache_path(path)
            remote_p = self._remote_path(path)

            if os.path.exists(cache_p):
                os.unlink(cache_p)
                logger.info("DELETED: Removed '%s' from cache.", path)

            if os.path.exists(remote_p):
                os.unlink(remote_p)
                logger.info("DELETED: Removed '%s' from remote.", path)

            self.dirty_files.discard(path)


def main() -> None:
    """Parse arguments and mount the filesystem."""
    parser = argparse.ArgumentParser(
        description="SimpleCacheFS: A FUSE caching filesystem.",
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument('remote_dir', help='The directory simulating remote storage.')
    parser.add_argument('cache_dir', help='The local directory to use as a cache.')
    parser.add_argument('mountpoint', help='The path where the filesystem will be mounted.')
    parser.add_argument(
        '--write-mode',
        choices=['write-through', 'write-back'],
        default='write-through',
        help="The caching strategy for write operations:\n"
             "  write-through: Writes are immediately synced to remote storage. (default)\n"
             "  write-back: Writes are cached and synced to remote storage on file close."
    )
    parser.add_argument(
        '--metadata-cache',
        action='store_true',
        help="Enable metadata caching. If set, 'getattr' will use the cached file's\n"
             "metadata. Otherwise, it will always check the remote."
    )
    args: argparse.Namespace = parser.parse_args()

    fs = SimpleCacheFS(
        remote_dir=args.remote_dir,
        cache_dir=args.cache_dir,
        write_mode=args.write_mode,
        metadata_cache=args.metadata_cache
    )

    FUSE(fs, args.mountpoint, foreground=True, allow_other=True)


if __name__ == '__main__':
    main()
