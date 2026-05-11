# -*- coding: utf-8 -*-
"""ETS (emniyet.org.tr) 7068 UTF-8 sayfasından kanunlar/disiplin.json üretir."""
from __future__ import annotations

import json
import re
from pathlib import Path

try:
    from bs4 import BeautifulSoup
except ImportError:
    raise SystemExit('pip install beautifulsoup4') from None


ROOT = Path(__file__).resolve().parents[1]
HTML = ROOT / 'assets/mevzuat/sources/7068_emniyet_org_tr_snapshot.html'
OUT = ROOT / 'assets/mevzuat/kanunlar/disiplin.json'

RE_MADDE_NUM = re.compile(r'^MADDE\s*(\d+)\b', re.IGNORECASE)
RE_GECICI = re.compile(r'^GEÇİCİ\s*MADDE\s*(\d+)', re.IGNORECASE)


def normalize_head(s: str) -> str:
    return ' '.join(s.split())


def flush_entry(
    acc: list[dict[str, str]],
    aid: str | None,
    alabel: str | None,
    buffer: list[str],
) -> None:
    if not aid or not alabel or not buffer:
        return
    text = '\n\n'.join(x.strip() for x in buffer if x.strip())
    acc.append({
        'id': aid,
        'article': alabel,
        'title': '',
        'text': text,
        'source': 'emniyet.org.tr (ETS); resmî teyit: mevzuat.gov.tr',
    })


def main() -> None:
    if not HTML.is_file():
        raise SystemExit(f'Eksik: {HTML} — önce ETS tam metin dosyası konulmalı.')
    soup = BeautifulSoup(HTML.read_text(encoding='utf-8'), 'html.parser')
    td = soup.find('td', colspan='3')

    paragraphs = td.find_all('p') if td else soup.find_all('p')

    acc: list[dict[str, str]] = []
    aid: str | None = None
    alabel: str | None = None
    buffer: list[str] = []

    for p in paragraphs:
        strong = p.find('strong')
        if strong:
            raw_head = strong.get_text(' ', strip=True)
            hn = normalize_head(raw_head)

            if hn.upper().startswith('EK MADDE'):
                buffer.append(p.get_text(' ', strip=True))
                continue

            gm = RE_GECICI.match(hn)
            if gm:
                flush_entry(acc, aid, alabel, buffer)
                buffer = []
                n = gm.group(1)
                aid = f'7068-gecici-{n}'
                alabel = f'Geçici Madde {n}'
                rest = p.get_text(' ', strip=True).replace(raw_head.strip(), '', 1).strip()
                rest = re.sub(r'^[-–]\s*', '', rest).strip()
                buffer.append(rest)
                continue

            mn = RE_MADDE_NUM.match(hn)
            if mn:
                flush_entry(acc, aid, alabel, buffer)
                buffer = []
                num = int(mn.group(1))
                alabel = f'Madde {num}'
                aid = f'dsk-{num}'
                rest = p.get_text(' ', strip=True)
                # "MADDE 7 -" veya "MADDE 23 –" biçimlerini kırp
                rest = RE_MADDE_NUM.sub('', rest, count=1).strip()
                rest = re.sub(r'^[-–]\s*', '', rest).strip()
                if rest:
                    buffer.append(rest)
                continue

            # Örn: "Kapsam", "Genel Hükümler", "Ayırıcı hususlar" — madde govdesine karışır
            continue

        # devam satırı veya güçsüz paragraf
        line = p.get_text(' ', strip=True)
        if not line:
            continue
        if alabel:
            buffer.append(line)

    flush_entry(acc, aid, alabel, buffer)

    for a in acc:
        if a['id'] == 'dsk-39':
            a['text'] = re.sub(
                r'\n\n\d{2}/\d{2}/\d{4}[\s\S]*$',
                '',
                a['text'],
                count=1,
            ).strip()

    root = {
        'law': '7068 Genel Kolluk Disiplin Hükümleri Kanunu',
        'sourceUrl': 'https://www.mevzuat.gov.tr/MevzuatMetin/1.5.7068.pdf',
        'source': 'https://www.mevzuat.gov.tr/mevzuat?MevzuatNo=7068&MevzuatTur=1',
        'lastContentReview':
            'İçerik ETS güncelleme snapshot üzerinden doldurulmuştur; resmî teyit için Mevzuat Bilgi Sistemi esas alınır.',
        'articles': acc,
    }
    OUT.write_text(json.dumps(root, ensure_ascii=False, indent=2), encoding='utf-8')
    print('yazildi', OUT, 'madde=', len(acc))


if __name__ == '__main__':
    main()
