import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:train_map/model/CompLineModel.dart';
import 'package:train_map/RailwayBloc.dart';
import 'package:train_map/widget/PopupOptionMenu.dart';
import 'package:train_map/widget/RailwayPanel.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
    Provider(
      create: (_) => RailwayBloc(),
      dispose: (_, RailwayBloc bloc) => bloc.dispose(),
      builder: (context, _) =>
        Scaffold(
          appBar: AppBar(
            title: Text("train map"),
            actions: [
              PopupOptionMenu(),
           ],
          ),
          drawer: Drawer(
            child: StreamBuilder(
              stream: Provider.of<RailwayBloc>(context).compLine,
              builder: (_, AsyncSnapshot<List<CompLineModel>> snapshot) => ListView(
                children: snapshot.data?.map((e) =>
                    ExpansionTile(
                      title: Text(e.comp),
                      children: e.lines.map((line) =>
                          SelectionTile(
                            title: Text(line),
                            initialState: e.selected.contains(e.comp + "/" + line),
                            onTap: (selected) {
                              final id = e.comp + "/" + line;
                              if (selected) {
                                Provider.of<RailwayBloc>(context, listen: false).pushId(id);
                                e.selected.add(id);
                              } else {
                                Provider.of<RailwayBloc>(context, listen: false).popId(id);
                                e.selected.remove(id);
                              }
                            },
                          )
                      ).toList()
                    )
                ).toList() ?? []
//                  DrawerHeader(
//                  child: Text('ヘッダー'),
//              decoration: BoxDecoration(
//                color: Colors.blue,
//              ),
//            ),
              )
            )
          ),
          body: StreamBuilder(
            stream: Provider.of<RailwayBloc>(context).polylines,
            builder: (_, AsyncSnapshot<List<Polyline>> snapshot) => FlutterMap(
              options: MapOptions(
                center: LatLng(35.6814245, 139.7668958),
                zoom: 13.0,
                enableMultiFingerGestureRace: true,
              ),
              layers: [
                TileLayerOptions(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c']
                ),
                PolylineLayerOptions(
                  polylines: snapshot.data ?? [],
                )
              ],
            ),
          ),
        ),
    );
}
