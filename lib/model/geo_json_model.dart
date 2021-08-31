import 'package:collection/collection.dart';
import 'package:latlong2/latlong.dart';
import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';

import 'package:train_map/model/geometry_model.dart';
import 'package:train_map/util.dart';

extension AsLatLng on GeoPoint {
  LatLng asLatLng() {
    return LatLng(this.latitude, this.longitude);
  }
}

extension AsLineString on GeoJsonLine {
  LineString asLineString() {
    return LineString(coords: this.geoSerie?.geoPoints.map((e) => e.asLatLng()).toList() ?? []);
  }
}

extension AsRailroadGeometry on GeoJsonFeatureCollection {
  List<GeometryModel> asRailroadGeometry() =>
    this.collection.map((f) {
      List<LineString> lines = [];
      if (f.type == GeoJsonFeatureType.line) {
        lines.add((f.geometry as GeoJsonLine).asLineString());
      } else {
        lines = (f.geometry as GeoJsonMultiLine).lines.map((l) => l.asLineString()).toList();
      }

      return GeometryModel(
        id: f.properties!['運営会社'] + '/' + f.properties!['路線名'],
        lineCoords: lines
      );
    }).toList();
}

extension AsStationGeometry on GeoJsonFeatureCollection {
  List<GeometryModel> asStationGeometry() {
    Map<String, List<GeoJsonFeature>> grouped =
      groupBy<GeoJsonFeature, String>(
        this.collection,
        (f) => f.properties!['運営会社'] + '/' + f.properties!['路線名']
      );

    return grouped.mapValue((id, fs) =>
      GeometryModel(
        id: id,
        stationCoords: fs.map((f) => Station(
          name: f.properties!["駅名"],
          coord: (f.geometry as GeoJsonPoint).geoPoint.asLatLng()
        )).toList()
      )
    ).toList();
  }
}
