#!/usr/bin/env python3
"""2026 idari para ceza Excel → JSON."""
from __future__ import annotations

import glob
import json
import os
import re
import sys

import openpyxl

DESKTOP = r"c:\Users\burak\Desktop\yönetmelikler"
OUT = os.path.join(
    os.path.dirname(__file__), "..", "assets", "json", "idari_para_cezalari_2026.json"
)


def _s(v) -> str:
    if v is None:
        return ""
    return str(v).strip()


def _ceza(v) -> int:
    if v is None:
        return 0
    if isinstance(v, (int, float)):
        return int(v)
    s = _s(v).replace(".", "").replace(",", ".")
    try:
        return int(float(s))
    except ValueError:
        return 0


def main() -> None:
    paths = glob.glob(os.path.join(DESKTOP, "*2026*.xlsx"))
    if not paths:
        print("Excel bulunamadı", file=sys.stderr)
        sys.exit(1)
    path = paths[0]
    wb = openpyxl.load_workbook(path, read_only=True, data_only=True)
    ws = wb.active
    rows = list(ws.iter_rows(min_row=3, values_only=True))
    kayitlar = []
    for row in rows:
        if not row or not any(c is not None and _s(c) for c in row):
            continue
        sira = row[0]
        if sira is None:
            continue
        kayitlar.append(
            {
                "id": str(int(sira)) if isinstance(sira, (int, float)) else _s(sira),
                "kanunSayisi": _s(row[1]),
                "kanun": _s(row[2]),
                "madde": _s(row[3]),
                "kabahatAdi": _s(row[4]),
                "cezaMiktari": _ceza(row[5]),
                "kararVerenMakam": _s(row[6]),
                "itirazMercii": _s(row[9]) if len(row) > 9 else "",
                "itirazSuresi": _s(row[10]) if len(row) > 10 else "",
                "odemeSuresi": _s(row[11]) if len(row) > 11 else "",
                "belge": _s(row[13]) if len(row) > 13 else "",
            }
        )
    data = {
        "yil": 2026,
        "kaynak": "2026 Yılı İdari Para Ceza Miktarları",
        "kayitlar": kayitlar,
    }
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Wrote {OUT} ({len(kayitlar)} kayıt)")


if __name__ == "__main__":
    main()
