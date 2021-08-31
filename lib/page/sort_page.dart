import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "package:train_map/railway_bloc.dart";
import 'package:train_map/model/railway_info_model.dart';
import 'package:train_map/util.dart';

class SortWidget extends StatefulWidget {
  final List<String> items;
  final void Function(List<String>) onApply;

  SortWidget({required this.items, required this.onApply});

  @override
  _SortWidgetState createState() => _SortWidgetState();
}

class _SortWidgetState extends State<SortWidget> {
  List<String> items = [];

  @override
  void initState() {
    super.initState();
    items = widget.items;
  }

  @override
  void didUpdateWidget(covariant SortWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    items = widget.items;
  }

  @override
  Widget build(BuildContext context) =>
    Column(
      children: [
        Expanded(
          child: ReorderableListView(
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final item = items.removeAt(oldIndex);
              setState(() {
                items.insert(newIndex, item);
              });
            },
            children: items.mapEnum((i, e) =>
                ListTile(
                  key: Key(e),
                  title: Text(e),
                  trailing: ReorderableDragStartListener(
                    index: i,
                    child: Icon(Icons.drag_handle_outlined),
                  ),
                )
            ).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: OutlinedButton(
            onPressed: () => widget.onApply(items),
            child: Text("apply"),
          ),
        ),
      ],
    );
}

class ModeSelectWidget extends StatefulWidget {
  @override
  _ModeSelectWidgetState createState() => _ModeSelectWidgetState();
}

class _ModeSelectWidgetState extends State<ModeSelectWidget> {
  String _mode = "comp";
  String? _selectedComp;

  @override
  Widget build(BuildContext context) =>
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownButton(
                value: _mode,
                onChanged: (String? value) {
                  setState(() {
                    _mode = value ?? "comp";
                  });
                },
                items: [
                  DropdownMenuItem(child: Text("comp"), value: "comp"),
                  DropdownMenuItem(child: Text("line"), value: "line"),
                ],
              ),

              if(_mode == "line")
                StreamBuilder(
                  stream: Provider
                      .of<RailwayBloc>(context)
                      .railwayInfo,
                  builder: (_, AsyncSnapshot<RailwayInfoModel> snapshot) =>
                      DropdownButton(
                        value: _selectedComp,
                        onChanged: (String? value) =>
                            setState(() {
                              _selectedComp = value;
                            }),
                        items: snapshot.data?.collection.map((e) =>
                            DropdownMenuItem(
                              child: Text(e.comp.name),
                              value: e.comp.name,
                            )
                        ).toList(),
                      ),
                ),
            ],
          ),
          Expanded(
            child: StreamBuilder(
              stream: Provider.of<RailwayBloc>(context).railwayInfo,
              builder: (context, AsyncSnapshot<RailwayInfoModel> snapshot) {
                if (snapshot.data == null) {
                  return SizedBox();
                } else {
                  List<String> items = [];
                  if (_mode == "comp") {
                    items = snapshot.data?.collection.map((e) => e.comp.name).toList() ?? [];
                  } else {
                    if (_selectedComp != null) {
                      items = snapshot.data?.collection
                          .firstWhere((e) => _selectedComp == e.comp.name)
                          .lines
                          .map((e) => e.name)
                          .toList() ?? [];
                    }
                  }

                  return SortWidget(
                    items: items,
                    onApply: (items) {
                      Provider.of<RailwayBloc>(context, listen: false)
                          .updateIndex(
                            type: _mode,
                            id: _selectedComp,
                            items: items
                          );
                    }
                  );
                }
              }
            ),
          ),
        ],
      );
}

class SortPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
    Scaffold(
      appBar: AppBar(
        title: Text("sort menu"),
      ),
      body: ModeSelectWidget(),
    );
}