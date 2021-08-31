import 'package:latlong2/latlong.dart';

extension FormatString on LatLng {
  String toFormatedString() => '${this.latitude},${this.longitude}';
}

extension ParseLatLng on String {
  LatLng parseLatLng() => LatLng(double.parse(this.split(',')[0]), double.parse(this.split(',')[1]));
}

class LineString {
  List<LatLng> coords;

  LineString({required this.coords});

  factory LineString.fromString(String str) => LineString(
    coords: str.split(";").map((e) => e.parseLatLng()).toList()
  );

  @override
  String toString() => coords.map((e) => e.toFormatedString()).join(";");
}

class Station {
  LatLng coord;
  String name;

  Station({required this.coord, required this.name});

  factory Station.fromString(String str) => Station(
    coord: str.split(";")[0].parseLatLng(),
    name: str.split(";")[1]
  );

  @override
  String toString() => coord.toFormatedString() + ';' + name;
}

class GeometryModel {
  String id;
  List<LineString>? lineCoords;
  List<Station>? stationCoords;

  GeometryModel({required this.id, this.lineCoords, this.stationCoords});

  factory GeometryModel.fromMap(Map<String, String> map) => GeometryModel(
    id: map["id"]!,
    lineCoords: map["line_coords"]?.split("/").map((e) => LineString.fromString(e)).toList(),
    stationCoords: map["station_coords"]?.split("/").map((e) => Station.fromString(e)).toList(),
  );

  Map<String, String?> toMap() => {
    "id": id,
    "line_coords": lineCoords?.map((e) => e.toString()).join('/'),
    "station_coords": stationCoords?.map((e) => e.toString()).join('/')
  }..removeWhere((_, v) => v == null);
}
