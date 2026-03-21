import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:bvibe/data/model/auth.model.dart';

class AuthHelper {
  static final AuthHelper instance = AuthHelper._init();

  static Database? _database;

  AuthHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('bvibe.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    print('DATABASE LOCATION: $path');

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE users (
  id $idType,
  username $textType,
  password $textType
  )
''');
  }
 
  Future<Map<String, dynamic>?> getUser(String username) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      columns: ['id', 'username', 'password'],
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  Future<int> insertUser(AuthModel user) async {
    final db = await instance.database;

    // delete all user
    await db.delete('users');

    return await db.insert('users', {
      'username': user.userName,
      'password': user.passCode,
    });
  }

  Future<AuthModel?> readAllUsers() async {
    final db = await instance.database;
    final result = await db.query('users', orderBy: 'id ASC', limit: 1);
    
    if (result.isNotEmpty) {
      final map = result.first;
      return AuthModel(
        id: map['id'].toString(),
        userName: map['username'].toString(),
        passCode: map['password'].toString(),
      );
    } else {
      return null;
    }
  }

  Future<int> updateUser(AuthModel user) async {
    final db = await instance.database;
    return db.update(
      'users',
      {
        'username': user.userName,
        'password': user.passCode,
      },
      where: 'id = ?',
      whereArgs: [int.parse(user.id!)],
    );
  }

  Future<int> deleteUser(String id) async {
    final db = await instance.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [int.parse(id)]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
