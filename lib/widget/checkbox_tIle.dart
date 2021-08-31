import "package:flutter/material.dart";

class CheckboxTile extends StatefulWidget {
  final String title;
  final bool init;
  final void Function(bool) onChanged;

  CheckboxTile({required this.title, required this.init, required this.onChanged});

  @override
  _CheckboxTileState createState() => _CheckboxTileState();
}

class _CheckboxTileState extends State<CheckboxTile> {
  bool _state = true;

  @override
  void initState() {
    super.initState();
    _state = widget.init;
  }

  @override
  void didUpdateWidget(covariant CheckboxTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    _state = widget.init;
  }

  @override
  Widget build(BuildContext context) =>
    Row(
      children: [
        Checkbox(
          value: _state,
          onChanged: (value) {
            setState(() {
              _state = value ?? false;
            });
            widget.onChanged(value ?? false);
          },
        ),
        SizedBox(height: 0, width: 10,),
        Text(widget.title, style: TextStyle(fontSize: 15),)
      ],
    );
}

