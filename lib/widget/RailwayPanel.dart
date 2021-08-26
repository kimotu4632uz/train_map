import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:train_map/model/CompLineModel.dart';
import 'package:train_map/RailwayBloc.dart';

class SelectionTile extends StatefulWidget {
  final Widget title;
  final Function(bool) onTap;
  final bool initialState;

  SelectionTile({required this.title, required this.onTap, required this.initialState});

  @override
  _SelectionTileState createState() => _SelectionTileState();
}

class _SelectionTileState extends State<SelectionTile> {
  bool selected = false;

  @override
  void initState() {
    selected = widget.initialState;
  }

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
    ListView(
      children: [
        ExpansionTile(
          title: Text("hello"),
          children: [
            Text("world")
          ],
        )
      ],
    );
}
