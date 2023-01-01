import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';

Future<void> showChangelog(context, {forceShow: false}) async {
  String changelog = """
    Can edit nickname in transaction select payer bottomsheet
    Fixed reoccurrence for budgets and budget time periods
    Fixed your progress bar on budget container color
    Added box shadow to note popup
    Added note tooltip - can view note on homepage
    Added keep alive on home page when scrolling it doesn't push things down if long list of transactions
    Added nicknames for shared category users
    Fixed ordering of synced categories
    When deleting a category, asks for leave group, or delete on server
    When leaving a category group, asks for delete
    Can select and change payer in transaction
    Removed list of categories on edit budgets page
    Original creator of transaction shown under sync
    If time of backup and sync less than 7 days, it shows time ago difference it was updated
    Sharing a category properly updates the UI
    Offline transaction updates happen before downloading updates from server
    Budget can select to show only transactions created by you
    Add category button when selecting categories
    All category selector when selecting categories for budget
    Shared categories
    Upgraded to Drift Database 1.3.0 -> 2.3.0
    Added Firebase login for web
    Fixed pie chart duplicate key removing pie chart when on past budget page
    Fixed rounded corner when percentage is small of progress bar in budget container
    Fixed bottom padding color for popup in material you
    Notifications setting section
    Moved show wallet switcher setting to edit wallets page
    Moved total spent label setting to edit budget page
    Added DB version to file when exporting to drive
    Fixed shimmer colors for non material you theme
    Fixed paying subscription transaction
    Fix race condition for setting subscription notifications - wait for database first
    Loading effect when getting backups from drive
    Backup settings moved under manage page on accounts page
    Database migration for sync categories feature
    Fixed overflow associated title on category page
    Added spacing at bottom of edit category
    Fixed adding category color
    Started shareable categories implementation
    Added backup frequency in account page
    Added year of transaction in sticky header (if not current year)
    Force restart when loading backup
    Fixed daily notifications schedule time
    Added notifications for upcoming transactions
    First wallet added to the app is protected
    Fixed routing for first Google login
    Budget page improved animations and curves
    Notifications and scheduling
    Added Material You Theme setting
    Fixed animation for search button on transactions page
    Select Category should try and always display at least 4 entries per row
    Added system theme color option
    New route pushing management
    Added back bar graph animation (new route management system removed stutter when navigating)
    Border radius fix for app bar
    Added padding between transaction title and amount
    Animated Goo disabled on web entirely
    Status bar icons follow light/dark theme properly
    Added no transactions image when no transactions found for certain month
    Improved empty budgets page when no transactions found
    No longer shows failed to sign in when first launch app

    Adaptive icon for Android 13+
    Upcoming transactions now show up on home page (within 3 days)

    New dropdown menu when selecting transactions to delete - shows amount selected and total cash flow of transactions
    Selected transactions cleared when using back button
    Today, Yesterday, Days of Week labels now include the month and date
    Changed the way Google login permissions work (on Android)
    All permissions still required on Web for Gmail parsing to work (to avoid this error: gapi.auth2 has been initialized with different options.)

    Improvements to past budget pages (removed UI elements that don't make sense)
    Added horizontal line indicating the best point to be at during that current period for spending
    Fixed past budgets bar graph
    Changed the order of execution of startup functions
    New FAB animation
    
    Progress bar text clipping fixes
    Daylight savings time transaction result fixes
    Fixed associated title getting added twice (title trim fix comparison)
    Email loading stops when page exited
    Deleting associated titles optimized with batch insert all

    App name changed
    Home page now List View for better performance
    Fixed home page jumping around with budget container load/unload
    Discard changes popup doesn't show up anymore when no changed made to transaction
    Budget now animates even when 100% then shakes
    Budget progress no longer has count-up
    Budget list page period length hidden
    Budget page graph takes color of selected category
    If category has less than 5%, icon isn't shown on pie chart
    When category tapped and less than 5%, percent and image is shown
    Total cash flow for transactions page month
    Changed shimmer effect to reflect a transaction entry
    Fixed settings container closing colors on light mode
    Color tweaks
    Can no longer enter NaN or Infinite transaction amounts
    Associated titles not auto created when empty string
    Extra white space removed from associated titles
    Colors discard changes discrepencies fixed
    Selected color selected properly when editing
    Can tap snackbar messages for some actions
    Email scanning redone
    Email scanning profiles and different templates
    Home page animations
    Home page transactions list shows upcoming transactions (3 days before)
    Fixed adding wallet unreferenced widget for animation
    Started currency picker for wallet
    
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
