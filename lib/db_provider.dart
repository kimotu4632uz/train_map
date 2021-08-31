import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBProvider {
  static final DBProvider dbProvider = DBProvider();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'railway.db');

    return await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE geometry(id TEXT PRIMARY KEY, line_coords TEXT, station_coords TEXT)'
        );
        await db.execute(
          "CREATE TABLE comp(name TEXT PRIMARY KEY, 'index' INT, type TEXT)"
        );
        await db.execute(
          "CREATE TABLE line(name TEXT, comp TEXT, type TEXT, color TEXT, 'index' INT)"
        );
      }
    );
  }

}
