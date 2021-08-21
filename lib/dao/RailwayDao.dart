import 'package:train_map/model/RailwayModel.dart';

import '../db_provider.dart';
import '../model/CompLineModel.dart';
import '../model/GeoJsonModel.dart';

class RailwayDao {
  final dbProvider = DBProvider.dbProvider;
  final table = "railway";

  Future<void> insert(GeoJsonModel model) async {
    final db = await dbProvider.database;
    for (Map<String, String> feature in model.toMapList()) {
      feature["id"] = '${feature["comp"]}/${feature["line"]}';
      await db.insert(table, feature);
    }
  }

  Stream<RailwayModel> getRailway(String id) async* {
    final db = await dbProvider.database;
    final result = await db.query(
      table,
      distinct: true,
      columns: ['id', 'line_coords', 'station_coords'],
      where: 'id = ?',
      whereArgs: [id]
    );

    yield RailwayModel.fromMap(result.first.map((key, value) => MapEntry(key, value.toString())));
  }

  Stream<List<CompLineModel>> getCompLine() async* {
    final db = await dbProvider.database;
    final comps = await db.query(
      table,
      distinct: true,
      columns: ['comp'],
    );

    List<CompLineModel> result = [];
    for (final comp in comps) {
      final key = comp["comp"].toString();
      final lines = await db.query(
        table,
        columns: ['comp', 'line'],
        where: 'comp = ?',
        whereArgs: [key],
      );
      result.add(
        CompLineModel.fromMapList(
          lines.map((e) =>
            e.map((key, value) => MapEntry(key, value.toString()))
          ).toList()
        )
      );
    }

    yield result;
  }
}
