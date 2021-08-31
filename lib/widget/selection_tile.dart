import 'package:flutter/material.dart';

class SelectionTile extends StatefulWidget {
  final Widget title;
  final Function(bool) onTap;
  final bool initialState;

  SelectionTile({required this.title, required this.onTap, required this.initialState});

  @override
  _SelectionTileState createState() => _SelectionTileState();
}

class _SelectionTileState extends State<SelectionTile> {
  bool _selected = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialState;
  }

  @override
  void didUpdateWidget(covariant SelectionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selected = widget.initialState;
  }

  @override
  Widget build(BuildContext context) =>
      ListTile(
        title: widget.title,
        selected: _selected,
        onTap: () {
          setState(() {
            _selected = !_selected;
            widget.onTap(_selected);
          });
        },
      );
}
