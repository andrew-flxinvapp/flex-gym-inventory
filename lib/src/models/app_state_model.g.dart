// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppStateCollection on Isar {
  IsarCollection<AppState> get appStates => this.collection();
}

const AppStateSchema = CollectionSchema(
  name: r'AppState',
  id: 7189399113359544372,
  properties: {
    r'activeGymId': PropertySchema(
      id: 0,
      name: r'activeGymId',
      type: IsarType.string,
    )
  },
  estimateSize: _appStateEstimateSize,
  serialize: _appStateSerialize,
  deserialize: _appStateDeserialize,
  deserializeProp: _appStateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _appStateGetId,
  getLinks: _appStateGetLinks,
  attach: _appStateAttach,
  version: '3.1.0+1',
);

int _appStateEstimateSize(
  AppState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.activeGymId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _appStateSerialize(
  AppState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.activeGymId);
}

AppState _appStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppState();
  object.activeGymId = reader.readStringOrNull(offsets[0]);
  object.id = id;
  return object;
}

P _appStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appStateGetId(AppState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appStateGetLinks(AppState object) {
  return [];
}

void _appStateAttach(IsarCollection<dynamic> col, Id id, AppState object) {
  object.id = id;
}

extension AppStateQueryWhereSort on QueryBuilder<AppState, AppState, QWhere> {
  QueryBuilder<AppState, AppState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppStateQueryWhere on QueryBuilder<AppState, AppState, QWhereClause> {
  QueryBuilder<AppState, AppState, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AppState, AppState, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<AppState, AppState, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterWhereClause> idBetween(
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

extension AppStateQueryFilter
    on QueryBuilder<AppState, AppState, QFilterCondition> {
  QueryBuilder<AppState, AppState, QAfterFilterCondition> activeGymIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'activeGymId',
      ));
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition>
      activeGymIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'activeGymId',
      ));
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition> activeGymIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeGymId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition>
      activeGymIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activeGymId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition> activeGymIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activeGymId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition> activeGymIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activeGymId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition> activeGymIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activeGymId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition> activeGymIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activeGymId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition> activeGymIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activeGymId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition> activeGymIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activeGymId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition> activeGymIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeGymId',
        value: '',
      ));
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition>
      activeGymIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activeGymId',
        value: '',
      ));
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AppState, AppState, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AppState, AppState, QAfterFilterCondition> idBetween(
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

extension AppStateQueryObject
    on QueryBuilder<AppState, AppState, QFilterCondition> {}

extension AppStateQueryLinks
    on QueryBuilder<AppState, AppState, QFilterCondition> {}

extension AppStateQuerySortBy on QueryBuilder<AppState, AppState, QSortBy> {
  QueryBuilder<AppState, AppState, QAfterSortBy> sortByActiveGymId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeGymId', Sort.asc);
    });
  }

  QueryBuilder<AppState, AppState, QAfterSortBy> sortByActiveGymIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeGymId', Sort.desc);
    });
  }
}

extension AppStateQuerySortThenBy
    on QueryBuilder<AppState, AppState, QSortThenBy> {
  QueryBuilder<AppState, AppState, QAfterSortBy> thenByActiveGymId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeGymId', Sort.asc);
    });
  }

  QueryBuilder<AppState, AppState, QAfterSortBy> thenByActiveGymIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeGymId', Sort.desc);
    });
  }

  QueryBuilder<AppState, AppState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppState, AppState, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension AppStateQueryWhereDistinct
    on QueryBuilder<AppState, AppState, QDistinct> {
  QueryBuilder<AppState, AppState, QDistinct> distinctByActiveGymId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeGymId', caseSensitive: caseSensitive);
    });
  }
}

extension AppStateQueryProperty
    on QueryBuilder<AppState, AppState, QQueryProperty> {
  QueryBuilder<AppState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppState, String?, QQueryOperations> activeGymIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeGymId');
    });
  }
}
