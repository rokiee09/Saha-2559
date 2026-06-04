#!/usr/bin/env python3
"""Build hizmet_sureleri_raw.tsv and gorev_hizmet_sureleri_2026.json from WhatsApp EK-1 extractions."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TOOLS = Path(__file__).resolve().parent
BLOCKS = TOOLS / "hizmet_image_blocks.txt"
PATCH = TOOLS / "hizmet_gap_patch.txt"
TSV_OUT = TOOLS / "hizmet_sureleri_raw.tsv"
JSON_OUT = ROOT / "assets" / "json" / "gorev_hizmet_sureleri_2026.json"

LINE_RE = re.compile(r"^(\d+)\t(.+?)\t([12])\t(\d+)\s*$")


def parse_blocks(text: str) -> list[tuple[int, str, int, int]]:
    rows: list[tuple[int, str, int, int]] = []
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        m = LINE_RE.match(line)
        if not m:
            raise ValueError(f"Bad line: {line!r}")
        rows.append((int(m.group(1)), m.group(2), int(m.group(3)), int(m.group(4))))
    return rows


def dedupe(rows: list[tuple[int, str, int, int]]) -> list[tuple[int, str, int, int]]:
    """Keep last occurrence per SN (later patches override OCR errors)."""
    seen: dict[int, tuple[int, str, int, int]] = {}
    for row in rows:
        seen[row[0]] = row
    return [seen[k] for k in sorted(seen)]


def find_gaps(sns: list[int]) -> list[int]:
    if not sns:
        return []
    gaps = []
    for i in range(min(sns), max(sns) + 1):
        if i not in sns:
            gaps.append(i)
    return gaps


def main() -> None:
    parts = [BLOCKS.read_text(encoding="utf-8")]
    if PATCH.exists():
        parts.append(PATCH.read_text(encoding="utf-8"))
    rows = dedupe(parse_blocks("\n".join(parts)))
    sns = [r[0] for r in rows]

    TSV_OUT.write_text(
        "\n".join(f"{sn}\t{yer}\t{bolge}\t{yil}" for sn, yer, bolge, yil in rows) + "\n",
        encoding="utf-8",
    )

    kayitlar = [
        {"sn": sn, "yer": yer, "bolge": bolge, "yil": yil}
        for sn, yer, bolge, yil in rows
    ]
    payload = {
        "yil": 2026,
        "kaynak": "Cumhurbaşkanlığı Kararı 10665 (5.12.2025 RG) — EK-1 Sayılı Cetvel",
        "uyari": "Resmî cetvel esas alınmalıdır; uygulama bilgi amaçlıdır.",
        "kayit_sayisi": len(kayitlar),
        "kayitlar": kayitlar,
    }
    JSON_OUT.parent.mkdir(parents=True, exist_ok=True)
    JSON_OUT.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    gaps = find_gaps(sns)
    print(f"TSV: {TSV_OUT}")
    print(f"JSON: {JSON_OUT}")
    print(f"Count: {len(rows)}")
    print(f"SN min/max: {min(sns)} / {max(sns)}")
    if gaps:
        print(f"Gaps ({len(gaps)}): {gaps[:20]}{'...' if len(gaps) > 20 else ''}")
    else:
        print("Gaps: none")


if __name__ == "__main__":
    main()
