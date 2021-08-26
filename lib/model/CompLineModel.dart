
class CompLineModel{
  String comp;
  List<String> lines;
  Set<String> selected = {};

  CompLineModel({required this.comp, required this.lines});

  List<Map<String, String>> toMapList() =>
      lines.map((e) => {
        'comp': comp,
        'line': e
      }).toList();

  factory CompLineModel.fromMapList(List<Map<String, String>> map) =>
      CompLineModel(
        comp: map.first["comp"] ?? "",
        lines: map.map((e) => e["line"] ?? "").toList(),
      );
}
