// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AtividadesTable extends Atividades
    with TableInfo<$AtividadesTable, Atividade> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AtividadesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _descricaoMeta =
      const VerificationMeta('descricao');
  @override
  late final GeneratedColumn<String> descricao = GeneratedColumn<String>(
      'descricao', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _coordenadorMeta =
      const VerificationMeta('coordenador');
  @override
  late final GeneratedColumn<String> coordenador = GeneratedColumn<String>(
      'coordenador', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _patrimonioMeta =
      const VerificationMeta('patrimonio');
  @override
  late final GeneratedColumn<String> patrimonio = GeneratedColumn<String>(
      'patrimonio', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _horarioInicialMeta =
      const VerificationMeta('horarioInicial');
  @override
  late final GeneratedColumn<String> horarioInicial = GeneratedColumn<String>(
      'horario_inicial', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _horarioFinalMeta =
      const VerificationMeta('horarioFinal');
  @override
  late final GeneratedColumn<String> horarioFinal = GeneratedColumn<String>(
      'horario_final', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _horimetroInicialMeta =
      const VerificationMeta('horimetroInicial');
  @override
  late final GeneratedColumn<String> horimetroInicial = GeneratedColumn<String>(
      'horimetro_inicial', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _horimetroFinalMeta =
      const VerificationMeta('horimetroFinal');
  @override
  late final GeneratedColumn<String> horimetroFinal = GeneratedColumn<String>(
      'horimetro_final', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        descricao,
        coordenador,
        patrimonio,
        horarioInicial,
        horarioFinal,
        horimetroInicial,
        horimetroFinal
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'atividades';
  @override
  VerificationContext validateIntegrity(Insertable<Atividade> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('descricao')) {
      context.handle(_descricaoMeta,
          descricao.isAcceptableOrUnknown(data['descricao']!, _descricaoMeta));
    } else if (isInserting) {
      context.missing(_descricaoMeta);
    }
    if (data.containsKey('coordenador')) {
      context.handle(
          _coordenadorMeta,
          coordenador.isAcceptableOrUnknown(
              data['coordenador']!, _coordenadorMeta));
    } else if (isInserting) {
      context.missing(_coordenadorMeta);
    }
    if (data.containsKey('patrimonio')) {
      context.handle(
          _patrimonioMeta,
          patrimonio.isAcceptableOrUnknown(
              data['patrimonio']!, _patrimonioMeta));
    } else if (isInserting) {
      context.missing(_patrimonioMeta);
    }
    if (data.containsKey('horario_inicial')) {
      context.handle(
          _horarioInicialMeta,
          horarioInicial.isAcceptableOrUnknown(
              data['horario_inicial']!, _horarioInicialMeta));
    } else if (isInserting) {
      context.missing(_horarioInicialMeta);
    }
    if (data.containsKey('horario_final')) {
      context.handle(
          _horarioFinalMeta,
          horarioFinal.isAcceptableOrUnknown(
              data['horario_final']!, _horarioFinalMeta));
    } else if (isInserting) {
      context.missing(_horarioFinalMeta);
    }
    if (data.containsKey('horimetro_inicial')) {
      context.handle(
          _horimetroInicialMeta,
          horimetroInicial.isAcceptableOrUnknown(
              data['horimetro_inicial']!, _horimetroInicialMeta));
    } else if (isInserting) {
      context.missing(_horimetroInicialMeta);
    }
    if (data.containsKey('horimetro_final')) {
      context.handle(
          _horimetroFinalMeta,
          horimetroFinal.isAcceptableOrUnknown(
              data['horimetro_final']!, _horimetroFinalMeta));
    } else if (isInserting) {
      context.missing(_horimetroFinalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Atividade map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Atividade(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      descricao: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}descricao'])!,
      coordenador: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}coordenador'])!,
      patrimonio: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}patrimonio'])!,
      horarioInicial: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}horario_inicial'])!,
      horarioFinal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}horario_final'])!,
      horimetroInicial: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}horimetro_inicial'])!,
      horimetroFinal: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}horimetro_final'])!,
    );
  }

  @override
  $AtividadesTable createAlias(String alias) {
    return $AtividadesTable(attachedDatabase, alias);
  }
}

class Atividade extends DataClass implements Insertable<Atividade> {
  final int id;
  final String descricao;
  final String coordenador;
  final String patrimonio;
  final String horarioInicial;
  final String horarioFinal;
  final String horimetroInicial;
  final String horimetroFinal;
  const Atividade(
      {required this.id,
      required this.descricao,
      required this.coordenador,
      required this.patrimonio,
      required this.horarioInicial,
      required this.horarioFinal,
      required this.horimetroInicial,
      required this.horimetroFinal});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['descricao'] = Variable<String>(descricao);
    map['coordenador'] = Variable<String>(coordenador);
    map['patrimonio'] = Variable<String>(patrimonio);
    map['horario_inicial'] = Variable<String>(horarioInicial);
    map['horario_final'] = Variable<String>(horarioFinal);
    map['horimetro_inicial'] = Variable<String>(horimetroInicial);
    map['horimetro_final'] = Variable<String>(horimetroFinal);
    return map;
  }

  AtividadesCompanion toCompanion(bool nullToAbsent) {
    return AtividadesCompanion(
      id: Value(id),
      descricao: Value(descricao),
      coordenador: Value(coordenador),
      patrimonio: Value(patrimonio),
      horarioInicial: Value(horarioInicial),
      horarioFinal: Value(horarioFinal),
      horimetroInicial: Value(horimetroInicial),
      horimetroFinal: Value(horimetroFinal),
    );
  }

  factory Atividade.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Atividade(
      id: serializer.fromJson<int>(json['id']),
      descricao: serializer.fromJson<String>(json['descricao']),
      coordenador: serializer.fromJson<String>(json['coordenador']),
      patrimonio: serializer.fromJson<String>(json['patrimonio']),
      horarioInicial: serializer.fromJson<String>(json['horarioInicial']),
      horarioFinal: serializer.fromJson<String>(json['horarioFinal']),
      horimetroInicial: serializer.fromJson<String>(json['horimetroInicial']),
      horimetroFinal: serializer.fromJson<String>(json['horimetroFinal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'descricao': serializer.toJson<String>(descricao),
      'coordenador': serializer.toJson<String>(coordenador),
      'patrimonio': serializer.toJson<String>(patrimonio),
      'horarioInicial': serializer.toJson<String>(horarioInicial),
      'horarioFinal': serializer.toJson<String>(horarioFinal),
      'horimetroInicial': serializer.toJson<String>(horimetroInicial),
      'horimetroFinal': serializer.toJson<String>(horimetroFinal),
    };
  }

  Atividade copyWith(
          {int? id,
          String? descricao,
          String? coordenador,
          String? patrimonio,
          String? horarioInicial,
          String? horarioFinal,
          String? horimetroInicial,
          String? horimetroFinal}) =>
      Atividade(
        id: id ?? this.id,
        descricao: descricao ?? this.descricao,
        coordenador: coordenador ?? this.coordenador,
        patrimonio: patrimonio ?? this.patrimonio,
        horarioInicial: horarioInicial ?? this.horarioInicial,
        horarioFinal: horarioFinal ?? this.horarioFinal,
        horimetroInicial: horimetroInicial ?? this.horimetroInicial,
        horimetroFinal: horimetroFinal ?? this.horimetroFinal,
      );
  Atividade copyWithCompanion(AtividadesCompanion data) {
    return Atividade(
      id: data.id.present ? data.id.value : this.id,
      descricao: data.descricao.present ? data.descricao.value : this.descricao,
      coordenador:
          data.coordenador.present ? data.coordenador.value : this.coordenador,
      patrimonio:
          data.patrimonio.present ? data.patrimonio.value : this.patrimonio,
      horarioInicial: data.horarioInicial.present
          ? data.horarioInicial.value
          : this.horarioInicial,
      horarioFinal: data.horarioFinal.present
          ? data.horarioFinal.value
          : this.horarioFinal,
      horimetroInicial: data.horimetroInicial.present
          ? data.horimetroInicial.value
          : this.horimetroInicial,
      horimetroFinal: data.horimetroFinal.present
          ? data.horimetroFinal.value
          : this.horimetroFinal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Atividade(')
          ..write('id: $id, ')
          ..write('descricao: $descricao, ')
          ..write('coordenador: $coordenador, ')
          ..write('patrimonio: $patrimonio, ')
          ..write('horarioInicial: $horarioInicial, ')
          ..write('horarioFinal: $horarioFinal, ')
          ..write('horimetroInicial: $horimetroInicial, ')
          ..write('horimetroFinal: $horimetroFinal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, descricao, coordenador, patrimonio,
      horarioInicial, horarioFinal, horimetroInicial, horimetroFinal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Atividade &&
          other.id == this.id &&
          other.descricao == this.descricao &&
          other.coordenador == this.coordenador &&
          other.patrimonio == this.patrimonio &&
          other.horarioInicial == this.horarioInicial &&
          other.horarioFinal == this.horarioFinal &&
          other.horimetroInicial == this.horimetroInicial &&
          other.horimetroFinal == this.horimetroFinal);
}

class AtividadesCompanion extends UpdateCompanion<Atividade> {
  final Value<int> id;
  final Value<String> descricao;
  final Value<String> coordenador;
  final Value<String> patrimonio;
  final Value<String> horarioInicial;
  final Value<String> horarioFinal;
  final Value<String> horimetroInicial;
  final Value<String> horimetroFinal;
  const AtividadesCompanion({
    this.id = const Value.absent(),
    this.descricao = const Value.absent(),
    this.coordenador = const Value.absent(),
    this.patrimonio = const Value.absent(),
    this.horarioInicial = const Value.absent(),
    this.horarioFinal = const Value.absent(),
    this.horimetroInicial = const Value.absent(),
    this.horimetroFinal = const Value.absent(),
  });
  AtividadesCompanion.insert({
    this.id = const Value.absent(),
    required String descricao,
    required String coordenador,
    required String patrimonio,
    required String horarioInicial,
    required String horarioFinal,
    required String horimetroInicial,
    required String horimetroFinal,
  })  : descricao = Value(descricao),
        coordenador = Value(coordenador),
        patrimonio = Value(patrimonio),
        horarioInicial = Value(horarioInicial),
        horarioFinal = Value(horarioFinal),
        horimetroInicial = Value(horimetroInicial),
        horimetroFinal = Value(horimetroFinal);
  static Insertable<Atividade> custom({
    Expression<int>? id,
    Expression<String>? descricao,
    Expression<String>? coordenador,
    Expression<String>? patrimonio,
    Expression<String>? horarioInicial,
    Expression<String>? horarioFinal,
    Expression<String>? horimetroInicial,
    Expression<String>? horimetroFinal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (descricao != null) 'descricao': descricao,
      if (coordenador != null) 'coordenador': coordenador,
      if (patrimonio != null) 'patrimonio': patrimonio,
      if (horarioInicial != null) 'horario_inicial': horarioInicial,
      if (horarioFinal != null) 'horario_final': horarioFinal,
      if (horimetroInicial != null) 'horimetro_inicial': horimetroInicial,
      if (horimetroFinal != null) 'horimetro_final': horimetroFinal,
    });
  }

  AtividadesCompanion copyWith(
      {Value<int>? id,
      Value<String>? descricao,
      Value<String>? coordenador,
      Value<String>? patrimonio,
      Value<String>? horarioInicial,
      Value<String>? horarioFinal,
      Value<String>? horimetroInicial,
      Value<String>? horimetroFinal}) {
    return AtividadesCompanion(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      coordenador: coordenador ?? this.coordenador,
      patrimonio: patrimonio ?? this.patrimonio,
      horarioInicial: horarioInicial ?? this.horarioInicial,
      horarioFinal: horarioFinal ?? this.horarioFinal,
      horimetroInicial: horimetroInicial ?? this.horimetroInicial,
      horimetroFinal: horimetroFinal ?? this.horimetroFinal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (descricao.present) {
      map['descricao'] = Variable<String>(descricao.value);
    }
    if (coordenador.present) {
      map['coordenador'] = Variable<String>(coordenador.value);
    }
    if (patrimonio.present) {
      map['patrimonio'] = Variable<String>(patrimonio.value);
    }
    if (horarioInicial.present) {
      map['horario_inicial'] = Variable<String>(horarioInicial.value);
    }
    if (horarioFinal.present) {
      map['horario_final'] = Variable<String>(horarioFinal.value);
    }
    if (horimetroInicial.present) {
      map['horimetro_inicial'] = Variable<String>(horimetroInicial.value);
    }
    if (horimetroFinal.present) {
      map['horimetro_final'] = Variable<String>(horimetroFinal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AtividadesCompanion(')
          ..write('id: $id, ')
          ..write('descricao: $descricao, ')
          ..write('coordenador: $coordenador, ')
          ..write('patrimonio: $patrimonio, ')
          ..write('horarioInicial: $horarioInicial, ')
          ..write('horarioFinal: $horarioFinal, ')
          ..write('horimetroInicial: $horimetroInicial, ')
          ..write('horimetroFinal: $horimetroFinal')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AtividadesTable atividades = $AtividadesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [atividades];
}

typedef $$AtividadesTableCreateCompanionBuilder = AtividadesCompanion Function({
  Value<int> id,
  required String descricao,
  required String coordenador,
  required String patrimonio,
  required String horarioInicial,
  required String horarioFinal,
  required String horimetroInicial,
  required String horimetroFinal,
});
typedef $$AtividadesTableUpdateCompanionBuilder = AtividadesCompanion Function({
  Value<int> id,
  Value<String> descricao,
  Value<String> coordenador,
  Value<String> patrimonio,
  Value<String> horarioInicial,
  Value<String> horarioFinal,
  Value<String> horimetroInicial,
  Value<String> horimetroFinal,
});

class $$AtividadesTableFilterComposer
    extends Composer<_$AppDatabase, $AtividadesTable> {
  $$AtividadesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descricao => $composableBuilder(
      column: $table.descricao, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coordenador => $composableBuilder(
      column: $table.coordenador, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get patrimonio => $composableBuilder(
      column: $table.patrimonio, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get horarioInicial => $composableBuilder(
      column: $table.horarioInicial,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get horarioFinal => $composableBuilder(
      column: $table.horarioFinal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get horimetroInicial => $composableBuilder(
      column: $table.horimetroInicial,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get horimetroFinal => $composableBuilder(
      column: $table.horimetroFinal,
      builder: (column) => ColumnFilters(column));
}

class $$AtividadesTableOrderingComposer
    extends Composer<_$AppDatabase, $AtividadesTable> {
  $$AtividadesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descricao => $composableBuilder(
      column: $table.descricao, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coordenador => $composableBuilder(
      column: $table.coordenador, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get patrimonio => $composableBuilder(
      column: $table.patrimonio, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get horarioInicial => $composableBuilder(
      column: $table.horarioInicial,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get horarioFinal => $composableBuilder(
      column: $table.horarioFinal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get horimetroInicial => $composableBuilder(
      column: $table.horimetroInicial,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get horimetroFinal => $composableBuilder(
      column: $table.horimetroFinal,
      builder: (column) => ColumnOrderings(column));
}

class $$AtividadesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AtividadesTable> {
  $$AtividadesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get descricao =>
      $composableBuilder(column: $table.descricao, builder: (column) => column);

  GeneratedColumn<String> get coordenador => $composableBuilder(
      column: $table.coordenador, builder: (column) => column);

  GeneratedColumn<String> get patrimonio => $composableBuilder(
      column: $table.patrimonio, builder: (column) => column);

  GeneratedColumn<String> get horarioInicial => $composableBuilder(
      column: $table.horarioInicial, builder: (column) => column);

  GeneratedColumn<String> get horarioFinal => $composableBuilder(
      column: $table.horarioFinal, builder: (column) => column);

  GeneratedColumn<String> get horimetroInicial => $composableBuilder(
      column: $table.horimetroInicial, builder: (column) => column);

  GeneratedColumn<String> get horimetroFinal => $composableBuilder(
      column: $table.horimetroFinal, builder: (column) => column);
}

class $$AtividadesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AtividadesTable,
    Atividade,
    $$AtividadesTableFilterComposer,
    $$AtividadesTableOrderingComposer,
    $$AtividadesTableAnnotationComposer,
    $$AtividadesTableCreateCompanionBuilder,
    $$AtividadesTableUpdateCompanionBuilder,
    (Atividade, BaseReferences<_$AppDatabase, $AtividadesTable, Atividade>),
    Atividade,
    PrefetchHooks Function()> {
  $$AtividadesTableTableManager(_$AppDatabase db, $AtividadesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AtividadesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AtividadesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AtividadesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> descricao = const Value.absent(),
            Value<String> coordenador = const Value.absent(),
            Value<String> patrimonio = const Value.absent(),
            Value<String> horarioInicial = const Value.absent(),
            Value<String> horarioFinal = const Value.absent(),
            Value<String> horimetroInicial = const Value.absent(),
            Value<String> horimetroFinal = const Value.absent(),
          }) =>
              AtividadesCompanion(
            id: id,
            descricao: descricao,
            coordenador: coordenador,
            patrimonio: patrimonio,
            horarioInicial: horarioInicial,
            horarioFinal: horarioFinal,
            horimetroInicial: horimetroInicial,
            horimetroFinal: horimetroFinal,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String descricao,
            required String coordenador,
            required String patrimonio,
            required String horarioInicial,
            required String horarioFinal,
            required String horimetroInicial,
            required String horimetroFinal,
          }) =>
              AtividadesCompanion.insert(
            id: id,
            descricao: descricao,
            coordenador: coordenador,
            patrimonio: patrimonio,
            horarioInicial: horarioInicial,
            horarioFinal: horarioFinal,
            horimetroInicial: horimetroInicial,
            horimetroFinal: horimetroFinal,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AtividadesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AtividadesTable,
    Atividade,
    $$AtividadesTableFilterComposer,
    $$AtividadesTableOrderingComposer,
    $$AtividadesTableAnnotationComposer,
    $$AtividadesTableCreateCompanionBuilder,
    $$AtividadesTableUpdateCompanionBuilder,
    (Atividade, BaseReferences<_$AppDatabase, $AtividadesTable, Atividade>),
    Atividade,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AtividadesTableTableManager get atividades =>
      $$AtividadesTableTableManager(_db, _db.atividades);
}
