import 'dart:async';
import 'dart:convert';

import 'package:train_map/dao/RailwayDao.dart';
import 'package:train_map/model/CompLineModel.dart';
import 'package:train_map/model/GeoJsonModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_map/flutter_map.dart';

class RailwayBloc {
  final _dao = RailwayDao();
  final _controller = BehaviorSubject<List<CompLineModel>>();
  List<String> showId = [];
  final _showController = BehaviorSubject<List<String>>.seeded([]);
  final _polylinesController = BehaviorSubject<List<Polyline>>();

  RailwayBloc() {
    _controller.addStream(_dao.getCompLine());
  }

  List<Polyline> get polylines => showId;
  Stream<Null> get polylineNotify => _polylinesController.stream;

  Future<void> importRailroadGeojson(Stream<List<int>> geojson) async {
    final content = await utf8.decodeStream(geojson);
    final json = jsonDecode(content);
    final model = GeoJsonModel.fromJson(json);
    await _dao.insert(model);

  }

  Stream<List<CompLineModel>> getCompLine() {
//    _controller.addStream(_dao.getCompLine());
    return _controller.stream;
  }

  void pushId(String id) {
    showId.add(id);
    _showController.sink.add(showId);
  }

  void popId(String id) {
    showId.remove(id);
    _showController.sink.add(showId);
  }

  void dispose() {
    _controller.close();
    _showController.close();
  }
}