import 'package:train_map/db_provider.dart';
import 'package:train_map/model/railway_info_model.dart';

class LineDao {
  final _dbProvider = DBProvider.dbProvider;
  final _table = "line";

  Future<void> insert(RailwayInfoModel model) async {
    final db = await _dbProvider.database;
    for (final map in model.toLinesMap()) {
      await db.insert(_table, map);
    }
  }

  Future<Line> get(String id) async {
    final db = await _dbProvider.database;
    final data = await db.query(
      _table,
      where: 'comp = ? and name = ?',
      whereArgs: id.split('/')
    );
    return Line.fromMap(data.first);
  }

  Future<List<Line>> getAll(String comp) async {
    final db = await _dbProvider.database;
    final data = await db.query(
      _table,
      where: "comp = ?",
      whereArgs: [comp]
    );
    return data.map((e) => Line.fromMap(e)).toList();
  }

  Future<void> updateIndex(String comp, List<String> items) async {
    final db = await _dbProvider.database;
    items.asMap().forEach((i, e) async {
      await db.update(
        _table,
        {"index": i},
        where: "comp = ? and name = ?",
        whereArgs: [comp, e],
      );
    });
  }
}