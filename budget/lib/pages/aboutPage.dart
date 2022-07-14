import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return PageFramework(
      dragDownToDismiss: true,
      title: "About",
      navbar: true,
      appBarBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBarBackgroundColorStart: Theme.of(context).canvasColor,
      listWidgets: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 7),
          child: Column(
            children: [
              TextFont(
                text: "Budget App",
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
              SizedBox(height: 5),
              TextFont(
                text: "v" +
                    versionGlobal +
                    ", db-v" +
                    schemaVersionGlobal.toString(),
                fontSize: 14,
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 7),
          child: Tappable(
            onTap: () {},
            color: Theme.of(context).colorScheme.lightDarkAccent,
            borderRadius: 15,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
              child: Column(
                children: [
                  TextFont(
                    text: "Lead Developer",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  TextFont(
                    text: "James",
                    fontSize: 33,
                    fontWeight: FontWeight.bold,
                    textColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  TextFont(
                    text: "dapperappdeveloper@gmail.com",
                    fontSize: 17,
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 7),
          child: Tappable(
            onTap: () {},
            color: Theme.of(context).colorScheme.lightDarkAccent,
            borderRadius: 15,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
              child: Column(
                children: [
                  TextFont(
                    text: "Database Designer",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  TextFont(
                    text: "YuYing",
                    fontSize: 33,
                    fontWeight: FontWeight.bold,
                    textColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 7),
          child: Center(
            child: TextFont(
              text: "Major Tools",
              fontSize: 22,
              fontWeight: FontWeight.bold,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 7),
          child: Button(
            label: "View Licenses",
            onTap: () {
              showLicensePage(
                  context: context,
                  applicationVersion: "v" +
                      versionGlobal +
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
              fontSize: 15,
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 7),
      child: Tappable(
        onTap: () async {
          if (await canLaunchUrl(Uri.parse(link)))
            await launchUrl(Uri.parse(link));
        },
        color: Theme.of(context).colorScheme.lightDarkAccent,
        borderRadius: 15,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
          child: Column(
            children: [
              TextFont(
                text: title,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              TextFont(
                text: link,
                fontSize: 13,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
