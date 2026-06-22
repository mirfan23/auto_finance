class TransactionTable {
  static const String tableName = "transactions";

  static const String createTable = '''
  CREATE TABLE $tableName (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    bank TEXT,
    amount INTEGER,
    type TEXT,
    category TEXT,
    rawText TEXT,
    time INTEGER
  )
  ''';
}