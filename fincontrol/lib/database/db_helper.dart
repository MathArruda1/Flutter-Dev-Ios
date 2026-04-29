import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../Models/lancamento.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fincontrol.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE lancamentos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item TEXT,
        valor REAL,
        isEntrada INTEGER
      )
    ''');
  }

Future<int> insert(Lancamento lancamento) async {
  final db = await instance.database;

  print("Salvando: ${lancamento.item}");

  return await db.insert(
    'lancamentos',
    {
      'item': lancamento.item,
      'valor': lancamento.valor,
      'isEntrada': lancamento.isEntrada ? 1 : 0,
    },
  );
}

Future<List<Lancamento>> getAll() async {
  final db = await instance.database;

  final result = await db.query('lancamentos');

  print(result); // mostra tudo salvo

  return result.map((json) {
    return Lancamento(
      item: json['item'] as String,
      valor: (json['valor'] as num).toDouble(),
      isEntrada: (json['isEntrada'] as int) == 1,
    );
  }).toList();
}
}