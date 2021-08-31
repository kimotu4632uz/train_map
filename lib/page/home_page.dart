import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:flutter_map/flutter_map.dart";
import "package:latlong2/latlong.dart";
import 'package:tuple/tuple.dart';
import 'package:collection/collection.dart';

import "package:train_map/railway_bloc.dart";
import "package:train_map/widget/popup_option_menu.dart";
import "package:train_map/widget/railway_selection_drawer.dart";

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
    Scaffold(
      appBar: AppBar(
        title: Text("train map"),
        actions: [
          PopupOptionMenu(),
       ],
      ),
      drawer: Drawer(
        child: RailwaySelectionDrawer()
      ),
      body: StreamBuilder(
        stream: Provider.of<RailwayBloc>(context).geometry,
        builder: (_, AsyncSnapshot<Tuple2<DisplayGeometry, List<Marker>>> snapshot) {
          return FlutterMap(
            options: MapOptions(
                center: LatLng(35.6814245, 139.7668958),
                zoom: 13.0,
                enableMultiFingerGestureRace: true,
                interactiveFlags: InteractiveFlag.drag | InteractiveFlag
                    .rotate | InteractiveFlag.pinchZoom | InteractiveFlag
                    .pinchMove | InteractiveFlag.flingAnimation,
                plugins: []
            ),
            layers: [
              TileLayerOptions(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ["a", "b", "c"]
              ),
              PolylineLayerOptions(
                polylines: snapshot.data?.item1.lines ?? [],
//                polylineCulling: true,
              ),
              MarkerLayerOptions(
                markers: [snapshot.data?.item1.points ?? [], snapshot.data?.item2 ?? []].flattened.toList(),
              ),
            ],
          );

        }
      ),
    );
}
