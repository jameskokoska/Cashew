import 'package:budget/database/tables.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/defaultCategories.dart';
import 'package:budget/widgets/fab.dart';
import 'package:flutter/material.dart';
import './pages/homePage.dart';
import 'package:budget/colors.dart';

void main() async {
  database = await FinanceDatabase();
  runApp(MyApp());
}

Future initialize() async {
  //Initialize default categories
  for (var category in defaultCategories()) {
    await database.createOrUpdateCategory(category);
  }
  return true;
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initialize(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
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
                  ),
                ),
              ),
            );
          } else {
            return Container();
          }
        });
  }
}
