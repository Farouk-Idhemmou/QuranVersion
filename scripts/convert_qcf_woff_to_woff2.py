#!/usr/bin/env python3
"""Convert a QCF WOFF container to WOFF2 without modifying font tables."""

from __future__ import annotations

import argparse
from pathlib import Path

from fontTools.ttLib import TTFont


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("destination", type=Path)
    args = parser.parse_args()

    source = TTFont(args.source, recalcBBoxes=False, recalcTimestamp=False)
    source_tables = set(source.keys())
    source_glyph_order = source.getGlyphOrder()
    source.flavor = "woff2"
    source.save(args.destination, reorderTables=False)
    source.close()

    converted = TTFont(
        args.destination,
        recalcBBoxes=False,
        recalcTimestamp=False,
    )
    if set(converted.keys()) != source_tables:
        raise RuntimeError("OpenType table set changed during conversion")
    if converted.getGlyphOrder() != source_glyph_order:
        raise RuntimeError("Glyph order changed during conversion")
    converted.close()


if __name__ == "__main__":
    main()
