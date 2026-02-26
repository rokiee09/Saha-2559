import 'package:isar/isar.dart';

part 'martyr.g.dart';

@collection
class Martyr {
  Id id = Isar.autoIncrement;

  late String fullName;
  late String cityName;
  DateTime? dateOfMartyrdom;
  String? location;
  String? story; // Saygı odaklı anlatım, yorum alanı yok.
}

