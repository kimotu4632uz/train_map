import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geojson/geojson.dart';
import 'package:tuple/tuple.dart';
import 'package:collection/collection.dart';

import 'package:train_map/dao/geometry_dao.dart';
import 'package:train_map/dao/comp_dao.dart';
import 'package:train_map/dao/line_dao.dart';
import 'package:train_map/model/railway_info_model.dart';
import 'package:train_map/model/geo_json_model.dart';

enum GeometryType {
  Railroad,
  Station
}

class DisplayGeometry {
  List<Polyline> lines;
  List<Marker> points;

  DisplayGeometry({required this.lines, required this.points});
}

class MenuData {
  RailwayInfoModel? railwayInfo;
  Set<String> showType;
  Set<String> selected;

  MenuData({this.railwayInfo, required this.showType, required this.selected});
}

class RailwayBloc {
  final _geometryDao = GeometryDao();
  final _compDao = CompDao();
  final _lineDao = LineDao();

  final _railwayInfoController = BehaviorSubject<RailwayInfoModel>();

  Set<String> _showTypeSet = {
    "新幹線",
    "JR在来線",
    "公営鉄道",
    "民営鉄道",
    "第三セクター",
  };

  final _showTypeController = BehaviorSubject<Set<String>>.seeded({
    "新幹線",
    "JR在来線",
    "公営鉄道",
    "民営鉄道",
    "第三セクター",
  });

  Map<String, DisplayGeometry> _geometryMap = {};
  final _geometryController = BehaviorSubject<Map<String, DisplayGeometry>>.seeded({});

  Map<String, Marker> _popupMap = {};
  final _popupController = BehaviorSubject<List<Marker>>.seeded([]);

  RailwayBloc() {
    _railwayInfoController.addStream(_genRailwayInfo());
  }

  Stream<RailwayInfoModel> _genRailwayInfo() async* {
    List<CompLineModel> result = [];
    List<Comp> comps = await _compDao.getAll();
    comps.sort((a, b) => a.index.compareTo(b.index));

    for (final comp in comps) {
      List<Line> lines = await _lineDao.getAll(comp.name);
      lines.sort((a, b) => a.index.compareTo(b.index));
      result.add(CompLineModel(comp: comp, lines: lines));
    }

    yield RailwayInfoModel(collection: result);
  }

  Stream<Tuple2<DisplayGeometry, List<Marker>>> get geometry =>
    Rx.combineLatest2(
      _geometryController.stream.transform<DisplayGeometry>(
        StreamTransformer.fromHandlers(
          handleData: (data, sink) {
            sink.add(DisplayGeometry(lines: data.values.map((e) => e.lines).flattened.toList(), points: data.values.map((e) => e.points).flattened.toList()));
          }
        )
      ),
      _popupController.stream,
      (DisplayGeometry a, List<Marker> b) => Tuple2(a, b)
    );

  Stream<RailwayInfoModel> get railwayInfo => _railwayInfoController.stream;
  Stream<Set<String>> get showType => _showTypeController.stream;

  Stream<MenuData> get menuData => Rx.combineLatest2(
    railwayInfo,
    showType,
    (RailwayInfoModel? a, Set<String> b) => MenuData(railwayInfo: a, showType: b, selected: _geometryMap.keys.toSet())
  );

  Future<void> importGeoJson(Stream<List<int>> bytes, GeometryType type) async {
    final content = await utf8.decodeStream(bytes);
    final geojson = await featuresFromGeoJson(content);

    switch (type) {
      case GeometryType.Railroad:
        await _geometryDao.insert(geojson.asRailroadGeometry());
        break;
      case GeometryType.Station:
        await _geometryDao.insert(geojson.asStationGeometry());
        break;
    }
  }

  Future<void> importCompLine(Stream<List<int>> bytes) async {
    final content = await utf8.decodeStream(bytes);
    final json = jsonDecode(content) as List;
    final model = RailwayInfoModel.fromJson(json);
    await _compDao.insert(model);
    await _lineDao.insert(model);
    _railwayInfoController.addStream(_genRailwayInfo());
  }

  Future<void> updateIndex({required String type, String? id, required List<String> items}) async {
    if (type == "comp") {
      await _compDao.updateIndex(items);
    } else {
      if (id != null) {
        await _lineDao.updateIndex(id, items);
      }
    }

    _railwayInfoController.addStream(_genRailwayInfo());
  }

  void pushId(String id) {
    String geoid = id;
    if (id.split("/")[0].endsWith("(新幹線)")) {
      geoid = id.replaceFirst("(新幹線)", "");
    }

    _geometryDao.get(geoid).listen((model) async {
      final lineInfo = await _lineDao.get(id);

      _geometryMap[id] = DisplayGeometry(
          lines: model.lineCoords?.map((line) =>
            Polyline(
              points: line.coords,
              strokeWidth: 3.0,
              borderStrokeWidth: 1.0,
              color: lineInfo.color ?? Colors.blueAccent,
              borderColor: Colors.black87,
            )
          ).toList() ?? [],
        points: model.stationCoords?.map((s) =>
            Marker(
              point: s.coord,
              height: 20.0,
              width: 20.0,
              builder: (context) =>
                GestureDetector(
                  child: Icon(Icons.location_on_rounded),
                  onTap: () {
                    _popupMap[s.name] =
                      Marker(
                        point: LatLng(s.coord.latitude + 0.0005, s.coord.longitude),
                        height: 100,
                        width: 250,
                        builder: (context) =>
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                            child: Card(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(lineInfo.name, style: TextStyle(fontSize: 12),),
                                      Text(s.name, style: TextStyle(fontSize: 15),),
                                    ],
                                  ),
                                  IconButton(
                                    iconSize: 15,
                                    icon: Icon(Icons.close),
                                    onPressed: () {
                                      _popupMap.remove(s.name);
                                      _popupController.sink.add(_popupMap.values.toList());
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                      );
                    _popupController.sink.add(_popupMap.values.toList());
                  },
                )
            )
        ).toList() ?? [],
      );
      _geometryController.sink.add(_geometryMap);
    });
  }

  void popId(String id) {
    _geometryMap.remove(id);
    _geometryController.sink.add(_geometryMap);
  }

  void pushType(String type) {
    _showTypeSet.add(type);
    _showTypeController.sink.add(_showTypeSet);
  }

  void popType(String type) {
    _showTypeSet.remove(type);
    _showTypeController.sink.add(_showTypeSet);
  }

  void dispose() {
    _geometryController.close();
    _railwayInfoController.close();
    _popupController.close();
    _showTypeController.close();
  }
}
