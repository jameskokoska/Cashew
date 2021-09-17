import 'package:budget/widgets/fab.dart';
import 'package:flutter/material.dart';
import './pages/homePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: MyHomePage(
          title: "test",
        ),
        floatingActionButton: FAB(openPage: OpenTestPage()),
      ),
    );
  }
}
