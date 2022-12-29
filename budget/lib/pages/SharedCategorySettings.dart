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

class SharedCategorySettings extends StatefulWidget {
  SharedCategorySettings({
    Key? key,
    required this.category,
    required this.setSelectedMembers,
  }) : super(key: key);

  final TransactionCategory category;
  final Function(List<String>?) setSelectedMembers;

  @override
  _SharedCategorySettingsState createState() => _SharedCategorySettingsState();
}

class _SharedCategorySettingsState extends State<SharedCategorySettings> {
  List<String> members = [];
  bool isLoaded = false;
  bool isErrored = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      dynamic response = await getMembersFromCategory(
          widget.category.sharedKey!, widget.category);
      if (response == null) {
        openSnackbar(SnackbarMessage(title: "Connection error"));
        setState(() {
          isErrored = true;
        });
        return;
      }
      print(FirebaseAuth.instance.currentUser!.email);
      print(widget.category.sharedOwnerMember);
      setState(() {
        members = response;
        isLoaded = true;
      });
      widget.setSelectedMembers(members);
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
          widget.category.sharedKey!, originalMember, widget.category);
      await addMemberToCategory(
          widget.category.sharedKey!, member, widget.category);
      setState(() {
        int index = members.indexOf(originalMember);
        members.removeAt(index);
        members.add(member);
      });
    } else {
      await addMemberToCategory(
          widget.category.sharedKey!, member, widget.category);
      setState(() {
        members.add(member);
      });
    }
    widget.setSelectedMembers(members);
  }

  removeMember(String member) async {
    await removeMemberFromCategory(
        widget.category.sharedKey!, member, widget.category);
    setState(() {
      int index = members.indexOf(member);
      members.removeAt(index);
    });
    widget.setSelectedMembers(members);
  }

  @override
  Widget build(BuildContext context) {
    if (isErrored) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextFont(
              text:
                  widget.category.sharedOwnerMember == CategoryOwnerMember.owner
                      ? "Add Members"
                      : "Members",
              textColor: Theme.of(context).colorScheme.textLight,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextFont(
              text: "Only group owners can edit members",
              textColor: Theme.of(context).colorScheme.textLight,
              fontSize: 13,
              maxLines: 10,
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: TextFont(
              text: "Connection Error",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFont(
            text: widget.category.sharedOwnerMember == CategoryOwnerMember.owner
                ? "Add Members"
                : "Members",
            textColor: Theme.of(context).colorScheme.textLight,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFont(
            text: "Only group owners can edit members",
            textColor: Theme.of(context).colorScheme.textLight,
            fontSize: 13,
            maxLines: 10,
          ),
        ),
        SizedBox(height: 10),
        widget.category.sharedOwnerMember == CategoryOwnerMember.owner
            ? Row(
                children: [
                  Expanded(
                    child: AddButton(onTap: () {
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
                    }),
                  ),
                ],
              )
            : SizedBox.shrink(),
        !isLoaded
            ? Padding(
                padding: const EdgeInsets.only(
                  top: 28.0,
                  bottom: 10,
                ),
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: CategoryMemberContainer(
                      member: members[0],
                      setMember: (_) {},
                      onDelete: () {},
                      canModify: false,
                      isOwner: true,
                      isYou: members[0] == appStateSettings["currentUserEmail"],
                    ),
                  ),
                  for (String member in members.sublist(1))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: CategoryMemberContainer(
                        member: member,
                        setMember: (text) async {
                          addMember(text,
                              updateEntry: true, originalMember: member);
                        },
                        onDelete: () {
                          removeMember(member);
                        },
                        canModify: widget.category.sharedOwnerMember ==
                            CategoryOwnerMember.owner,
                        isOwner: false, //only the first entry is the owner
                        isYou: member == appStateSettings["currentUserEmail"],
                      ),
                    ),
                ],
              ),
        SizedBox(height: 5),
        widget.category.sharedOwnerMember == CategoryOwnerMember.owner
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Button(
                  icon: Icons.block,
                  iconColor: Theme.of(context).colorScheme.errorContainer,
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
                  icon: Icons.logout_rounded,
                  iconColor: Theme.of(context).colorScheme.errorContainer,
                  label: "Leave Shared Group",
                  onTap: () async {
                    bool status = await leaveSharedCategory(widget.category);
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
                    openPopup(
                      context,
                      title: "Delete " + widget.category.name + " category?",
                      description:
                          "This will delete all transactions associated with this category. This will only delete the transactions on your device.",
                      icon: Icons.delete_rounded,
                      onCancel: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      onCancelLabel: "Cancel",
                      onSubmit: () {
                        database.deleteCategory(
                            widget.category.categoryPk, widget.category.order);
                        database.deleteCategoryTransactions(
                            widget.category.categoryPk);
                        Navigator.pop(context);
                        openSnackbar(
                          SnackbarMessage(
                            title: "Deleted " + widget.category.name,
                            icon: Icons.delete,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      onSubmitLabel: "Delete",
                    );
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
    required this.isYou,
    required this.canModify,
  }) : super(key: key);

  final String member;
  final Function(String) setMember;
  final VoidCallback onDelete;
  final bool isOwner;
  final bool isYou;
  final bool canModify;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Tappable(
        onTap: () {
          if (!canModify) return;
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    !isOwner && !isYou
                        ? SizedBox.shrink()
                        : TextFont(
                            text: isOwner
                                ? isYou
                                    ? "Owner (You)"
                                    : "Owner"
                                : isYou
                                    ? "You"
                                    : "Member",
                            fontSize: 15,
                            textColor: Theme.of(context).colorScheme.secondary,
                          ),
                    TextFont(
                      text: member,
                      fontSize: 16,
                    ),
                  ],
                ),
              ),
            ),
            canModify
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
