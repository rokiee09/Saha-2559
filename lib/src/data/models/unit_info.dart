import 'package:isar/isar.dart';

part 'unit_info.g.dart';

@collection
class UnitInfo {
  Id id = Isar.autoIncrement;

  late String unitName;
  late String level; // İl, İlçe, Şube vb.
  String? duties;
  String? contactPhone;
  String? address;
}

