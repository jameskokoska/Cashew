import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class AddTransactionPage extends StatefulWidget {
  AddTransactionPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: Container(),
                backgroundColor: Colors.black,
                floating: false,
                pinned: true,
                expandedHeight: 200.0,
                collapsedHeight: 65,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                  title: TextFont(
                    text: "Add Transaction",
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    TextInput(labelText: "labelText"),
                  ],
                ),
              ),
              SliverFillRemaining()
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Button(
              label: "Select Category",
              width: MediaQuery.of(context).size.width,
              height: 50,
              fractionScaleHeight: 0.93,
              fractionScaleWidth: 0.98,
              onTap: () {
                showMaterialModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  expand: true,
                  context: context,
                  builder: (context) => GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: SingleChildScrollView(
                        controller: ModalScrollController.of(context),
                        child: Column(
                          children: [
                            TextFont(
                              text: "Select Category",
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
