import 'package:flutter/material.dart';
import './scenes/login.dart';
import './theming/appTheme.dart';
import './data_store.dart';

final dataStore = DataStore();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hux',
      theme: appTheme,
      home: LoginScene(dataStore: dataStore),
      debugShowCheckedModeBanner: false,
    );
  }
}
