import 'package:bvibe/data/model/auth.model.dart';
import 'package:bvibe/data/helper/database.helper.dart';

class AuthHelper {
  static final AuthHelper instance = AuthHelper._init();

  AuthHelper._init();

  Future<Map<String, dynamic>?> getUser(String username) async {
    final db = await DatabaseHelper.instance.database;
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

  Future<bool> hasUsers() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('users', limit: 1);
    return result.isNotEmpty;
  }

  Future<int> insertUser(AuthModel user) async {
    final db = await DatabaseHelper.instance.database;

    return await db.transaction((txn) async {
      // delete all user
      await txn.delete('users');

      return await txn.insert('users', {
        'username': user.userName,
        'password': user.passCode,
      });
    });
  }

  Future<AuthModel?> readCurrentUserData() async {
    final db = await DatabaseHelper.instance.database;
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
    final db = await DatabaseHelper.instance.database;
    return db.update(
      'users',
      {'username': user.userName, 'password': user.passCode},
      where: 'id = ?',
      whereArgs: [int.parse(user.id!)],
    );
  }

  Future<int> deleteUser(String id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [int.parse(id)],
    );
  }
}
