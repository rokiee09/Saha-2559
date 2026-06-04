#!/usr/bin/env python3
"""Sağlık PDF'lerini uygulama JSON formatına dönüştürür."""
from __future__ import annotations

import glob
import json
import os
import re
import sys

import fitz

DESKTOP = r"c:\Users\burak\Desktop\yönetmelikler"
OUT_DIR = os.path.join(
    os.path.dirname(__file__), "..", "assets", "saglik"
)


def _clean_page_text(text: str) -> str:
    skip_patterns = [
        r"^EBYS-\d",
        r"^-- \d+ of \d+ --$",
        r"^Ayrıntılı Bilgi",
        r"^Unvanı\s*:",
        r"^Elektronik Ağ",
        r"^Adres\s*$",
        r"^Telefon",
        r"^e-posta",
        r"^www\.egm\.gov\.tr",
        r"^\d+/\d+$",
        r"^T\.C\.$",
        r"^İÇİŞLERİ BAKANLIĞI",
        r"^Emniyet Genel Müdürlüğü$",
        r"^Sayı\s*:",
        r"^Konu\s*:",
        r"^DAĞITIM",
        r"^EGM Genelge",
        r"^îlgi\s*:",
        r"^Ilgi\s*:",
    ]
    lines = []
    for line in text.splitlines():
        s = line.strip()
        if not s:
            continue
        if any(re.match(p, s, re.I) for p in skip_patterns):
            continue
        lines.append(s)
    return "\n".join(lines)


def extract_egm_genelge(path: str) -> dict:
    doc = fitz.open(path)
    pages: list[str] = []
    for page in doc:
        pages.append(_clean_page_text(page.get_text()))

    full = "\n\n".join(pages)
    # İlk sayfadaki resmi evrak üst bilgisini at; içerik 1.x ile başlar.
    m = re.search(r"(1\.[\s\S]+)", full)
    body = m.group(1).strip() if m else full

    sections: list[dict] = []
    # 1.2.3- gibi numaralı başlıklar
    parts = re.split(r"\n(?=\d+\.\d+(?:\.\d+)?(?:\.\d+)?- )", body)
    for part in parts:
        part = part.strip()
        if not part:
            continue
        head = re.match(r"^(\d+(?:\.\d+)+)-\s*", part)
        if not head:
            continue
        sid = head.group(1)
        title_line = part[len(head.group(0)) :].split("\n", 1)[0].strip()
        text = part[len(head.group(0)) :].strip()
        if "\n" in text:
            _, rest = text.split("\n", 1)
            text = rest.strip()
        else:
            text = ""
        if not text and title_line:
            text = title_line
            title_line = ""
        sections.append(
            {
                "id": f"su-{sid.replace('.', '-')}",
                "article": sid,
                "title": title_line[:120] if title_line else f"Bölüm {sid}",
                "text": text,
            }
        )

    return {
        "law": "Sağlık Uygulamalarına İlişkin Uygulama Rehberi",
        "displayTitle": "Sağlık Uygulamaları Rehberi",
        "subtitle": (
            "Emniyet teşkilatında hastalık raporu, istirahat ve heyet süreçlerine "
            "ilişkin uygulama esasları (genelge niteliğinde özet metin)."
        ),
        "disclaimer": (
            "Resmî evrak numarası ve üst yazı gösterilmez; metin içerik olarak "
            "korunmuştur. Bağlayıcı işlem için kurum yazısı ve güncel mevzuat esas alınır."
        ),
        "source": "Emniyet Genel Müdürlüğü sağlık uygulamaları genelgesi (içerik)",
        "articles": sections,
    }


def extract_saglik_sartlari(path: str) -> dict:
    doc = fitz.open(path)
    pages: list[str] = []
    for page in doc:
        pages.append(_clean_page_text(page.get_text()))
    full = "\n\n".join(pages)

    sections: list[dict] = []
    ek_parts = re.split(r"\n(?=EK-\d+)", full)
    for part in ek_parts:
        part = part.strip()
        if not part.startswith("EK-"):
            continue
        m = re.match(r"^(EK-\d+)\s*(?:\([^)]+\))?\s*\n(.+?)(?:\n|$)", part, re.S)
        if not m:
            continue
        ek_no = m.group(1)
        first_line = m.group(2).strip().split("\n")[0][:200]
        sections.append(
            {
                "id": ek_no.lower().replace("-", "_"),
                "article": ek_no,
                "title": first_line,
                "text": part,
            }
        )

    return {
        "law": "Emniyet Teşkilatı Sağlık Şartları Yönetmeliği",
        "displayTitle": "Emniyet Sağlık Şartları Yönetmeliği",
        "subtitle": "Ekler: sağlık kurulu raporu, sağlık formu ve branş sınıflandırması",
        "source": "Resmi Gazete ekleri (PDF)",
        "articles": sections,
    }


def main() -> None:
    os.makedirs(OUT_DIR, exist_ok=True)
    saglik_sart = glob.glob(os.path.join(DESKTOP, "Emniyet-teskilati-saglik*.pdf"))
    uygulama = glob.glob(os.path.join(DESKTOP, "*Uygulama*.pdf"))

    if not saglik_sart:
        print("Emniyet sağlık şartları PDF bulunamadı", file=sys.stderr)
        sys.exit(1)
    if not uygulama:
        print("Sağlık uygulamaları PDF bulunamadı", file=sys.stderr)
        sys.exit(1)

    sart_data = extract_saglik_sartlari(saglik_sart[0])
    uyg_data = extract_egm_genelge(uygulama[0])

    sart_path = os.path.join(OUT_DIR, "emniyet_saglik_sartlari.json")
    uyg_path = os.path.join(OUT_DIR, "saglik_uygulamalari_rehberi.json")

    with open(sart_path, "w", encoding="utf-8") as f:
        json.dump(sart_data, f, ensure_ascii=False, indent=2)
    with open(uyg_path, "w", encoding="utf-8") as f:
        json.dump(uyg_data, f, ensure_ascii=False, indent=2)

    print(f"Wrote {sart_path} ({len(sart_data['articles'])} sections)")
    print(f"Wrote {uyg_path} ({len(uyg_data['articles'])} sections)")


if __name__ == "__main__":
    main()
