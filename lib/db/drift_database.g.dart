// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_database.dart';

// ignore_for_file: type=lint
class $RegistrosTable extends Registros
    with TableInfo<$RegistrosTable, Registro> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RegistrosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _conteudoMeta =
      const VerificationMeta('conteudo');
  @override
  late final GeneratedColumn<String> conteudo = GeneratedColumn<String>(
      'conteudo', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sincronizadoMeta =
      const VerificationMeta('sincronizado');
  @override
  late final GeneratedColumn<bool> sincronizado = GeneratedColumn<bool>(
      'sincronizado', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("sincronizado" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [id, conteudo, sincronizado];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'registros';
  @override
  VerificationContext validateIntegrity(Insertable<Registro> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('conteudo')) {
      context.handle(_conteudoMeta,
          conteudo.isAcceptableOrUnknown(data['conteudo']!, _conteudoMeta));
    } else if (isInserting) {
      context.missing(_conteudoMeta);
    }
    if (data.containsKey('sincronizado')) {
      context.handle(
          _sincronizadoMeta,
          sincronizado.isAcceptableOrUnknown(
              data['sincronizado']!, _sincronizadoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Registro map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Registro(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      conteudo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}conteudo'])!,
      sincronizado: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}sincronizado'])!,
    );
  }

  @override
  $RegistrosTable createAlias(String alias) {
    return $RegistrosTable(attachedDatabase, alias);
  }
}

class Registro extends DataClass implements Insertable<Registro> {
  final String id;
  final String conteudo;
  final bool sincronizado;
  const Registro(
      {required this.id, required this.conteudo, required this.sincronizado});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['conteudo'] = Variable<String>(conteudo);
    map['sincronizado'] = Variable<bool>(sincronizado);
    return map;
  }

  RegistrosCompanion toCompanion(bool nullToAbsent) {
    return RegistrosCompanion(
      id: Value(id),
      conteudo: Value(conteudo),
      sincronizado: Value(sincronizado),
    );
  }

  factory Registro.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Registro(
      id: serializer.fromJson<String>(json['id']),
      conteudo: serializer.fromJson<String>(json['conteudo']),
      sincronizado: serializer.fromJson<bool>(json['sincronizado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'conteudo': serializer.toJson<String>(conteudo),
      'sincronizado': serializer.toJson<bool>(sincronizado),
    };
  }

  Registro copyWith({String? id, String? conteudo, bool? sincronizado}) =>
      Registro(
        id: id ?? this.id,
        conteudo: conteudo ?? this.conteudo,
        sincronizado: sincronizado ?? this.sincronizado,
      );
  Registro copyWithCompanion(RegistrosCompanion data) {
    return Registro(
      id: data.id.present ? data.id.value : this.id,
      conteudo: data.conteudo.present ? data.conteudo.value : this.conteudo,
      sincronizado: data.sincronizado.present
          ? data.sincronizado.value
          : this.sincronizado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Registro(')
          ..write('id: $id, ')
          ..write('conteudo: $conteudo, ')
          ..write('sincronizado: $sincronizado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, conteudo, sincronizado);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Registro &&
          other.id == this.id &&
          other.conteudo == this.conteudo &&
          other.sincronizado == this.sincronizado);
}

class RegistrosCompanion extends UpdateCompanion<Registro> {
  final Value<String> id;
  final Value<String> conteudo;
  final Value<bool> sincronizado;
  final Value<int> rowid;
  const RegistrosCompanion({
    this.id = const Value.absent(),
    this.conteudo = const Value.absent(),
    this.sincronizado = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RegistrosCompanion.insert({
    required String id,
    required String conteudo,
    this.sincronizado = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        conteudo = Value(conteudo);
  static Insertable<Registro> custom({
    Expression<String>? id,
    Expression<String>? conteudo,
    Expression<bool>? sincronizado,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conteudo != null) 'conteudo': conteudo,
      if (sincronizado != null) 'sincronizado': sincronizado,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RegistrosCompanion copyWith(
      {Value<String>? id,
      Value<String>? conteudo,
      Value<bool>? sincronizado,
      Value<int>? rowid}) {
    return RegistrosCompanion(
      id: id ?? this.id,
      conteudo: conteudo ?? this.conteudo,
      sincronizado: sincronizado ?? this.sincronizado,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (conteudo.present) {
      map['conteudo'] = Variable<String>(conteudo.value);
    }
    if (sincronizado.present) {
      map['sincronizado'] = Variable<bool>(sincronizado.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RegistrosCompanion(')
          ..write('id: $id, ')
          ..write('conteudo: $conteudo, ')
          ..write('sincronizado: $sincronizado, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RegistrosTable registros = $RegistrosTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [registros];
}

typedef $$RegistrosTableCreateCompanionBuilder = RegistrosCompanion Function({
  required String id,
  required String conteudo,
  Value<bool> sincronizado,
  Value<int> rowid,
});
typedef $$RegistrosTableUpdateCompanionBuilder = RegistrosCompanion Function({
  Value<String> id,
  Value<String> conteudo,
  Value<bool> sincronizado,
  Value<int> rowid,
});

class $$RegistrosTableFilterComposer
    extends Composer<_$AppDatabase, $RegistrosTable> {
  $$RegistrosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conteudo => $composableBuilder(
      column: $table.conteudo, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get sincronizado => $composableBuilder(
      column: $table.sincronizado, builder: (column) => ColumnFilters(column));
}

class $$RegistrosTableOrderingComposer
    extends Composer<_$AppDatabase, $RegistrosTable> {
  $$RegistrosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conteudo => $composableBuilder(
      column: $table.conteudo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get sincronizado => $composableBuilder(
      column: $table.sincronizado,
      builder: (column) => ColumnOrderings(column));
}

class $$RegistrosTableAnnotationComposer
    extends Composer<_$AppDatabase, $RegistrosTable> {
  $$RegistrosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get conteudo =>
      $composableBuilder(column: $table.conteudo, builder: (column) => column);

  GeneratedColumn<bool> get sincronizado => $composableBuilder(
      column: $table.sincronizado, builder: (column) => column);
}

class $$RegistrosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RegistrosTable,
    Registro,
    $$RegistrosTableFilterComposer,
    $$RegistrosTableOrderingComposer,
    $$RegistrosTableAnnotationComposer,
    $$RegistrosTableCreateCompanionBuilder,
    $$RegistrosTableUpdateCompanionBuilder,
    (Registro, BaseReferences<_$AppDatabase, $RegistrosTable, Registro>),
    Registro,
    PrefetchHooks Function()> {
  $$RegistrosTableTableManager(_$AppDatabase db, $RegistrosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RegistrosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RegistrosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RegistrosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> conteudo = const Value.absent(),
            Value<bool> sincronizado = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RegistrosCompanion(
            id: id,
            conteudo: conteudo,
            sincronizado: sincronizado,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String conteudo,
            Value<bool> sincronizado = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RegistrosCompanion.insert(
            id: id,
            conteudo: conteudo,
            sincronizado: sincronizado,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RegistrosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RegistrosTable,
    Registro,
    $$RegistrosTableFilterComposer,
    $$RegistrosTableOrderingComposer,
    $$RegistrosTableAnnotationComposer,
    $$RegistrosTableCreateCompanionBuilder,
    $$RegistrosTableUpdateCompanionBuilder,
    (Registro, BaseReferences<_$AppDatabase, $RegistrosTable, Registro>),
    Registro,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RegistrosTableTableManager get registros =>
      $$RegistrosTableTableManager(_db, _db.registros);
}
