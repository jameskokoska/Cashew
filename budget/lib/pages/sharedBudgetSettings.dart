import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/shareBudget.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:budget/colors.dart';
import 'package:shimmer/shimmer.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/struct/randomConstants.dart';

class SharedBudgetSettings extends StatefulWidget {
  SharedBudgetSettings({
    Key? key,
    required this.budget,
  }) : super(key: key);

  final Budget budget;

  @override
  _SharedBudgetSettingsState createState() => _SharedBudgetSettingsState();
}

class _SharedBudgetSettingsState extends State<SharedBudgetSettings> {
  List<String> members = [];
  bool isLoaded = false;
  bool isErrored = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      dynamic response =
          await getMembersFromBudget(widget.budget.sharedKey!, widget.budget);
      if (response == null) {
        openSnackbar(SnackbarMessage(title: "Connection error"));
        setState(() {
          isErrored = true;
        });
        return;
      } else if (response == false) {
        setState(() {
          members = [];
          isLoaded = false;
        });
        return;
      }
      print(FirebaseAuth.instance.currentUser!.email);
      print(widget.budget.sharedOwnerMember);
      setState(() {
        members = response;
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
          icon: appStateSettings["outlinedIcons"]
              ? Icons.warning_outlined
              : Icons.warning_rounded,
          title: "User already exists",
        ),
      );
      return;
    }
    if (!member.contains("@") || !member.contains(".com")) {
      openSnackbar(
        SnackbarMessage(
          icon: appStateSettings["outlinedIcons"]
              ? Icons.warning_outlined
              : Icons.warning_rounded,
          title: "Email only",
          description: "Please ensure a valid email is entered.",
        ),
      );
    }
    if (updateEntry) {
      await removeMemberFromBudget(
          widget.budget.sharedKey!, originalMember, widget.budget);
      await addMemberToBudget(widget.budget.sharedKey!, member, widget.budget);
      setState(() {
        int index = members.indexOf(originalMember);
        members.removeAt(index);
        members.add(member);
      });
    } else {
      await addMemberToBudget(widget.budget.sharedKey!, member, widget.budget);
      setState(() {
        members.add(member);
      });
    }
  }

  removeMember(String member) async {
    await removeMemberFromBudget(
        widget.budget.sharedKey!, member, widget.budget);
    setState(() {
      int index = members.indexOf(member);
      members.removeAt(index);
    });
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
              text: widget.budget.sharedOwnerMember == SharedOwnerMember.owner
                  ? "Add Members"
                  : "Members",
              textColor: getColor(context, "textLight"),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextFont(
              text: "Only group owners can edit members",
              textColor: getColor(context, "textLight"),
              fontSize: 13,
              maxLines: 10,
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: Icon(
              appStateSettings["outlinedIcons"]
                  ? Icons.warning_outlined
                  : Icons.warning_rounded,
              color: Theme.of(context).colorScheme.secondary,
              size: 40,
            ),
          ),
          Center(
            child: TextFont(
              text: "Connection Error",
              fontSize: 15,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 10),
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFont(
            text: widget.budget.sharedOwnerMember == SharedOwnerMember.owner
                ? "Add Members"
                : "Members",
            textColor: getColor(context, "textLight"),
            fontSize: 16,
          ),
        ),
        SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFont(
            text: "Only group owners can edit members",
            textColor: getColor(context, "textLight"),
            fontSize: 13,
            maxLines: 10,
          ),
        ),
        SizedBox(height: 10),
        widget.budget.sharedOwnerMember == SharedOwnerMember.owner
            ? isLoaded
                ? Row(
                    children: [
                      Expanded(
                        child: AddButton(
                            padding: EdgeInsets.only(
                              left: 15,
                              right: 15,
                              bottom: 9,
                              top: 4,
                            ),
                            onTap: () {
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
                : Shimmer.fromColors(
                    period: Duration(milliseconds: 1000),
                    baseColor: appStateSettings["materialYou"]
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : getColor(context, "lightDarkAccentHeavyLight"),
                    highlightColor: appStateSettings["materialYou"]
                        ? Theme.of(context)
                            .colorScheme
                            .secondaryContainer
                            .withOpacity(0.2)
                        : getColor(context, "lightDarkAccentHeavy")
                            .withAlpha(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 15,
                          right: 15,
                          bottom: 9,
                          top: 10,
                        ),
                        height: 52,
                        margin: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: getColor(context, "lightDarkAccent")
                              .withOpacity(0.5),
                          border: Border.all(
                            width: 1.5,
                            color: getColor(context, "lightDarkAccentHeavy"),
                          ),
                        ),
                        child: Center(
                          child: TextFont(
                            text: "+",
                            fontWeight: FontWeight.bold,
                            textColor:
                                getColor(context, "lightDarkAccentHeavy"),
                          ),
                        ),
                      ),
                    ),
                  )
            : SizedBox.shrink(),
        !isLoaded
            ? Column(
                children: [
                  for (int i = 0;
                      i < (widget.budget.sharedMembers ?? []).length;
                      i++)
                    Shimmer.fromColors(
                      period: Duration(
                          milliseconds:
                              (1000 + randomDouble[i % 10] * 520).toInt()),
                      baseColor: appStateSettings["materialYou"]
                          ? Theme.of(context).colorScheme.secondaryContainer
                          : getColor(context, "lightDarkAccentHeavyLight"),
                      highlightColor: appStateSettings["materialYou"]
                          ? Theme.of(context)
                              .colorScheme
                              .secondaryContainer
                              .withOpacity(0.2)
                          : getColor(context, "lightDarkAccentHeavy")
                              .withAlpha(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Container(
                          width: double.infinity,
                          height: 70,
                          margin: const EdgeInsets.only(bottom: 8.0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: getColor(context, "lightDarkAccent")
                                .withOpacity(0.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  color: Colors.white,
                                ),
                                height: 15,
                                width: 85 + randomDouble[i % 10] * 40,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  color: Colors.white,
                                ),
                                height: 17,
                                width: 175 + randomDouble[i % 10] * 80,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                ],
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
                        canModify: widget.budget.sharedOwnerMember ==
                            SharedOwnerMember.owner,
                        isOwner: false, //only the first entry is the owner
                        isYou: member == appStateSettings["currentUserEmail"],
                      ),
                    ),
                ],
              ),
        SizedBox(height: 5),
        widget.budget.sharedOwnerMember == SharedOwnerMember.owner
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Button(
                  icon: appStateSettings["outlinedIcons"]
                      ? Icons.block_outlined
                      : Icons.block_rounded,
                  iconColor: Theme.of(context).colorScheme.onError,
                  label: "Stop Sharing",
                  onTap: () async {
                    openPopup(
                      context,
                      title: "Stop Sharing?",
                      description:
                          "Are you sure you want to stop sharing this budget? This will delete all entries from the server.",
                      icon: appStateSettings["outlinedIcons"]
                          ? Icons.block_outlined
                          : Icons.block_rounded,
                      onCancel: () {
                        Navigator.pop(context);
                      },
                      onCancelLabel: "cancel".tr(),
                      onSubmit: () async {
                        Navigator.pop(context);
                        openLoadingPopup(context);
                        bool status =
                            await removedSharedFromBudget(widget.budget);
                        if (status == false) {
                          openSnackbar(
                            SnackbarMessage(
                              icon: appStateSettings["outlinedIcons"]
                                  ? Icons.warning_outlined
                                  : Icons.warning_rounded,
                              description:
                                  "There was a problem removing the shared budget from the server. Please try again later.",
                            ),
                          );
                          return;
                        }
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      onSubmitLabel: "delete".tr(),
                    );
                  },
                  color: Theme.of(context).colorScheme.error,
                  textColor: Theme.of(context).colorScheme.onError,
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Button(
                  icon: appStateSettings["outlinedIcons"]
                      ? Icons.logout_outlined
                      : Icons.logout_rounded,
                  iconColor: Theme.of(context).colorScheme.errorContainer,
                  label: "Leave Shared Group",
                  onTap: () async {
                    openLoadingPopup(context);
                    bool status = await leaveSharedBudget(widget.budget);
                    if (status == false) {
                      openSnackbar(
                        SnackbarMessage(
                          icon: appStateSettings["outlinedIcons"]
                              ? Icons.warning_outlined
                              : Icons.warning_rounded,
                          description:
                              "There was a problem removing the shared budget from the server. Please Try again later.",
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    openPopup(
                      context,
                      title: "Delete " + widget.budget.name + " budget?",
                      description:
                          "This will delete all transactions associated with this category. This will only delete the transactions on your device.",
                      icon: appStateSettings["outlinedIcons"]
                          ? Icons.delete_outlined
                          : Icons.delete_rounded,
                      onCancel: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      onCancelLabel: "cancel".tr(),
                      onSubmit: () {
                        database.deleteBudget(context, widget.budget);
                        // database.deleteBudgetTransactions(
                        //     widget.category.categoryPk);
                        Navigator.pop(context);
                        openSnackbar(
                          SnackbarMessage(
                            title: "Deleted " + widget.budget.name,
                            icon: Icons.delete,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      onSubmitLabel: "delete".tr(),
                    );
                  },
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  textColor: Theme.of(context).colorScheme.errorContainer,
                ),
              ),
        SizedBox(height: 25),
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
          if (!canModify)
            memberPopup(context, member);
          else
            openBottomSheet(
              context,
              PopupFramework(
                title: "Edit Member",
                subtitle: "Edit the nickname of the member",
                child: Column(
                  children: [
                    SelectText(
                      icon: appStateSettings["outlinedIcons"]
                          ? Icons.person_outlined
                          : Icons.person_rounded,
                      setSelectedText: (_) {},
                      nextWithInput: setMember,
                      selectedText: member,
                      placeholder: "example@gmail.com",
                      autoFocus: false,
                    ),
                    SelectText(
                      icon: appStateSettings["outlinedIcons"]
                          ? Icons.sell_outlined
                          : Icons.sell_rounded,
                      setSelectedText: (_) {},
                      nextWithInput: (text) {
                        Map<dynamic, dynamic> nicknames =
                            appStateSettings["usersNicknames"];
                        nicknames[member] = text;
                        updateSettings("usersNicknames", nicknames,
                            pagesNeedingRefresh: [], updateGlobalState: false);
                      },
                      selectedText:
                          appStateSettings["usersNicknames"][member] ?? "",
                      placeholder: "Nickname",
                      textCapitalization: TextCapitalization.words,
                      autoFocus: true,
                      requestLateAutoFocus: true,
                    ),
                  ],
                ),
              ),
            );
        },
        borderRadius: 15,
        color: getColor(context, "lightDarkAccent"),
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
                    TextFont(
                      text: isOwner
                          ? isYou
                              ? getMemberNickname(member) == member
                                  ? "Owner (You)"
                                  : getMemberNickname(member) + " (Owner - You)"
                              : getMemberNickname(member) == member
                                  ? "Owner"
                                  : getMemberNickname(member) + " (Owner)"
                          : isYou
                              ? getMemberNickname(member) != "Me"
                                  ? getMemberNickname(member) + " (Member - Me)"
                                  : "Me (Member)"
                              : getMemberNickname(member) == member
                                  ? "Member"
                                  : getMemberNickname(member) + " (Member)",
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
                        icon: appStateSettings["outlinedIcons"]
                            ? Icons.delete_outlined
                            : Icons.delete_rounded,
                        onSubmitLabel: "Remove",
                        onSubmit: () {
                          Navigator.pop(context);
                          onDelete();
                        },
                        onCancelLabel: "cancel".tr(),
                        onCancel: () {
                          Navigator.pop(context);
                        },
                      );
                    },
                    borderRadius: 15,
                    color: getColor(context, "lightDarkAccent"),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Icon(
                        appStateSettings["outlinedIcons"]
                            ? Icons.close_outlined
                            : Icons.close_rounded,
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

memberPopup(context, String member) {
  openBottomSheet(
    context,
    PopupFramework(
      title: "Edit Nickname",
      subtitle: "Edit the nickname of the member",
      child: Column(
        children: [
          Opacity(
            opacity: 0.4,
            child: SelectText(
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.person_outlined
                  : Icons.person_rounded,
              setSelectedText: (_) {},
              selectedText: member,
              placeholder: "example@gmail.com",
              autoFocus: false,
              readOnly: true,
            ),
          ),
          SelectText(
            icon: appStateSettings["outlinedIcons"]
                ? Icons.sell_outlined
                : Icons.sell_rounded,
            setSelectedText: (_) {},
            nextWithInput: (text) {
              Map<dynamic, dynamic> nicknames =
                  appStateSettings["usersNicknames"];
              nicknames[member] = text;
              updateSettings("usersNicknames", nicknames,
                  pagesNeedingRefresh: [], updateGlobalState: false);
            },
            selectedText: appStateSettings["usersNicknames"][member] ?? "",
            placeholder: "Nickname",
            autoFocus: false,
            requestLateAutoFocus: true,
          ),
        ],
      ),
    ),
  );
}
