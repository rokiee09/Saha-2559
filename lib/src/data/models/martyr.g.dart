// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'martyr.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMartyrCollection on Isar {
  IsarCollection<Martyr> get martyrs => this.collection();
}

const MartyrSchema = CollectionSchema(
  name: r'EmniyetMartyr',
  id: -7358137696273628160,
  properties: {
    r'cityName': PropertySchema(
      id: 0,
      name: r'cityName',
      type: IsarType.string,
    ),
    r'dateOfMartyrdom': PropertySchema(
      id: 1,
      name: r'dateOfMartyrdom',
      type: IsarType.dateTime,
    ),
    r'fullName': PropertySchema(
      id: 2,
      name: r'fullName',
      type: IsarType.string,
    )
  },
  estimateSize: _martyrEstimateSize,
  serialize: _martyrSerialize,
  deserialize: _martyrDeserialize,
  deserializeProp: _martyrDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _martyrGetId,
  getLinks: _martyrGetLinks,
  attach: _martyrAttach,
  version: '3.1.0+1',
);

int _martyrEstimateSize(
  Martyr object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cityName.length * 3;
  bytesCount += 3 + object.fullName.length * 3;
  return bytesCount;
}

void _martyrSerialize(
  Martyr object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cityName);
  writer.writeDateTime(offsets[1], object.dateOfMartyrdom);
  writer.writeString(offsets[2], object.fullName);
}

Martyr _martyrDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Martyr();
  object.cityName = reader.readString(offsets[0]);
  object.dateOfMartyrdom = reader.readDateTimeOrNull(offsets[1]);
  object.fullName = reader.readString(offsets[2]);
  object.id = id;
  return object;
}

P _martyrDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _martyrGetId(Martyr object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _martyrGetLinks(Martyr object) {
  return [];
}

void _martyrAttach(IsarCollection<dynamic> col, Id id, Martyr object) {
  object.id = id;
}

extension MartyrQueryWhereSort on QueryBuilder<Martyr, Martyr, QWhere> {
  QueryBuilder<Martyr, Martyr, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MartyrQueryWhere on QueryBuilder<Martyr, Martyr, QWhereClause> {
  QueryBuilder<Martyr, Martyr, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Martyr, Martyr, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterWhereClause> idBetween(
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

extension MartyrQueryFilter on QueryBuilder<Martyr, Martyr, QFilterCondition> {
  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> cityNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> cityNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> cityNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> cityNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cityName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> cityNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> cityNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> cityNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> cityNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cityName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> cityNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cityName',
        value: '',
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> cityNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cityName',
        value: '',
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> dateOfMartyrdomIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dateOfMartyrdom',
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition>
      dateOfMartyrdomIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dateOfMartyrdom',
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> dateOfMartyrdomEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateOfMartyrdom',
        value: value,
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition>
      dateOfMartyrdomGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateOfMartyrdom',
        value: value,
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> dateOfMartyrdomLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateOfMartyrdom',
        value: value,
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> dateOfMartyrdomBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateOfMartyrdom',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> fullNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> fullNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> fullNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> fullNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fullName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> fullNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> fullNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> fullNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> fullNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fullName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> fullNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullName',
        value: '',
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> fullNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fullName',
        value: '',
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Martyr, Martyr, QAfterFilterCondition> idBetween(
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
}

extension MartyrQueryObject on QueryBuilder<Martyr, Martyr, QFilterCondition> {}

extension MartyrQueryLinks on QueryBuilder<Martyr, Martyr, QFilterCondition> {}

extension MartyrQuerySortBy on QueryBuilder<Martyr, Martyr, QSortBy> {
  QueryBuilder<Martyr, Martyr, QAfterSortBy> sortByCityName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cityName', Sort.asc);
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterSortBy> sortByCityNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cityName', Sort.desc);
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterSortBy> sortByDateOfMartyrdom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfMartyrdom', Sort.asc);
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterSortBy> sortByDateOfMartyrdomDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfMartyrdom', Sort.desc);
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterSortBy> sortByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterSortBy> sortByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }
}

extension MartyrQuerySortThenBy on QueryBuilder<Martyr, Martyr, QSortThenBy> {
  QueryBuilder<Martyr, Martyr, QAfterSortBy> thenByCityName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cityName', Sort.asc);
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterSortBy> thenByCityNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cityName', Sort.desc);
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterSortBy> thenByDateOfMartyrdom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfMartyrdom', Sort.asc);
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterSortBy> thenByDateOfMartyrdomDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfMartyrdom', Sort.desc);
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterSortBy> thenByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterSortBy> thenByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Martyr, Martyr, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension MartyrQueryWhereDistinct on QueryBuilder<Martyr, Martyr, QDistinct> {
  QueryBuilder<Martyr, Martyr, QDistinct> distinctByCityName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cityName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Martyr, Martyr, QDistinct> distinctByDateOfMartyrdom() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateOfMartyrdom');
    });
  }

  QueryBuilder<Martyr, Martyr, QDistinct> distinctByFullName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fullName', caseSensitive: caseSensitive);
    });
  }
}

extension MartyrQueryProperty on QueryBuilder<Martyr, Martyr, QQueryProperty> {
  QueryBuilder<Martyr, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Martyr, String, QQueryOperations> cityNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cityName');
    });
  }

  QueryBuilder<Martyr, DateTime?, QQueryOperations> dateOfMartyrdomProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateOfMartyrdom');
    });
  }

  QueryBuilder<Martyr, String, QQueryOperations> fullNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fullName');
    });
  }
}
