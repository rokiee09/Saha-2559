import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/law_article.dart';
import '../models/field_card.dart';
import '../models/unit_info.dart';
import '../models/city_contact.dart';
import '../models/martyr.dart';

class IsarService {
  static Isar? _isar;

  static Future<void> init() async {
    if (_isar != null) return;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        LawArticleSchema,
        FieldCardSchema,
        UnitInfoSchema,
        CityContactSchema,
        MartyrSchema,
      ],
      directory: dir.path,
    );
  }

  static Isar get db {
    final isar = _isar;
    if (isar == null) {
      throw StateError('IsarService.init() çağrılmadan veritabanına erişilmeye çalışıldı.');
    }
    return isar;
  }
}

