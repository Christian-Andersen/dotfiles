import argparse
from pathlib import Path

import cv2
import numpy as np

# Constants to avoid "Magic Number" linter errors (PLR2004)
MIN_REQUIRED_CLASSES = 2
HUD_META_LINES = 4  # IMG, BRUSH, OPACITY, and the separator line


class UniversalBrushLabeler:
    """
    A high-performance image segmentation tool.
    Supports up to 10 classes (0-9) with automated saving and HUD.
    """

    def __init__(
        self, input_dir: str, output_dir: str, class_names: list[str], alpha: float
    ) -> None:  # ANN204: Added return type
        self.input_path = Path(input_dir)
        self.output_path = Path(output_dir)
        self.output_path.mkdir(parents=True, exist_ok=True)

        # Limit to 10 names to match keyboard row 0-9. Index 0 is Eraser.
        self.class_names = class_names[:10]
        self.num_classes = len(self.class_names) - 1
        self.alpha = max(0.0, min(1.0, alpha))

        self.image_files = sorted(
            [p for p in self.input_path.iterdir() if p.suffix.lower() in (".jpg", ".png", ".jpeg", ".bmp", ".webp")]
        )

        self.current_idx = 0
        self.drawing = False
        self.show_hud = True
        self.last_point: tuple[int, int] | None = None
        self.mouse_pos: tuple[int, int] = (0, 0)

        self.brush_size = 20
        self.current_class = 1
        self.mask_cache: dict[int, np.ndarray] = {}
        self.window_name = "Universal Brush Labeler"

        # Fix for type-check diagnostics: Explicitly define numpy array dtype
        self.colors: list[list[int]] = []
        for i in range(self.num_classes):
            hue = int(179 * i / max(1, self.num_classes))
            hsv_pixel = np.array([[[hue, 210, 255]]], dtype=np.uint8)
            color = cv2.cvtColor(hsv_pixel, cv2.COLOR_HSV2BGR)[0][0]
            self.colors.append(color.tolist())

        self._load_existing_masks()

    def _load_existing_masks(self) -> None:
        for idx, img_path in enumerate(self.image_files):
            mask_file = self.output_path / f"mask_{img_path.stem}.png"
            if mask_file.exists():
                mask_data = cv2.imread(str(mask_file), cv2.IMREAD_GRAYSCALE)
                if mask_data is not None:
                    mask_data[mask_data > self.num_classes] = 0
                    self.mask_cache[idx] = mask_data

    def _save_current_mask(self) -> None:
        if self.current_idx not in self.mask_cache:
            return
        img_path = self.image_files[self.current_idx]
        mask_data = self.mask_cache[self.current_idx]
        out_name = self.output_path / f"mask_{img_path.stem}.png"
        cv2.imwrite(str(out_name), mask_data)

    def mouse_callback(
        self, event: int, x: int, y: int, _flags: int, _param: None
    ) -> None:  # ARG002: Prefixed unused args with underscore
        self.mouse_pos = (x, y)
        if self.current_idx not in self.mask_cache:
            return
        mask = self.mask_cache[self.current_idx]

        if event == cv2.EVENT_LBUTTONDOWN:
            self.drawing = True
            cv2.circle(mask, (x, y), self.brush_size, self.current_class, -1)
            self.last_point = (x, y)
        elif event == cv2.EVENT_MOUSEMOVE and self.drawing:
            if self.last_point:
                cv2.line(mask, self.last_point, (x, y), self.current_class, self.brush_size * 2)
            cv2.circle(mask, (x, y), self.brush_size, self.current_class, -1)
            self.last_point = (x, y)
        elif event == cv2.EVENT_LBUTTONUP:
            self.drawing = False
            self.last_point = None
            self._save_current_mask()

    def _draw_text_with_shadow(
        self,
        img: np.ndarray,
        text: str,
        pos: tuple[int, int],
        scale: float,
        color: tuple[int, int, int],
    ) -> None:  # ANN202: Added return type
        font = cv2.FONT_HERSHEY_SIMPLEX
        cv2.putText(img, text, pos, font, scale, (0, 0, 0), 3, cv2.LINE_AA)
        cv2.putText(img, text, pos, font, scale, color, 1, cv2.LINE_AA)

    def render(self, img: np.ndarray, mask: np.ndarray) -> np.ndarray:
        display = img.copy()
        labeled_pixels = mask > 0
        if np.any(labeled_pixels):
            overlay = np.zeros_like(img)
            for c in range(1, self.num_classes + 1):
                overlay[mask == c] = self.colors[c - 1]

            display[labeled_pixels] = cv2.addWeighted(img, 1.0 - self.alpha, overlay, self.alpha, 0)[labeled_pixels]

        if self.show_hud:
            self._draw_hud(display)
            cv2.circle(display, self.mouse_pos, self.brush_size, (255, 255, 255), 1, cv2.LINE_AA)

        cv2.circle(display, self.mouse_pos, 1, (0, 0, 255), -1)
        return display

    def _draw_hud(self, canvas: np.ndarray) -> None:
        font_scale = 0.55
        line_h = 30

        hud_elements = [
            f"IMG: {self.current_idx + 1}/{len(self.image_files)}",
            f"BRUSH: {self.brush_size}",
            f"OPACITY: {self.alpha:.2f}",
            "---",
        ]
        hud_elements.extend(f"{i}: {name}" for i, name in enumerate(self.class_names))

        max_w = 0
        for text in hud_elements:
            (w, _), _ = cv2.getTextSize(text, cv2.FONT_HERSHEY_SIMPLEX, font_scale, 1)
            max_w = max(max_w, w)

        hud_w, hud_h = max_w + 65, (len(hud_elements) * line_h) + 20
        if hud_h > canvas.shape[0] or hud_w > canvas.shape[1]:
            return

        cv2.rectangle(canvas, (10, 10), (10 + hud_w, 10 + hud_h), (25, 25, 25), -1)
        cv2.rectangle(canvas, (10, 10), (10 + hud_w, 10 + hud_h), (70, 70, 70), 1)

        for i, text in enumerate(hud_elements):
            y = 40 + (i * line_h)
            if i >= HUD_META_LINES:  # PLR2004: Used constant
                c_idx = i - HUD_META_LINES
                clr = (70, 70, 70) if c_idx == 0 else self.colors[c_idx - 1]
                if self.current_class == c_idx:
                    cv2.rectangle(canvas, (15, y - 20), (10 + hud_w - 5, y + 8), (200, 200, 200), 1)
                cv2.rectangle(canvas, (20, y - 15), (38, y + 3), clr, -1)
                cv2.rectangle(canvas, (20, y - 15), (38, y + 3), (255, 255, 255), 1)
                self._draw_text_with_shadow(canvas, text, (48, y), font_scale, (255, 255, 255))
            else:
                self._draw_text_with_shadow(canvas, text, (20, y), font_scale, (255, 255, 255))

    def _handle_keypress(self, key: int) -> bool:
        """Refactored keyboard logic to reduce method complexity (C901/PLR0912)."""
        if key == ord("q"):
            return False
        if key == ord("h"):
            self.show_hud = not self.show_hud
        elif key in (81, ord("a"), 2):  # Left
            self._save_current_mask()
            self.current_idx = max(0, self.current_idx - 1)
        elif key in (83, ord("d"), 3):  # Right
            self._save_current_mask()
            self.current_idx = min(len(self.image_files) - 1, self.current_idx + 1)
        elif key in (ord("+"), ord("=")):
            self.brush_size = min(400, self.brush_size + 2)
        elif key in (ord("-"), ord("_")):
            self.brush_size = max(1, self.brush_size - 2)
        elif ord("0") <= key <= ord("9"):
            v = int(chr(key))
            if v < len(self.class_names):
                self.current_class = v
        elif key == ord("c"):
            self.mask_cache[self.current_idx].fill(0)
            self._save_current_mask()
        return True

    def run(self) -> None:
        if not self.image_files:
            print("Error: No valid images found.")
            return

        cv2.namedWindow(self.window_name, cv2.WINDOW_NORMAL)
        cv2.setMouseCallback(self.window_name, self.mouse_callback)

        while True:
            if cv2.getWindowProperty(self.window_name, cv2.WND_PROP_VISIBLE) < 1:
                self._save_current_mask()
                break

            img = cv2.imread(str(self.image_files[self.current_idx]))
            if img is None:
                continue

            if self.current_idx not in self.mask_cache:
                self.mask_cache[self.current_idx] = np.zeros(img.shape[:2], dtype=np.uint8)

            display = self.render(img, self.mask_cache[self.current_idx])
            cv2.imshow(self.window_name, display)

            key = cv2.waitKey(1) & 0xFF
            if not self._handle_keypress(key):
                self._save_current_mask()
                break

        cv2.destroyAllWindows()
        print(f"\nFinal masks saved to: {self.output_path.absolute()}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Clean Universal Brush Labeler")
    parser.add_argument("-i", "--input", required=True, help="Input images path")
    parser.add_argument("-o", "--output", required=True, help="Output masks path")
    parser.add_argument("-n", "--names", nargs="+", required=True, help="Class names")
    parser.add_argument("-p", "--opacity", type=float, default=0.6, help="Alpha")

    args = parser.parse_args()

    if len(args.names) < MIN_REQUIRED_CLASSES:
        print("Error: Provide at least TWO class names (Background + Object).")
        raise SystemExit(1)

    UniversalBrushLabeler(args.input, args.output, args.names, args.opacity).run()
