class LogsRepository {
  final Database db;

  LogsRepository(this.db);

  // Insere um log na tabela
  Future<int> insertLog(String message, String source) async {
    return await db.insert(
      'logs',
      {
        'message': message,
        'source': source,
        // timestamp será gerado automaticamente se "DEFAULT CURRENT_TIMESTAMP"
      },
    );
  }

  // Busca todos os logs (ordenados do mais recente p/ mais antigo, por ex.)
  Future<List<Map<String, dynamic>>> getAllLogs() async {
    return await db.query(
      'logs',
      orderBy: 'id DESC', // do mais recente p/ mais antigo
    );
  }
}

class Database {
  insert(String s, Map<String, String> map) {}

  query(String s, {required String orderBy}) {}
}
