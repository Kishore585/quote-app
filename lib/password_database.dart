import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PasswordDatabase {
  static final PasswordDatabase _instance = PasswordDatabase._internal();
  factory PasswordDatabase() => _instance;

  static Database? _database;

  PasswordDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'passwords.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE passwords (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            account TEXT NOT NULL,
            username TEXT NOT NULL,
            password TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> addPassword(String account, String username, String password) async {
    final db = await database;
    return await db.insert(
      'passwords',
      {
        'account': account,
        'username': username,
        'password': password,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllPasswords() async {
    final db = await database;
    return await db.query('passwords', orderBy: 'id DESC');
  }

  Future<int> updatePassword(int id, String account, String username, String password) async {
    final db = await database;
    return await db.update(
      'passwords',
      {
        'account': account,
        'username': username,
        'password': password,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePassword(int id) async {
    final db = await database;
    return await db.delete(
      'passwords',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
