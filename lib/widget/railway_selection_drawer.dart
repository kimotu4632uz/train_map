import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "package:train_map/railway_bloc.dart";
import "package:train_map/widget/selection_tile.dart";
import "package:train_map/widget/checkbox_tIle.dart";

class RailwaySelectionDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      StreamBuilder(
        stream: Provider.of<RailwayBloc>(context).menuData,
        builder: (_, AsyncSnapshot<MenuData> snapshot) =>
          ListView(
            children: makeTileList(snapshot.data, context),
          )
      );

  List<Widget> makeTileList(MenuData? model, BuildContext context) {
    List<Widget> header = [
      DrawerHeader(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.sort, size: 20,),
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (_) =>
                          AlertDialog(
                            title: Text("表示オプション"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: ["新幹線", "JR在来線", "公営鉄道", "民営鉄道", "第三セクター"].map((id) =>
                                  CheckboxTile(
                                    title: id,
                                    init: model?.showType.contains(id) ?? true,
                                    onChanged: (value) {
                                      if (value){
                                        Provider.of<RailwayBloc>(context, listen: false).pushType(id);
                                      } else {
                                        Provider.of<RailwayBloc>(context, listen: false).popType(id);
                                      }
                                    },
                                  )
                              ).toList(),
                            )
                          )
                    );
                  },
                ),
                SizedBox(height: 0, width: 10,),
                Text("フィルター", style: TextStyle(fontSize: 15),)
              ],
            ),
          ],
        ),
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
      ),
    ];

    if (model != null && model.railwayInfo != null) {
      header.addAll(
        model.railwayInfo!.collection
          .where((e) => model.showType.contains(e.comp.type))
          .map((e) =>
            ExpansionTile(
              title: Text(e.comp.name),
              children: e.lines.map((line) =>
                SelectionTile(
                  title: Text(line.name),
                  initialState: model.selected.contains(e.comp.name + "/" + line.name),
                  onTap: (selected) {
                    final id = e.comp.name + "/" + line.name;
                    if (selected) {
                      Provider.of<RailwayBloc>(context, listen: false).pushId(id);
                    } else {
                      Provider.of<RailwayBloc>(context, listen: false).popId(id);
                    }
                  },
                )
              ).toList().cast<Widget>()
            )
          )
      );
    }
    return header;
  }
}