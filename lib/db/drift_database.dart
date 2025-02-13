import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'tables.dart';

// O 'part' aqui diz ao Drift onde gerar o código auxiliar:
part 'drift_database.g.dart';

@DriftDatabase(
  tables: [
    Registros
  ], // Referência à classe 'Registros' que você criou em tables.dart
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Sempre que mudar a estrutura, incremente a version e crie migrações.
  @override
  int get schemaVersion => 1;

  // Exemplo de função de inserir dado
  Future<void> inserirRegistro(String id, String conteudo) {
    return into(registros).insert(RegistrosCompanion(
      id: Value(id),
      conteudo: Value(conteudo),
      sincronizado: const Value(false),
    ));
  }

  // Ler todos os registros
  Future<List<Registro>> listarRegistros() => select(registros).get();

  // Retorna só os registros não sincronizados
  Future<List<Registro>> listarNaoSincronizados() {
    return (select(registros)..where((t) => t.sincronizado.equals(false)))
        .get();
  }

  // Marcar como sincronizado
  Future<void> marcarComoSincronizado(String id) {
    return (update(registros)..where((t) => t.id.equals(id)))
        .write(const RegistrosCompanion(sincronizado: Value(true)));
  }
}

// Abre o banco local
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Caso queira armazenar em arquivo local (no celular/desktop):
    // final dbFolder = await getApplicationDocumentsDirectory();
    // final file = File(path.join(dbFolder.path, 'app.sqlite'));
    // return NativeDatabase(file);

    // Para testes (banco em memória):
    return NativeDatabase.memory();
  });
}
