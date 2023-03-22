import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';

Future<void> showChangelog(context, {forceShow = false}) async {
  String changelog = """
    Shared transactions only updated when category properly changes for shared transactions only
    Initial categories updated time set to 0
    Fixed cached wallet offset on restoring sync
    Sync now works on a sequential log system - this ensures all changes are processed in order!
    Primary wallet import fix for caches currency selected
    Sync fixes now replaces old entries directly without updating
    Sync fixes with shared transactions/budgets
    Order of budgets, categories, wallets, titles fixed when editing
    When category is updated through sync, shared transactions are not
    Fixed deleting category leads to wrong transactions sent to delete for sync
    Sync no longer syncs shared budgets/transactions
    Fixed sync replacing newer changes with older ones
    Fixed navigation issues on mobile (using page controller - uses lazy indexed stack now)
    Fixed device id name on web devices
    Navigation sidebar disabled when onboarding
    New account and backup buttons
    Fixed month selector media query width position considers side navbar
    Fixed stack order, side panel always on top
    Fixed offset in last synced time race condition
    (need to track the time you last synced with that specific client e.g. if change made on mobile, web syncs now, wait 5 seconds, then movile syncs, - web thinks that it got that latest version from mobile already changes not here!)
    Links listed below notes in transaction entry
    Added time and date to sidebar on web
    Web no longer asks for gmail permissions
    Fixed search icon text input colors
    Improved selected transactions action bar size on web
    Fixed drag down to dismiss stuck on web
    Added users email on side navigation bar
    Added sync button on side navigation bar
    Sign-in silent fix on mobile
    All entries should have a new modified date if changed
    Upgraded Google sign in API
    Fixed layout of username in production in side navbar
    Fixed keyboard in production
    If user logged out/not logged in to Google, cloud functions do not activate/try to activate
    Migration fixes for database (when adding new columns, catches duplicate column)
    When new settings are added, default settings applied when old backup restored
    Client syncing should be complete
    Delete log propagation
    Delete log
    Database cleanup
    When reordering items, modified date is updated
    Fixed starting position of month selector on web with side navbar
    Option to sync all changes
    Loading progress bar on top for web
    Login and loading fixes on web
    Fixed dropdown selector not having default value, chooses first entry
    Client sync setting
    Client syncs when changes are made 
    Fixed default wallet when importing client sync changes
    Cleaned up client sync backup detection code
    Client sync import fixes
    De-cluttered unused imports
    Read changes past modified time
    Client specific backup read and write 
    Each client backup to Google Drive
    Started cross client sync feature
    Searching for categories, wallets, titles, budgets
    Scaffold for page framework now has overlay
    Color fixes for material you disabled
    Added close button to bottom of changelog
    View app intro and changelog moved below developers in About page
    Fixed width sizing for web with new sidebar for bottom sheet and max padding
    Added budget history grid for web
    Improved colors and sidebar for full screen web
    Fixed back arrow navigation
    Reformatted home screen layout for full screen web
    New side navigation for web
    Back button only works if can pop
    Back button only shows if can pop
    Implemented new filters into budgets
    Sticky header in add budget page
    Improved action spacing for sliverappbar
    Changed input text to accept input directly instead of popup sheet
    Fixed colors of icons not following colorscheme of page
    Fixed associated title popup delay
    Initial population of new filter columns in budgets
    Splash color follows color theme
    Fixed background color of transaction entries (for open navigation container)
    Fixed initial background color of loading page on web
    Fixed header background color on past budget page
    Started new budget filters
    Notification permission request
    Color fixes
    Added material you colorscheme to budget history page
    Started improving add new budget page
    Scanned email transactions income supported based on the category
    Fixed header for page frameworks that don't require expanding
    Category immediately appears if touched in pie chart
    Budget background follows theme of budget
    Fixed split budget progress for your spending compared to others (watchTotalSpentByCurrentUserOnly)
    Improved stop sharing button colors
    Better connection error if loading members list
    Back button deselects user if selected on shared budgets
    Removed extra spacing at bottom of transaction list page
    Pin budget moved to corner
    New tab slider
    Added tooltips to buttons
    Wallet is watched for updates on wallet details page
    Animated subscription total buttons
    Skipped payment subscriptions don't show up on subscription page
    New and improved page for adding transaction
    Fixed bar graph glitch and date past for budgets
    Removed scrollbar for web
    View more budgets padding glitch
    Improved contrast for material you budget progress bar
    Removed line graph and pie chart if no transactions in budget
    Right click action performs long press on web
    Top app bar larger for web
    Web respects system dark mode when loading
    Added loading animation on web
    Currency icon removed from some amount popups
    Keyboard open animation for bottom button
    Fixed long lasting bug with alignment on sliver app bar (especially with keyboard)
    Fixed back button double popping route for select amount
    Added debounce to past budget line graph selection to avoid spam
    Fixed linear gradient light mode
    Fixed open close container colors light mode
    Fixed add button light mode
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
    changelogPoints.add(
      Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Button(
          label: "Close",
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
    );

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
