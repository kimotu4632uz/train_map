import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import 'package:train_map/RailwayBloc.dart';

class PopupOptionMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
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
  );
}