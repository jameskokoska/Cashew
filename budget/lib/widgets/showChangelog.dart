import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';

Future<void> showChangelog(context, {forceShow = false}) async {
  String changelog = """
    Budget history line graph gets extended when more budgets loaded
    Selecting amount for transaction limits amount of numbers that actually change the amount
    New save bottom button
    Fixed count-up animation decimal glitching
    New animation for pie chart
    If there are no transactions for budget, still shows 0 spent
    Can add category limit by long pressing category entry in budget page
    Per category budget limits implemented
    New horizontal scroll view for budgets on web home
    Animated percent animates backwards when value changes
    Category budget limits deleted when category deleted
    Reordered colors based on hue
    Fixed color picker on smaller bottom sheet popup
    Improved loading animation, uses native loading with async main
    Added total cash flow to bottom of budget page
    Consistent name changes for category when selecting icon with recommended category name
    Editing associated title doesn't popup for editing text within the popup
    Can edit category by long pressing in add transaction page
    Can use arrow keys to go through onboarding
    Can use number keys to change pages quickly when on home page
    Fixed delayed keyboard input entry
    Long press back button on select amount to clear numbers
    Can edit wallet from wallet history page
    Budget history line graph shows goal line no matter what
    Fixed interval for line graph
    Fixed monthly label for past budget history spending graph
    Fixed bottom sheet colors with material you
    Removed over-scroll glow in bottom sheet
    Width constrained for number pad
    Close button on popup modals if full screen
    Started budget category limits
    Removed gradient on past spending lines
    Fixed discard changes warning for transaction if no changes made
    Added ability to scroll through month selector with mouse wheel
    Selecting category icon replaces name properly
    Tapping category icon in transaction opens transaction
    Fixed category name initial value on web
    Started adding new table and backend - budget category limits 
    Optimized layout of some pages for full screen web
    Improved no transactions found placeholder image
    Fixed when adding transaction from added only budget and it's shared can't select which member of the budget
    Compacted UI
    Category spending size changes
    Back button deselects category
    Notification no longer comes if you opened the app on that day
    Added ability to individually toggle which upcoming notifications to enable for which transactions
    Can tap settings entry to change its switch value
    Fixed default value of upcoming notifications setting
    Cleaned up accounts and CSV import
    Rearranged settings page
    Wallet is respected in wallet statistics
    Added all spending statistics
    Wallet summary page, tap the selected wallet to see spending information for entire wallet
    New settings buttons
    Uses Material You switch
    Fixed notifications IDs repeating
    When new subscription/repeating transaction added id is correct 
    Fixed date offset by adding days with 0 spending
    Can set to keep past spending habits or not in line graph for budget page
    Can select which budget to reference as the home page line graph
    Search searches transaction notes
    Search ignores capitalization
    If transaction amount for upcoming transaction is zero, it asks how much it is
    Date period defaults to 1 for repeating transactions
    Spending graph positive for budget page, since income isn't used for budgets
    Fixed past spending graphs showing wrong corresponding days for current period
    Fixed tapping category on budgets page to select only those transactions
    Can see spenders amount in Budget History is shared budget
    Fixed term lengths of budgets
    Fixed currency conversions
    All currencies downloaded at launch, uses 1 request instead of multiple
    Show currency conversion on transaction entry
    Can drag to reorder budgets on budget page
    When stop sharing budget, transactions are no longer removed from that budget
    When stop sharing, transactions still remember spender 
    Warning before stop sharing
    Changelog popup has scrollbar
    Filled area above budget goal in past budget history line graph spending tracking with extra color
    Fixed editing member nickname timeout for text auto focus
    Added budget history spending momentum graph to compare with past periods
    On touch information for line graphs
    Line graph support multiple lines
    Scrollbar
    Fixed colors for budget history page (light mode)
    Converted bar graph to line graph for budget history
    Updated FL Charts package
    Added vibration when reordering categories
    Fixed auto backups timing
    App rename to Cashew
    Icon search
    Most likely category name when selecting icon
    Added more icons
    Fixed popup closing from keyboard when editing nickname
    Icon Buttons shifted to the left instead of the right
    Shows currency in add transaction selected wallet
    Can copy amount to clipboard by long pressing
    Fixed commas for amounts in budget and app bar
    Fixed lag in large budget history bar graph
    Fixed auto backups
    Fixed Budget History to respect budget transactions to include setting
    Support for multiple currencies with correct conversion!
    Fixed lock screen animation for biometrics
    Currencies are caches and load in O(1)
    Refresh button on budgets page now sync queue (same as pull to refresh)
    Wallet selector removed from transaction if only one wallet
    Added biometrics to unlock application option
    Added drag to reorder categories on grid
    Capitalized titles on transaction entry
    Text capitalization
    Removed shimmer from offscreen transactions on all transactions page
    Fixed background color for material you
    Fixed default wallet selection in add transactions radio popup
    Fixed most of currency icons
    Default budget selected when adding transactions in budget page
    Fixed Date Created for import from csv transactions
    If transactions are added out of time range to custom ranged budget for added transactions only, they appear and are added to the total
    Fixed tapping Added transactions icon changed shared status of budget when adding budget
    Transactions are only rendered the day that a transaction exists on, optimization
    This also allows the view of transactions out of a time range - for example when an added only budget has transactions out of a custom time perios range
    Added more budget transaction added filters: fromEveryone, onlyIfOwner, onlyIfOwnerIfShared, onlyIfShared, onlyIfNotShared, excludeOther, excludeOtherIfShared, excludeOtherIfNotShared
    Added wallet picker in add transaction
    Added exclude other transactions that are added to another budget option
    Editing budget page fixes
    Added only option for budgets - need to explicitly add a transaction to these types of budgets
    Fixed switching shared budgets when editing transaction
    Removed wallets limitation
    Changed synced snackbar message
    Can't add transactions to budget not shared from budget page
    Selected category properly selected when editing transaction and changing category
    Circular progress indicator white shadow on light mode
    Category Icon size and color changes on budget page
    Rounded Category Icon for transactions
    Increased efficiency of shifting associated title
    Back button on subscription page properly deselects transactions
    Fixed discard popup and removed sorting by date and time created
    Fixed the way upcoming transactions work with shared budgets
    FireStore silent sign-in
    Rewrote all shared code - now shares a budget
    Fixed adding category
    Fixed drag to select on upcoming, overdue and subscriptions page
    New loading bar for google login
    If added ny csv, method added is set to csv internally
    Shows date transactions are from on search page
    Can search category even if lowercase
    Fixed select multiple transactions and edit category to shared one
    Sped up mass remove from shared category with batch
    Are you sure to restore cloud backup popup
    Fixed timings of batch commits to Firebase
    Drag to select multiple transactions
    Scanned and synced snackbar only shows up if greater than 0
    Pull to refresh only enabled if logged in before
    Fixed infinite percent on budget history
    Fixed paint lag on large percentage number for animated circular progress
    Fixed memory leak for shake animation
    Prevented spamming of export to drive
    Completed past budgets page
    Budget edits and changes are now watched on budget page 
    Added edit budget icon on budget page
    Added delete category, transaction, wallet button when on editing page
    Changed reorder animation to opacity instead of scale down
    Past budget bar graph labels correspond to budget time period
    Swipe down on home page/transaction page to refresh cloud transaction
    Fixed changing upcoming transaction to default transaction type - marks it as paid
    Fixed background of circular progress when selecting shared transaction member on budget page
    Added new global loading indeterminate progress bar
    Started changing past budgets page
    Fixed discard changes popup when editing shared properties
    Added share action on category page
    Delayed the input for nickname setting as it would close the popup on prod
    Users are sorted based on who spent more
    Fixed multiple category selector with shared categories
    Added bottom padding to edit lists
    New circular progress ring
    Can select transactions on overdue/upcoming pages
    Upcoming transactions can no longer be shared
    Can see how much each user has spent if shared category of spending
    When user gets removed from category or a becomes part of one a notification is shown
    When editing transaction amount, prefilled with existing value
    Added default category to auto transactions page
    Can edit nickname in transaction select payer bottom sheet
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
      showScrollbar: true,
    );

    updateSettings("lastLoginVersion", version + buildNumber);
  }
}
