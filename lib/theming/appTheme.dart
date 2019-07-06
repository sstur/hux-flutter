import 'package:flutter/material.dart';

final appTheme = ThemeData(
  fontFamily: 'Roboto',
  primaryTextTheme: TextTheme(
    button: TextStyle(color: Colors.white),
  ),
  textTheme: TextTheme(
    title: TextStyle(
      fontFamily: 'RobotoCondensed',
      fontWeight: FontWeight.bold,
      color: Color(0xff000000),
    ),
    body1: TextStyle(fontSize: 18),
  ),
  appBarTheme: AppBarTheme(
    brightness: Brightness.light,
    color: Color(0xffffffff),
    iconTheme: IconThemeData(color: Color(0xff000000)),
    textTheme: TextTheme(
      title: TextStyle(
        fontFamily: 'RobotoCondensed',
        fontWeight: FontWeight.bold,
        fontSize: 24,
        color: Color(0xff000000),
      ),
    ),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Color(0xfff7444e),
    textTheme: ButtonTextTheme.primary,
  ),
);
