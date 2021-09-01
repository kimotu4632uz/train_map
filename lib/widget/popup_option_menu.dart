import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:train_map/railway_bloc.dart';

class PopupOptionMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
    PopupMenuButton(
      onSelected: (value) async {
        if (value == "sort") {
          await Navigator.pushNamed(context, "/sort");
          return;
        }

        if (value == "about") {
          final packageInfo = await PackageInfo.fromPlatform();
          showAboutDialog(
            context: context,
            applicationName: packageInfo.appName,
            applicationVersion: packageInfo.version,
          );
          return;
        }

        final result = await FilePicker.platform.pickFiles(
          allowMultiple: false,
          withData: false,
          withReadStream: true,
        );

        if (result != null && result.files.first.readStream != null) {
          switch (value) {
            case "railroad":
              await Provider.of<RailwayBloc>(context, listen: false).importGeoJson(result.files.first.readStream!, GeometryType.Railroad);
              showDialog(
                context: context,
                builder: (_) =>
                  AlertDialog(content: Text("Railroad import finished!"))
              );
              break;
            case "station":
              await Provider.of<RailwayBloc>(context, listen: false).importGeoJson(result.files.first.readStream!, GeometryType.Station);
              showDialog(
                  context: context,
                  builder: (_) =>
                      AlertDialog(content: Text("Station import finished!"))
              );
              break;
            case "info":
              await Provider.of<RailwayBloc>(context, listen: false).importCompLine(result.files.first.readStream!);
              showDialog(
                  context: context,
                  builder: (_) =>
                      AlertDialog(content: Text("RailwayInfo import finished!"))
              );
              break;
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
        ),
        PopupMenuItem(
          child: Text("import railway info from json"),
          value: "info",
        ),
        PopupMenuItem(
          child: Text("menu sort"),
          value: "sort",
        ),
        PopupMenuItem(
          child: Text("about this app"),
          value: "about",
        ),
      ],
  );
}