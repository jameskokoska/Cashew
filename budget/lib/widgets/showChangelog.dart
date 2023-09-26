import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/detailedChangelogPage.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/outlinedButtonStacked.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'listItem.dart';

String getChangelogString() {
  return """
    < 4.4.7
    Added FAB to wallet details page
    Fixed line graph history in wallet details page when custom period selected
    < 4.4.6
    New period time range selection for homepage widgets and all spending page
    Balance correction category budget transaction filter
    Transaction filter only exists if there is a balance correction category
    Added significant amount of currencies
    Discard changes popup is only shown if a change was made when creating a new entry
    Fixed line graph would include transactions that were in an excluded category
    Balance correction transactions no longer count towards income/expense totals, only net totals
    Fixed automatically marking subscriptions as paid syncing
    When editing the amount of a transaction, default action is no longer add transaction
    Fixed past budget page graph with negative budget periods
    Added vegetable category icons
    < 4.4.5
    Added AED currency
    Fixed date formatting locale
    Replaces include income selector on onboarding with currency picker
    Generating loan transactions with bill splitter awaits for each generated transaction
    < 4.4.4
    Feathered faded edge removed space between
    Transfer balance option in wallet details page above Merge Account
    < 4.4.3
    Only paid transactions count towards a goal
    Fixed data syncing not activating after initial launch
    Fixed when order of objectives is corrected, the modified time is not updated -> opening the page on a newer device can undo all changes when syncing - even though nothing was specifically edited! 
    Transaction correction creations are now awaited so database does not lock
    Fixed translations
    < 4.4.2
    Added net total to spending details page
    Added balance transfer between different accounts with supported currency conversions
    Fixed CSV export when entry has colon (":")
    When tapping income/expense total, search page has applied account filter
    If no goal or budget when selecting, option to create one
    Seamless count number when decimals not provided
    Tooltip no longer prevents category reorder in popup with long title
    Gasoline icon
    < 4.4.1
    Fixed ordering of categories based on amount spent
    Fixed transaction count across accounts
    < 4.4.0
    Prevented multiple syncs from running at once
    Decreased width of goals
    Pie chart homepage shows top categories spent legend
    Fixed final decimal count rounding
    Fixed order objectives added
    < 4.3.9
    Pie chart homepage widget
    Color fixes, especially on income and expense selector
    < 4.3.8
    Objective filters on search page
    Onboarding page text modifications
    Onboarding page include income selection
    View budget transaction filter info popup if all budget selected
    Added objectives to demo preview mode
    Objectives homepage widget
    Fixed objectives grid layout
    Fixed no results padding on full screen for heatmap
    Fixed category selection showing only category transactions
    Fixed auto focus issues on web for text input
    Dropdown menu matches theme of budget
    Tab income/expense selector in all spending and wallet summary
    If budget added and no budget added before, homepage section enabled
    If budget objective and no objective added before, homepage section enabled
    Added faded edges to color picker
    Added major changes to changelog
    Changelog upgrades for different languages
    Changelog details page
    Warning icon filled instead of outlined
    Fixed navigation sidebar dark mode transition
    < 4.3.7
    Added example goals
    Fixed scroll to index with info icon
    Increase budget warning popup
    Transaction tag formatting fixes
    Transaction entry shows progress towards goal
    Category limits warning when over 100% of the total
    < 4.3.6
    Internally renamed wallets to accounts and objectives to goals for translations
    Excluded categories no longer selectable from watch categories
    Selected watched categories correct based on what was selected in the budget
    Implemented default behavior for budget transaction filters
    Themed action app bar for budgets and objectives pages
    Fixed currency conversions for goals
    Finished goals info page
    Fixed premium popup for objectives
    Fixed syncing progress
    Fixed objective syncing
    Fixed bill splitter total amounts
    When previewing data, categories will get recreated and not replace modified ones
    Added info button and popup for transaction type selection
    < 4.3.5
    Budget type info button
    Exclude transactions from budget
    Objectives renamed to goals
    Fixed rounding of amounts when counting animation is used
    < 4.3.4
    Objectives entries completed
    Objectives add page bottom buttons for incomplete information
    Objectives information page
    Searching for a category icon no longer case sensitive
    More category icons
    Fixed ordering by date for loans
    Fixed expanded container on backup page
    Brought pack outlined icons in debug page
    < 4.3.3
    iOS layout for objectives
    Added objectives to side navigation
    Select transactions add to objective in action bar
    Can now add income to budgets
    New income and expense selector
    New objective type selection
    Finished objective syncing
    Finished objective deletion
    Finished objective transaction selection
    When logging in on landing page, syncing progress bar shown
    Currency code shown if current account currency different than primary
    Fixed day spending calculation for budget
    Centered text for budget name
    Text align to start instead of always left
    Fixed tapping note icon when in full screen on non web
    < 4.3.2
    Objective syncing support
    Objective list page
    Objective container
    < 4.3.1
    Net worth home page widget
    When setting custom start date for Income and Expense home page widget, amount of transactions now correct
    Home page order preserved when new widget added
    Count number when correcting total wallet balance
    Add objectives page completed
    < 4.3.0
    Started developing objectives
    Objectives database table
    Fixed outlined icons pin indication
    Faded icons in import CSV template button
    < 4.2.9
    Reordered selected transactions actions menu
    Correct the total amount in an account - in the account details page or edit account page
    Merge accounts with others - in the edit account page
    < 4.2.8
    Fixed intrinsic height error when clock on sidebar would be collapsed
    Last opened version for changelog defaults to current version
    Fixed context for Google login side navigation button (Preview mode warning would not open)
    Removed size shift transition when exiting full screen/landscape
    < 4.2.7
    Added GHS currency
    Fixed order in preview data for wallets
    Fixed removed ability to reorder categories on grid when you shouldn't
    Fixed if add button was disabled in select categories, it would still wrap extra line
    Transactions flash less when newly added, flash longer when date changed
    Transaction flash more consistent with timing - counts amount of animation cycles instead of timer based
    < 4.2.6
    Migration fix
    Sync text fix
    < 4.2.5
    Emoji icon selection for categories
    Import Google Sheets data
    Collapsible side navigation panel when full screen
    Fixed box shadow for swipe to delete
    < 4.2.4
    Documents access in Files for iOS
    Full snap popup sheet when entering name on home page
    Budget history conversion fix
    < 4.2.3
    Fixed parsing of number input when decimal separator is comma
    Fixed Android crash on some devices
    < 4.2.2
    Fixed back swipe animation when cancelling a delete
    Fixed CSV parsing amount always returns income
    Fixed exporting CSV method added
    Removed unnecessary columns when exporting CSV
    < 4.2.1
    CSV tries to parse amount with symbols
    CSV import error if not all parameters assigned
    CSV import date format error has more information
    < 4.2.0
    Fixed format of swipe to delete container on iOS
    Debug flag to enable outlined icons
    < 4.1.9
    Added swipe to delete when on edit data pages
    New reminder types: 24 hours from app last opened, and everyday
    Fixed even split initial value for Bill Splitter
    Improved layout of row entry
    < 4.1.8
    Discard changes works properly for Bill Splitter
    Bill Splitter data saving
    Bill Splitter loan transaction generation
    Bill Splitter translations
    < 4.1.7
    Export to CSV file
    Renamed 'Wallets' to 'Accounts'
    More translations
    < 4.1.6
    Hovering over a category selector with a long name will show full title
    Category title in add transaction page has max 2 lines
    < 4.1.5
    Quickly find the transaction added/updated - Added flashing background to transactions after new one created/date changed
    Fixed CSV import error, with batch inserting and fixed total transaction count
    Bill splitter summary page (still in testing)
    < 4.1.4
    Started bill splitter (still in testing)
    < 4.1.3
    Loading indeterminate background color follows app bar color
    Fixed snackbar background shadow and color on dark mode
    Removed refresh pixels for navigation framework - removed the opacity jitter (however there still may be artifacts when the page is changed?)
    Removed legacy transaction amount colors support (Debug Option)
    Removed old Android Navbar support (Debug Option)
    Navigation bar colors
    2 Weeks of notifications scheduled instead of just 1
    Can only request new icons if suggestion text field is not empty
    Fixed overflow on category names for limits and entry
    Added option to ask for note when selecting title for transaction
    Fixed accent color resetting to always using system color
    Status bar color reset to the proper color after launch
    Centered translations help text if no icon
    Navbar uses percent instead of animation controller value - if the height resizes the subtitle and background color does not follow the proper values of the scroll percentage (Only uses percentage if not using the small header)
    The above is noticeable if selecting a budget history cycle from the line graph and the height resizes to fit content
    < 4.1.2
    Initial tab selected is 'All' instead of 'Expense' on home page
    Upcoming notifications cancelled when exiting Preview Demo
    < 4.1.1
    Added translations team to About page
    Select budget type popup only shown when not adding an initial Addable budget
    Improved empty days color for heatmap
    Fixed system color for launch screen on iOS
    < 4.1.0
    New category icons
    Category icons sorted by recommended name
    Applied new small header on smaller height phones
    Fixed edit spending goals position on budget page
    Fixed subtitle on large displays
    Fixed background color when initial and final is custom color
    Fixed separator app bar not showing up for custom background app bars
    Fixed feedback sharing of optional email
    < 4.0.9
    Fixed discard changes popup
    < 4.0.8
    Color fixes
    < 4.0.7
    Header color extended behind when swiping down to dismiss
    New header for iOS
    Removed blur components
    New app bar color theming
    Fixed font and colors for rich text
    Upgraded to Flutter 3.13.2
    < 4.0.6
    Secondary header to match iOS style
    Fixed transition backdrop for popup sheet on iOS
    Fixed mixup with status bar icon color on iOS
    < 4.0.5
    Animated text style
    Added plus button to add category, title, budget, wallet in actions in edit page
    FAB always adds a transaction on root page
    New plus button for adding a budget
    Fixed day counter in remaining days of budget
    Discard changes popup when adding new transaction, category, and wallet
    Fixed select category icon bottom sheet sizing
    Fixed status bar icon color
    Changed font for iOS back to default
    Decreased vertical empty space in iOS
    Added 'Done' button when editing multiline notes on transactions page for iOS to minimize keyboard
    < 4.0.4
    Hot fix for adding transactions and budgets
    < 4.0.3
    Fixed discard changes popup when transaction missing period length
    < 4.0.2
    Fixed toggling between category spending limits when from edit budget page would cause inconsistent saving of data
    Fixed income arrow indicator width
    Fixed swipe down background on backups page for iOS
    Reworded Google Drive backup for iOS
    Added per day indication for amount remaining
    Fixed remaining days (added 1) to be more logical
    Can swipe down to dismiss immediately with iOS scroll physics
    Heatmap scroll to load now loads if greater than extent
    Custom product IDs platform based support
    < 4.0.1
    Fixed heatmap popup alignment for iOS
    Fixed background for premium products
    Fixed updating the period length and type for transactions
    Added transition for bottom action button in edit transaction page
    < 4.0.0
    Fixed positioning and spacing of income/outcome arrow
    Ability to copy amount of loans and scheduled total amount
    Value copied to clipboard shown in snackbar
    < 3.9.9
    Select budget type popup and info when creating a budget
    Fixed loans and upcoming page search bar and tabs for larger screens
    < 3.9.8
    New heatmap homepage widget! (disabled by default)
    Fixed stuck loading on launch if Google Drive permission denied
    Income and expense arrow for upcoming page
    Hint text for loans page
    < 3.9.7
    Max amount for budget, max period length for budget, period length cannot be zero
    Fixed over-scroll stretch when keyboard opens with bottom sheet
    Fixed color picker
    < 3.9.6
    New scheduled and loans pages with search
    Added currency name in transaction entry when multiple currencies used
    Cleaned up Cashew Pro screen
    < 3.9.5
    Premium popup dismissed after purchase
    Continue for free developer message
    AnimatedExpanded is now fully expanded when first rendered, if set
    Restart lock side navigation fix (Can't use settings since settings were most likely reset)
    Safe area added for custom popups
    < 3.9.4
    Biometric popup instead of error container
    Biometric setting error container
    Translations
    < 3.9.3
    Connecting to store error dark text and tap to reload store
    Removed re-snapping bottom sheet when entering amount
    Scrollbar safe area removed (safe area is already applied in parent)
    When restart popup, side navigation is disabled
    New sync button on navbar, follows other navbar button styles
    Material date pickers for iOS
    < 3.9.2
    Yearly plan savings (Disabled for now)
    Upgraded to support Flutter 3.13
    < 3.9.1
    Significantly improves speed of CSV import - use batching
    CSV progress fix
    iOS notifications status warning refreshes properly
    iOS Google login fix
    < 3.9.0
    Fixed locale loading for changelog
    SF Pro font for iOS devices
    Notification permission checks for iOS
    < 3.8.9
    If not much height space when searching edit pages, the settings options are hidden
    Category transaction count no longer considers wallet
    < 3.8.8
    New animated size animations
    Autocomplete fixed for titles
    Related titles recommends categories again
    Budget total label setting
    Premium page formatting fixes
    Fixed today indicator position
    Translations
    Changelog only shown if English
    Color tweaks
    < 3.8.7
    Fixed purchase listeners getting duplicated
    Fixed associated title not updating in edit category page
    Today indicator always stays on screen and line follows
    < 3.8.6
    Disabled dangerous debug flags
    Payment processing and plan management
    Exchange rate info page
    Rearranged about, more, and settings page
    Settings page updates UI when orientation changed
    < 3.8.5
    Homepage now shows the past 7 days with transactions within the past month
    If sign-in fails on launch, it will retry on next launch
    If sign-in fails on user action, it will not retry on next launch
    Number backups is remembered for loading shimmer
    View delete logs in debug flags page
    All delete logs erased after exiting preview mode - this would create issues if user syncs
    Fixed reset language on backup load
    Today indicator in budget more accurately shows the current day progress
    In edit home, tapping container toggles switch
    Fixed notification transaction name
    Tapping upcoming notification transaction, opens transaction details
    Leave rating loading popup
    Title of pages capitalized
    Fixed system language reset when restoring backup
    Removed maybePop because it causes will pop scope to activate (save changes popup)
    < 3.8.4
    Home page line graph reset if selected graph deleted
    Add all selected transactions to a category
    Date time modified wasn't properly updated on some queries
    Improved reordering of titles
    Polished and improved delete process of everything
    Original due date stored when transaction paid
    Fixed left safe area
    New navbar on Android
    < 3.8.3
    Select wallet and select budget now uses radio buttons bottom popup
    Added rounding to decimal precision when converting to money
    Radio item now highlighted when selected
    Radio items support colors
    Only expenses can be added to budgets when using add to budget action bar
    When ask for transaction title disabled, full snap is not used anymore
    Fixed home page graph and selecting budget graph - using old number values for id
    Added bottom spacing to avoid add button for borrowed and lent pages
    Fixed long press actions - such as long press to reorder for categories on iOS
    Back button returns to homepage before exiting app
    Removed sync on every change option for non-web
    Fixed select budgets pin on home page edit
    ScaledAnimatedSwitcher now used on selecting budgets pin icon
    Current pinned to homepage status of budget shown in dropdown menu
    Language is reset when restoring a backup - fixes issue with language label not correctly matching when restoring
    Note: Language cannot be restored because initializeSettings when databaseJustImported is false does not have access to context
    Removed delay after selecting language
    Add or edit titles snaps to full screen always
    < 3.8.2
    If category deleted, generate preview still functions
    Preview data has random times added
    Ability to change budget on selected transactions
    Ability to change wallet on selected transactions
    Fixed recommended associated titles
    Pre-cached onboarding images
    < 3.8.1
    Added spending limits to preview
    If currency conversions are null, a factor of 1 is used as conversion
    Preview demo mode
    Migrated database to use String UUIDs
    Reduced popup snapping, increased snapping to max on certain popups
    Action bar has create transaction copy button
    < 3.8.0
    Cashew pro background now extends past scrollable area - support for iOS over-scroll
    Proper currency for editing wallets row entry
    Fixed iOS tappable long press but incomplete would freeze animation
    Swipe along checks to select transaction
    New transaction selection enabled for web
    iOS new selection check icon for transactions
    iOS rounded corners style for more components
    < 3.7.9
    Suggest icon popup and suggestion container
    New divider colors
    New language picker
    Fixed income and expense start date
    Spending goals button to edit budget page
    Budget page progress bars contrast color fixes
    Selection click vibration instead of impacts
    Fixed biometrics crash
    Back button exits app on Android
    Fixed border on past budgets page when not in iOS
    Edit spending goals button directly above categories on bigger screens
    < 3.7.8
    Bottom safe area for popups
    Extra action now located as a full bottom button for popup
    Refactored select amount widget
    New tappable widget for iOS - Fade animation
    Better horizontal padding resizing
    Increased width when using horizontal padding constrained
    Fixed safe area in horizontal mode, left and right safe areas
    Fixed subtitle animation speed
    Long press vibration on iOS
    Slow open container animation iOS
    Animated budget containers disabled on iOS
    Animated Premium banner disabled on iOS
    Removed blur effects by default on iOS
    < 3.7.7
    Added disable blur option
    Fixed iOS onboarding page
    Changelog can always be opened when forced
    < 3.7.6
    Fixed recommended spending amount sizes
    Backup limit shown in backup popup
    iOS Google backups are branded as Google Drive
    Fixed scroll to top for transactions list page
    Backup limit option hidden
    Premium banner uses open container animation
    Moved translation help to about page 
    < 3.7.5
    Cashew Pro banner in settings
    Removed old implementation of associated titles lookup
    Added vibration when scrubbing through line graphs
    New budget history container for iOS
    Current period in past budget periods is only labelled as current period if it is one
    Fixed scroll animations when scrolled past 0 in iOS
    Fixed past budget periods, if the 31 of the month it fails to show certain past periods, such as Feb
    Removed vibration for iOS bottom sheet
    Universal IO for locale on web
    Translations
    < 3.7.4
    Improved decimal precisions and support for comma locale
    Fixed animations in enter amount
    Added border color to wallet pickers
    iOS homepage scroll animation fix
    Fixed amount range filters getting added on first open
    Spending goals moved to separate page
    New dropdown menu actions for app bar
    Fixed merge category
    Google login warning on iOS
    Add element to database key generation uses auto increment
    Done for: wallets, budgets, transactions, categories, titles, scanner templates
    < 3.7.3
    Edit row action button animated scale switcher
    iOS notification configurations
    Can select primary wallet in edit wallets list page
    Pick custom color gradient outline
    New iOS popup bottom sheet layout
    New iOS edit row entries
    Material You setting moved to accent color for iOS
    Upcoming transaction icon changed
    New iOS navigation bar
    Fixed max offset for back gesture animation
    Now can 'undo' back swipe progress be going in reverse
    Fixed add budget page pin icon pushed too far offscreen
    Fixed blur effect
    Navigation gesture resets screen when a popup preventing navigation pop
    < 3.7.2
    Transaction type action button size re-checked when changed in add transaction page
    Fixed upcoming transaction actions removing popup not finding context after database updated
    Upcoming and Overdue transaction amounts get refreshed every 5 seconds - since the query uses DateTime.now() it needs to be refreshed
    If transaction type changed, createdAnotherFutureTransaction is now reset
    Added blur behind app bar for iOS
    Fixed scroll animations for iOS
    Added swipe to go back gesture
    Refactored iOS debug settings
    New iOS header colors and icons
    Fixed range slider in filters
    Silent sign-in when platform error when not on web
    < 3.7.1
    Cashew Pro popup
    Custom context menu refactored
    Removed counting of number in add transaction page
    < 3.7.0
    Fixed gradient in save button for transaction action
    Selected filter chips on search page
    Context menu appear height higher than target
    Vibrate on show custom context menu
    Added quick fade to context menu
    Added scroll to top arrow on edit data pages
    Made added budget icon background more prominent
    Only perform auto sync if user is already logged in
    No longer asks to restore a backup, instead it automatically restores the 'sync' backups before launched
    Streamlined login and restore backup process
    < 3.6.9
    Fixed padding on Google login button
    Fixed flickering of count up beginning amount
    Fixed animation and spacing for past budget containers when selected on mobile
    < 3.6.8
    Transaction amounts round properly - when using CountUp
    Transaction entry converted amount matches set decimals of other wallet
    Amount is lighter color is it does not count towards total
    New belonging to budget tag in transaction entry
    Removed icon shadows
    Added background color to category icons in UI
    < 3.6.7
    New add transaction layout for large screens
    Added website meta tags
    Removed system color on web causing issues on Mac
    < 3.6.6
    Started transaction type actions within add transaction page
    Transaction entry type buttons changed to be more streamlined
    Refactored transaction entry
    Transactions on lent and borrowed page combine when selected
    Changed income selector in edit category page
    Fixed spacing in edit category page
    Text size fixes on smaller screens for adding titles and category names
    < 3.6.5
    All spending total fixes now accounts for currencies
    New line graph intervals and visuals
    Line graphs now account for spending before that date
    Added new debug option: start spending at 0 for line graphs
    Fixed horizontal line for custom budget periods
    New settings page layout for mobile
    Remove battery saver setting
    Removed username setting
    < 3.6.4
    Fixed when converting a transaction into a subscription, upcoming, or repetitive, it would be marked as paid
    Fixed upcoming notifications were getting set if before the current time
    Disabled icon searching on other languages
    Added preview data generation in debug menu
    < 3.6.3
    If sign-in fails on launch, boarding page does not proceed
    Selected transaction opens with selected color
    Fixed color of past budget container
    Delete category warning and ask about transfer transactions
    Fixed calendar able to be opened more than once with sidebar
    Added (control + c) and (control + v) shortcuts when entering amount
    New sync button on sidebar
    New login and refresh sync system for web
    If auto backup hasn't been made when user signs in, will make backup
    Web no longer attempts to log user in on launch
    Snackbar centered if side navigation bar enabled
    Disabled drag down to dismiss when action does nothing
    Fixed double routing for quick actions
    Fixed translations
    < 3.6.2
    Search string no longer gets reset when filters cleared
    Added quick action shortcuts on Android - Add transaction and view budgets
    Name entry is auto focused when adding a category, wallet etc.
    Fixed colors of background progress indicators on budget page
    Added shadow to category icons without background
    Improved add button colors
    Fixed flickering color when using choice chip
    When watching categories in past budget page, show average and total spent for categories
    Fixed horizontal margin for past budgets page line graph
    Added paste from clipboard functionality for amounts
    Used height of display instead of ratio
    Adjusted header height based on screen size
    < 3.6.1
    Fixed Android keyboard height issue
    Fixed color of bottom sheet for padding
    Added limo and parents icons
    Long press category limit entry to edit category
    Category spending limits keeps decimals in percent when editing
    Switching absolute budget spending limit converts values properly between percent and absolute
    < 3.6.0
    Consistent routing used when logging in with Google
    Long press selected multiple transactions total in app bar to copy amount
    Long press to copy amount in edit transaction page
    Context menu for select amount - copy and paste
    Context menu experiments
    New context menu on web
    Fixed cache image not changing image if category changes
    Sidebar user login fixes
    Download SQL backup by long pressing
    Removed shadow for past budget container when material you
    Choice chips follow background when deselected
    Decreased background of popup in light mode material you
    Increased efficiency of updating settings
    Refactored Google User global
    Transactions page, if empty, displays the time period
    Home page is only refreshed when user closes Edit Home page
    Added translations help text in settings
    New FAB animation when switching pages
    < 3.5.9
    Icon for watched categories has background if selected
    Fixed flickering select category
    Fixed wrong initial type for watchedCategoriesOnBudget
    Picking budget in initial category selector properly updates UI in add transaction page
    If language is 2 words, line break added to reduce width of language picker dropdown
    System color is more expressive when Material You is enabled - modified lightDarkAccentHeavyLight when using system theme color
    Load more in budget history follows budget colorscheme
    Moved load more past time periods button to upper right in graphs
    Unpaid transactions are always at the top of the day section
    New subscription transactions keep time
    Only mark subscriptions as paid if setting enabled
    Fixed if no date selected in custom start date for home page line graph
    Cached category icons for transaction entry
    Notifications translations
    Fixed 24 hour clock on System language
    Border radius on account and backup settings
    < 3.5.8
    Fixed edit pages titles translations
    < 3.5.7
    Fixed line chart showing an extra max X point
    Fixed past spending line chart bottom titles spreading
    Fixed line chart bottom titles if not full number
    Past budgets fade in when loaded
    Fixed transaction entry border radius
    Fixed transactions count for transactions amount boxes
    Sped up counting number animations
    Navigation bar clock uses 24 hour format respective of locale
    Long press choice chips to edit corresponding item
    Enter amount watches wallets
    Today indicator animation fixes
    < 3.5.6
    Fixed offset of sliver sticky header, pushed it up by 1 pixel
    Fixed force set budget amount before adding when total null
    Added visual breaks when full screen add transaction page
    Option to select addable budget when selecting category when adding transaction for the first time
    New languages supported
    More translations
    Cleaned up unused imports
    < 3.5.5
    Fixed app bar top safe area
    Corners mesh together on selected transactions when grouped together
    Fixed landing page no wallet existed because database was not initialized - since it needs to be initialized after UI and translations are loaded
    Amounts would start with "0" when performing calculations
    Home page username formatting
    Wallet selector undefined when app first loaded
    < 3.5.4
    Added labels to language picker
    Today indicator size fixes
    Newest transaction for that day at top of list
    Fixed header animations with respect to header max size
    Wallet selector in add transaction page
    Convert to primary currency button only shows if selected currency is different
    Removed rounded corners on top app bar
    Only show other currency in transaction entry if the currency is different, not just the wallet
    Account and backup translations
    Fixed bottom padding in accounts page
    Fixed action buttons and back button sizes
    Header size fixes
    Header transitions smoothly to background color again
    More translations
    < 3.5.2
    Added start date option for spending graph home screen widget
    Added start date for income and expense home screen widget
    Fixed transparent error on release mode
    Fixed placeholder translations
    < 3.5.1
    Fixed silent sign-in missing scopes for web, will ask user to re-sign-in if scopes are needed for backup, syncing etc
    Fixed default names for wallet and categories
    Generate translations files script
    Added more translations and support for switching languages
    About page only shown in more actions when sidebar hidden
    Click time and date in corner to view calendar popup
    All rating stars now animate when value changed
    Rounded setting containers when sidebar enabled
    Indeterminate loading bar uses 5 second timeout
    < 3.4.8
    Added more icons for categories
    About page uses smaller icon
    Error widget shows transparent container in production
    Ghost loading transactions have max width
    < 3.4.7
    Notes input when title is asked when using a large screen
    When focus is false, Notes input updates with any links inputted
    Changed height of wrapped choice chips
    Fixed budget pie chart icon different size on settings page
    Loading indeterminate progress same width as sidebar when full screen
    < 3.4.6
    Fixed past budgets if the day of the month was towards the end
    Fixed filter button shows applied if searching in search bar
    Fixed income/expense in wallet summary page
    Fixed silent Google sign-in on web
    < 3.4.5
    Fixed color of total spent text when hovering over past budget line graph with watched category
    < 3.4.4
    Sync after every change progress bar has opacity to be less distracting
    Selected transactions action bar has similar shadow to page titles
    Note only shows while hovering on web
    Fixed web import backup
    If editing category, selecting an icon won't force change the title of the category
    Category gets updated properly if changed on Add Transaction page
    Fixed date setting reset the selected time to midnight
    Started translations
    Recommended title selecting category now selects the title
    Fixed double transactions at midnight on web
    < 3.4.3
    Select categories to watch is now bottom sheet
    Can open down down container by tapping the entire settings block
    < 3.4.2
    Rearranged files
    Fixed colors on wallet summary spending graph
    < 3.4.1
    Color tweaks for select chips
    Expense and Income pages open up to search page with selected filters
    < 3.4.0
    Transaction filters on search page completed and working
    Scroll to top of page button on search page
    < 3.3.3
    Started search filters - they can be selected properly
    Added descriptions to settings
    Colorful NoResults when Material You disabled
    Disabled scroll to top when swiping through months on transactions page
    Disabled vibration when full screen bottom sheet on bouncing scroll physics
    Added bottom padding to each page w.r.t. safe area
    Added add transaction FAB to search page
    Added setting to mark subscriptions as paid automatically
    iOS scroll physics when swiping page down to dismiss budget page shows proper color
    Lent and borrowed transactions pages complete
    Upcoming transactions notifications follow the time of the transaction
    Fixed category icon percentages on wallet details page
    Fixed income warning when adding to specific budget
    < 3.3.2
    Fixed button label colors
    Budget container background follows theme of budget
    Fixed adding shared transactions would think it was income
    Placeholder when percent is 0 for category spending goals
    Debts and credit renamed to Lent and Borrowed
    Upcoming and overdue transaction page total centered
    < 3.3.1
    Fixed select chips scroll to selected when small index on non-scrollable list
    Changelog hidden on first launch
    < 3.3.0
    Debts and credits work in progress - use if you lend money or someone owes you money
    Fixed onWillPopScope and back swipe for iOS
    iOS navigation debug flag
    Splash color disabled on iOS
    Page transitions use new fade in from bottom animation
    Select chips follows height of ChoiceChip
    Select chips scroll to the selected chip
    < 3.2.2
    Officially removed DateTimeCreated - merged into dateCreated
    Removed right arrow on outlines settings containers
    Ask for transaction title disabled by default for devices with older Android version (since keyboard height changes do not update the UI)
    Bottom sheet snaps to 0.6 only if tall display
    Safe areas improvements
    Select category, add category button follows ratio of 1:1
    Reordering grid view waits until async finishes before updating UI
    < 3.2.1
    Fixed horizontal line in added budgets only when time period over
    Only show new changes in changelog based on version
    < 3.2.0
    Date and time merged into one variable
    Fixed feedback colors
    Added ghost transactions when loading
    New no results and nothing found images
    No results in budget page follows tint color
    Fixed member spending not showing up because of Provider
    Can select time of day for a transaction
    Leave feedback doesn't wait to connect to store (closes immediately)
    Watched categories in budget history are saved
    Can only select the categories that are selected for that budget
    Tooltip with colors when selecting categories to view in past budgets page
    MaxY follows that of the selected categories
    Can select categories and compare category spending on budget history page
    Pull to refresh for email parsing option
    Refactored ask for notification time
    Circular progress UI size tweaks
    Ask for rating is no longer delayed
    Fixed category spent amounts in budget page
    Web upcoming/overdue transactions centered subtitle
    Web wallet summary layout width constrained
    Added percentage budget limits
    Fixed notification times
    Fixed past budget, budget page line graph horizontal line 
    Added share feedback button
    Added open source link
    Finished rating popup
    Improved FadeIn, ScaleIn widgets
    Improved bottom sheet when extended
    When bottom sheet full screen, little vibration
    Started rating popup
    Updated web icons and loading animation
    First budget history entry says current period
    When category selected, goal line not always in view
    Fixed transfer wallets
    Refactored the way currencies are handled
    Fixed some transactions not displayed if they occured at the end day of a time period
    Horizontal progress bar for spending goals visualization in budgets page
    Add transaction page uses 2 columns on larger displays
    Spending target always shown on budget spending line graphs
    If missing mandatory information, bottom button guides user to fill in that information
    Add category button at bottom of category limits list in budget page
    If custom budget range out of date, its height is smaller since less details are shown
    Incognito keyboard debug option
    Warning if missing notification permission
    Fixed notifications permissions
    Budgets in a grid on wider displays
    Disabled change transaction page if navigation bar hidden
    Month is always centered on transaction page when changing screen sizes
    Fixed battery saver colors
    PageView on transactions page uses builder for infinite built on demand scrolling
    Transactions page has a more uniform look
    Refactors main.dart
    Refactored homepage
    No results formatting fixes on web
    Fixed browser info on web
    Fixed homepage on web
    Onboarding completed
    Added re-orderable homepage sections
    Fixed if budget amount is 0
    Tapping upcoming transaction notification opens Overdue transactions page
    Fixed category budget limits if budget goal is 0
    Listens to a day change and all data is updated accordingly
    Title left empty if entered title matches exactly that of a category
    Fixed initial selected amount
    'You should save...' text removed for custom time range budgets out of range
    Upcoming transactions paid/skip payment buttons fixes
    Username trimmed
    Budgets pinned picker and spending graph selection in edit home page
    Moved settings to edit home page
    Doesn't show wallet picker if only one wallet, ignores cached amounts
    Fixed budget total in budget details page
    Started edit home page sections
    When adding a budget in transactions page, it defaults to added only budget
    Edit Category list shows income/expense category
    No results icon in Subscriptions page
    Adding budget on transaction page defaults to Added Transactions only
    No result respects upcoming transactions in budget page
    No results/search results found indication 
    If deleting a wallet, can choose to transfer transactions to another wallet
    Category Budget Limits merged with Category with Total
    Select amount wrap fixes
    Fixed time picker font size
    Added web app link to sync page
    Copy to clipboard on long press for AboutInfoBox links
    Improved budget page and budget widget size and formatting
    Improved wallet selection size and formatting
    Moved extra settings to debug page
    Disabled email scanning and shared budgets - only accessible in debug menu
    Added warning when deleting added transactions only budget
    Improved CSV import with custom date format
    Default wallet on first startup follows locale
    New currency picker
    Wallet summary and all spending now shows 10 days of recent transactions
    All spending totals sorted by total
    Tintable category icons debug option
    Budgets are watched in budget selection
    Removed "All" filter
    Can't add income transactions to a budget
    Kotlin version upgraded
    Improved contrast of cursor color in text input
    Removed today indicator on custom budget time period if progress larger than 100
    Added edit button to budget list page
    Added button to convert selected currency to primary wallet
    Order of wallets followed in add transaction
    Fixed timezones - use isOnDay instead of date.year.equals etc https://github.com/simolus3/drift/issues/1933#issuecomment-1189561299
    Fixed duplicated category totals when using different currencies
    Changed design of edit/reorder cards
    Reordering now uses batch updating
    Fixed reordering animation glitches
    Improved currency picker, add wallet page
    Popup can scroll when too large
    Started on custom decimal place precision for wallet
    Fixed wallet currencies icons
    Biometrics unlock required verification to enable/disable
    Improved biometrics unlock page
    Rename nickname by tapping on homepage
    Improved recommended titles when adding transactions
    Opted for MultiExecutor for database
    Total transaction count at bottom of budget page
    New app icon
    Added line graph background on budget page
    Started filters page
    Animation speed debug setting (modifies time dilation)
    Changed how colors are managed to follow flutters theming engine closely
    Added fallback font for missing characters
    Added font picker
    Fixed backup time of specific client
    Tap amount left/spent to toggle between setting on budget page
    Fixed delete shared budget cancel saying it deleted budget
    Max width for popup
    Can only select other users if Shared to Other Budgets filter enabled
    Links properly append http and www.
    Links properly cropped
    Can select all users and all filters respects the default null value (means all selected) in add budget page
    If syncing setting disabled sidebar setting hidden
    Title centered when screen wide enough
    Budget history graph pinned to top when scrolling through
    Budget history graph updates properly when budget changes attributes
    Fixed parsing emails with certain format
    Pie chart only larger if double column enabled
    When navbar switches pages, routes popped without animation
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
    (need to track the time you last synced with that specific client e.g. if change made on mobile, web syncs now, wait 5 seconds, then mobile syncs, - web thinks that it got that latest version from mobile already changes not here!)
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
    Colors discard changes discrepancies fixed
    Selected color selected properly when editing
    Can tap snackbar messages for some actions
    Email scanning redone
    Email scanning profiles and different templates
    Home page animations
    Home page transactions list shows upcoming transactions (3 days before)
    Fixed adding wallet unreferenced widget for animation
    Started currency picker for wallet
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
}

// If they were not already seen by a user, they are shown at the top of the changelog
Map<String, List<MajorChanges>> getMajorChanges() {
  return {
    "< 4.4.1": [
      MajorChanges(
        "major-change-1".tr(),
        Icons.arrow_drop_up_rounded,
        info: [
          "major-change-1-1".tr(),
        ],
      ),
      MajorChanges(
        "major-change-2".tr(),
        Icons.category_rounded,
        info: [
          "major-change-2-1".tr(),
        ],
      ),
      MajorChanges(
        "major-change-3".tr(),
        Icons.savings_rounded,
        info: [
          "major-change-3-1".tr(),
          "major-change-3-2".tr(),
        ],
      ),
      MajorChanges(
        "major-change-4".tr(),
        Icons.home_rounded,
        info: [
          "major-change-4-1".tr(),
          "major-change-4-2".tr(),
        ],
      ),
      MajorChanges(
        "major-change-5".tr(),
        Icons.emoji_emotions_rounded,
        info: [
          "major-change-5-1".tr(),
        ],
      ),
      MajorChanges(
        "major-change-6".tr(),
        Icons.bug_report_rounded,
        info: [
          "major-change-6-1".tr(),
        ],
      ),
    ],
    "< 4.4.6": [
      MajorChanges(
        "major-change-7".tr(),
        Icons.timelapse_rounded,
        info: [
          "major-change-7-1".tr(),
        ],
      ),
      MajorChanges(
        "major-change-8".tr(),
        Icons.price_change_rounded,
      ),
    ],
  };
}

Future<void> showChangelog(
  BuildContext context, {
  bool forceShow = false,
  bool majorChangesOnly = false,
  Widget? extraWidget,
}) async {
  String version = packageInfoGlobal.version;
  List<Widget>? changelogPoints = getChangelogPointsWidgets(
    context,
    forceShow: forceShow,
    majorChangesOnly:
        Localizations.localeOf(context).toString().toLowerCase() != "en"
            ? true
            : majorChangesOnly,
  );

  //Don't show changelog on first login and only show if english, unless forced
  if (changelogPoints != null &&
      changelogPoints.length > 0 &&
      (forceShow ||
          (appStateSettings["numLogins"] > 1
          //   &&  Localizations.localeOf(context).toString().toLowerCase() == "en"
          ))) {
    openBottomSheet(
      context,
      PopupFramework(
        title: "changelog".tr(),
        subtitle: getVersionString(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [(extraWidget ?? SizedBox.shrink()), ...changelogPoints],
        ),
        showCloseButton: true,
      ),
      showScrollbar: true,
    );
  }

  updateSettings(
    "lastLoginVersion",
    version,
    pagesNeedingRefresh: [],
    updateGlobalState: false,
  );
}

List<Widget>? getChangelogPointsWidgets(BuildContext context,
    {bool forceShow = false, bool majorChangesOnly = false}) {
  String changelog = getChangelogString();
  Map<String, List<MajorChanges>> majorChanges = getMajorChanges();
  String version = packageInfoGlobal.version;
  int versionInt = parseVersionInt(version);
  int lastLoginVersionInt =
      parseVersionInt(appStateSettings["lastLoginVersion"]);

  if (forceShow || lastLoginVersionInt != versionInt) {
    List<Widget> changelogPoints = [];
    List<Widget> majorChangelogPointsAtTop = [];

    int versionBookmark = versionInt;
    for (String string in changelog.split("\n")) {
      string = string.replaceFirst("    ", ""); // remove the indent
      if (string.startsWith("< ")) {
        if (forceShow) {
          changelogPoints.addAll(
              getAllMajorChangeWidgetsForVersion(string, majorChanges) ?? []);
        }

        versionBookmark = parseVersionInt(string.replaceAll("< ", ""));
        if (forceShow == false && versionBookmark <= lastLoginVersionInt) {
          continue;
        }

        majorChangelogPointsAtTop.addAll(
            getAllMajorChangeWidgetsForVersion(string, majorChanges) ?? []);

        if (majorChangesOnly == true) {
          continue;
        }

        changelogPoints.add(Padding(
          padding: const EdgeInsets.only(bottom: 5, top: 3),
          child: TextFont(
            text: string.replaceAll("< ", ""),
            fontSize: 25,
            maxLines: 10,
            fontWeight: FontWeight.bold,
          ),
        ));
        continue;
      }

      if (majorChangesOnly == true) {
        continue;
      }

      if (forceShow == false && versionBookmark <= lastLoginVersionInt) {
        continue;
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
    if (changelogPoints.length > 0)
      changelogPoints.add(
        SizedBox(height: 10),
      );

    if (!forceShow) changelogPoints.insertAll(0, majorChangelogPointsAtTop);
    return changelogPoints;
  }
  return null;
}

int parseVersionInt(String versionString) {
  try {
    int parsedVersion = int.parse(versionString.replaceAll(".", ""));
    return parsedVersion;
  } catch (e) {
    print("Error parsing version number, defaulting to version 0.");
  }
  return 0;
}

String getVersionString() {
  String version = packageInfoGlobal.version;
  String buildNumber = packageInfoGlobal.buildNumber;
  return "v" +
      version +
      "+" +
      buildNumber +
      ", db-v" +
      schemaVersionGlobal.toString();
}

class MajorChanges {
  MajorChanges(this.title, this.icon, {this.info});

  String title;
  IconData icon;
  List<String>? info;
}

List<Widget>? getAllMajorChangeWidgetsForVersion(
    String version, Map<String, List<MajorChanges>> majorChanges) {
  if (majorChanges[version] == null) return null;
  return [
    SizedBox(height: 5),
    for (MajorChanges majorChange in (majorChanges[version] ?? []))
      Padding(
        padding: const EdgeInsets.only(
          bottom: 5,
          top: 5,
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButtonStacked(
                filled: false,
                alignLeft: true,
                alignBeside: true,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                text: majorChange.title.tr(),
                iconData: majorChange.icon,
                onTap: () {},
                afterWidget: majorChange.info == null
                    ? null
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (String info in majorChange.info ?? [])
                            ListItem(
                              info.tr(),
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    SizedBox(height: 10),
  ];
}
