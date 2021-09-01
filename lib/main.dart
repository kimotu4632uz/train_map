import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import "package:provider/provider.dart";

import "package:train_map/railway_bloc.dart";
import 'package:train_map/page/home_page.dart';
import 'package:train_map/page/sort_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final locale = Locale("ja", "JP");

  @override
  Widget build(BuildContext context) =>
    Provider(
      create: (_) => RailwayBloc(),
      dispose: (_, RailwayBloc bloc) => bloc.dispose(),
      builder: (context, _) =>
        MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'train_map',
          routes: {
            '/': (_) => HomePage(),
            '/sort': (_) => SortPage(),
          },
          initialRoute: '/',
          locale: locale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            locale,
          ],
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
        ),
    );
}
