import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editCategoriesPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/firebaseAuthGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/selectCategoryImage.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:budget/colors.dart';
import 'package:math_expressions/math_expressions.dart';

class SharedCategoryPage extends StatefulWidget {
  SharedCategoryPage({
    Key? key,
    required this.category,
  }) : super(key: key);

  final TransactionCategory category;

  @override
  _SharedCategoryPageState createState() => _SharedCategoryPageState();
}

class _SharedCategoryPageState extends State<SharedCategoryPage> {
  List<String> members = [];
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      dynamic response =
          await getMembersFromCategory(widget.category.sharedKey!);
      if (response == null) {
        Navigator.pop(context);
        openSnackbar(SnackbarMessage(title: "Connection error"));
        return;
      }
      print(FirebaseAuth.instance.currentUser!.email);
      print(widget.category.sharedOwnerMember);
      setState(() {
        members = List<String>.from(response);
        isLoaded = true;
      });
    });
  }

  addMember(String member,
      {bool updateEntry = false, String originalMember = ""}) async {
    member = member.replaceAll(' ', '');
    if (members.contains(member)) {
      openSnackbar(
        SnackbarMessage(
          icon: Icons.warning_rounded,
          title: "User already exists",
        ),
      );
      return;
    }
    if (!member.contains("@") || !member.contains(".com")) {
      openSnackbar(
        SnackbarMessage(
          icon: Icons.warning_rounded,
          title: "Email only",
          description: "Please ensure a valid email is entered.",
        ),
      );
    }
    if (updateEntry) {
      await removeMemberFromCategory(
          widget.category.sharedKey!, originalMember);
      await addMemberToCategory(widget.category.sharedKey!, member);
      setState(() {
        int index = members.indexOf(originalMember);
        members.removeAt(index);
        members.add(member);
      });
    } else {
      await addMemberToCategory(widget.category.sharedKey!, member);
      setState(() {
        members.add(member);
      });
    }
  }

  removeMember(String member) async {
    await removeMemberFromCategory(widget.category.sharedKey!, member);
    setState(() {
      int index = members.indexOf(member);
      members.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      dragDownToDismiss: true,
      title: widget.category.name,
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: TextFont(
          text: "Edit shared properties",
          textAlign: TextAlign.left,
          fontSize: 15,
        ),
      ),
      subtitleAlignment: Alignment.bottomLeft,
      listWidgets: [
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFont(
            text: "Shared Category Members",
            textColor: Theme.of(context).colorScheme.textLight,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 10),
        !isLoaded
            ? Padding(
                padding: const EdgeInsets.only(
                  top: 28.0,
                  bottom: 10,
                ),
                child: Center(child: CircularProgressIndicator()),
              )
            : SizedBox.shrink(),
        ...[
          for (String member in members)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CategoryMemberContainer(
                member: member,
                setMember: (text) async {
                  addMember(text, updateEntry: true, originalMember: member);
                },
                onDelete: () {
                  removeMember(member);
                },
                isOwner: widget.category.sharedOwnerMember ==
                    CategoryOwnerMember.owner,
              ),
            ),
        ],
        widget.category.sharedOwnerMember == CategoryOwnerMember.owner
            ? AddButton(onTap: () {
                openBottomSheet(
                  context,
                  PopupFramework(
                    title: "Add Member",
                    subtitle: "Enter the email of the member",
                    child: SelectText(
                      setSelectedText: (_) {},
                      placeholder: "example@example.com",
                      nextWithInput: (text) async {
                        addMember(text);
                      },
                    ),
                  ),
                );
              })
            : SizedBox.shrink(),
        SizedBox(height: 20),
        widget.category.sharedOwnerMember == CategoryOwnerMember.owner
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Button(
                  label: "Stop Sharing",
                  onTap: () async {
                    bool status =
                        await removedSharedFromCategory(widget.category);
                    if (status == false) {
                      openSnackbar(
                        SnackbarMessage(
                          icon: Icons.warning_rounded,
                          description:
                              "There was a problem removing the shared category from the server. Please Try again later.",
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context);
                  },
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  textColor: Theme.of(context).colorScheme.errorContainer,
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Button(
                  label: "Leave Shared Group",
                  onTap: () async {
                    bool status =
                        await removedSharedFromCategory(widget.category);
                    if (status == false) {
                      openSnackbar(
                        SnackbarMessage(
                          icon: Icons.warning_rounded,
                          description:
                              "There was a problem removing the shared category from the server. Please Try again later.",
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context);
                  },
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  textColor: Theme.of(context).colorScheme.errorContainer,
                ),
              ),
      ],
    );
  }
}

class CategoryMemberContainer extends StatelessWidget {
  const CategoryMemberContainer({
    Key? key,
    required this.member,
    required this.setMember,
    required this.onDelete,
    required this.isOwner,
  }) : super(key: key);

  final String member;
  final Function(String) setMember;
  final VoidCallback onDelete;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Tappable(
        onTap: () {
          openBottomSheet(
            context,
            PopupFramework(
              title: "Edit Member",
              subtitle: "Edit the email of the member",
              child: SelectText(
                setSelectedText: (_) {},
                nextWithInput: (text) {
                  setMember(text);
                },
                selectedText: member,
                placeholder: "example@gmail.com",
              ),
            ),
          );
        },
        borderRadius: 15,
        color: Theme.of(context).colorScheme.lightDarkAccent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                child: TextFont(
                  text: member,
                  fontSize: 18,
                ),
              ),
            ),
            isOwner
                ? Tappable(
                    onTap: () async {
                      await openPopup(
                        context,
                        title: "Remove Member?",
                        description:
                            "The transactions this user has downloaded will still be available to them",
                        icon: Icons.delete_rounded,
                        onSubmitLabel: "Remove",
                        onSubmit: () {
                          Navigator.pop(context);
                          onDelete();
                        },
                        onCancelLabel: "Cancel",
                        onCancel: () {
                          Navigator.pop(context);
                        },
                      );
                    },
                    borderRadius: 15,
                    color: Theme.of(context).colorScheme.lightDarkAccent,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Icon(
                        Icons.close_rounded,
                        size: 25,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
