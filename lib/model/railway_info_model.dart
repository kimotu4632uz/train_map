import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'package:train_map/util.dart';

class Comp {
  String name;
  String type;
  int index;

  Comp({required this.name, required this.type, required this.index});

  factory Comp.fromMap(Map<String, dynamic> map) => Comp(
    name: map["name"],
    type: map["type"],
    index: map["index"],
  );

  factory Comp.fromJson(Map<String, dynamic> json, int index) => Comp(
    name: json["name"],
    type: json["type"]["name"],
    index: index,
  );
}

class Line {
  String name;
  String type;
  Color? color;
  int index;

  Line({required this.name, required this.type, this.color, required this.index});

  factory Line.fromMap(Map<String, dynamic> map) => Line(
    name: map["name"],
    type: map["type"],
    color: map['color'] != null ? Color(int.parse('ff' + map["color"], radix: 16)) : null,
    index: map["index"],
  );

  factory Line.fromJson(Map<String, dynamic> json, int index) => Line(
    name: json["name"],
    type: json["type"]["name"],
    color: json['color'] != null ? Color(int.parse('ff' + json["color"], radix: 16)) : null,
    index: index,
  );
}

class CompLineModel {
  Comp comp;
  List<Line> lines;

  CompLineModel({required this.comp, required this.lines});

  Map<String, dynamic> toCompMap() => {
    "name": comp.name,
    "type": comp.type,
    "index": comp.index,
  };

  List<Map<String, dynamic>> toLinesMap() =>
    lines.map((line) => {
      "name": line.name,
      "type": line.type,
      "color": line.color?.value.toRadixString(16).substring(2).toLowerCase(),
      "index": line.index,
      "comp": comp.name,
    }).toList();
  
  factory CompLineModel.fromJson(Map<String, dynamic> json, int index) => CompLineModel(
    comp: Comp.fromJson(json["comp"], index),
    lines: (json["lines"] as List).mapEnum((i, line) => Line.fromJson(line, i)).toList().cast(),
  );
}

class RailwayInfoModel {
  List<CompLineModel> collection;

  RailwayInfoModel({required this.collection});

  factory RailwayInfoModel.fromJson(List json) => RailwayInfoModel(
    collection: json.mapEnum((i, e) => CompLineModel.fromJson(e, i)).toList().cast<CompLineModel>()
  );

  List<Map<String, dynamic>> toLinesMap() =>
      collection.map((e) => e.toLinesMap()).flattened.toList();

  List<Map<String, dynamic>> toCompsMap() =>
      collection.map((e) => e.toCompMap()).toList();
}
