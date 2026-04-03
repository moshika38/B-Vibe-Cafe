import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;

    _database = await _initDB('bvibe.db');
    return _database!;
  }

  Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, 'bvibe.db');
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    print('DATABASE LOCATION: $path');

    return await openDatabase(
      path,
      version: 15,
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

        if (oldVersion < 10) {
          // Rename or migrate to business_info
          await db.execute('''
CREATE TABLE IF NOT EXISTS business_info (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  businessName TEXT NOT NULL,
  businessEmail TEXT NOT NULL,
  businessAddress TEXT NOT NULL,
  businessNumber TEXT NOT NULL,
  businessLogo TEXT NOT NULL,
  thankYouText TEXT NOT NULL
)
''');

          // Migration logic from invoice_settings
          try {
            final List<Map<String, dynamic>> oldData =
                await db.query('invoice_settings');
            if (oldData.isNotEmpty) {
              for (var row in oldData) {
                await db.insert('business_info', {
                  'businessName': row['businessName'],
                  'businessEmail': '', // New column
                  'businessAddress': row['businessAddress'],
                  'businessNumber': row['businessNumber'],
                  'businessLogo': row['businessLogo'],
                  'thankYouText': row['thankYouText'],
                });
              }
            }
            await db.execute('DROP TABLE IF EXISTS invoice_settings');
          } catch (e) {
            // If table doesn't exist or migration fails, it's safe to continue
            print("Database migration notice: $e");
          }
        }

        if (oldVersion < 11) {
          try {
            await db.execute(
              'ALTER TABLE receipts ADD COLUMN receipt_create_date TEXT NOT NULL DEFAULT ""',
            );
            await db.execute(
              'ALTER TABLE receipts ADD COLUMN receipt_create_time TEXT NOT NULL DEFAULT ""',
            );

            // Migrate data from receipt_date_time
            final List<Map<String, dynamic>> receipts =
                await db.query('receipts');
            for (var row in receipts) {
              final oldDateTime = row['receipt_date_time'];
              if (oldDateTime != null) {
                await db.update(
                  'receipts',
                  {
                    'receipt_create_date': oldDateTime,
                    'receipt_create_time': oldDateTime,
                  },
                  where: 'receipt_id = ?',
                  whereArgs: [row['receipt_id']],
                );
              }
            }
          } catch (e) {
            print("Database migration version 11 error: $e");
          }
        }

        if (oldVersion < 12) {
          // Recovery: Recreate receipts table if it was manually deleted
          await db.execute('''
CREATE TABLE IF NOT EXISTS receipts (
  receipt_id TEXT PRIMARY KEY,
  receipt_create_date TEXT NOT NULL,
  receipt_create_time TEXT NOT NULL,
  payment_status INTEGER NOT NULL,
  payment_date TEXT NOT NULL,
  payment_time TEXT NOT NULL,
  payment_method TEXT NOT NULL,
  total_amount TEXT NOT NULL,
  paid_amount TEXT NOT NULL,
  balance_amount TEXT NOT NULL,
  items TEXT NOT NULL,
  order_type TEXT NOT NULL DEFAULT "Dine-In"
)
''');
        }
        if (oldVersion < 14) {
          try {
            await db.execute('''
CREATE TABLE IF NOT EXISTS printers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  address TEXT,
  type TEXT,
  isBle INTEGER,
  vendorId TEXT,
  productId TEXT,
  role TEXT UNIQUE
)
''');
          } catch (e) {
            print("Database migration version 14 error: $e");
          }
        }
        if (oldVersion < 15) {
          try {
            await db.execute('''
CREATE TABLE IF NOT EXISTS archive_receipts (
  receipt_id TEXT PRIMARY KEY,
  receipt_create_date TEXT NOT NULL,
  receipt_create_time TEXT NOT NULL,
  payment_status INTEGER NOT NULL,
  payment_date TEXT NOT NULL,
  payment_time TEXT NOT NULL,
  payment_method TEXT NOT NULL,
  total_amount TEXT NOT NULL,
  paid_amount TEXT NOT NULL,
  balance_amount TEXT NOT NULL,
  items TEXT NOT NULL,
  order_type TEXT NOT NULL DEFAULT "Dine-In"
)
''');
          } catch (e) {
            print("Database migration version 15 error: $e");
          }
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
  iconNumber $intType,
  orderIndex $intType DEFAULT 0
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
  receipt_create_date $textType,
  receipt_create_time $textType,
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

    // ── Table: Archive Receipts ──
    await db.execute('''
CREATE TABLE IF NOT EXISTS archive_receipts (
  receipt_id $idTypeText,
  receipt_create_date $textType,
  receipt_create_time $textType,
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

    // ── Table: Printers ──
    await db.execute('''
CREATE TABLE IF NOT EXISTS printers (
  id $idTypeInt,
  name $textType,
  address $textType,
  type $textType,
  isBle $intType,
  vendorId $textType,
  productId $textType,
  role $textType UNIQUE
)
''');

    // ── Table: Business Info ──
    await db.execute('''
CREATE TABLE IF NOT EXISTS business_info (
  id $idTypeInt,
  businessName $textType,
  businessEmail $textType,
  businessAddress $textType,
  businessNumber $textType,
  businessLogo $textType,
  thankYouText $textType
)
''');
  }

  Future<void> initializeAppDatabase() async {
    final db = await instance.database;
    
    // Auto-archive old receipts at startup
    await archiveOldReceipts();

    final result = await db.query('users');

    if (result.isEmpty) {
      await db.insert('users', {'username': 'user', 'password': '1234'});
    }
  }

  Future<void> archiveOldReceipts() async {
    try {
      final db = await instance.database;
      final now = DateTime.now();

      // Calculate cutoff date: 4 months ago
      final cutoff = DateTime(now.year, now.month - 4, now.day);
      final cutoffDate = cutoff.toIso8601String();

      await db.transaction((txn) async {
        // 1. Get old receipts
        final List<Map<String, dynamic>> oldReceipts = await txn.query(
          'receipts',
          where: 'receipt_create_date < ?',
          whereArgs: [cutoffDate],
        );

        if (oldReceipts.isEmpty) return;

        // 2. Move to archive_receipts
        for (var receipt in oldReceipts) {
          await txn.insert(
            'archive_receipts',
            receipt,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        // 3. Delete from original table
        await txn.delete(
          'receipts',
          where: 'receipt_create_date < ?',
          whereArgs: [cutoffDate],
        );
      });
      print("System startup: Auto-archiving completed.");
    } catch (e) {
      print("Error in startup archiveOldReceipts: $e");
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
