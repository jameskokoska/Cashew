import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/debugPage.dart';
import 'package:budget/pages/onBoardingPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/showChangelog.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String version = packageInfoGlobal.version;
    String buildNumber = packageInfoGlobal.buildNumber;
    return PageFramework(
      dragDownToDismiss: true,
      title: "About",
      navbar: false,
      appBarBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBarBackgroundColorStart: Theme.of(context).canvasColor,
      horizontalPadding: getHorizontalPaddingConstrained(context),
      listWidgets: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 7),
          child: Column(
            children: [
              Tappable(
                onLongPress: () {
                  pushRoute(
                    context,
                    DebugPage(),
                  );
                },
                child: TextFont(
                  text: "Cashew",
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  textAlign: TextAlign.center,
                  maxLines: 5,
                ),
              ),
              SizedBox(height: 5),
              Tappable(
                onTap: () {
                  showChangelog(context, forceShow: true);
                },
                child: TextFont(
                  text: "v" +
                      version +
                      "+" +
                      buildNumber +
                      ", db-v" +
                      schemaVersionGlobal.toString(),
                  fontSize: 14,
                  textAlign: TextAlign.center,
                  maxLines: 5,
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 5),
          child: Tappable(
            onTap: () {},
            color: getColor(context, "lightDarkAccent"),
            borderRadius: 15,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
              child: Column(
                children: [
                  TextFont(
                    text: "Lead Developer",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                    maxLines: 5,
                  ),
                  TextFont(
                    text: "James",
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                    textColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    textAlign: TextAlign.center,
                    maxLines: 5,
                  ),
                  TextFont(
                    text: "dapperappdeveloper@gmail.com",
                    fontSize: 16,
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    textColor: getColor(context, "textLight"),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 5),
          child: Tappable(
            onTap: () {},
            color: getColor(context, "lightDarkAccent"),
            borderRadius: 15,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
              child: Column(
                children: [
                  TextFont(
                    text: "Database Designer",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                    maxLines: 5,
                  ),
                  TextFont(
                    text: "YuYing",
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                    textColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    textAlign: TextAlign.center,
                    maxLines: 5,
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 23),
                child: Button(
                  label: "View App Intro",
                  onTap: () {
                    pushRoute(
                      context,
                      OnBoardingPage(popNavigationWhenDone: true),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 23),
                child: Button(
                  label: "View Changelog",
                  onTap: () {
                    showChangelog(context, forceShow: true);
                  },
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 7),
          child: Center(
            child: TextFont(
              text: "Graphics",
              fontSize: 20,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
              maxLines: 5,
            ),
          ),
        ),
        AboutInfoBox(
          title: "Icons from FlatIcon by FreePik",
          link: "https://www.flaticon.com/",
        ),
        AboutInfoBox(
          title: "Icons from Font Awesome",
          link: "http://fortawesome.github.com/Font-Awesome/",
        ),
        AboutInfoBox(
          title: "Landing graphics by pch-vector",
          link: "https://www.freepik.com/author/pch-vector",
        ),
        Container(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 7),
          child: Center(
            child: TextFont(
              text: "Major Tools",
              fontSize: 20,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
              maxLines: 5,
            ),
          ),
        ),
        AboutInfoBox(
          title: "Flutter",
          link: "https://flutter.dev/",
        ),
        AboutInfoBox(
          title: "Google Cloud APIs",
          link: "https://cloud.google.com/",
        ),
        AboutInfoBox(
          title: "Drift SQL Database",
          link: "https://drift.simonbinder.eu/",
        ),
        AboutInfoBox(
          title: "FL Charts",
          link: "https://github.com/imaNNeoFighT/fl_chart",
        ),
        AboutInfoBox(
          title: "Currency Rates API",
          link: "https://github.com/fawazahmed0/currency-api",
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 7),
          child: Button(
            label: "View Licenses",
            onTap: () {
              showLicensePage(
                  context: context,
                  applicationVersion: "v" +
                      version +
                      "+" +
                      buildNumber +
                      ", db-v" +
                      schemaVersionGlobal.toString(),
                  applicationLegalese:
                      "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.");
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 7),
          child: Center(
            child: TextFont(
              text: "Made in Canada 🍁",
              fontSize: 14,
              textAlign: TextAlign.center,
              maxLines: 5,
            ),
          ),
        ),
        SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 7),
          child: Button(
            label: "Delete All Data",
            onTap: () {
              openPopup(
                context,
                title: "Erase everything?",
                description: "All Google Drive backups will be kept.",
                icon: Icons.warning_amber_rounded,
                onSubmit: () async {
                  Navigator.pop(context);
                  openPopup(
                    context,
                    title: "Are you sure you want to erase everything?",
                    description: "All data and preferences will be deleted!",
                    icon: Icons.warning_rounded,
                    onSubmit: () async {
                      database.deleteEverything();
                      await sharedPreferences.clear();
                      restartApp(context);
                    },
                    onSubmitLabel: "Erase",
                    onCancelLabel: "Cancel",
                    onCancel: () {
                      Navigator.pop(context);
                    },
                  );
                },
                onSubmitLabel: "Erase",
                onCancelLabel: "Cancel",
                onCancel: () {
                  Navigator.pop(context);
                },
              );
            },
            color: Theme.of(context).colorScheme.error,
            textColor: Theme.of(context).colorScheme.onError,
          ),
        ),
      ],
    );
  }
}

class AboutInfoBox extends StatelessWidget {
  const AboutInfoBox({
    Key? key,
    required this.title,
    required this.link,
  }) : super(key: key);

  final String title;
  final String link;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 5),
      child: Tappable(
        onTap: () async {
          openUrl(link);
        },
        color: getColor(context, "lightDarkAccent"),
        borderRadius: 15,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
          child: Column(
            children: [
              TextFont(
                text: title,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
                maxLines: 5,
              ),
              SizedBox(height: 6),
              TextFont(
                text: link,
                fontSize: 14,
                textAlign: TextAlign.center,
                textColor: getColor(context, "textLight"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
