import 'package:frontend/models/user_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AuthLocal {
  String tableName = "User";

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDb();
    return _database!;
  }

  Future<void> deleteOldDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "auth.db");
    await deleteDatabase(path);
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "auth.db");
    // await deleteDatabase(path);

    return openDatabase(
      path,
      version: 2,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {
          await db.execute('DROP TABLE $tableName ');
          await db.execute('''

CREATE TABLE $tableName(

id TEXT PRIMARY KEY,
email TEXT NOT NULL,
token TEXT NOT NULL,
name TEXT NOT NULL,
createdAt TEXT NOT NULL,
updatedAt TEXT NOT NULL

)
''');
        }
      },
      onCreate: (db, version) {
        return db.execute('''

CREATE TABLE $tableName(

id TEXT PRIMARY KEY,
email TEXT NOT NULL,
token TEXT NOT NULL,
name TEXT NOT NULL,
createdAt TEXT NOT NULL,
updatedAt TEXT NOT NULL

)
''');
      },
    );
  }

  Future<void> insertUser(UserModel userModel) async {
    final db = await database;
    await db.insert(
      tableName,
      userModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUser() async {
    final db = await database;
    final result = await db.query(tableName, limit: 1);
    print(result);
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }
}
