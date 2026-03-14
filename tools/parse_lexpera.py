#!/usr/bin/env python3
"""
Parse LEXPERA law documents and extract articles in JSON format.
Pattern: #### Title (optional) followed by #### MADDE N
"""
import re
import json
import os

def clean_text(text):
    """Remove markdown links but keep the link text: [text](url) -> text"""
    return re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', text).strip()

def normalize_article_id(madde_match, prefix):
    """Convert MADDE N, MADDE N/A, EK MADDE 1, GEÇİCİ MADDE N to id format"""
    num = madde_match.group(1).strip().upper()
    if num.startswith('EK '):
        return f"{prefix}-e{num.replace('EK ', '').replace('/', '')}"
    if num.startswith('GEÇİCİ ') or num.startswith('G'):
        g_num = num.replace('GEÇİCİ ', '').replace('G', '').strip()
        return f"{prefix}-g{g_num}" if g_num else f"{prefix}-g{num[-1]}"
    # MADDE 38/A -> 38a, MADDE 110A -> 110a
    num = num.replace('/', '').replace(' ', '')
    return f"{prefix}-{num.lower()}"

def parse_lexpera_file(filepath, law_name, prefix):
    """Parse a LEXPERA txt file and extract all articles."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Split by #### MADDE pattern - also match EK MADDE, GEÇİCİ MADDE
    madde_pattern = re.compile(
        r'####\s+(?:([^\n]+?)\s+)?(?:MADDE|EK MADDE|GEÇİCİ MADDE)\s+(\d+[A-Za-z/]*)\s*$',
        re.MULTILINE
    )
    
    # Simpler: find all #### lines
    lines = content.split('\n')
    articles = []
    i = 0
    
    while i < len(lines):
        line = lines[i]
        # Match: #### MADDE N or #### EK MADDE 1 or #### GEÇİCİ MADDE 1
        madde_match = re.search(
            r'^####\s+(?:MADDE|EK MADDE|GEÇİCİ MADDE)\s+(\d+[A-Za-z/]*)\s*$',
            line.strip()
        )
        if madde_match:
            art_num = madde_match.group(1)
            # Title is the previous #### line if it's not a MADDE
            title = ""
            j = i - 1
            while j >= 0:
                prev = lines[j].strip()
                if prev.startswith('#### ') and 'MADDE' not in prev:
                    title = prev.replace('#### ', '').strip()
                    break
                if prev.startswith('### '):
                    break
                j -= 1
            
            # Collect text until next #### (title or MADDE) or ### 
            text_lines = []
            i += 1
            while i < len(lines):
                curr = lines[i]
                curr_stripped = curr.strip()
                if re.match(r'^####\s+(?:MADDE|EK MADDE|GEÇİCİ MADDE)\s+', curr_stripped):
                    break
                if curr_stripped.startswith('#### '):
                    # Next article's title - stop, don't include
                    break
                if curr_stripped.startswith('### ') and not curr_stripped.startswith('####'):
                    break
                text_lines.append(curr)
                i += 1
            
            text = clean_text('\n'.join(text_lines))
            # Remove trailing "#### Title" if any slipped through
            text = re.sub(r'\n+####\s+[^\n]+$', '', text)
            # Remove "Belgenin tamamını göster" and similar
            text = re.sub(r'Belgenin tamamını göster.*', '', text, flags=re.DOTALL).strip()
            text = re.sub(r'Bottom Search Toolbar.*', '', text, flags=re.DOTALL).strip()
            text = re.sub(r'Yükleniyor\.\.\..*', '', text, flags=re.DOTALL).strip()
            
            # Build article id (lowercase for consistency: cmk-38a, kabahatler-42a)
            art_num_clean = art_num.replace('/', '').lower()
            if 'EK MADDE' in line or 'GEÇİCİ MADDE' in line:
                if 'EK' in line:
                    art_id = f"{prefix}-e{art_num_clean}"
                    article_label = f"Ek Madde {art_num}"
                else:
                    art_id = f"{prefix}-g{art_num_clean}"
                    article_label = f"Geçici Madde {art_num}"
            else:
                art_id = f"{prefix}-{art_num_clean}"
                if '/' in art_num:
                    article_label = f"Madde {art_num}"
                else:
                    article_label = f"Madde {art_num}"
            
            articles.append({
                "id": art_id,
                "article": article_label,
                "title": title if title else article_label,
                "text": text,
                "source": "mevzuat.gov.tr"
            })
            continue
        i += 1
    
    return {
        "law": law_name,
        "source": "mevzuat.gov.tr",
        "articles": articles
    }

def main():
    base = r"C:\Users\burak\.cursor\projects\c-Users-burak-Desktop-polis-mevzuat-uygulamas\agent-tools"
    out_base = r"c:\Users\burak\Desktop\polis mevzuat uygulaması\assets\mevzuat\kanunlar"
    
    configs = [
        ("164823a7-cdc0-46cd-99dc-0333893af40d.txt", "5271 Ceza Muhakemesi Kanunu", "cmk", "cmk.json"),
        ("1627a28f-7065-41a6-95cb-4da1089d5e3b.txt", "5237 Türk Ceza Kanunu", "tck", "tck.json"),
        ("b5f815be-9cc9-4ada-8139-b71c5d4afd85.txt", "5326 Kabahatler Kanunu", "kabahatler", "kabahatler.json"),
        ("b0a2a71e-ff6b-4e9e-8813-1373ecdc7f74.txt", "2918 Karayolları Trafik Kanunu", "trafik", "trafik.json"),
        ("a1469135-7b1d-45bd-a8cb-dc828aa9f458.txt", "2911 Toplantı ve Gösteri Yürüyüşleri Kanunu", "toplanti_gosteri", "toplanti_gosteri.json"),
        ("c746bc2e-bfc4-40fe-ad58-d8064a67f860.txt", "3713 Terörle Mücadele Kanunu", "tmk", "tmk.json"),
    ]
    
    for filename, law_name, prefix, outname in configs:
        filepath = os.path.join(base, filename)
        if not os.path.exists(filepath):
            print(f"File not found: {filepath}")
            continue
        data = parse_lexpera_file(filepath, law_name, prefix)
        outpath = os.path.join(out_base, outname)
        os.makedirs(os.path.dirname(outpath), exist_ok=True)
        with open(outpath, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"Wrote {len(data['articles'])} articles to {outpath}")

if __name__ == "__main__":
    main()
