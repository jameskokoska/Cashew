import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/widgets/fab.dart';
import 'package:flutter/material.dart';
import './pages/homePage.dart';
import 'package:budget/colors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Avenir',
        buttonColor: Theme.of(context).colorScheme.accentColor,
        primaryColor: Colors.white,
        accentColor: Theme.of(context).colorScheme.accentColor,
        primaryColorDark: Colors.grey[200],
        primaryColorLight: Colors.grey[100],
        primaryColorBrightness: Brightness.light,
        brightness: Brightness.light,
        canvasColor: Colors.grey[100],
        appBarTheme: AppBarTheme(brightness: Brightness.light),
      ),
      darkTheme: ThemeData(
        fontFamily: 'Avenir',
        buttonColor: Theme.of(context).colorScheme.accentColor,
        primaryColor: Colors.black,
        accentColor: Theme.of(context).colorScheme.accentColor,
        primaryColorDark: Colors.grey[800],
        primaryColorBrightness: Brightness.dark,
        primaryColorLight: Colors.grey[850],
        brightness: Brightness.dark,
        indicatorColor: Colors.white,
        canvasColor: Colors.black,
        appBarTheme: AppBarTheme(brightness: Brightness.dark),
      ),
      themeMode: ThemeMode.system,
      home: Scaffold(
        body: MyHomePage(
          title: "test",
        ),
        floatingActionButton: FAB(
            openPage: AddTransactionPage(
          title: "",
        )),
      ),
    );
  }
}
