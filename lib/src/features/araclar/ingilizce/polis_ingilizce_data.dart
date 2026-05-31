import 'package:flutter/widgets.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

/// Polis İngilizcesi: turist/yabancı ile sık kullanılan hazır kalıplar.
/// Tamamen offline. Okunuşlar yaklaşıktır.

class IngilizceKalip {
  const IngilizceKalip({
    required this.tr,
    required this.en,
    this.okunus = '',
  });

  final String tr;
  final String en;
  final String okunus;
}

class IngilizceKategori {
  const IngilizceKategori({
    required this.id,
    required this.title,
    required this.icon,
    required this.kaliplar,
  });

  final String id;
  final String title;
  final IconData icon;
  final List<IngilizceKalip> kaliplar;

  static const List<IngilizceKategori> all = [
    IngilizceKategori(
      id: 'durdurma',
      title: 'Durdurma & Kontrol',
      icon: PhosphorIconsRegular.handPalm,
      kaliplar: [
        IngilizceKalip(
          tr: 'Polis! Durun.',
          en: 'Police! Stop.',
          okunus: 'polis, stap',
        ),
        IngilizceKalip(
          tr: 'Bu bir polis kontrolüdür.',
          en: 'This is a police check.',
          okunus: 'dis iz ı polis çek',
        ),
        IngilizceKalip(
          tr: 'Lütfen ellerinizi görebileceğim yerde tutun.',
          en: 'Please keep your hands where I can see them.',
          okunus: 'pliiz kiip yor hends ver ay ken sii dem',
        ),
        IngilizceKalip(
          tr: 'Sakin olun, endişelenmeyin.',
          en: 'Stay calm, do not worry.',
          okunus: 'stey kaam, du nat vari',
        ),
        IngilizceKalip(
          tr: 'Üzerinizde silah var mı?',
          en: 'Do you have any weapons on you?',
          okunus: 'du yu hev eni vepıns on yu',
        ),
      ],
    ),
    IngilizceKategori(
      id: 'kimlik',
      title: 'Kimlik & Pasaport',
      icon: PhosphorIconsRegular.identificationCard,
      kaliplar: [
        IngilizceKalip(
          tr: 'Pasaportunuzu görebilir miyim?',
          en: 'May I see your passport?',
          okunus: 'mey ay sii yor pasport',
        ),
        IngilizceKalip(
          tr: 'Kimliğiniz yanınızda mı?',
          en: 'Do you have your ID with you?',
          okunus: 'du yu hev yor ay-dii vit yu',
        ),
        IngilizceKalip(
          tr: 'Buraya ne zaman geldiniz?',
          en: 'When did you arrive here?',
          okunus: 'ven did yu ırayv hiır',
        ),
        IngilizceKalip(
          tr: 'Nerede kalıyorsunuz?',
          en: 'Where are you staying?',
          okunus: 'ver ar yu steying',
        ),
        IngilizceKalip(
          tr: 'Seyahatinizin amacı nedir?',
          en: 'What is the purpose of your visit?',
          okunus: 'vat iz dı pörpıs ov yor vizit',
        ),
      ],
    ),
    IngilizceKategori(
      id: 'arac',
      title: 'Araç & Trafik',
      icon: PhosphorIconsRegular.car,
      kaliplar: [
        IngilizceKalip(
          tr: 'Ehliyetinizi ve ruhsatınızı alabilir miyim?',
          en: 'Your driving licence and registration, please.',
          okunus: 'yor drayving laysıns end recistreyşın pliiz',
        ),
        IngilizceKalip(
          tr: 'Lütfen aracı kenara çekin.',
          en: 'Please pull over the car.',
          okunus: 'pliiz pul ovır dı kar',
        ),
        IngilizceKalip(
          tr: 'Motoru kapatın.',
          en: 'Turn off the engine.',
          okunus: 'törn of dı encin',
        ),
        IngilizceKalip(
          tr: 'Hız sınırını aştınız.',
          en: 'You exceeded the speed limit.',
          okunus: 'yu iksiidıd dı spiid limit',
        ),
        IngilizceKalip(
          tr: 'Araçtan iner misiniz?',
          en: 'Can you step out of the car?',
          okunus: 'ken yu step aut ov dı kar',
        ),
      ],
    ),
    IngilizceKategori(
      id: 'yon',
      title: 'Yön Tarifi',
      icon: PhosphorIconsRegular.mapPinLine,
      kaliplar: [
        IngilizceKalip(
          tr: 'Düz gidin.',
          en: 'Go straight ahead.',
          okunus: 'go streyt ıhed',
        ),
        IngilizceKalip(
          tr: 'Sağa / sola dönün.',
          en: 'Turn right / left.',
          okunus: 'törn rayt / left',
        ),
        IngilizceKalip(
          tr: 'Yaklaşık 100 metre ileride.',
          en: 'It is about 100 metres ahead.',
          okunus: 'it iz ıbaut van handred miitırs ıhed',
        ),
        IngilizceKalip(
          tr: 'En yakın hastane şurada.',
          en: 'The nearest hospital is over there.',
          okunus: 'dı niırıst hospital iz ovır der',
        ),
      ],
    ),
    IngilizceKategori(
      id: 'yardim',
      title: 'Yardım & Acil',
      icon: PhosphorIconsRegular.lifebuoy,
      kaliplar: [
        IngilizceKalip(
          tr: 'Size nasıl yardımcı olabilirim?',
          en: 'How can I help you?',
          okunus: 'hav ken ay help yu',
        ),
        IngilizceKalip(
          tr: 'Yaralı mısınız? Ambulans çağırayım mı?',
          en: 'Are you hurt? Shall I call an ambulance?',
          okunus: 'ar yu hört? şel ay kol en ambulans',
        ),
        IngilizceKalip(
          tr: 'Lütfen burada bekleyin.',
          en: 'Please wait here.',
          okunus: 'pliiz veyt hiır',
        ),
        IngilizceKalip(
          tr: 'İngilizce bilen birini çağıracağım.',
          en: 'I will call someone who speaks English.',
          okunus: 'ay vil kol samvan hu spiks ingliş',
        ),
        IngilizceKalip(
          tr: 'Beni anlıyor musunuz?',
          en: 'Do you understand me?',
          okunus: 'du yu andırstend mi',
        ),
      ],
    ),
    IngilizceKategori(
      id: 'gozalti',
      title: 'Yakalama & Haklar',
      icon: PhosphorIconsRegular.warning,
      kaliplar: [
        IngilizceKalip(
          tr: 'Gözaltına alınıyorsunuz.',
          en: 'You are being taken into custody.',
          okunus: 'yu ar biing teykın intu kastıdi',
        ),
        IngilizceKalip(
          tr: 'Bir avukatla görüşme hakkınız var.',
          en: 'You have the right to speak to a lawyer.',
          okunus: 'yu hev dı rayt tu spiik tu ı loyır',
        ),
        IngilizceKalip(
          tr: 'Bir yakınınıza haber verebilirsiniz.',
          en: 'You can inform a relative.',
          okunus: 'yu ken inform ı relıtiv',
        ),
        IngilizceKalip(
          tr: 'Lütfen benimle karakola gelin.',
          en: 'Please come with me to the police station.',
          okunus: 'pliiz kam vit mi tu dı polis steyşın',
        ),
      ],
    ),
  ];
}
