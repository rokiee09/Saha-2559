import 'package:isar/isar.dart';

part 'field_card.g.dart';

@collection
class FieldCard {
  Id id = Isar.autoIncrement;

  late String title;
  late String description;
  String? lawRef; // Örn: PVSK 16
  String? iconKey;
}

