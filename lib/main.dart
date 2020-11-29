import 'package:flutter/material.dart';
import 'package:to_do_list/screens/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'To Do List',
        debugShowCheckedModeBanner: false,
        home: HomePage());
  }
}
