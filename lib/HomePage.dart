import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:train_map/RailwayBloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'model/CompLineModel.dart';

class SelectableTile extends StatefulWidget {
  final Widget title;
  final Function(bool) onTap;

  SelectableTile({required this.title, required this.onTap});

  @override
  _SelectableTileState createState() => _SelectableTileState();
}

class _SelectableTileState extends State<SelectableTile> {
  bool selected = false;

  @override
  Widget build(BuildContext context) =>
      ListTile(
        title: widget.title,
        selected: selected,
        onTap: () {
          setState(() {
            selected = !selected;
            widget.onTap(selected);
          });
        },
      );
}

class RailwayPanel extends StatefulWidget {
  final List<CompLineModel> railways;

  RailwayPanel(this.railways);

  @override
  _RailwayPanelState createState() => _RailwayPanelState();
}

class _RailwayPanelState extends State<RailwayPanel> {
  late List<CompLineModel> railways;

  @override
  void initState() {
    super.initState();
    railways = widget.railways;
  }

  @override
  Widget build(BuildContext context) =>
      ExpansionPanelList(
        expandedHeaderPadding: EdgeInsets.zero,
        expansionCallback: (index, _) {
          setState(() {
            railways[index].isExpanded = !railways[index].isExpanded;
          });
        },
        children:
          railways.map((railway) =>
              ExpansionPanel(
                headerBuilder: (_, isExpanded) => Text(railway.comp),
                body: ListBody(
                  children: railway.lines.map((line) =>
                      SelectableTile(
                        title: Text(line),
                        onTap: (selected) {
                          final id = railway.comp + "/" + line;
                          if (selected) {
                            Provider.of<RailwayBloc>(context, listen: false).pushId(id);
                          } else {
                            Provider.of<RailwayBloc>(context, listen: false).popId(id);
                          }
                        },
                      )
                  ).toList(),
                ),
                isExpanded: railway.isExpanded,
              )
          ).toList(),
      );
}

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
              PopupMenuButton(
                onSelected: (value) async {
                  final result = await FilePicker.platform.pickFiles(
                    allowMultiple: false,
                    withData: false,
                    withReadStream: true,
                  );

                  if (result != null && result.files.first.readStream != null) {
                    if (value == "railroad") {
                      Provider.of<RailwayBloc>(context, listen: false).importRailroadGeojson(result.files.first.readStream!);
                    }
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    child: Text("import railroad geojson"),
                    value: "railroad",
                  ),
                  PopupMenuItem(
                    child: Text("import station geojson"),
                    value: "station",
                  )
                ],
              )
            ],
          ),
          drawer: Drawer(
            child: ListView(
              children: [
                DrawerHeader(
                  child: Text('ヘッダー'),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                ),
                StreamBuilder(
                  stream: Provider.of<RailwayBloc>(context).getCompLine(),
                  builder: (_, AsyncSnapshot<List<CompLineModel>> snapshot) =>
                    snapshot.data == null ? Text("") : RailwayPanel(snapshot.data!),
                )
             ],
            ),
          ),
          body: FlutterMap(
            options: MapOptions(
              center: LatLng(35.6814245, 139.7668958),
              zoom: 13.0
            ),
            layers: [
              TileLayerOptions(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c']
              ),
              PolylineLayerOptions(
                polylines: Provider.of<RailwayBloc>(context, listen: false).polylines,
                rebuild: Provider.of<RailwayBloc>(context).polylineNotify,
              )
            ],
          ),
        ),
    );
}
