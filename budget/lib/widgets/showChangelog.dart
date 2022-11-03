import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';

Future<void> showChangelog(context, {forceShow: false}) async {
  String changelog = """
    App name changed
    Home page now List View for better performance
    Discard changes popup doesn't show up anymore when no changed made to transaction
    Budget now animates even when 100% then shakes
    Budget progress no longer has count-up

    Past changes:

    Extra white space removed when adding transaction titles from email
    Emails are marked as read when parsed
    Escape key pops current navigation route
    Notifications setting removed on web
    Web should have better text input handling (direct instead of popups)
    Larger displays navigation bar max size
    New budget progress bar animation
    Budget bar graph to track older budget periods spending
    Notifications transaction reminder WIP
    Empty Budget new image
    Budget aligned when switching pages
    Added popup for restart - Importing backup on web requires restart
    Upcoming transactions that have been already paid at one point no longer create a new upcoming transaction
    Upcoming transactions are now added to the date they were paid on
    Can no longer see past periods for a custom budget period
    Cannot reorder when only one entry in list
    Long press a category on any page to edit it
    Budget recurrence lengths are disabled for now
    Sticky header no longer in home page transaction list, optimization
    Upcoming and overdue transactions are sorted based on due date
    Added changelog!
    You can read the changelog in the About page.

    All past changes will go here, to prevent clutter.
end""";

  String version = packageInfoGlobal.version;
  String buildNumber = packageInfoGlobal.buildNumber;
  if (forceShow ||
      appStateSettings["lastLoginVersion"] != version + buildNumber) {
    List<Widget> changelogPoints = [];
    for (String string in changelog.split("\n")) {
      string = string.replaceFirst("    ", ""); // remove the indent
      if (forceShow == false && string == "Past changes:") {
        // Show the past changes if forceShow
        break;
      } else if (string == "Past changes:") {
        changelogPoints.add(SizedBox(height: 10));
      }
      if (string.trim() == "") {
        // this is an empty line
        changelogPoints.add(SizedBox(
          height: 8,
        ));
      } else if (string.trim() != "end") {
        changelogPoints.add(Padding(
          padding: const EdgeInsets.only(bottom: 5.5),
          child: TextFont(
            text: string,
            fontSize: 16.5,
            maxLines: 5,
          ),
        ));
      }
    }

    openBottomSheet(
      context,
      PopupFramework(
        title: "Changelog",
        subtitle: "v" +
            version +
            "+" +
            buildNumber +
            ", db-v" +
            schemaVersionGlobal.toString(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: changelogPoints,
        ),
      ),
    );

    updateSettings("lastLoginVersion", version + buildNumber);
  }
}
