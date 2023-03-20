import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

class DebugPage extends StatelessWidget {
  const DebugPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return PageFramework(
      dragDownToDismiss: true,
      title: "Debug",
      navbar: true,
      appBarBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBarBackgroundColorStart: Theme.of(context).colorScheme.background,
      listWidgets: [
        Button(
            label: "TAPME",
            onTap: () {
              openSnackbar(
                SnackbarMessage(
                  title:
                      '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}.${DateTime.now().millisecond}',
                  icon: Icons.time_to_leave,
                  timeout: Duration(milliseconds: 1000),
                ),
              );
              openSnackbar(
                SnackbarMessage(
                  title: "Test",
                  description:
                      '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}.${DateTime.now().millisecond}',
                  icon: Icons.abc,
                  timeout: Duration(milliseconds: 1000),
                  onTap: () {},
                ),
              );
              openSnackbar(
                SnackbarMessage(
                  title:
                      '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}.${DateTime.now().millisecond}',
                  timeout: Duration(milliseconds: 1000),
                ),
              );
              openSnackbar(
                SnackbarMessage(
                  title:
                      '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}.${DateTime.now().millisecond}',
                  description: "Some description",
                  timeout: Duration(milliseconds: 7000),
                ),
              );
              openSnackbar(
                SnackbarMessage(
                  title:
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation',
                  timeout: Duration(milliseconds: 10000),
                ),
              );
            }),
        TextFont(
            maxLines: 10,
            text: kIsWeb
                ? html.window.navigator.userAgent.toString().toLowerCase()
                : ""),
        ColorBox(color: Theme.of(context).colorScheme.surface, name: "surface"),
        ColorBox(
            color: Theme.of(context).colorScheme.onSurface, name: "onSurface"),
        ColorBox(
            color: Theme.of(context).colorScheme.background,
            name: "background"),
        ColorBox(
            color: Theme.of(context).colorScheme.onBackground,
            name: "onBackground"),
        Container(
          margin: EdgeInsets.all(10),
          height: 1,
          color: Colors.grey,
        ),
        ColorBox(color: Theme.of(context).colorScheme.primary, name: "primary"),
        ColorBox(
            color: Theme.of(context).colorScheme.onPrimary, name: "onPrimary"),
        ColorBox(
            color: Theme.of(context).colorScheme.primaryContainer,
            name: "primaryContainer"),
        ColorBox(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            name: "onPrimaryContainer"),
        Container(
          margin: EdgeInsets.all(10),
          height: 1,
          color: Colors.grey,
        ),
        ColorBox(
            color: Theme.of(context).colorScheme.secondary, name: "secondary"),
        ColorBox(
            color: Theme.of(context).colorScheme.onSecondary,
            name: "onSecondary"),
        ColorBox(
            color: Theme.of(context).colorScheme.secondaryContainer,
            name: "secondaryContainer"),
        ColorBox(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            name: "onSecondaryContainer"),
        Container(
          margin: EdgeInsets.all(10),
          height: 1,
          color: Colors.grey,
        ),
        ColorBox(
            color: Theme.of(context).colorScheme.tertiary, name: "tertiary"),
        ColorBox(
            color: Theme.of(context).colorScheme.onTertiary,
            name: "onTertiary"),
        ColorBox(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            name: "tertiaryContainer"),
        ColorBox(
            color: Theme.of(context).colorScheme.onTertiaryContainer,
            name: "onTertiaryContainer"),
        Container(
          margin: EdgeInsets.all(10),
          height: 1,
          color: Colors.grey,
        ),
        ColorBox(color: Theme.of(context).colorScheme.error, name: "error"),
        ColorBox(color: Theme.of(context).colorScheme.onError, name: "onError"),
        ColorBox(
            color: Theme.of(context).colorScheme.errorContainer,
            name: "errorContainer"),
        ColorBox(
            color: Theme.of(context).colorScheme.onErrorContainer,
            name: "onErrorContainer"),
      ],
    );
  }
}

class ColorBox extends StatelessWidget {
  const ColorBox({Key? key, required this.color, required this.name})
      : super(key: key);

  final Color color;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Container(width: 20),
          Container(width: 50, height: 50, color: color),
          Container(width: 20),
          TextFont(text: name)
        ],
      ),
    );
  }
}
