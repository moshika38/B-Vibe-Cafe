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
      version: 9,
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
          await db.execute(
            'ALTER TABLE items ADD COLUMN categoryId TEXT NOT NULL DEFAULT ""',
          );
        }

        if (oldVersion < 6) {
          await db.execute('''
CREATE TABLE IF NOT EXISTS receipts (
  receipt_id TEXT PRIMARY KEY,
  receipt_date_time TEXT NOT NULL,
  payment_status INTEGER NOT NULL,
  payment_date TEXT NOT NULL,
  payment_time TEXT NOT NULL,
  payment_method TEXT NOT NULL,
  total_amount TEXT NOT NULL,
  paid_amount TEXT NOT NULL,
  balance_amount TEXT NOT NULL,
  items TEXT NOT NULL
)
''');
        }

        if (oldVersion < 7) {
          await db.execute('''
CREATE TABLE IF NOT EXISTS receipts (
  receipt_id TEXT PRIMARY KEY,
  receipt_date_time TEXT NOT NULL,
  payment_status INTEGER NOT NULL,
  payment_date TEXT NOT NULL,
  payment_time TEXT NOT NULL,
  payment_method TEXT NOT NULL,
  total_amount TEXT NOT NULL,
  paid_amount TEXT NOT NULL,
  balance_amount TEXT NOT NULL,
  items TEXT NOT NULL
)
''');
        }

        if (oldVersion < 8) {
          await db.execute('''
CREATE TABLE IF NOT EXISTS invoice_settings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  businessName TEXT NOT NULL,
  businessAddress TEXT NOT NULL,
  businessNumber TEXT NOT NULL,
  businessLogo TEXT NOT NULL,
  thankYouText TEXT NOT NULL
)
''');
        }

        if (oldVersion < 9) {
          await db.execute(
            'ALTER TABLE receipts ADD COLUMN order_type TEXT NOT NULL DEFAULT "Dine-In"',
          );
        }
      },
    );
  }

  Future _createDB(Database db, int version) async {
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
  imagePath $textType,
  isRetail $textType
)
''');

    // ── Table: Receipts ──
    await db.execute('''
CREATE TABLE IF NOT EXISTS receipts (
  receipt_id $idTypeText,
  receipt_date_time $textType,
  payment_status $intType,
  payment_date $textType,
  payment_time $textType,
  payment_method $textType,
  total_amount $textType,
  paid_amount $textType,
  balance_amount $textType,
  items $textType,
  order_type $textType
)
''');

    // ── Table: Invoice Settings ──
    await db.execute('''
CREATE TABLE IF NOT EXISTS invoice_settings (
  id $idTypeInt,
  businessName $textType,
  businessAddress $textType,
  businessNumber $textType,
  businessLogo $textType,
  thankYouText $textType
)
''');
  }

  Future<void> initializeAppDatabase() async {
    final db = await instance.database;
    final result = await db.query('users');

    if (result.isEmpty) {
      await db.insert('users', {'username': 'user', 'password': '1234'});
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
