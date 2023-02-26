// @dart=2.9

import 'package:flutter/material.dart';
import 'package:hackathon/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          colorScheme: const ColorScheme(
              brightness: Brightness.dark,
              primary: Colors.black,
              onPrimary: Colors.white,
              secondary: Colors.amber,
              onSecondary: Colors.blue,
              error: Colors.red,
              onError: Colors.white,
              background: Colors.black,
              onBackground: Colors.white,
              surface: Colors.black,
              onSurface: Colors.white)),
      home: const Home(),
    );
  }
}
