import 'package:animations/animations.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/defaultCategories.dart';
import 'package:budget/widgets/fab.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './pages/homePage.dart';
import 'package:budget/colors.dart';
import 'dart:math';

void main() async {
  database = await constructDb();
  runApp(App());
}

int randomInt = Random().nextInt(100);

Future initialize() async {
  //Initialize default categories
  for (var category in defaultCategories()) {
    await database.createOrUpdateCategory(category);
  }
  return true;
}

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initialize(),
      builder: (context, snapshot) {
        Widget child = Container(
          key: ValueKey(0),
          width: 50,
          height: 50,
          color: Colors.blueGrey,
        );
        if (snapshot.hasData) {
          child = MaterialApp(
            key: ValueKey(1),
            title: 'Budget App',
            theme: ThemeData(
              fontFamily: 'Avenir',
              primaryColor: Colors.white,
              primaryColorDark: Colors.grey[200],
              primaryColorLight: Colors.grey[100],
              primaryColorBrightness: Brightness.light,
              brightness: Brightness.light,
              canvasColor: Colors.grey[100],
              accentColor: Theme.of(context).colorScheme.accentColor,
              appBarTheme:
                  AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light),
            ),
            darkTheme: ThemeData(
              fontFamily: 'Avenir',
              primaryColor: Colors.black,
              primaryColorDark: Colors.grey[800],
              primaryColorBrightness: Brightness.dark,
              primaryColorLight: Colors.grey[850],
              brightness: Brightness.dark,
              indicatorColor: Colors.white,
              canvasColor: Colors.black,
              accentColor: Theme.of(context).colorScheme.accentColor,
              appBarTheme:
                  AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.dark),
            ),
            themeMode: ThemeMode.system,
            home: Scaffold(
              body: MyHomePage(),
              floatingActionButton: Row(
                children: [
                  FAB(
                    openPage: AddTransactionPage(
                      title: "Add Transaction",
                    ),
                  ),
                  FAB(
                    openPage: AddBudgetPage(title: "Add Budget"),
                  ),
                  FAB(
                    openPage: EditBudgetPage(title: "Edit Budgets"),
                  ),
                ],
              ),
            ),
          );
        }
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeScaleTransition(animation: animation, child: child);
          },
          child: child,
        );
      },
    );
  }
}
