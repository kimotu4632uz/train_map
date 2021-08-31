import 'package:train_map/db_provider.dart';
import 'package:train_map/model/railway_info_model.dart';

class CompDao {
  final _dbProvider = DBProvider.dbProvider;
  final _table = "comp";

  Future<void> insert(RailwayInfoModel model) async {
    final db = await _dbProvider.database;
    for (final map in model.toCompsMap()) {
      await db.insert(_table, map);
    }
  }

  Future<List<Comp>> getAll() async {
    final db = await _dbProvider.database;
    final data = await db.query(_table);
    return data.map((e) => Comp.fromMap(e)).toList();
  }

  Future<void> updateIndex(List<String> items) async {
    final db = await _dbProvider.database;
    items.asMap().forEach((i, e) async {
      await db.update(
        _table,
        {"index": i},
        where: "name = ?",
        whereArgs: [e]
      );
    });
  }
}