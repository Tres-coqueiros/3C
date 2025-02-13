import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

part 'app_database.g.dart'; // Certifique-se de rodar build_runner para gerar este arquivo

@DataClassName('Atividade')
class Atividades extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get descricao => text().withLength(min: 1, max: 255)();
  TextColumn get coordenador => text().withLength(min: 1, max: 255)();
  TextColumn get patrimonio => text().withLength(min: 1, max: 255)();
  TextColumn get horarioInicial => text().withLength(min: 1, max: 20)();
  TextColumn get horarioFinal => text().withLength(min: 1, max: 20)();
  TextColumn get horimetroInicial => text().withLength(min: 1, max: 10)();
  TextColumn get horimetroFinal => text().withLength(min: 1, max: 10)();
}

@DriftDatabase(tables: [Atividades])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Inserir nova atividade
  Future<int> inserirAtividade(AtividadesCompanion atividade) =>
      into(atividades).insert(atividade);

  // Buscar todas as atividades
  Future<List<Atividade>> obterAtividades() => select(atividades).get();

  // Buscar uma atividade pelo ID
  Future<Atividade?> obterAtividadePorId(int id) {
    return (select(atividades)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  // Atualizar uma atividade existente
  Future<int> atualizarAtividade(int id, AtividadesCompanion atividade) {
    return (update(atividades)..where((tbl) => tbl.id.equals(id)))
        .write(atividade);
  }

  // Excluir uma atividade
  Future<int> excluirAtividade(int id) =>
      (delete(atividades)..where((tbl) => tbl.id.equals(id))).go();

  obterNumeroDeAtividades() {}
}

// Configuração do banco SQLite
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_database.sqlite'));
    return NativeDatabase(file);
  });
}
