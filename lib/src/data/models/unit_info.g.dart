// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_info.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUnitInfoCollection on Isar {
  IsarCollection<UnitInfo> get unitInfos => this.collection();
}

const UnitInfoSchema = CollectionSchema(
  name: r'UnitInfo',
  id: 1003,
  properties: {
    r'address': PropertySchema(
      id: 0,
      name: r'address',
      type: IsarType.string,
    ),
    r'contactPhone': PropertySchema(
      id: 1,
      name: r'contactPhone',
      type: IsarType.string,
    ),
    r'duties': PropertySchema(
      id: 2,
      name: r'duties',
      type: IsarType.string,
    ),
    r'level': PropertySchema(
      id: 3,
      name: r'level',
      type: IsarType.string,
    ),
    r'unitName': PropertySchema(
      id: 4,
      name: r'unitName',
      type: IsarType.string,
    )
  },
  estimateSize: _unitInfoEstimateSize,
  serialize: _unitInfoSerialize,
  deserialize: _unitInfoDeserialize,
  deserializeProp: _unitInfoDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _unitInfoGetId,
  getLinks: _unitInfoGetLinks,
  attach: _unitInfoAttach,
  version: '3.1.0+1',
);

int _unitInfoEstimateSize(
  UnitInfo object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.address;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.contactPhone;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.duties;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.level.length * 3;
  bytesCount += 3 + object.unitName.length * 3;
  return bytesCount;
}

void _unitInfoSerialize(
  UnitInfo object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.address);
  writer.writeString(offsets[1], object.contactPhone);
  writer.writeString(offsets[2], object.duties);
  writer.writeString(offsets[3], object.level);
  writer.writeString(offsets[4], object.unitName);
}

UnitInfo _unitInfoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UnitInfo();
  object.address = reader.readStringOrNull(offsets[0]);
  object.contactPhone = reader.readStringOrNull(offsets[1]);
  object.duties = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.level = reader.readString(offsets[3]);
  object.unitName = reader.readString(offsets[4]);
  return object;
}

P _unitInfoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _unitInfoGetId(UnitInfo object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _unitInfoGetLinks(UnitInfo object) {
  return [];
}

void _unitInfoAttach(IsarCollection<dynamic> col, Id id, UnitInfo object) {
  object.id = id;
}

extension UnitInfoQueryWhereSort on QueryBuilder<UnitInfo, UnitInfo, QWhere> {
  QueryBuilder<UnitInfo, UnitInfo, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UnitInfoQueryWhere on QueryBuilder<UnitInfo, UnitInfo, QWhereClause> {
  QueryBuilder<UnitInfo, UnitInfo, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<UnitInfo, UnitInfo, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterWhereClause> idBetween(
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

extension UnitInfoQueryFilter
    on QueryBuilder<UnitInfo, UnitInfo, QFilterCondition> {
  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> addressIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'address',
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> addressIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'address',
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> addressEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> addressGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> addressLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> addressBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'address',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> addressStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> addressEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> addressContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> addressMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'address',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> addressIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'address',
        value: '',
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> addressIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'address',
        value: '',
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> contactPhoneIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'contactPhone',
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition>
      contactPhoneIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'contactPhone',
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> contactPhoneEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition>
      contactPhoneGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> contactPhoneLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> contactPhoneBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contactPhone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition>
      contactPhoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> contactPhoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> contactPhoneContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> contactPhoneMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contactPhone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition>
      contactPhoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contactPhone',
        value: '',
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition>
      contactPhoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contactPhone',
        value: '',
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> dutiesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'duties',
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> dutiesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'duties',
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> dutiesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'duties',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> dutiesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'duties',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> dutiesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'duties',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> dutiesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'duties',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> dutiesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'duties',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> dutiesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'duties',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> dutiesContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'duties',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> dutiesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'duties',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> dutiesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'duties',
        value: '',
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> dutiesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'duties',
        value: '',
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> idBetween(
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

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> levelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'level',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> levelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'level',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> levelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'level',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> levelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'level',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> levelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'level',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> levelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'level',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> levelContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'level',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> levelMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'level',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> levelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'level',
        value: '',
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> levelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'level',
        value: '',
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> unitNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unitName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> unitNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unitName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> unitNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unitName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> unitNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unitName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> unitNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unitName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> unitNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unitName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> unitNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unitName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> unitNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unitName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> unitNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unitName',
        value: '',
      ));
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterFilterCondition> unitNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unitName',
        value: '',
      ));
    });
  }
}

extension UnitInfoQueryObject
    on QueryBuilder<UnitInfo, UnitInfo, QFilterCondition> {}

extension UnitInfoQueryLinks
    on QueryBuilder<UnitInfo, UnitInfo, QFilterCondition> {}

extension UnitInfoQuerySortBy on QueryBuilder<UnitInfo, UnitInfo, QSortBy> {
  QueryBuilder<UnitInfo, UnitInfo, QAfterSortBy> sortByAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'address', Sort.asc);
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterSortBy> sortByAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'address', Sort.desc);
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterSortBy> sortByContactPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactPhone', Sort.asc);
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterSortBy> sortByContactPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactPhone', Sort.desc);
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterSortBy> sortByDuties() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duties', Sort.asc);
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterSortBy> sortByDutiesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duties', Sort.desc);
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterSortBy> sortByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.asc);
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterSortBy> sortByLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.desc);
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterSortBy> sortByUnitName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitName', Sort.asc);
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterSortBy> sortByUnitNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitName', Sort.desc);
    });
  }
}

extension UnitInfoQuerySortThenBy
    on QueryBuilder<UnitInfo, UnitInfo, QSortThenBy> {
  QueryBuilder<UnitInfo, UnitInfo, QAfterSortBy> thenByAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'address', Sort.asc);
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterSortBy> thenByAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'address', Sort.desc);
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterSortBy> thenByContactPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactPhone', Sort.asc);
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterSortBy> thenByContactPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactPhone', Sort.desc);
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterSortBy> thenByDuties() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duties', Sort.asc);
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterSortBy> thenByDutiesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duties', Sort.desc);
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterSortBy> thenByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.asc);
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterSortBy> thenByLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.desc);
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterSortBy> thenByUnitName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitName', Sort.asc);
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QAfterSortBy> thenByUnitNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitName', Sort.desc);
    });
  }
}

extension UnitInfoQueryWhereDistinct
    on QueryBuilder<UnitInfo, UnitInfo, QDistinct> {
  QueryBuilder<UnitInfo, UnitInfo, QDistinct> distinctByAddress(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'address', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QDistinct> distinctByContactPhone(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contactPhone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QDistinct> distinctByDuties(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'duties', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QDistinct> distinctByLevel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'level', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UnitInfo, UnitInfo, QDistinct> distinctByUnitName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unitName', caseSensitive: caseSensitive);
    });
  }
}

extension UnitInfoQueryProperty
    on QueryBuilder<UnitInfo, UnitInfo, QQueryProperty> {
  QueryBuilder<UnitInfo, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UnitInfo, String?, QQueryOperations> addressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'address');
    });
  }

  QueryBuilder<UnitInfo, String?, QQueryOperations> contactPhoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contactPhone');
    });
  }

  QueryBuilder<UnitInfo, String?, QQueryOperations> dutiesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duties');
    });
  }

  QueryBuilder<UnitInfo, String, QQueryOperations> levelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'level');
    });
  }

  QueryBuilder<UnitInfo, String, QQueryOperations> unitNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unitName');
    });
  }
}
