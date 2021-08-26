import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:train_map/dao/RailwayDao.dart';
import 'package:train_map/model/CompLineModel.dart';
import 'package:train_map/model/GeoJsonModel.dart';

class RailwayBloc {
  final _dao = RailwayDao();
  final _compLineController = BehaviorSubject<List<CompLineModel>>();

  Map<String, List<Polyline>> _polylineMap = {};
  final _polylinesController = BehaviorSubject<Map<String, List<Polyline>>>.seeded({});

  RailwayBloc() {
    _compLineController.addStream(_dao.getCompLine());
  }

  Stream<List<Polyline>> get polylines => _polylinesController.stream.transform(
    StreamTransformer.fromHandlers(
      handleData: (data, sink) {
        sink.add(data.values.expand((e) => e).toList());
      }
    )
  );

  Stream<List<CompLineModel>> get compLine => _compLineController.stream;

  Future<void> importRailroadGeojson(Stream<List<int>> geojson) async {
    final content = await utf8.decodeStream(geojson);
    final json = jsonDecode(content);
    final model = GeoJsonModel.fromJson(json);
    await _dao.insert(model);
  }

  void pushId(String id) {
    _dao.getRailway(id).listen((model) {
      _polylineMap[id] = model.lineCoords.map((line) => Polyline(
          points: line.coords,
          strokeWidth: 3,
          borderColor: Colors.black87,
          borderStrokeWidth: 1,
          color: Colors.blueAccent
      )).toList();
      _polylinesController.sink.add(_polylineMap);
    });
  }

  void popId(String id) {
    _polylineMap.remove(id);
    _polylinesController.sink.add(_polylineMap);
  }

  void dispose() {
    _compLineController.close();
    _polylinesController.close();
  }
}