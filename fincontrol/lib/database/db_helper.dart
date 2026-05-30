import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../Models/lancamento.dart';
import '../services/auth.dart'; // Importado para saber quem está logado

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
      version: 2, // 🚀 AUMENTAMOS A VERSÃO PARA FORÇAR O FLUTTER A ATUALIZAR A TABELA
      onCreate: _createDB,
      onUpgrade: _onUpgrade, // 🚀 CASO O APP JÁ ESTEJA INSTALADO, ELE ADICIONA A COLUNA ATUAL
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE lancamentos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item TEXT,
        valor REAL,
        isEntrada INTEGER,
        usuario TEXT -- 🚀 NOVA COLUNA: Guarda quem inseriu (Math, arruda, etc.)
      )
    ''');
  }

  // Lógica para atualizar o app que já tem o banco antigo sem dar crash
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE lancamentos ADD COLUMN usuario TEXT DEFAULT 'desconhecido';");
    }
  }

  Future<int> insert(Lancamento lancamento) async {
    final db = await instance.database;
    
    // 👤 Pega o username do usuário que está logado no momento
    String? usuarioLogado = await AuthService.getUsername(); 

    print("Salvando para o usuário [$usuarioLogado]: ${lancamento.item}");

    return await db.insert(
      'lancamentos',
      {
        'item': lancamento.item,
        'valor': lancamento.valor,
        'isEntrada': lancamento.isEntrada ? 1 : 0,
        'usuario': usuarioLogado ?? 'desconhecido', // 🚀 Atrela o gasto ao dono
      },
    );
  }

  Future<List<Lancamento>> getAll() async {
    final db = await instance.database;
    
    // 👤 Pega o username de quem está visualizando a tela agora
    String? usuarioLogado = await AuthService.getUsername();

    // 🚀 FILTRO CRÍTICO: Só traz os lançamentos pertencentes ao usuário atual!
    final result = await db.query(
      'lancamentos',
      where: 'usuario = ?',
      whereArgs: [usuarioLogado ?? 'desconhecido'],
    );

    print("Dados locais do usuário [$usuarioLogado]: $result");

    return result.map<Lancamento>((json) {
      return Lancamento(
        id: json['id'] as int?,
        item: json['item'] as String,
        valor: (json['valor'] as num).toDouble(),
        isEntrada: (json['isEntrada'] as int) == 1,
      );
    }).toList();
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'lancamentos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}