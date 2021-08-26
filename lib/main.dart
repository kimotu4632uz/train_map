import 'package:flutter/material.dart';

import 'package:train_map/HomePage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'train_map',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
}
