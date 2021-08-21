import 'package:latlong2/latlong.dart';
import 'RailwayModel.dart';

class Feature {
  String comp;
  String line;
  List<LineString> lineCoords;

  Feature({required this.comp, required this.line, required this.lineCoords});

  factory Feature.fromJson(Map<String, dynamic> json) =>
    Feature(
      comp: json["properties"]["運営会社"],
      line: json["properties"]["路線名"],
      lineCoords: (json["geometry"]["type"] == "LineString" ? [json["geometry"]["coordinates"]] :json["geometry"]["coordinates"]).map((e) =>
        LineString(coords: e
            .map((f) => LatLng(f[1] as double, f[0] as double))
            .toList().cast<LatLng>())
        ).toList().cast<LineString>()
    );

  Map<String, String> toMap() => {
    "comp": comp,
    "line": line,
    "line_coords": lineCoords.map((e) => e.toString()).join('/')
  };
}

class GeoJsonModel {
  List<Feature> features;

  GeoJsonModel({required this.features});

  factory GeoJsonModel.fromJson(Map<String, dynamic> json) {
    return GeoJsonModel(
        features: json["features"].map((e) => Feature.fromJson(e)).toList().cast<Feature>()
    );
  }

  List<Map<String, String>> toMapList() =>
    features.map((e) => e.toMap()).toList();
}
