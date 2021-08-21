import 'package:tuple/tuple.dart';

class CompLineModel{
  bool isExpanded;
  String comp;
  List<String> lines;

  CompLineModel({required this.isExpanded, required this.comp, required this.lines});

  List<Map<String, String>> toMapList() =>
      lines.map((e) => {
        'comp': comp,
        'line': e
      }).toList();

  factory CompLineModel.fromMapList(List<Map<String, String>> map) =>
      CompLineModel(
        isExpanded: false,
        comp: map.first["comp"] ?? "",
        lines: map.map((e) => e["line"] ?? "").toList(),
      );
}
