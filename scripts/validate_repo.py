#!/usr/bin/env python3
from __future__ import annotations

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
README_FILES = [ROOT / "README.md", ROOT / "README.en.md", ROOT / "README.es.md"]
CITATION = ROOT / "CITATION.cff"

LINK_RE = re.compile(r"\[[^\]]+\]\(([^)]+)\)")


def check_links() -> list[str]:
    errors: list[str] = []
    for md_file in README_FILES:
        text = md_file.read_text(encoding="utf-8")
        for link in LINK_RE.findall(text):
            if "://" in link or link.startswith("#"):
                continue
            target = (md_file.parent / link).resolve()
            if not target.exists():
                rel = md_file.relative_to(ROOT)
                errors.append(f"{rel}: broken link -> {link}")
    return errors


def check_citation() -> list[str]:
    errors: list[str] = []
    text = CITATION.read_text(encoding="utf-8")
    required_keys = [
        "cff-version:",
        "title:",
        "message:",
        "type:",
        "version:",
        "date-released:",
        "authors:",
        "license:",
    ]
    for key in required_keys:
        if key not in text:
            errors.append(f"CITATION.cff missing required field: {key[:-1]}")
    return errors


def main() -> int:
    errors = [*check_links(), *check_citation()]
    if errors:
        print("Validation failed:")
        for err in errors:
            print(f" - {err}")
        return 1
    print("Validation OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
