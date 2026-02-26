// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'law_article.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLawArticleCollection on Isar {
  IsarCollection<LawArticle> get lawArticles => this.collection();
}

const LawArticleSchema = CollectionSchema(
  name: r'LawArticle',
  id: 1,
  properties: {
    r'articleNumber': PropertySchema(
      id: 0,
      name: r'articleNumber',
      type: IsarType.long,
    ),
    r'commonMistakes': PropertySchema(
      id: 1,
      name: r'commonMistakes',
      type: IsarType.string,
    ),
    r'fieldExample': PropertySchema(
      id: 2,
      name: r'fieldExample',
      type: IsarType.string,
    ),
    r'isFavorite': PropertySchema(
      id: 3,
      name: r'isFavorite',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 4,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'lastViewedAt': PropertySchema(
      id: 5,
      name: r'lastViewedAt',
      type: IsarType.dateTime,
    ),
    r'lawCode': PropertySchema(
      id: 6,
      name: r'lawCode',
      type: IsarType.string,
    ),
    r'lawName': PropertySchema(
      id: 7,
      name: r'lawName',
      type: IsarType.string,
    ),
    r'officialText': PropertySchema(
      id: 8,
      name: r'officialText',
      type: IsarType.string,
    ),
    r'plainSummary': PropertySchema(
      id: 9,
      name: r'plainSummary',
      type: IsarType.string,
    ),
    r'relatedArticleIds': PropertySchema(
      id: 10,
      name: r'relatedArticleIds',
      type: IsarType.longList,
    ),
    r'sourceUrl': PropertySchema(
      id: 11,
      name: r'sourceUrl',
      type: IsarType.string,
    ),
    r'userNote': PropertySchema(
      id: 12,
      name: r'userNote',
      type: IsarType.string,
    )
  },
  estimateSize: _lawArticleEstimateSize,
  serialize: _lawArticleSerialize,
  deserialize: _lawArticleDeserialize,
  deserializeProp: _lawArticleDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _lawArticleGetId,
  getLinks: _lawArticleGetLinks,
  attach: _lawArticleAttach,
  version: '3.1.0+1',
);

int _lawArticleEstimateSize(
  LawArticle object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.commonMistakes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.fieldExample;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.lawCode.length * 3;
  bytesCount += 3 + object.lawName.length * 3;
  bytesCount += 3 + object.officialText.length * 3;
  bytesCount += 3 + object.plainSummary.length * 3;
  bytesCount += 3 + object.relatedArticleIds.length * 8;
  {
    final value = object.sourceUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.userNote;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _lawArticleSerialize(
  LawArticle object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.articleNumber);
  writer.writeString(offsets[1], object.commonMistakes);
  writer.writeString(offsets[2], object.fieldExample);
  writer.writeBool(offsets[3], object.isFavorite);
  writer.writeDateTime(offsets[4], object.lastUpdated);
  writer.writeDateTime(offsets[5], object.lastViewedAt);
  writer.writeString(offsets[6], object.lawCode);
  writer.writeString(offsets[7], object.lawName);
  writer.writeString(offsets[8], object.officialText);
  writer.writeString(offsets[9], object.plainSummary);
  writer.writeLongList(offsets[10], object.relatedArticleIds);
  writer.writeString(offsets[11], object.sourceUrl);
  writer.writeString(offsets[12], object.userNote);
}

LawArticle _lawArticleDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LawArticle();
  object.articleNumber = reader.readLong(offsets[0]);
  object.commonMistakes = reader.readStringOrNull(offsets[1]);
  object.fieldExample = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.isFavorite = reader.readBool(offsets[3]);
  object.lastUpdated = reader.readDateTimeOrNull(offsets[4]);
  object.lastViewedAt = reader.readDateTimeOrNull(offsets[5]);
  object.lawCode = reader.readString(offsets[6]);
  object.lawName = reader.readString(offsets[7]);
  object.officialText = reader.readString(offsets[8]);
  object.plainSummary = reader.readString(offsets[9]);
  object.relatedArticleIds = reader.readLongList(offsets[10]) ?? [];
  object.sourceUrl = reader.readStringOrNull(offsets[11]);
  object.userNote = reader.readStringOrNull(offsets[12]);
  return object;
}

P _lawArticleDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readLongList(offset) ?? []) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _lawArticleGetId(LawArticle object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _lawArticleGetLinks(LawArticle object) {
  return [];
}

void _lawArticleAttach(IsarCollection<dynamic> col, Id id, LawArticle object) {
  object.id = id;
}

extension LawArticleQueryWhereSort
    on QueryBuilder<LawArticle, LawArticle, QWhere> {
  QueryBuilder<LawArticle, LawArticle, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LawArticleQueryWhere
    on QueryBuilder<LawArticle, LawArticle, QWhereClause> {
  QueryBuilder<LawArticle, LawArticle, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LawArticleQueryFilter
    on QueryBuilder<LawArticle, LawArticle, QFilterCondition> {
  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      articleNumberEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'articleNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      articleNumberGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'articleNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      articleNumberLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'articleNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      articleNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'articleNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      commonMistakesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'commonMistakes',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      commonMistakesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'commonMistakes',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      commonMistakesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'commonMistakes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      commonMistakesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'commonMistakes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      commonMistakesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'commonMistakes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      commonMistakesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'commonMistakes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      commonMistakesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'commonMistakes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      commonMistakesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'commonMistakes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      commonMistakesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'commonMistakes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      commonMistakesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'commonMistakes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      commonMistakesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'commonMistakes',
        value: '',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      commonMistakesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'commonMistakes',
        value: '',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      fieldExampleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fieldExample',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      fieldExampleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fieldExample',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      fieldExampleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fieldExample',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      fieldExampleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fieldExample',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      fieldExampleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fieldExample',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      fieldExampleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fieldExample',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      fieldExampleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fieldExample',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      fieldExampleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fieldExample',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      fieldExampleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fieldExample',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      fieldExampleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fieldExample',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      fieldExampleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fieldExample',
        value: '',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      fieldExampleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fieldExample',
        value: '',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> isFavoriteEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFavorite',
        value: value,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      lastUpdatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      lastUpdatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      lastUpdatedGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      lastUpdatedLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      lastUpdatedBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      lastViewedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastViewedAt',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      lastViewedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastViewedAt',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      lastViewedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastViewedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      lastViewedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastViewedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      lastViewedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastViewedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      lastViewedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastViewedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> lawCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lawCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      lawCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lawCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> lawCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lawCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> lawCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lawCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> lawCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lawCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> lawCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lawCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> lawCodeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lawCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> lawCodeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lawCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> lawCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lawCode',
        value: '',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      lawCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lawCode',
        value: '',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> lawNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lawName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      lawNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lawName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> lawNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lawName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> lawNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lawName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> lawNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lawName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> lawNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lawName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> lawNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lawName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> lawNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lawName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> lawNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lawName',
        value: '',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      lawNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lawName',
        value: '',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      officialTextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'officialText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      officialTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'officialText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      officialTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'officialText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      officialTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'officialText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      officialTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'officialText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      officialTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'officialText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      officialTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'officialText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      officialTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'officialText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      officialTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'officialText',
        value: '',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      officialTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'officialText',
        value: '',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      plainSummaryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'plainSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      plainSummaryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'plainSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      plainSummaryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'plainSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      plainSummaryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'plainSummary',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      plainSummaryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'plainSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      plainSummaryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'plainSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      plainSummaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'plainSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      plainSummaryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'plainSummary',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      plainSummaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'plainSummary',
        value: '',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      plainSummaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'plainSummary',
        value: '',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      relatedArticleIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relatedArticleIds',
        value: value,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      relatedArticleIdsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'relatedArticleIds',
        value: value,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      relatedArticleIdsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'relatedArticleIds',
        value: value,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      relatedArticleIdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'relatedArticleIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      relatedArticleIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'relatedArticleIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      relatedArticleIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'relatedArticleIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      relatedArticleIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'relatedArticleIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      relatedArticleIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'relatedArticleIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      relatedArticleIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'relatedArticleIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      relatedArticleIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'relatedArticleIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      sourceUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sourceUrl',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      sourceUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceUrl',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> sourceUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      sourceUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> sourceUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> sourceUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      sourceUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> sourceUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> sourceUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> sourceUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      sourceUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      sourceUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> userNoteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'userNote',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      userNoteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'userNote',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> userNoteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      userNoteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> userNoteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> userNoteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userNote',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      userNoteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> userNoteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> userNoteContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition> userNoteMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userNote',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      userNoteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userNote',
        value: '',
      ));
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterFilterCondition>
      userNoteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userNote',
        value: '',
      ));
    });
  }
}

extension LawArticleQueryObject
    on QueryBuilder<LawArticle, LawArticle, QFilterCondition> {}

extension LawArticleQueryLinks
    on QueryBuilder<LawArticle, LawArticle, QFilterCondition> {}

extension LawArticleQuerySortBy
    on QueryBuilder<LawArticle, LawArticle, QSortBy> {
  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> sortByArticleNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'articleNumber', Sort.asc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> sortByArticleNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'articleNumber', Sort.desc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> sortByCommonMistakes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commonMistakes', Sort.asc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy>
      sortByCommonMistakesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commonMistakes', Sort.desc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> sortByFieldExample() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldExample', Sort.asc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> sortByFieldExampleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldExample', Sort.desc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> sortByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> sortByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> sortByLastViewedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastViewedAt', Sort.asc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> sortByLastViewedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastViewedAt', Sort.desc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> sortByLawCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lawCode', Sort.asc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> sortByLawCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lawCode', Sort.desc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> sortByLawName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lawName', Sort.asc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> sortByLawNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lawName', Sort.desc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> sortByOfficialText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'officialText', Sort.asc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> sortByOfficialTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'officialText', Sort.desc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> sortByPlainSummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plainSummary', Sort.asc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> sortByPlainSummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plainSummary', Sort.desc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> sortBySourceUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUrl', Sort.asc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> sortBySourceUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUrl', Sort.desc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> sortByUserNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userNote', Sort.asc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> sortByUserNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userNote', Sort.desc);
    });
  }
}

extension LawArticleQuerySortThenBy
    on QueryBuilder<LawArticle, LawArticle, QSortThenBy> {
  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> thenByArticleNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'articleNumber', Sort.asc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> thenByArticleNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'articleNumber', Sort.desc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> thenByCommonMistakes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commonMistakes', Sort.asc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy>
      thenByCommonMistakesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commonMistakes', Sort.desc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> thenByFieldExample() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldExample', Sort.asc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> thenByFieldExampleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldExample', Sort.desc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> thenByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> thenByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> thenByLastViewedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastViewedAt', Sort.asc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> thenByLastViewedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastViewedAt', Sort.desc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> thenByLawCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lawCode', Sort.asc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> thenByLawCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lawCode', Sort.desc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> thenByLawName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lawName', Sort.asc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> thenByLawNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lawName', Sort.desc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> thenByOfficialText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'officialText', Sort.asc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> thenByOfficialTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'officialText', Sort.desc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> thenByPlainSummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plainSummary', Sort.asc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> thenByPlainSummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plainSummary', Sort.desc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> thenBySourceUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUrl', Sort.asc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> thenBySourceUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUrl', Sort.desc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> thenByUserNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userNote', Sort.asc);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QAfterSortBy> thenByUserNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userNote', Sort.desc);
    });
  }
}

extension LawArticleQueryWhereDistinct
    on QueryBuilder<LawArticle, LawArticle, QDistinct> {
  QueryBuilder<LawArticle, LawArticle, QDistinct> distinctByArticleNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'articleNumber');
    });
  }

  QueryBuilder<LawArticle, LawArticle, QDistinct> distinctByCommonMistakes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'commonMistakes',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QDistinct> distinctByFieldExample(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fieldExample', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QDistinct> distinctByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFavorite');
    });
  }

  QueryBuilder<LawArticle, LawArticle, QDistinct> distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<LawArticle, LawArticle, QDistinct> distinctByLastViewedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastViewedAt');
    });
  }

  QueryBuilder<LawArticle, LawArticle, QDistinct> distinctByLawCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lawCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QDistinct> distinctByLawName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lawName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QDistinct> distinctByOfficialText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'officialText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QDistinct> distinctByPlainSummary(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'plainSummary', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QDistinct>
      distinctByRelatedArticleIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'relatedArticleIds');
    });
  }

  QueryBuilder<LawArticle, LawArticle, QDistinct> distinctBySourceUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LawArticle, LawArticle, QDistinct> distinctByUserNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userNote', caseSensitive: caseSensitive);
    });
  }
}

extension LawArticleQueryProperty
    on QueryBuilder<LawArticle, LawArticle, QQueryProperty> {
  QueryBuilder<LawArticle, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LawArticle, int, QQueryOperations> articleNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'articleNumber');
    });
  }

  QueryBuilder<LawArticle, String?, QQueryOperations> commonMistakesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'commonMistakes');
    });
  }

  QueryBuilder<LawArticle, String?, QQueryOperations> fieldExampleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fieldExample');
    });
  }

  QueryBuilder<LawArticle, bool, QQueryOperations> isFavoriteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFavorite');
    });
  }

  QueryBuilder<LawArticle, DateTime?, QQueryOperations> lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<LawArticle, DateTime?, QQueryOperations> lastViewedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastViewedAt');
    });
  }

  QueryBuilder<LawArticle, String, QQueryOperations> lawCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lawCode');
    });
  }

  QueryBuilder<LawArticle, String, QQueryOperations> lawNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lawName');
    });
  }

  QueryBuilder<LawArticle, String, QQueryOperations> officialTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'officialText');
    });
  }

  QueryBuilder<LawArticle, String, QQueryOperations> plainSummaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'plainSummary');
    });
  }

  QueryBuilder<LawArticle, List<int>, QQueryOperations>
      relatedArticleIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relatedArticleIds');
    });
  }

  QueryBuilder<LawArticle, String?, QQueryOperations> sourceUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceUrl');
    });
  }

  QueryBuilder<LawArticle, String?, QQueryOperations> userNoteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userNote');
    });
  }
}
