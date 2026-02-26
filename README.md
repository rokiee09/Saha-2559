# Saha 2559

Polis mevzuat, saha, haklar, teşkilat ve kültür bilgilerini **offline** olarak sunan Flutter uygulaması.

## Çalıştırma

1. Flutter SDK kur (stable kanal, Windows):
2. Proje klasörüne geç:

```bash
cd "C:\Users\burak\Desktop\polis mevzuat uygulaması"
flutter pub get
flutter run
```

## Modeller ve JSON şeması (özet)

### LawArticle

```json
[
  {
    "lawCode": "PVSK",
    "lawName": "Polis Vazife ve Salahiyet Kanunu",
    "articleNumber": 16,
    "official_text": "...",
    "plain_summary": "...",
    "field_example": "...",
    "common_mistakes": "...",
    "related": [15, 17],
    "source_url": "https://mevzuat.gov.tr/...",
    "last_updated": "2024-01-01"
  }
]
```

### CityContact

```json
[
  {
    "cityName": "Ankara",
    "phone": "0312XXXXXXX",
    "sourceUrl": "https://..."
  }
]
```

### Martyr

```json
[
  {
    "fullName": "Şehit Polis Memuru ...",
    "cityName": "İstanbul",
    "dateOfMartyrdom": "2016-07-15",
    "location": "İstanbul",
    "story": "Saygı odaklı kısa hayat hikayesi..."
  }
]
```

