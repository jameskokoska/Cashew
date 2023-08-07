import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/debugPage.dart';
import 'package:budget/pages/onBoardingPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/languageMap.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/showChangelog.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
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
      title: "about".tr(),
      appBarBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBarBackgroundColorStart: Theme.of(context).canvasColor,
      horizontalPadding: getHorizontalPaddingConstrained(context),
      listWidgets: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          child: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              Image(
                image: AssetImage("assets/icon/icon-small.png"),
                height: 70,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Tappable(
                    borderRadius: 15,
                    onLongPress: () {
                      pushRoute(
                        context,
                        DebugPage(),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 10),
                      child: TextFont(
                        text: globalAppName,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        textAlign: TextAlign.center,
                        maxLines: 5,
                      ),
                    ),
                  ),
                  Tappable(
                    borderRadius: 10,
                    onTap: () {
                      showChangelog(context, forceShow: true);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 10),
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
                  ),
                ],
              )
            ],
          ),
        ),
        SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Tappable(
            onTap: () {
              openUrl("https://github.com/jameskokoska/Cashew");
            },
            color: getColor(context, "lightDarkAccent"),
            borderRadius: 15,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.code_rounded),
                      SizedBox(width: 10),
                      TextFont(
                        text: "app-is-open-source"
                            .tr(namedArgs: {"app": globalAppName}),
                        fontSize: 18,
                        textAlign: TextAlign.center,
                        maxLines: 5,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        TranslationsHelp(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Tappable(
            onTap: () {
              openUrl('mailto:dapperappdeveloper@gmail.com');
            },
            color: getColor(context, "lightDarkAccent"),
            borderRadius: 15,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
              child: Column(
                children: [
                  TextFont(
                    text: "lead-developer".tr(),
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
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Tappable(
            onTap: () {},
            color: getColor(context, "lightDarkAccent"),
            borderRadius: 15,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
              child: Column(
                children: [
                  TextFont(
                    text: "database-designer".tr(),
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
                padding: const EdgeInsets.only(left: 15),
                child: Button(
                  label: "view-app-intro".tr(),
                  onTap: () {
                    pushRoute(
                      context,
                      OnBoardingPage(popNavigationWhenDone: true),
                    );
                  },
                  expandedLayout: true,
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Button(
                  label: "view-changelog".tr(),
                  onTap: () {
                    showChangelog(context, forceShow: true);
                  },
                  expandedLayout: true,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          child: Center(
            child: TextFont(
              text: "graphics".tr(),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
              maxLines: 5,
            ),
          ),
        ),
        AboutInfoBox(
          title: "freepik-credit".tr(),
          link: "https://www.flaticon.com/authors/freepik",
        ),
        AboutInfoBox(
          title: "font-awesome-credit".tr(),
          link: "https://fontawesome.com/",
        ),
        AboutInfoBox(
          title: "pch-vector-credit".tr(),
          link: "https://www.freepik.com/author/pch-vector",
        ),
        Container(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          child: Center(
            child: TextFont(
              text: "major-tools".tr(),
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
        SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Button(
                  label: "view-licenses-and-legalese".tr(),
                  color: Theme.of(context).colorScheme.tertiary,
                  textColor: Theme.of(context).colorScheme.onTertiary,
                  expandedLayout: true,
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
                            "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE." +
                                "\n\n" +
                                "exchange-rate-notice-description".tr());
                  },
                ),
              ),
            )
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Button(
                  label: "privacy-policy".tr(),
                  color: Theme.of(context).colorScheme.tertiary,
                  textColor: Theme.of(context).colorScheme.onTertiary,
                  expandedLayout: true,
                  onTap: () {
                    openUrl("http://cashewapp.web.app/policy.html");
                  },
                ),
              ),
            )
          ],
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          child: Center(
            child: TextFont(
              text: "made-in-canada".tr() + " 🍁",
              fontSize: 14,
              textAlign: TextAlign.center,
              maxLines: 5,
            ),
          ),
        ),
        SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          child: Button(
            label: "delete-all-data".tr(),
            onTap: () {
              openPopup(
                context,
                title: "erase-everything".tr(),
                description: "erase-everything-description".tr(),
                icon: Icons.warning_amber_rounded,
                onSubmit: () async {
                  Navigator.pop(context);
                  openPopup(
                    context,
                    title: "erase-everything-warning".tr(),
                    description: "erase-everything-warning-description".tr(),
                    icon: Icons.warning_rounded,
                    onSubmit: () async {
                      Navigator.pop(context);
                      openLoadingPopup(context);
                      await Future.wait([
                        database.deleteEverything(),
                        sharedPreferences.clear()
                      ]);
                      await database.close();
                      Navigator.pop(context);
                      restartApp(context);
                    },
                    onSubmitLabel: "erase".tr(),
                    onCancelLabel: "cancel".tr(),
                    onCancel: () {
                      Navigator.pop(context);
                    },
                  );
                },
                onSubmitLabel: "erase".tr(),
                onCancelLabel: "cancel".tr(),
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
    this.color,
    this.padding,
  }) : super(key: key);

  final String title;
  final String link;
  final Color? color;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Tappable(
        onTap: () async {
          openUrl(link);
        },
        onLongPress: () {
          copyToClipboard(link);
        },
        color: color ?? getColor(context, "lightDarkAccent"),
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

class TranslationsHelp extends StatelessWidget {
  const TranslationsHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Tappable(
        onTap: () {
          openUrl('mailto:dapperappdeveloper@gmail.com');
        },
        color:
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.7),
        borderRadius: 15,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.connect_without_contact_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 31,
                ),
              ),
              Expanded(
                child: TextFont(
                  textColor: Theme.of(context).colorScheme.onSecondaryContainer,
                  richTextSpan: [
                    TextSpan(
                      text: 'dapperappdeveloper@gmail.com',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.solid,
                        decorationColor:
                            getColor(context, "unPaidOverdue").withOpacity(0.8),
                        color:
                            getColor(context, "unPaidOverdue").withOpacity(0.8),
                      ),
                    ),
                  ],
                  text: "translations-help".tr() + " ",
                  maxLines: 5,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
