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

class RailwayModel {
  String id;
  List<LineString> lineCoords;
  List<Station>? stationCoords;

  RailwayModel({required this.id, required this.lineCoords, required this.stationCoords});

  factory RailwayModel.fromMap(Map<String, String> json) => RailwayModel(
    id: json["id"] ?? "",
    lineCoords: (json["line_coords"] ?? "").split("/").map((e) => LineString.fromString(e)).toList(),
//    stationCoords: (json["station_coords"] ?? "").split("/").map((e) => Station.fromString(e)).toList(),
    stationCoords: null
  );
}
