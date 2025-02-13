// lib/db/tables.dart
import 'package:drift/drift.dart';

class Registros extends Table {
  TextColumn get id => text()(); // Ex: "UUID" ou outro ID
  TextColumn get conteudo => text()(); // Algum campo de texto
  BoolColumn get sincronizado => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
