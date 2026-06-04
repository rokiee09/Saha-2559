"""Extract görev puanları from screenshot images via OCR."""
import json
import re
import sys
from pathlib import Path

from rapidocr_onnxruntime import RapidOCR

DEFAULT_ASSETS = Path(
    r"C:\Users\burak\.cursor\projects\c-Users-burak-Documents-Codex-2026-05-23-kendini-bana-anlat-ne-i-e\assets"
)
JSON_DIR = Path(__file__).resolve().parent.parent / "assets" / "json"

PUAN_RE = re.compile(r"(\d{1,2}[.,]\d{3})\s*Puan?", re.IGNORECASE)
LOC_RE = re.compile(r"^[A-ZÇĞİÖŞÜIVXLC0-9\-]+$")

# OCR ASCII → Türkçe il/ilçe adı düzeltmeleri (parça bazlı).
WORD_FIX: dict[str, str] = {
    "AGRI": "AĞRI",
    "ADIYAMAN": "ADIYAMAN",
    "AFYONKARAHISAR": "AFYONKARAHİSAR",
    "AKSARAY": "AKSARAY",
    "AMASYA": "AMASYA",
    "ANKARA": "ANKARA",
    "ANTALYA": "ANTALYA",
    "ARDAHAN": "ARDAHAN",
    "ARTVIN": "ARTVİN",
    "AYDIN": "AYDIN",
    "BALIKESIR": "BALIKESİR",
    "BARTIN": "BARTIN",
    "BATMAN": "BATMAN",
    "BAYBURT": "BAYBURT",
    "BILECIK": "BİLECİK",
    "BINGOL": "BİNGÖL",
    "BITLIS": "BİTLİS",
    "BOLU": "BOLU",
    "BURDUR": "BURDUR",
    "BURSA": "BURSA",
    "CANAKKALE": "ÇANAKKALE",
    "CANKIRI": "ÇANKIRI",
    "CORUM": "ÇORUM",
    "DENIZLI": "DENİZLİ",
    "DIYARBAKIR": "DİYARBAKIR",
    "DUZCE": "DÜZCE",
    "EDIRNE": "EDİRNE",
    "ELAZIG": "ELAZIĞ",
    "ERZINCAN": "ERZİNCAN",
    "ERZURUM": "ERZURUM",
    "ESKISEHIR": "ESKİŞEHİR",
    "GAZIANTEP": "GAZİANTEP",
    "GIRESUN": "GİRESUN",
    "GUMUSHANE": "GÜMÜŞHANE",
    "HAKKARI": "HAKKARİ",
    "HATAY": "HATAY",
    "IGDIR": "IĞDIR",
    "ISPARTA": "ISPARTA",
    "ISTANBUL": "İSTANBUL",
    "IZMIR": "İZMİR",
    "KAHRAMANMARAS": "KAHRAMANMARAŞ",
    "KARABUK": "KARABÜK",
    "KARAMAN": "KARAMAN",
    "KARS": "KARS",
    "KASTAMONU": "KASTAMONU",
    "KAYSERI": "KAYSERİ",
    "KILIS": "KİLİS",
    "KIRIKKALE": "KIRIKKALE",
    "KIRKLARELI": "KIRKLARELİ",
    "KIRSEHIR": "KIRŞEHIR",
    "KOCAELI": "KOCAELİ",
    "KONYA": "KONYA",
    "KUTAHYA": "KÜTAHYA",
    "MALATYA": "MALATYA",
    "MANISA": "MANİSA",
    "MARDIN": "MARDİN",
    "MERSIN": "MERSİN",
    "MUGLA": "MUĞLA",
    "MUS": "MUŞ",
    "NEVSEHIR": "NEVŞEHIR",
    "NIGDE": "NİĞDE",
    "ORDU": "ORDU",
    "OSMANIYE": "OSMANİYE",
    "RIZE": "RİZE",
    "SAKARYA": "SAKARYA",
    "SAMSUN": "SAMSUN",
    "SANLIURFA": "ŞANLIURFA",
    "SIIRT": "SİİRT",
    "SINOP": "SİNOP",
    "SIRNAK": "ŞIRNAK",
    "SIVAS": "SİVAS",
    "TEKIRDAG": "TEKİRDAĞ",
    "TOKAT": "TOKAT",
    "TRABZON": "TRABZON",
    "TUNCELI": "TUNCELİ",
    "USAK": "UŞAK",
    "VAN": "VAN",
    "YALOVA": "YALOVA",
    "YOZGAT": "YOZGAT",
    "ZONGULDAK": "ZONGULDAK",
    "CUKUROVA": "ÇUKUROVA",
    "CERKES": "ÇERKEŞ",
    "CUBUK": "ÇUBUK",
    "CATALCA": "ÇATALCA",
    "CEKMEKOY": "ÇEKMEKÖY",
    "CINARCIK": "ÇINARCIK",
    "CIFTELIKKOY": "ÇİFTLİKKÖY",
    "CALDIRAN": "ÇALDIRAN",
    "CATAK": "ÇATAK",
    "CILDIR": "ÇILDIR",
    "CUKURCA": "ÇUKURCA",
    "CINAR": "ÇINAR",
    "CAYCUMA": "ÇAYCUMA",
    "CAYELI": "ÇAYELİ",
    "CAYIRALAN": "ÇAYIRALAN",
    "CAYKARA": "ÇAYKARA",
    "DIYADIN": "DİYADİN",
    "DOGUBAYAZIT": "DOĞUBAYAZIT",
    "ELESKIRT": "ELEŞKİRT",
    "ELMADAG": "ELMADAĞ",
    "ALTINDAG": "ALTINDAĞ",
    "GOLBASI": "GÖLBAŞI",
    "GUDUL": "GÜDÜL",
    "YENIMAHALLE": "YENİMAHALLE",
    "SINCAN": "SİNCAN",
    "ETIMESGUT": "ETİMESGUT",
    "KECIOREN": "KEÇİÖREN",
    "SERIFLIKOCHISAR": "ŞEREFLİKOÇHİSAR",
    "SEMDINLI": "ŞEMDİNLİ",
    "SURUC": "SURUÇ",
    "SIVEREK": "SİVEREK",
    "SIVASLI": "SİVASLI",
    "SAVASTEPE": "SAVAŞTEPE",
    "SUSURLUK": "SUSURLUK",
    "SOGUT": "SÖĞÜT",
    "SOKE": "SÖKE",
    "DORTYOL": "DÖRTYOL",
    "DORTDIVAN": "DÖRTDİVAN",
    "KURSUNLU": "KURŞUNLU",
    "GURPINAR": "GÜRPINAR",
    "GEVAS": "GEVAŞ",
    "GOLE": "GÖLE",
    "MERKEZEFENDI": "MERKEZEFENDİ",
    "SERINHISAR": "SERİNHİSAR",
    "SARAYKOY": "SARAYKÖY",
    "HALFETI": "HALFETİ",
    "HILVAN": "HİLVAN",
    "VIRANSEHIR": "VİRANŞEHIR",
    "PAMUKKALE": "PAMUKKALE",
}


def fix_turkish(name: str) -> str:
    parts = name.upper().split("-")
    return "-".join(WORD_FIX.get(p, p) for p in parts)


def parse_puan(raw: str) -> float:
    raw = raw.replace(",", ".")
    if "." in raw:
        return float(raw.replace(".", "")) / 1000.0
    return float(raw)


def parse_ocr_lines(lines: list[str]) -> list[tuple[str, float]]:
    entries: list[tuple[str, float]] = []
    for i, line in enumerate(lines):
        line = line.strip()
        if not line or line.lower() in ("ara", "görev puanları", "gorev puanlari"):
            continue
        m = PUAN_RE.search(line)
        if not m:
            continue
        puan = parse_puan(m.group(1))
        loc = None
        before = re.sub(r"[^A-ZÇĞİÖŞÜa-zçğıöşü0-9\- ]", "", line[: m.start()]).strip()
        before = before.upper().replace(" ", "")
        if before and LOC_RE.match(before):
            loc = before
        elif i > 0:
            prev = lines[i - 1].strip().upper().replace(" ", "")
            prev = re.sub(r"[^A-ZÇĞİÖŞÜ0-9\-]", "", prev)
            if prev and LOC_RE.match(prev):
                loc = prev
        if loc:
            entries.append((fix_turkish(loc), puan))
    return entries


def main() -> int:
    yil = 2026
    assets = DEFAULT_ASSETS
    if len(sys.argv) >= 2:
        yil = int(sys.argv[1])
    if len(sys.argv) >= 3:
        assets = Path(sys.argv[2])
    out = JSON_DIR / f"gorev_puanlari_{yil}.json"

    ocr = RapidOCR()
    all_entries: dict[str, float] = {}
    images = sorted(p for p in assets.glob("*.png") if p.is_file())
    if not images:
        images = sorted(p for p in assets.glob("**/*.png") if p.is_file())
    # Yalnızca görev puanı ekran görüntüleri (2026 cetveli).
    images = [p for p in images if "2026-06-04" in p.name or "Gorev" in p.name.lower()]

    for img in images:
        if not img.exists():
            print(f"skip missing: {img.name}", file=sys.stderr)
            continue
        result, _ = ocr(str(img))
        if not result:
            continue
        lines = [item[1] for item in result]
        # Yalnızca görev puanı ekranı görüntülerini işle
        blob = " ".join(lines).lower()
        if "puan" not in blob and "gorev" not in blob and "görev" not in blob:
            continue
        for loc, puan in parse_ocr_lines(lines):
            all_entries[loc] = puan

    sorted_items = sorted(all_entries.items(), key=lambda x: x[0])
    data = [{"yer": yer, "puan": round(puan, 3)} for yer, puan in sorted_items]

    out.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "yil": yil,
        "kaynak": f"Emniyet Genel Müdürlüğü {yil} görev yeri puanları (POL-NET / ekran görüntüsü OCR)",
        "uyari": "Resmî tebliğ esas alınmalıdır; uygulama bilgi amaçlıdır.",
        "kayit_sayisi": len(data),
        "kayitlar": data,
    }
    out.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    iller = {x["yer"].split("-")[0] for x in data}
    print(f"Extracted {len(data)} entries, {len(iller)} provinces -> {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
