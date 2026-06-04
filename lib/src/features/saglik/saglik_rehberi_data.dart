import 'package:flutter/widgets.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'saglik_metin.dart';

/// Kullanıcı dostu sağlık rehberi konuları.
enum SaglikRehberKonu {
  istirahat,
  heyet,
  elverislilik,
  malulen,
  engelli,
}

extension SaglikRehberKonuX on SaglikRehberKonu {
  String get id => name;

  String get title => switch (this) {
        SaglikRehberKonu.istirahat => 'İstirahat Raporları',
        SaglikRehberKonu.heyet => 'Heyet Süreci',
        SaglikRehberKonu.elverislilik => 'Göreve Elverişlilik',
        SaglikRehberKonu.malulen => 'Malulen Emeklilik',
        SaglikRehberKonu.engelli => 'Engelli Hakları',
      };

  String get subtitle => switch (this) {
        SaglikRehberKonu.istirahat =>
          'Tek hekim, süre sınırları, izin ve rapor türleri',
        SaglikRehberKonu.heyet => 'Sevk, sağlık kurulu, uzatım ve dönüş',
        SaglikRehberKonu.elverislilik =>
          'Sağlık şartları, rapor sonucu ve görev durumu',
        SaglikRehberKonu.malulen =>
          '5510 kapsamı, rapor ve emeklilik yönlendirmesi',
        SaglikRehberKonu.engelli =>
          'Engelli yakını mazeret izni ve refakat hakları',
      };

  IconData get icon => switch (this) {
        SaglikRehberKonu.istirahat => PhosphorIconsRegular.bed,
        SaglikRehberKonu.heyet => PhosphorIconsRegular.usersThree,
        SaglikRehberKonu.elverislilik => PhosphorIconsRegular.shieldCheck,
        SaglikRehberKonu.malulen => PhosphorIconsRegular.wheelchair,
        SaglikRehberKonu.engelli => PhosphorIconsRegular.heart,
      };
}

class SaglikMevzuatRef {
  const SaglikMevzuatRef({
    required this.label,
    this.entryId,
    this.sectionId,
    this.externalUrl,
    this.notInAppNote,
    this.metinId,
    this.metinSectionId,
  });

  final String label;
  final String? entryId;
  final String? sectionId;
  final String? externalUrl;
  final String? notInAppNote;
  final SaglikMetinId? metinId;
  final String? metinSectionId;

  bool get isInAppMevzuat => entryId != null && entryId!.isNotEmpty;
  bool get isInAppSaglikMetin => metinId != null;
  bool get isInApp => isInAppMevzuat || isInAppSaglikMetin;
}

class SaglikRehberIcerik {
  const SaglikRehberIcerik({
    required this.konu,
    required this.ozet,
    required this.uygulamada,
    required this.adimlar,
    required this.mevzuatRefs,
    required this.uyarilar,
  });

  final SaglikRehberKonu konu;
  final String ozet;
  final String uygulamada;
  final List<String> adimlar;
  final List<SaglikMevzuatRef> mevzuatRefs;
  final List<String> uyarilar;
}

class SaglikSenaryo {
  const SaglikSenaryo({
    required this.id,
    required this.baslik,
    required this.anahtarlar,
    required this.ozet,
    required this.uygulamada,
    required this.mevzuatNotlari,
    this.mevzuatRefs = const [],
    this.ilgiliKonu,
  });

  final String id;
  final String baslik;
  final List<String> anahtarlar;
  final String ozet;
  final String uygulamada;
  final List<String> mevzuatNotlari;
  final List<SaglikMevzuatRef> mevzuatRefs;
  final SaglikRehberKonu? ilgiliKonu;
}

const kSaglikMevzuatRefs = <SaglikMevzuatRef>[
  SaglikMevzuatRef(
    label: '657 DMK — m. 105 (Hastalık / refakat)',
    entryId: 'kanun-dmk',
    sectionId: 'dmk-105',
  ),
  SaglikMevzuatRef(
    label: '657 DMK — m. 104 (Engelli yakını mazeret)',
    entryId: 'kanun-dmk',
    sectionId: 'dmk-104',
  ),
  SaglikMevzuatRef(
    label: '5510 — Sosyal Sigortalar Kanunu',
    entryId: 'kanun-sgk',
  ),
  SaglikMevzuatRef(
    label: 'Emniyet Teşkilatı Sağlık Şartları Yönetmeliği',
    metinId: SaglikMetinId.emniyetSaglikSartlari,
  ),
  SaglikMevzuatRef(
    label: 'Sağlık Uygulamaları Rehberi',
    metinId: SaglikMetinId.saglikUygulamalari,
    notInAppNote:
        'Genelge niteliğinde uygulama esasları; resmî evrak üst bilgisi gösterilmez.',
  ),
  SaglikMevzuatRef(
    label: 'Devlet Memurları Hastalık Raporları Yönetmeliği',
    externalUrl:
        'https://www.mevzuat.gov.tr/mevzuat?MevzuatNo=28099&MevzuatTur=7&MevzuatTertip=5',
    notInAppNote: 'İstirahat ve refakat usulleri — resmî kaynak.',
  ),
];

SaglikRehberIcerik rehberIcerik(SaglikRehberKonu konu) => switch (konu) {
      SaglikRehberKonu.istirahat => const SaglikRehberIcerik(
            konu: SaglikRehberKonu.istirahat,
            ozet:
                'İlgili mevzuata göre istirahat (hastalık) raporu, görevden '
                'geçici ayrılmayı sağlar. Tek hekim raporları kısa süreli '
                'hastalıklarda; uzayan sürelerde sağlık kurulu (heyet) devreye '
                'girer. Teşhis koymaz; rapor türü ve süre sınırlarını '
                'gösterir.',
            uygulamada:
                'Raporu birim amirliğine / personel birimine iletin. '
                'Profilim → İzinlerim bölümünde rapor süresini kaydedebilir; '
                '10 günü aşan raporlarda heyet uyarısı görürsünüz.',
            adimlar: [
              'Sağlık kuruluşundan rapor alın (tek hekim veya kurul).',
              'Raporu görev biriminize / personel işlerine iletin.',
              'Rapor süresini ve türünü (istirahat) izin kaydına işleyin.',
              'Süre bitiminde göreve dönüş veya uzatım raporunu takip edin.',
              'Aynı hastalıkta toplam 20 günü aşıyorsa heyet raporu gerekir.',
            ],
            mevzuatRefs: [
              SaglikMevzuatRef(
                label: '657 DMK m. 105',
                entryId: 'kanun-dmk',
                sectionId: 'dmk-105',
              ),
            ],
            uyarilar: [
              'Bu özet tıbbi teşhis veya tedavi tavsiyesi değildir.',
              'Kesin süre ve rapor şekli güncel yönetmelik ve kurum uygulamasına bağlıdır.',
            ],
          ),
      SaglikRehberKonu.heyet => const SaglikRehberIcerik(
            konu: SaglikRehberKonu.heyet,
            ozet:
                'İlgili mevzuata göre heyet (sağlık kurulu) raporu; tek hekim '
                'raporuyle karşılanamayan veya süresi uzayan hastalıklarda, '
                'göreve elverişlilik ve maluliyet değerlendirmelerinde '
                'kullanılır. Sevk usulü kurum ve sağlık yönetmeliğine tabidir.',
            uygulamada:
                'Heyete sevk genelde birim sağlık işleri veya personel '
                'birimi üzerinden yapılır. Rapor sonucunu özlük dosyanıza '
                'işletmek için personel birimini takip edin.',
            adimlar: [
              'Tek hekim raporu süresi doldu veya aynı hastalık 20 günü aştı.',
              'Birim / sağlık işleri aracılığıyla heyete sevk talebi.',
              'Sağlık kurulunda muayene ve rapor düzenlenmesi.',
              'Rapor sonucu: iyileşme, süre uzatımı veya göreve elverişsizlik.',
              'Gerekirse maluliyet / emeklilik süreci ayrı değerlendirilir.',
            ],
            mevzuatRefs: [
              SaglikMevzuatRef(
                label: '657 DMK m. 105',
                entryId: 'kanun-dmk',
                sectionId: 'dmk-105',
              ),
              SaglikMevzuatRef(
                label: 'Sağlık Uygulamaları Rehberi',
                metinId: SaglikMetinId.saglikUygulamalari,
              ),
            ],
            uyarilar: [
              'Heyet kararı tıbbi muayene sonucudur; uygulama birim yazılarıyla tamamlanır.',
              'Bağlayıcı hukuki tavsiye değildir; teredditte personel birimine başvurun.',
            ],
          ),
      SaglikRehberKonu.elverislilik => const SaglikRehberIcerik(
            konu: SaglikRehberKonu.elverislilik,
            ozet:
                'İlgili mevzuata göre göreve elverişlilik; polisin sağlık '
                'şartlarını taşıyıp taşımadığının resmî raporla tespitidir. '
                'Emniyet Sağlık Şartları Yönetmeliği ve sağlık kurulu '
                'raporları çerçevesinde değerlendirilir.',
            uygulamada:
                'Atama, yükselme, silah taşıma ve görevde kalma gibi '
                'durumlarda sağlık raporu istenebilir. Sonuç göreve devam, '
                'sınırlı görev veya ayrılma yönünde olabilir.',
            adimlar: [
              'Kurumca istenen sağlık muayenesi / heyet sevkini takip edin.',
              'Emniyet sağlık şartları yönetmeliğindeki kriterleri gözden geçirin.',
              'Rapor sonucunu personel birimine iletin.',
              'Göreve devam veya görev değişikliği kararını kurum yazısıyla öğrenin.',
              'İtiraz / yeniden muayene usulleri için mevzuat ve genelgelere bakın.',
            ],
            mevzuatRefs: [
              SaglikMevzuatRef(
                label: 'Emniyet Sağlık Şartları Yönetmeliği',
                metinId: SaglikMetinId.emniyetSaglikSartlari,
              ),
              SaglikMevzuatRef(
                label: '657 DMK m. 105',
                entryId: 'kanun-dmk',
                sectionId: 'dmk-105',
              ),
            ],
            uyarilar: [
              'Sağlık durumunuzu anlatmanız teşhis değildir; rapor sonucu esastır.',
              'Silah taşıma ve özel görevlerde ek şartlar uygulanabilir.',
            ],
          ),
      SaglikRehberKonu.malulen => const SaglikRehberIcerik(
            konu: SaglikRehberKonu.malulen,
            ozet:
                'İlgili mevzuata göre malulen emeklilik; çalışma gücünün '
                'belirli oranda kaybının resmî sağlık kurulu raporuyla '
                'tespit edilmesi ve 5510 hükümleri çerçevesinde hak '
                'doğurmasıdır. Emeklilik takibi Profilim → Emeklilik ile '
                'ilişkilendirilebilir; maluliyet ayrı rapor sürecidir.',
            uygulamada:
                'Uzun süreli hastalık sonrası iyileşmeme hâlinde DMK m. 105 '
                'emeklilik hükümleri devreye girebilir. SGK / kurum '
                'emeklilik işlemleri personel birimi üzerinden yürür.',
            adimlar: [
              'Sağlık kurulu raporu ile maluliyet oranı tespiti.',
              '5510 ve ilgili yönetmelik kapsamında başvuru / kurum yazışması.',
              'Emeklilik dosyasının personel ve SGK tarafında tamamlanması.',
              'Aylık bağlama ve özlük hakları hakkında resmî tebligatı bekleyin.',
              'Gerekli sağlık şartlarını yeniden kazananlar için DMK m. 105 fıkralarına bakın.',
            ],
            mevzuatRefs: [
              SaglikMevzuatRef(
                label: '5510 Sosyal Sigortalar Kanunu',
                entryId: 'kanun-sgk',
              ),
              SaglikMevzuatRef(
                label: '657 DMK m. 105',
                entryId: 'kanun-dmk',
                sectionId: 'dmk-105',
              ),
            ],
            uyarilar: [
              'Maluliyet oranı ve emeklilik hakkı resmî rapor ve SGK işlemiyle belirlenir.',
              'Profilim’deki emeklilik tahmini bilgilendirme amaçlıdır; maluliyet kararı değildir.',
            ],
          ),
      SaglikRehberKonu.engelli => const SaglikRehberIcerik(
            konu: SaglikRehberKonu.engelli,
            ozet:
                'İlgili mevzuata göre engelli yakını hakları; memurun bakmakla '
                'yükümlü olduğu engelli çocuğu için mazeret izni, refakat '
                'izni ve benzeri özlük düzenlemelerini kapsar. Oran ve süre '
                'güncel DMK metnine bağlıdır.',
            uygulamada:
                'Engelli çocuk için sağlık raporu ve izin talebi birim '
                'amirliğine yapılır. Profilim → İzinlerim’de kayıt tutabilirsiniz.',
            adimlar: [
              'Engellilik durumunu gösteren sağlık raporunu temin edin.',
              '657 DMK m. 104 (E) kapsamında mazeret izni talebi hazırlayın.',
              'Amir onayı ve personel birimi kaydını tamamlayın.',
              'Refakat gerektiren ağır hastalık hâllerinde m. 105 refakat iznine bakın.',
              'Güncel oran (%70 vb.) için kanunun güncel metnini kontrol edin.',
            ],
            mevzuatRefs: [
              SaglikMevzuatRef(
                label: '657 DMK m. 104',
                entryId: 'kanun-dmk',
                sectionId: 'dmk-104',
              ),
              SaglikMevzuatRef(
                label: '657 DMK m. 105 (Refakat)',
                entryId: 'kanun-dmk',
                sectionId: 'dmk-105',
              ),
            ],
            uyarilar: [
              'Engellilik oranı ve yakınlık derecesi raporla ispatlanmalıdır.',
              'Kurum içi izin onay usulü Polis Personeli İzin Yönetmeliğine tabidir.',
            ],
          ),
    };

const kSaglikSenaryolari = <SaglikSenaryo>[
  SaglikSenaryo(
    id: 'bel_fitigi',
    baslik: 'Bel fıtığı ameliyatı — görev ve izin',
    anahtarlar: [
      'bel fitigi',
      'bel fıtığı',
      'fitik',
      'ameliyat',
      'ameliyat oldum',
      'disk',
      'omurga',
    ],
    ozet:
        'İlgili mevzuata göre ameliyat sonrası süreçte istirahat raporu '
        've gerekirse heyet raporu devreye girer. Göreve dönüş, iyileşme '
        'raporu ve göreve elverişlilik değerlendirmesi ayrı aşamalardır.',
    uygulamada:
        'Ameliyat raporunu birime iletin. İstirahat süresini izin kaydına '
        'işleyin. Süre uzarsa heyet; kalıcı kısıt varsa elverişlilik '
        'değerlendirmesi gündeme gelebilir.',
    mevzuatNotlari: [
      '657 DMK m. 105 — hastalık izni ve uzatım',
      'Sağlık Uygulamaları Rehberi — rapor süreleri',
      'Emniyet Sağlık Şartları — göreve elverişlilik',
    ],
    mevzuatRefs: [
      SaglikMevzuatRef(
        label: '657 DMK m. 105',
        entryId: 'kanun-dmk',
        sectionId: 'dmk-105',
      ),
      SaglikMevzuatRef(
        label: 'Sağlık Uygulamaları Rehberi',
        metinId: SaglikMetinId.saglikUygulamalari,
      ),
    ],
    ilgiliKonu: SaglikRehberKonu.istirahat,
  ),
  SaglikSenaryo(
    id: 'heyet_sevk',
    baslik: 'Heyete sevk süreci',
    anahtarlar: [
      'heyet',
      'heyete',
      'sevk',
      'saglik kurulu',
      'sağlık kurulu',
      'kurul raporu',
    ],
    ozet:
        'İlgili mevzuata göre heyete sevk; tek hekim raporunun yetmediği '
        'veya sürenin uzadığı hallerde sağlık kurulu muayenesi için '
        'yapılır. Sevk birim sağlık işleri / personel aracılığıyla olur.',
    uygulamada:
        'Personel biriminden sevk yazısını alın. Randevu ve rapor sonucunu '
        'takip edin. Sonuç: süre uzatımı, göreve dönüş veya elverişsizlik.',
    mevzuatNotlari: [
      'Sağlık Uygulamaları Rehberi',
      '657 DMK m. 105',
    ],
    ilgiliKonu: SaglikRehberKonu.heyet,
  ),
  SaglikSenaryo(
    id: 'psikolojik',
    baslik: 'Psikolojik değerlendirme / rapor',
    anahtarlar: [
      'psikolojik',
      'psikiyatri',
      'depresyon',
      'stres',
      'tukenmislik',
      'tükenmişlik',
      'ruhsal',
      'akil sagligi',
      'akıl sağlığı',
    ],
    ozet:
        'İlgili mevzuata göre psikiyatrik / psikolojik değerlendirme de '
        'sağlık raporu kapsamındadır. Teşhis koymaz; rapor türü, süre '
        've göreve elverişlilik ayrı değerlendirilir. Gizlilik kurum '
        'prosedürüne tabidir.',
    uygulamada:
        'Yetkili sağlık kuruluşundan rapor alın. Birim / sağlık işlerine '
        'bildirin. Silah taşıma ve görev kısıtı rapor sonucuna bağlı olabilir.',
    mevzuatNotlari: [
      '657 DMK m. 105 (akıl hastalığı uzun süreli izin)',
      'Emniyet Sağlık Şartları Yönetmeliği',
    ],
    ilgiliKonu: SaglikRehberKonu.elverislilik,
  ),
  SaglikSenaryo(
    id: 'istirahat_sure',
    baslik: 'İstirahat raporu kaç gün?',
    anahtarlar: [
      'istirahat',
      'rapor',
      'kac gun',
      'kaç gün',
      '10 gun',
      '10 gün',
      '20 gun',
      'tek hekim',
    ],
    ozet:
        'İlgili mevzuata göre tek hekim raporu bir defada en fazla 10 gün; '
        'aynı hastalıkta toplam 20 günü aşınca sağlık kurulu raporu gerekir. '
        'Uzun süreli hastalıklarda m. 105 azami süreler uygulanır.',
    uygulamada:
        'Profilim → İzinlerim’de rapor gün sayısını girince heyet uyarısı '
        'görürsünüz. Kesin süre rapor metnine ve yönetmeliğe bağlıdır.',
    mevzuatNotlari: [
      '657 DMK m. 105',
      'Sağlık raporları yönetmeliği (Devlet Personel Başkanlığı)',
    ],
    ilgiliKonu: SaglikRehberKonu.istirahat,
  ),
  SaglikSenaryo(
    id: 'malulen_surec',
    baslik: 'Malulen emeklilik süreci',
    anahtarlar: [
      'malulen',
      'malul',
      'maluliyet',
      'emekli olamam',
      'calisamiyorum',
      'çalışamıyorum',
    ],
    ozet:
        'İlgili mevzuata göre malulen emeklilik; çalışma gücü kaybının '
        'resmî raporla sabitlenmesi ve 5510 hükümlerine göre hak '
        'doğurmasıdır. Uzun süreli iyileşmeme hâlinde DMK m. 105 emeklilik '
        'yönlendirmesi de gündeme gelebilir.',
    uygulamada:
        'Sağlık kurulu raporunu personel birimine iletin. SGK / kurum '
        'emeklilik işlemlerini takip edin. Profilim → Emeklilik bilgi amaçlıdır.',
    mevzuatNotlari: [
      '5510 sayılı Kanun',
      '657 DMK m. 105',
    ],
    ilgiliKonu: SaglikRehberKonu.malulen,
  ),
  SaglikSenaryo(
    id: 'engelli_yakin',
    baslik: 'Engelli yakını izin hakları',
    anahtarlar: [
      'engelli',
      'engelli cocuk',
      'engelli çocuk',
      'yakini',
      'yakını',
      'ozel cocuk',
      'özel çocuk',
    ],
    ozet:
        'İlgili mevzuata göre en az belirli oranda engelli çocuğu olan '
        'memura, sağlık raporuyla mazeret izni verilebilir. Refakat '
        'izni ağır hastalık hâllerinde m. 105 kapsamında ayrı değerlendirilir.',
    uygulamada:
        'Engellilik raporunu ve izin talebini birime sunun. İzinlerim '
        'bölümünde kayıt tutabilirsiniz.',
    mevzuatNotlari: [
      '657 DMK m. 104 (E)',
      '657 DMK m. 105 refakat',
    ],
    ilgiliKonu: SaglikRehberKonu.engelli,
  ),
];

String _saglikFold(String input) {
  return input
      .replaceAll('İ', 'i')
      .replaceAll('I', 'ı')
      .toLowerCase()
      .replaceAll('ç', 'c')
      .replaceAll('ğ', 'g')
      .replaceAll('ı', 'i')
      .replaceAll('ö', 'o')
      .replaceAll('ş', 's')
      .replaceAll('ü', 'u');
}

List<SaglikSenaryo> saglikSenaryoEslestir(String query) {
  final q = _saglikFold(query);
  if (q.trim().length < 3) return [];
  final out = <SaglikSenaryo>[];
  for (final s in kSaglikSenaryolari) {
    for (final k in s.anahtarlar) {
      if (q.contains(_saglikFold(k))) {
        out.add(s);
        break;
      }
    }
  }
  return out;
}
