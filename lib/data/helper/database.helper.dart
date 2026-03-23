import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('bvibe.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    print('DATABASE LOCATION: $path');

    return await openDatabase(
      path, 
      version: 5, 
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
CREATE TABLE IF NOT EXISTS categories (
  id TEXT PRIMARY KEY,
  itemName TEXT NOT NULL,
  iconNumber INTEGER NOT NULL
)
''');
        }
        if (oldVersion < 4) {
          await db.execute('''
CREATE TABLE IF NOT EXISTS items (
  id TEXT PRIMARY KEY,
  categoryId TEXT NOT NULL,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  price TEXT NOT NULL,
  cost TEXT NOT NULL,
  imagePath TEXT NOT NULL
)
''');
        }
        if (oldVersion < 5) {
          await db.execute('ALTER TABLE items ADD COLUMN categoryId TEXT NOT NULL DEFAULT ""');
        }
      },
    );
  }

  Future _createDB(Database db, int version) async {
    // Shared Types
    const idTypeInt = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const idTypeText = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    // ── Table: Users ──
    await db.execute('''
CREATE TABLE IF NOT EXISTS users (
  id $idTypeInt,
  username $textType,
  password $textType
)
''');

    // ── Table: Categories ──
    await db.execute('''
CREATE TABLE IF NOT EXISTS categories (
  id $idTypeText,
  itemName $textType,
  iconNumber $intType
)
''');

    // ── Table: Items ──
    await db.execute('''
CREATE TABLE IF NOT EXISTS items (
  id $idTypeText,
  categoryId $textType,
  name $textType,
  description $textType,
  price $textType,
  cost $textType,
  imagePath $textType
)
''');
  }

  Future<void> initializeAppDatabase() async {
    final db = await instance.database;
    final result = await db.query('users');
    if (result.isEmpty) {
      await db.insert('users', {
        'username': 'user',
        'password': '1234',
      });
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
