import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:budget/colors.dart';
import 'package:budget/database/binary_string_conversion.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/editCategoriesPage.dart';
import 'package:budget/pages/editWalletsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/selectCategoryImage.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:budget/main.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import '../functions.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: OnBoardingPageBody());
  }
}

class OnBoardingPageBody extends StatefulWidget {
  const OnBoardingPageBody({Key? key}) : super(key: key);

  @override
  State<OnBoardingPageBody> createState() => OnBoardingPageBodyState();
}

class OnBoardingPageBodyState extends State<OnBoardingPageBody> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();
    final amountOfPages = 3;

    return Stack(
      children: [
        PageView(
          onPageChanged: (value) {
            setState(() {
              currentIndex = value;
            });
            print(currentIndex);
          },
          controller: controller,
          children: const <Widget>[
            OnBoardPage(),
            Center(
              child: Text('First Page'),
            ),
            Center(
              child: Text('Second Page'),
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 15,
            ),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedOpacity(
                    opacity: currentIndex <= 0 ? 0 : 1,
                    duration: Duration(milliseconds: 300),
                    child: ButtonIcon(
                      onTap: () {
                        controller.previousPage(
                          duration: Duration(milliseconds: 1500),
                          curve: ElasticOutCurve(0.9),
                        );
                      },
                      icon: Icons.arrow_back_rounded,
                      size: 45,
                    ),
                  ),
                  ButtonIcon(
                    onTap: () {
                      controller.nextPage(
                        duration: Duration(milliseconds: 1500),
                        curve: ElasticOutCurve(0.9),
                      );
                      if (currentIndex + 1 == amountOfPages) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PageNavigationFramework(
                              key: pageNavigationFrameworkKey,
                            ),
                          ),
                        );
                      }
                    },
                    icon: Icons.arrow_forward_rounded,
                    size: 45,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OnBoardPage extends StatelessWidget {
  const OnBoardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        IntrinsicWidth(
          child: Button(
            label: "Launch App!",
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PageNavigationFramework(
                    key: pageNavigationFrameworkKey,
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
