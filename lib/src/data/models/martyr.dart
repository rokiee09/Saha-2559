import 'package:isar/isar.dart';

part 'martyr.g.dart';

/// @Name, web (dart2js) için koleksiyon şema kimliğinin 53 bit içinde kalmasını sağlar.
@Name('EmniyetMartyr')
@collection
class Martyr {
  Id id = Isar.autoIncrement;

  /// Resmî kaynaklardan doğrulanmış tam ad (ünvan varsa aynı alanda)
  late String fullName;
  late String cityName;
  DateTime? dateOfMartyrdom;
}
