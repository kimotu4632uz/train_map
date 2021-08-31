import 'package:train_map/db_provider.dart';
import 'package:train_map/model/geometry_model.dart';

class GeometryDao {
  final _dbProvider = DBProvider.dbProvider;
  final _table = "geometry";

  Future<void> insert(List<GeometryModel> models) async {
    final db = await _dbProvider.database;
    for (final model in models) {
      final result = await db.query(_table, columns: ['id'], where: 'id = ?', whereArgs: [model.id]);
      if (result.length == 0) {
        await db.insert(_table, model.toMap());
      } else {
        await db.update(_table, model.toMap(), where: 'id = ?', whereArgs: [model.id]);
      }
    }
  }

  Stream<GeometryModel> get(String id) async* {
    final db = await _dbProvider.database;
    final result = await db.query(
      _table,
      distinct: true,
      columns: ['id', 'line_coords', 'station_coords'],
      where: 'id = ?',
      whereArgs: [id]
    );

    yield GeometryModel.fromMap(result.first.map((key, value) => MapEntry(key, value.toString())));
  }
}
