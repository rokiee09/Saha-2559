import 'package:isar/isar.dart';

part 'city_contact.g.dart';

@collection
class CityContact {
  Id id = Isar.autoIncrement;

  late String cityName;
  late String phone;
  String? address;
  String? sourceUrl;
}

