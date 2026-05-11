# -*- coding: utf-8 -*-
"""KSU / konsolide 657 PDF'inden tam metni çıkartıp kanunlar/657.json yazar."""
from __future__ import annotations

import json
import re
from pathlib import Path

try:
    import fitz  # pymupdf
except ImportError:
    raise SystemExit('pip install pymupdf') from None

ROOT = Path(__file__).resolve().parents[1]

# Yerel oluşturmak için: assets/mevzuat/_657_ksu.pdf veya şu adres:
_PDF_URL = (
    'https://hukuk.ksu.edu.tr/depo/belgeler/'
    '657%20SAYILI%20DEVLET%20MEMURLARI%20KANUNU_2202141348517900.pdf'
)
PDF_LOCAL = ROOT / 'assets/mevzuat/_657_ksu.pdf'
OUT = ROOT / 'assets/mevzuat/kanunlar/657.json'

# Satır başı "Madde 12 –" biçimi (çoğunluk konsolide)
RE_MADDE_HDR = re.compile(
    r'^Madde\s+(\d+)\s*[–\-]',
    flags=re.MULTILINE,
)


def skip_paragraph_noise(s: str) -> bool:
    t = s.strip().rstrip(':').strip()
    if not t:
        return True
    if t.startswith('KISIM'):
        return True
    if len(t) <= 48 and 'BÖLÜM' in t:
        return True
    if t in {
        'Kapsam',
        'Amaç',
        'Tanımlar',
        'Temel ilkeler',
        'İstihdam şekilleri',
        'Çeşitli ve Son Hükümler',
        'Uyumlu hüküm',
    }:
        return True
    if re.fullmatch(r'\d{3,5}', s.strip()):
        return True  # Sayfa düzeni (4180 vb.)
    return False


def strip_chunk_boundary_noise(txt: str) -> str:
    """PDF'te iki madde arasına düşen bölüm başlığı / sayfa no satırlarını uçtan kırpar."""
    lines = txt.split('\n')
    while lines and skip_paragraph_noise(lines[-1]):
        lines.pop()
    while lines and skip_paragraph_noise(lines[0]):
        lines.pop(0)
    return '\n'.join(lines).strip()


def strip_standalone_footer_numbers(txt: str) -> str:
    """Çıkartılmış metinde tek başına duran sayfa numarası satırlarını (4180 vb.) atar."""
    out: list[str] = []
    for line in txt.split('\n'):
        if re.fullmatch(r'\s*\d{3,5}\s*', line):
            continue
        out.append(line)
    return '\n'.join(out)


def pdf_to_text(path: Path) -> str:
    doc = fitz.open(path)
    return ''.join((doc[i].get_text() or '') for i in range(doc.page_count))


def main() -> None:
    if not PDF_LOCAL.is_file():
        raise SystemExit(
            f'PDF eksik: {PDF_LOCAL}\n'
            'İndirin (örnek): curl -Lo assets/mevzuat/_657_ksu.pdf ' + _PDF_URL
        )
    full = pdf_to_text(PDF_LOCAL)
    matches = list(RE_MADDE_HDR.finditer(full))
    by_num: dict[int, str] = {}
    for i, m in enumerate(matches):
        n = int(m.group(1))
        end = matches[i + 1].start() if i + 1 < len(matches) else len(full)
        chunk = strip_standalone_footer_numbers(
            strip_chunk_boundary_noise(full[m.start() : end])
        )
        if not chunk:
            continue
        if n not in by_num or len(chunk) > len(by_num[n]):
            by_num[n] = chunk

    arts = [
        {
            'id': f'dmk-{n}',
            'article': f'Madde {n}',
            'title': '',
            'text': txt,
            'source': 'Konsolide çıktı (PDF); güncelleme için MBS kullanın.',
        }
        for n, txt in sorted(by_num.items(), key=lambda x: x[0])
    ]

    payload = {
        'law': '657 Devlet Memurları Kanunu',
        'sourceUrl': 'https://www.mevzuat.gov.tr/MevzuatMetin/1.5.657.pdf',
        'source': 'https://www.mevzuat.gov.tr/mevzuat?MevzuatNo=657&MevzuatTur=1',
        'lastContentReview':
            'Çıkartma KSU hukuk fakültesi yayını PDF üzerinden; güncelleme tarihi için MBS esas alınır.',
        'articles': arts,
    }
    OUT.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding='utf-8')
    print('yazildi', OUT, 'madde=', len(arts))


if __name__ == '__main__':
    main()
