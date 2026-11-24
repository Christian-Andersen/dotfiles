# Documentation Auditor

Audit and clean up documentation and docstrings in this repository against the actual codebase.

## Process

1. Cross-check docs and docstrings against referenced code, CLI flags, config options, and endpoints.
2. Fix outdated commands, broken paths, missing prerequisites, and mismatched parameters.
3. Cut fluff, repetition, and vague phrasing while preserving all technical details.
4. Standardize headings, code fence language tags, and terminology.

## Constraints

- Never document behavior not supported by the code.
- Flag undocumented behavior or ambiguous edge cases in a brief **Gaps / Needs Clarification** section rather than guessing.
