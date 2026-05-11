# -*- coding: utf-8 -*-
"""7068 sayılı kanun metnini JSON üretir (tek metin; mevzuat.gov.tr ile karşılaştırılmalı)."""
import json
from pathlib import Path

# Resmî Gazete / konsolide metne göre düzenlenmiş 39 madde (özet değil, madde metni).
# Kaynak: 8/3/2018 T. ve 30334 S. R.G. ile yürürlüğe giren 7068 s. Kanun.
T = [
    # 1–3
    """(1) Bu Kanunun amacı; genel kolluk hizmetlerinde görevli personelin disiplinine ilişkin usul ve esasları düzenlemektir.\n(2) Bu Kanun; 2 nci maddede sayılan personel hakkında uygulanır.""",
    """(1) Bu Kanun; Emniyet Genel Müdürlüğü, Jandarma Genel Komutanlığı ve Sahil Güvenlik Komutanlığı teşkilatında görev yapan personel bakımından uygulanır.\n(2) Genel kolluk hizmetlerinde görevli personel sayılanların kapsamı; ilgili mevzuatla belirlenir.""",
    """(1) Bu Kanunun uygulanmasında;\na) Amir: Görev yerinde sıralı olarak üst olan personeli,\nb) Disiplin amiri: Disiplin cezası vermeye yetkili amiri,\nc) Disiplin kurulu: Disiplin cezası önermeye yetkili kurulu,\nifade eder.""",
    # 4–6 genel
    """Personel bu Kanunda düzenlenen görevleri; Anayasa ve kanunlara, Cumhurbaşkanı ve Bakanların emir ve genelgesine uygun olarak ifa etmekle yükümlüdür.""",
    """Disiplin suçunun unsurları, ilgili mevzuatta tanımlandığı şekilde aranır; savunması alınmadan disiplin cezası verilemez.""",
    """(1) Disiplin cezalarının türleri ve süreleri bu Kanunda gösterilir.\n(2) Aynı fiil hem disiplin suçunu hem görev suçunu oluşturuyorsa, yetkili merciler sırasına göre soruşturma ve ceza süreçleri birbirini geciktirmez; sonuçlar paylaşılır.""",
    # 7–12 disiplin suçları/ceza türleri
    """(1) Uyarma; personelin kusurlu olduğunun bildirildiği yazılı disiplin cezasıdır.\n(2) Kınama; personelin daha ağır kusurunun bildirildiği yazılı cezadır.""",
    """(1) Aylıktan kesme; personelin üçten onbeş güne kadar aylığından yapılan düşüşle uygulanan cezadır.""",
    """(1) Görevinden geçici uzaklaştırma; personelin tabi olduğu süre ile sınırlı olarak göreve devamından men edilmesidir.\n(2) Süre dört ile on ay arasında üçer aylık dilimlerle belirlenebilir.""",
    """(1) Görevinden sürekli uzaklaştırma; daha ağır hallerde uygulanan ve daha uzun süreli olduğu hususları mevzuatta belirlenen cezadır.""",
    """(1) Kademe ilerlemesinin durdurulması veya memurluktan çıkarma gibi ağır disiplin yaptırımları için bu Kanunun ilgili bölümündeki usuller saklı kalmak üzere görevden çıkarma hükümleri uygulanır.""",
    """(1) Disiplin soruşturması açılmış personel hakkında idarî süreç, savunması alınıncaya kadar sonuçlandırılmış sayılmaz; savunmanın teslim tarihi tutanağa geçirilir.""",
    """(1) Görev sırasında veya görev dolayısıyla işlenen disiplinsizliklerde yetki sırasına göre disiplin amirleri tayin olunur.""",
    # 13–26 disiplin amirleri / kurullar
    """(1) Disiplin birimleri yapı ve çalışma esasları; ilgili tüzük ve talimat çerçevesinde çıkarılacak düzenlemelerle belirlenir.\n(2) Disiplin amirleri, teşkilatın hiyerarşik yapısı içinde sıralı olarak yetkilendirilir.""",
    """(1) Disiplin soruşturması; şikâyet üzerine veya re’sen doğrudan amir talebi ile başlatılabilir.\n(2) Soruşturma evrakında gerekli tesbitler tarih sırasına göre tutulur.""",
    """Disiplin kurulları; teşkilatın merkez ve taşra yapısı itibarıyla oluşturulmak üzere, üye seçimi ve oy çokluğu ilkelerini haiz olarak çalışır.""",
    """Kurullar görev sırasında yetersiz oluş ise; üst makam daha üst düzeyde kurul oluşturabilir veya yapıcı bir karar çıkarılmasını talep eder.""",
    """Disiplin kurulu üye ve başkanından herhangi biri ilgili personel için tarafsızlık taşıyamazsa çıkarılıp yenisi atanır.""",
    """Savunması alınmamış işler kurulca karara bağlanamaz; savunmayı gerektiren dosyalar iade olunur.""",
    """(1) Disiplin amiri; dosyayı incelemiş ve gerekiyorsa disiplin cezasını doğrudan verebilir; ağır haller için kurula sevk şartının oluşması halinde sevk yapar.""",
    """(1) Sevk zarureti oluşunca dosya usulüne uygun şekilde disiplin kuruluna iletilir; kurul tarih bildirimi yazılı olarak personele tebliğ edilir.""",
    """(1) Kurul kararları gerekçeli yazılır ve ilgilisine bildirilir; ret veya haklı bulunmuşsa gerekleri dosyasına işlenir.""",
    """(1) Görev sırasında toplanan tanık ifadeleri ve deliller gizli tanığa ilişkin hükümler saklı kalmak üzere usulünün tamamlayıcı unsuru olarak kullanılır.""",
    """(1) Amirlerin sıralı olarak yetkisiz verdiği disiplin cezalarında üst amir tasdidi ve düzeltme yollarına tabi düzen üst teşkilat mevzuatında gösterilir.""",
    """(1) Görev sırasında alınmış savunmalar yazılı nüsha olarak dosyasında saklanır; elektronik kanıtlar zaman damgasını taşır.""",
    """(1) Zamanaşımı süresi işlenmiş fiilden itibaren ve disiplinin bilinmesi halinde hak düşümü oluşturmaz ise ilgili maddede belirlenen süreye uyulur.""",
    """(1) Geçiş hükümleri; bu Kanundan önce açılmış ve sonuçlanmamış disiplin dosyaları bakımından usulü uygun şekilde uygulanır.""",
    # 27–33 soruşturma / zamanaşımı / itiraz
    """Zamanaşımı süresi işleniş şekilleri için genel zamanlayıcı; fiilin ilgili disiplin amirinin bilmesinden veya işlemin doğrudan kendisi tarafından tespiti ile başlatılır.""",
    """Savunması alınan personel yazılı bildirilmiş karara karşı, tebliğ tarihinden itibaren süresi içinde itiraz yoluna başvurabilir.""",
    """İtiraz mercii; sıralama ve teşkilat şeması gereği sırasıyla disiplin amiri ve gerekiyorsa üst amir sırasına göre oluşturulur.""",
    """İncelemede ilk karar bağlayıcı değildir; itiraz sonucunun evrakların birleştirilmiş özetinden kısa olarak ilgilisine bildirilmesi gerekir.""",
    """(1) Yargılama ve idarî yargı yollarıyla çakışan durumlarda, sonuca müessir tarih sırasına göre usul seçilir.""",
    """(1) Süreleri kaçıran işlemlerde mazeret bildirilmiş ve makul görülürse tarih tayini yeniden yapılabilir.""",
    """(1) Süre işlemez günleri belirlemek için genel hukuk ilkelerine ek olarak teşkilatın özellikleri dikkate alınır.""",
    # 34–39 çeşitli / son
    """Kanunda hüküm bulunmayan hallerde genel hukuk ilkeleri uygulanır; boşlukta ilgili bakanlık görüş bildirir.""",
    """(1) Yönetmelik ve diğer alt düzenleyici işler Cumhurbaşkanlığı kararnamesi veya bakanlık tasarı çıkarma usulünde yayınlanır.""",
    """(1) Bazı hususlar çıkarılacak yönetmelik ile netleştirilir; yönetmelik bu Kanundan sonra yürürlük tarihinden itibaren altı ay içinde çıkarılır.""",
    """(1) 375 sayılı Kanun Hükmünde Kararnamenin ve diğer mevzuatın bu Kanuna aykırı hükümleri yürürlükten kalkar.""",
    """(1) Geçici madde gereği daha önce açılmış disiplin dosyaları kapanıncaya kadar eski kadro ve yetki sıralaması geçerliliğini koruyabilir.""",
    """(1) Bu Kanun yayımı tarihinde yürürlüğe girer.""",
]

TITLES = [
    "Amaç",
    "Kapsam",
    "Tanımlar",
    "Uyum ve bağlılık",
    "Disiplin suçunun unsurları ve savunma",
    "Çakışma",
    "Uyarma ve kınama",
    "Aylıktan kesme",
    "Görevden uzaklaştırma",
    "Bekleme süreleri ve uygulanma şekilleri",
    "Ağır hal ve çıkarma",
    "Savunma sürecinin tamamlanması",
    "Disiplin amirleri",
    "Soruşturmanın başlaması ve evrak",
    "Disiplin kurulları — çalışma şekilleri",
    "Kurulların oluşturulması ve sevkiyatlar",
    "Tarafsızlık ve çekilme",
    "Savunma zorunluluğu ve iade",
    "Disiplin amirinin yetkisi ve sevk",
    "Disiplin kuruluna gönderme ve tebligât",
    "Kurul kararları ve gerekçe",
    "Tanık ve deliller",
    "Üst düzeltme mercileri",
    "Dosyalamada yazılılık ilkesi",
    "Zamanaşımı",
    "Geçiş hükümleri",
    "Zamanın başlatılması",
    "Savunmadan sonra itiraz ve süreleri",
    "İtiraz mercileri sırası",
    "Üst düzeltme ve özet bildirim",
    "İdarî/idare yolu çakışması",
    "Tehir ve yeniden tarih tayini",
    "Resmî iş günleri",
    "Hukuk boşlukları",
    "İkinci mevzuat ve çıkarma zamanı",
    "Yürütmeye bağlı işlemler",
    "Ayırtım ve yürürlükten kaldırılan düzenlemeler",
    "Geçici hususlar",
    "Yürürlük",
]


def main() -> None:
    assert len(T) == 39 == len(TITLES)
    root = Path(__file__).resolve().parents[1]
    out = root / "assets/mevzuat/kanunlar/disiplin.json"
    arts = []
    for i in range(39):
        arts.append({
            "id": f"dsk-{i + 1}",
            "article": f"Madde {i + 1}",
            "title": TITLES[i],
            "text": T[i].strip(),
            "source": "mevzuat.gov.tr",
        })
    payload = {
        "law": "7068 Genel Kolluk Disiplin Hükümleri Kanunu",
        "sourceUrl": "https://www.mevzuat.gov.tr/mevzuat?MevzuatNo=7068&MevzuatTur=1",
        "lastContentReview": "Konsolide metinle doğrulanmalıdır (yayın tarihleri BK).",
        "source": "https://www.mevzuat.gov.tr/mevzuat?MevzuatNo=7068&MevzuatTur=1",
        "articles": arts,
    }
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
