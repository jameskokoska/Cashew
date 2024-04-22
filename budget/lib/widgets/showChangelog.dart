import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/creditDebtTransactionsPage.dart';
import 'package:budget/pages/editCategoriesPage.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/objectivesListPage.dart';
import 'package:budget/pages/settingsPage.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/outlinedButtonStacked.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'listItem.dart';

// Device legend
// Apple rejected app update because Android was referenced... We use code names now!
// (i) = iOS
// (A) = Android

String getChangelogString() {
  return """
    < 5.2.9
    Collapsible future transactions list section (if more than 5 transactions in the future)
    Number pad format setting
    Account selection for homepage pie chart section
    Improved income/expense only selection in homepage pie chart
    Added ability to change only income/expense in homepage transaction list
    Long press transaction list tabs on homepage to edit settings for transactions list
    Homepage transaction list tab income/expense filters are properly applied to the homepage graph
    Collapse wallet list selection if all wallets selected when editing homepage section
    Improved home screen widgets (A)
    Max lines for filter title contains and note contains input
    Optimized and improved performance of transaction list actions
    Collapsed future transaction list shows amount selected when collapsed
    Importing CSV preview parsed custom date format
    Enter amount beginning with negative sign
    Tap amount on range filter to specify exact upper and lower range
    Add extra spacing between edit home page alignment headers (when in full screen)
    Add elevation shadow to scroll to top and bottom FAB
    Rearrange number format settings in popup for consistency
    Add time to date info when deleting cloud backup
    Number of transactions includes unpaid transactions
    Balance correction amount color category setting
    Account spending detail page follows account colorscheme
    Improve colorscheme for budget and goal pages
    Border radius UI and color consistencies
    Translation updates
    Fix font setting always resetting (i)
    Fix exclude amount from budget default value for include amount overall would be incorrect
    Fix (i) biometric lock bypass
    Fix net total date banner initial net total when time period set to all time
    Fix All Spending page swipe to dismiss color when in full screen
    < 5.2.8
    New edit selected transactions popup
    Edit title for all selected transactions
    All time date range in search transaction page
    Search multiple title names by separating 'title contains' filter input with a comma
    Homepage transaction list setting - amount of days ahead to list transactions
    When editing goals/loans list, the total amount is listed for each entry
    Removed ability to enter decimal when setting certain values
    Refactor floating action button
    Auto-fill transaction titles in title inputs
    Swipe down to sync on widescreen layout
    Amount polarity for upcoming and overdue transaction totals
    Bill splitter generate loan transaction steps improved - custom date, title recommendations, select subcategory
    Prevent save changes button hide when keyboard opened
    Deep linking API (A): Automatically add multiple transactions per link using JSON (view [About] page for information)
    When importing CSV, if subcategory exists with the CSV entry category name, subcategory will be used
    Improved UI layouts and icons for clarity
    Added full black dark mode for Material You theme (A)
    Increased contrast of selected subcategory chip in add transaction page
    Fix padding for spending graph and space for side labels
    Fix when back swiping, swipe to dismiss is properly cancelled
    < 5.2.6
    New account spending summary table
    Improved navigation to respective pages when filters/date ranges set in spending summary table
    Improved custom number format
    Added complete editing text action button in add transaction page
    Fix date range filters for account graph
    Fix line graph double currency icon in label
    Fix currency exchange icons
    Translation updates
    < 5.2.5
    Revamped homepage pie chart section
    Custom number format support
    Searching date in search bar shows transactions from that time period
    Date range included when applying filters on transaction search page
    In transaction search page, added ability to jump to the bottom of the list
    Scroll to bottom/top does not animate if list too long
    Excluded budget transactions still show up in the budget list as excluded
    Select all option when selecting transactions
    Long pressing home page tab allows for edit home page
    Number animation setting
    Edit primary wallet currency setting for clarity, even though you can edit the account directly
    Default account labelled in edit accounts page
    Goals now show amount spent above total, if goal total type set to Total Amount
    Short number format setting
    Months list in transaction page cannot be scrolled past the earliest and latest transaction entered date
    Added all outgoing/incoming or just expense/income transactions setting for homepage pie chart
    Added color outlines to transaction filters
    Optimized onboarding page
    When loading backup, backup file name is displayed
    Fix reset the paid state when changing transaction types
    Fix cash flow filters when entering search page from positive/negative cashflow
    Fix polarity of lent and borrowed home screen sections
    Fix decimal precision save changes button for account edits
    Fix clipping of goal tag progress
    Fix default long term loan type when adding via plus button
    < 5.2.4
    Improved UI layout when creating a goal/long term loan
    Long term loan offset (useful for adding interest to long term loan totals)
    Deep linking API (A): Automate the adding of transactions using app URL links (view [About] page for information)
    Fix color picker initial color value
    Fix importing of backup and CSV files (A)
    Fix widget launching add transaction route twice
    Fix account list name alignment
    Fix widget action launch timeout on first launch
    Fix adding transaction from subscription/upcoming page defaults to unpaid
    Fix archived long term loan amounts no longer count towards total summary
    Fix long term loan total amounts and collect/settle amounts per day
    < 5.2.3
    Fix currency rates API
    File attachment in-app image preview
    File attachments use device date time instead of UTC
    Custom tab pages, can tap the active tab again to scroll to top
    Most repeated transactions list only show if are of normal transaction type
    Disabled automatic home page section enable when adding first budget/goal
    Remove delete button from app bar for long term loans
    Consistent padding alignment for date picker
    UI alignment fixes
    Border radius tweaks (i)
    < 5.2.2
    Exclude transaction from counting towards reports and totals (in more options)
    Percentage decimal precision setting (in Settings > More Options > Formatting)
    Graph axis label supports locale and short form for > 1,000
    Fixed text focus resume for inactive app
    If accounts all have same currency, currency label is removed in select chips
    Unfocus and remove focus node from cache when navigating
    Fixed confetti canvas size for completed loans/goals
    Removed selectable accent colors that don't change the app theme
    < 5.2.1
    Transfer transactions always ordered with transfer out (negative amount) listed first
    Removed last word title autocomplete predictions
    Capitalization inherits from auto completed titles
    Auto refocus only if focus was not lost
    Changed homepage add button icons and added labels
    Added percentage label to widget opacity slider (A)
    Decimal precision icon change and description
    Prevent transfers between same account
    Transfer button hidden if only one account
    When tapping support, Cashew Pro options highlight
    Fixed demo goals amount
    Enabled merging an account from primary account, primary account is changed instead of deleted
    Biometric unavailable popup only shows if lock was once enabled
    < 5.2.0
    If rounded to 0% but not exactly 0%, < 1% is used instead
    Improved help text in view calendar
    Widget automatically updates when settings changed (A)
    Removed ability to select accounts when only one account for net total settings
    Tapping an upcoming transaction opens overdue tab
    Currency total includes percentage
    Long press transaction type when adding transaction opens info popup
    Long press budget options when adding budget opens info popup
    Long press goal/long term loan amount to copy total to clipboard
    Consistent popup enter text confirmation buttons and spacing
    Set date time button when initially adding a transaction
    Warning text color in sidebar when synced more than 1 day ago
    Titles auto complete with partial titles
    If import CSV import fails, use template recommendation shows
    Fixed percentage spent per currency to take exchange rate into account 
    All spending page filter icon when scrolled past bottom
    No transactions found on long term loans page if all deleted
    When adding an account, defaults to device currency
    When restoring a backup, sync operations are cancelled
    If biometrics unavailable on a device, they are disabled
    Optimized fix out of order elements when data page opened
    Search requests focus automatically
    Keyboard focus resumes on app refocus from recent apps
    < 5.1.9
    Reorder theme mode settings, system is always first
    If multiple accounts with different currencies, can enable currency total summary in accounts list homepage widget
    Widget light and dark mode (A)
    Widget background opacity (A)
    More category icons
    Fixed sidebar clock not displaying time in 24 hour mode
    Date and time picker follows set color theme type 
    Fixed associated titles join
    Fixed partially collected loan filled in amount not collecting
    Archived items have opacity in selection list
    < 5.1.8
    Significantly improved associated title searching
    Search category and subcategory when entering title
    Search categories on edit categories page includes searching subcategories
    12/24 hour clock format setting
    Custom currency for transfers (tap the transfer amount to change the currency to another existing account's currency)
    When full screen, moved notifications to settings page
    After clearing title/note filter, the filter will be removed
    If no room in long term loan or goal total, extra information hidden
    Fixed initial touch unfocus when entering transaction search page
    < 5.1.7
    Overspent/over saved text for budgets displays amount total information of the current period
    Fixed rerender lag when opening transaction on search page
    Extra zeroes button new number layout
    Fixed spacing for bottom titles of line graph
    Fixed small separation between amount input buttons
    Translation fixes
    Fix multiple transaction saving events
    Fix delete account action in account picker for transaction
    < 5.1.5
    Fixed padding for full screen devices
    Fixed title searching with category name when adding a transaction (title has priority)
    Fixed wallet details page swipe to dismiss header
    Installment payment setup button follows objective colorscheme
    Hex color picker fixes
    Removed ability to long press and set custom period for loan totals on all spending page that always show all time
    Removed bill splitter deleting item on edit page
    Fixed CSV import error always opening
    < 5.1.4
    Selecting account shows total amount in the account
    Time and period range in wallet details page
    Default categories are not created after backup just restored
    Vault and holiday category icons
    Improved fix for overlapping pie chart labels
    Fixed loading past budget spending periods, -0 would be shown as the total percent
    Fixed collected/borrowed label when long term loan achieved
    Limited confetti to play only once
    Change goal/long term loan icon by tapping it in the details page
    Partially collecting/settling a loan auto fills with total amount
    < 5.1.3
    Fixed overlapping pie chart labels
    Improved background color for all spending time range quick switch header
    Fixed wallet details page line graph shows all time range
    Improved edit wallets and categories page actions
    < 5.1.2
    Fixed toggle between spending limit type for spending goals in a budget
    Added font family fallback for base components
    Delete option for recommended titles
    Focus is cleared when title is selected
    When in full screen wide, account picker wraps
    < 5.1.1
    New all spending period drop down selector: quickly change selected period on all spending page when viewing details of selected period
    Increased transaction max amount to 999,999,999,999 from 100,000,000
    When showing all time, line graph includes transactions past the current date
    When setting a title of a transaction, when editing details, it suggests titles
    Fixed re-rendering of pie chart home page graph
    Initial amount when adding wallet properly supports decimal precision
    Dropdown account picker if more than 3 when adding transaction
    Removed number format that would put subtraction at the end of the currency string
    Added explicit home page widget settings section in More Options
    Translation updates
    < 5.1.0
    Fixed polarity of net spending in all spending page history tab
    Only allow one widget launch per app lifecycle/resume
    Updated translations
    Tapping background of homepage pie chart deselects selected category
    Dropdown account picker when selecting amount for full screen when more than 5 accounts
    < 5.0.9
    Expense and income homepage selected time range and wallets for apply when search page opened
    Dropdown account selector when more than 3 accounts in Enter Amount popup
    Biometric workflow stops completely before re-authenticating
    Changed open source shortcut to about
    Fix home screen widget double launch
    < 5.0.8
    Transfer balance app quick shortcut
    Ability to select certain accounts for income/expense total on homepage
    Fixed budget history limit when watching selected categories
    New all spending summary no longer shows on wallet details page
    Most common transactions amount properly converted to main currency 
    Renamed and refactored homepage section settings
    Home screen widgets and shortcuts (A)
    < 5.0.7
    Hot fix for net worth and selected accounts
    Hot fix for search one time loans after deleting long term loan
    French language updated
    < 5.0.6
    Translation fixes for category totals
    When long term loan selected, polarity slider in add transaction follows default
    Icon for title/notes filter
    If row entry could not be reordered, opacity still follows that of archived status
    If a transactions payment has been removed, auto payments no longer marks it as paid
    < 5.0.5
    Long pressing date selector sets to current date and time
    When creating any transaction, it can be added to a long term loan 
    Loan transactions can be edited and removed from a loan
    Can select multiple transactions and add to goal
    Improved income/expense selector when adding transaction
    Multiple transaction selection actions only appear if relevant to users data
    Fixed automatic payment for transactions would be duplicated when synced
    Account transfers supported for long term loan transactions
    Pie chart homepage, revamped selection - all, positive cashflow, negative cashflow
    Fixed custom currency exchange rate, always references USD for proper conversion when entered
    All spending page spending amount breakdown improvements - see expense, income, upcoming, overdue,lent, and borrowed totals
    Ability to add custom currencies
    Refactored total and count queries
    Title and note contains filters
    If a row fails when importing CSV, it will skip
    < 5.0.4
    Better custom home page sections ordering on full screen
    Removed income/expense references when using a balance correction category
    Selecting balance correction no longer switches income/expense
    Changing goal does not update both balance corrections
    Fixed label for income category spending on budget page
    Loaded search filter for date loads at least one year into the future
    Loans are no longer counted towards income/expense totals
    Improved loan/borrowed transaction type descriptions
    Fixed total loans amount owing when tab initialized to long term loan page
    Loan filtering is more intuitive - now includes transactions from long term loans
    Flipped order of lent/borrowed when creating long term loan
    < 5.0.3
    Long term/partial loan tracking!
    Can disable transactions list on full screen
    Improved upcoming transactions in home page list
    If budgets page not pinned to tab bar, budgets on More page opens budgets list
    Swapped home page income and expense order
    Goal installments support currencies
    Fixed back button gesture to deselect categories when all spending set to main tab page
    All spending page shortcut hidden when sidebar shown
    Can hide (archive) budgets and goals
    Set date in search page is remembered
    < 5.0.2
    Fixed income pie chart in all spending
    Transfer balance button still appears when prevent delete enabled when editing wallet
    Income/expense tabs renamed when balance correction
    Refactored and organized CSV export columns
    Total cash flow for transactions list includes balance correction
    Date banner total option (can set the total displayed in the date banner to a net total)
    Cumulative all spending includes balance correction so net value is accurate
    Fixed currency when entering initial amount of wallet
    Fixed all spending cumulative page if only income transactions
    Fixed spending graph total with currencies
    Transaction page properly refreshes when changing date total
    < 5.0.1
    Fixed comma separator amounts not following number format
    Fixed selecting category on budget page properly displays spending graph for that category
    Colorful background for selected subcategory chips
    Installments supports subcategories
    Prevent add of installment transaction if missing period or amount
    Fixed goal progress out of bounds in tag
    All spending graph tooltip shows year if not the current year
    All spending history graph tooltip shows year if not the current year
    All spending graph zooms to show proper range when using cumulative spending
    Fixed gradient for all spending history graph
    Based on when you hit the (+) only certain types of transactions are selectable
    Heatmap first day follows locale
    Tap the arrow to withdraw (or select in the opposite way)
    Long pressing tabs in add transaction allows you to edit if transfer tab is shown
    Removed withdraw amount when transferring balance
    Removed pin from goals list (as it only applies to the homepage)
    Rearranged pages on More page
    Renamed all spending page shortcut on More page
    Added extra padding around extra popup button to increase visibility
    When language uses fallback font, the font is changed
    Improved snackbar title when new repetitive transaction created in the future
    Fixed creating installment would calculate to infinite amount if set to 0
    Fixed locale for Traditional Chinese language support
    Fixed exporting CSV template would give error if file already existed
    < 5.0.0
    If only one day selected in time range for all spending, line chart hidden
    Fixed time range for one day selected in all spending page
    Fixed hex color picker resetting cursor to beginning when invalid character entered
    Tweaked colors of highlighted links and link containers in notes
    All spending line graph for all time shows all time
    Fixed spending graph wouldn't load totals of transactions in the future
    Spending graph home page section can be set to all time
    Support for traditional Chinese language
    Update the date and time of multiple selected transactions at once
    Number format settings selector in more options
    Number format settings description of adding decimal precision
    Double column layout enabled if the navigation sidebar is minimized
    Auto login web app limitation note in settings
    Overdue transactions auto payment info
    If syncing fails, popup with more information is shown
    Notes with links are less cluttered with the URL shortened
    Extra zeros button (00) or (000) under formatting settings
    All spending page remembers last tab selected
    Added ATM and sim category icons
    Added fun santa hat and new years party hat to homepage during certain times of the year
    Long press pie chart home page section to edit time period
    Optimized line graph showing spending with multithreading and resolution
    Optimized all spending page category selection
    Optimized heatmap calculations
    Optimized budget details page line chart
    Migrated web database to IndexedDb to avoid local storage limits
    Removed ability to make balance correction a subcategory
    Added transfer balance tab when creating new transaction
    Added information when editing balance correction category
    Fixed editing details of balance correction or correcting balance would not have initial values for custom title and date
    Fixed goal reached calculation for expense goals when determining whether to create another repetitive transaction
    Improved goal progress bar in transaction entry
    Fixed changing the type of a transaction would reset the selected income/expense
    When marking a repetitive transaction as paid, it also marks the other balance correction
    Can create installment transactions for goals
    Setup installment payments if goal is empty directly on page
    Setup installments on long press (+) button page
    < 4.9.9
    Improved CSV import when the first row is not the header
    Improved CSV import tries to parse date with common date formats
    Fixed crash when importing many entries with CSV - database would process titles too much
    Optimized title creation when importing CSV
    Added excluded from budget transaction filters
    Deleting a transfer prompts to delete the related transfer
    Can enter color code when selecting custom color
    Account picker hidden if all the same currency on goals and budgets
    Attached files are only visible by account owner
    Improved links in notes of a transaction
    Added ability to remove links
    Added default limit for max transactions loaded in list
    < 4.9.8
    Search filters on transactions monthly page
    Search filters hides goals, addable budgets, and accounts selector if empty
    Removed added to other budget filters (irrelevant)
    Balance correction not counted towards monthly spending summary totals and daily spending banner totals
    If transaction is balance correction, amount is displayed as a faded color to indicate it is not added towards totals
    Added swipe down to refresh animation on tab pages
    Fixed emoji size for chip selection
    Fixed subcategories able to be selected as the main category
    Fixed pie chart not adding to 100% in budget page
    If file access fails, share sheet option with file
    Installments/payment plan tracking when creating transactions (linking to goals) (put on hold)
    Repetitive transactions will stop repeating after a goal is reached (if no end date set)
    In select popups (budget, account, goal), can long press to edit item entry
    Added setting to change the date transactions are marked as paid (default: today, can now be changed to keep original transaction date)
    Fixed negative zero in transaction entry goals progress tag
    Fixed crash when setting past days to a really large number on all spending graph
    Fixed naming of withdraw balance transfers
    Search page default initial date set to 1900 and next fifth year in the future
    All spending page properly respects selected date range for transactions
    Exported files use share sheet (i)
    Share sheet support for large displays (i)
    Choice chips icon padding tweaks
    Safe routing popping for leaving feedback
    Email popup only asks if blank when leaving feedback
    Fixed improper date range on hover when all spending was 0
    < 4.9.7
    Homepage banner can be disabled on full screen
    Upcoming transactions shown in light progress bar for current budget progress
    Added cycle filters for upcoming/overdue and lent/borrowed homepage section
    Fixed hover color of date range tooltip in light mode
    < 4.9.6
    Hovering all spending history graph, shows the date range in tooltip
    Monthly spending summary shows proper polarity of net spending
    Fixed home page transaction list after spacing if disabled homepage section after the transactions list
    < 4.9.5
    When editing currency transfers, edits can be bundled with the pair of transfer transactions
    Fixed note entry when first adding a transaction moving cursor to the end
    < 4.9.4
    Fixed associated transaction titles with cyrillic script
    Fixed search with cyrillic script
    Increasing text contrast applies to all text fields (minimum opacity threshold)
    Fixed cancelling date selection would reset the selected time
    Default font displays in default font
    < 4.9.3
    Fixed bottom padding insets especially for floating action button
    Removed redundant font families
    < 4.9.2
    Font and icon style settings
    Fixed container background color for transaction spending summary (i)
    Fixed all spending summary background color (i)
    Fixed side navigation bar icon scaling
    Increase text contrast setting for faded text
    Moved header height setting to More Options
    Removed add category button when adding spending limits for a category only budget
    < 4.9.1
    When using an account with many decimals, zeroes now show up to the point of a number (You can now visually see how many zeroes after a decimal place entered)
    Animated some settings icons
    Increased date time range for date range picker
    Search page defaults to load 5 years in the future to 5 years in the past
    Fixed migration database lock possibility
    Fixed spending goals totals across different budgets
    Spending totals default to selected currency if not set (i.e. an account was deleted)
    Fixed select wallet banner showing up when editing addable only budget
    Fixed borrowed having incorrect polarity when adding
    Fixed font sizes for date range selector
    All spending formatting fixes
    New category icons
    < 4.9.0
    Fixed wallet selection not attaching to goal
    Renamed major changelog
    < 4.8.9
    Major all spending page improvements and additions
    Currency support for budgets and goals totals
    Currency support for budget category spending limits
    Accounts can be filtered within a budget
    Add transaction page copies correct transaction amount with currency
    Applied filter chips with theme color follow the theme properly
    Wallet changes properly reflect when selecting amounts
    File saving permission fix for certain versions of (A)
    Improved add attachment divider color
    Tapping transaction navbar icon for the second time opens transaction search page after scrolling to top
    Fixed all spending page cycle filters for pie chart if selected certain wallets
    When tapping view all transactions in all spending page and category selected, the category filter is applied
    Increased default time period for search page (2 years) - because of optimizations!
    Improved size transition when deselecting category on all spending page
    Improved icon button paddings for clear and info buttons
    Refactored and improved date range picker (if start date is after end date, they will be swapped)
    Can set an end date when selecting time period for all spending page
    Time range properly applied to transaction list in all spending page based on cycle
    Search filters on transactions page stored in memory unless cleared
    Filters on all spending page
    All spending filter stored in memory unless cleared
    Change the order/disable recent transactions on home page
    Fixed graph display freeze when interval equal to almost 0
    Borrowed and lent transactions are forced into using proper income/expense polarity
    Changing header height properly updates all loaded pages
    Added page settings to page shortcut picker
    More options dropdown button will always show if there is only one option and small header is used
    Fixed side titles spending size for some currencies
    Removed old icon scaling code for transactions list page
    Added edit budget, account, and goals list shortcut to popup from add button on home screen widgets
    Custom color shows color gradient around color picker when system color selected
    Fixed periods for repetition type of days for daylight savings
    Added scrolling on custom popups, if content was too long
    Added information about installment tracking to add transaction select type
    When transferring or correcting an account balance, any edited changes are saved
    Fixed font family fallback for line graph touch data
    Fixed budget history line graph freeze when really large numbers displayed (issue with horizontal line drawing)
    When adding an account, you can set an initial amount
    All spending page full screen support
    Pie chart home page widget follows background of container
    Pie chart displays empty when no data
    < 4.8.8
    Transfer balance and correct total balance added to quick actions (long press plus button)
    Significantly improved performance for transaction search page
    More category icons
    Homepage transaction list animates on changes
    Improved absolute/percentage spending limits setting to dropdown
    Use 'en dash' for amount ranges
    Circular progress in budget page shows total spent instead of category limit progress
    Disabled lazy loading of transactions list on homepage
    Selected transactions dropdown menu follows colorscheme
    Fixed generate preview data missing category
    Improved formatting of budget history containers
    Budget history graph does not display zero periods initially
    < 4.8.7
    Long press add button to see list of most commonly added expenses and quickly duplicate them
    Added goal total or remaining spending label setting
    Header height setting
    Rearranged settings page to reduce clutter and confusion
    Balance correction is not considered when filtering search for income/expense - only when that category is selected
    Fixed default color for goals progress bar to match theme
    If upcoming payment had 0 total, no longer asks for amount
    Fixed discard changes popup if total amount was 0
    Applied filters added padding for wide displays
    If settings page loaded and user not signed in yet, UI now properly updates when sign in finished
    Database enum migration protection for backwards compatibility
    < 4.8.6
    Added account picker filters for all spending page
    Customizable navigation bar shortcuts - customize by long pressing in navigation bar
    Added default income category
    Added cash flow to search transaction page
    If a category no longer exists when adding transaction, the category is cleared
    Removed header line for (i) when selecting initial category because title in popup is empty
    Added force small subheader debug flag
    Rearranged about page
    Added Bulgarian language support
    < 4.8.5
    Long press category to edit when selecting
    Option to reorder categories in popup
    Option to only show related income/expense categories when selecting
    Income and expense selector when selecting initial category
    Fixed exact scheduling of notifications failing on (A) 14+
    Adding subcategory page shows name of main category
    Tapping watched category opens watch categories bottom sheet
    Budget periods with zero total spent are not considered when determining average category spending 
    Support for proper transaction amount polarity when importing CSV from Mint
    Account transfer transactions are labelled as transfer in/out if custom title empty
    Can duplicate up to 10 selected transactions
    Clear applied filters button beside applied filters chips in search page
    Added miscellaneous, increase and decrease icons
    If adding a category and income is selected, income will be selected by default
    < 4.8.4
    Upcoming transactions on homepage respect sliding income/expense selector
    Search page shows one month of transactions in the future by default
    When transferring balance or correcting total for accounts, can enter custom title along with custom date
    Enter title popup with note allows for attachments
    Fixed tapping checkbox in account picker for net worth settings would not select the account
    Fixed in-app review dependencies
    Fixed setting names capitalizations
    Fixed default currency code
    Fixed absolute spending limit conversions for subcategories when main category had no limit set (now defaults to using the budget limit)
    < 4.8.3
    Added account label setting - show an account name label for every transaction if enabled
    Extra settings minimize when search is focused in edit data pages
    Renamed setting budget total label to budget total type
    < 4.8.2
    Added dates to goals details page
    End date no longer exported with CSV
    Select category icon popup only focuses search bar on web, removed focus popup resizing
    Fixed overflow for income and expense selector
    Updated translations
    Added more category icons (eggs, car charging, battery, shrimp, meat, bread, 3D printer)
    Tweaked centering of income and expense arrows for income and expense tab selector
    Fixed custom weekly period length calculation
    Fixed incorrect percentages for category spending with subcategories
    < 4.8.1
    Goal spending circular progress limited to 100%
    Fixed back button over scroll opacity animation
    Tweaked background colors for subcategories
    < 4.8.0
    Added end date for savings/spending goals
    Spending/saving projection when end date set for goals
    End date for repeating and subscription transactions
    Separated settings for custom cycle periods for homepage widgets
    < 4.7.9
    Photo and document attachments for transactions
    Improved refresh rate on some devices
    Added 367 more currencies
    Exiting preview demo pops all routes
    Improved the way links are parsed in transaction notes
    Cleaned currency picker interface for missing information
    Fixed show no results in transaction entries
    < 4.7.8
    Automatic marking as paid for upcoming and repetitive transactions
    Added automatic marking as paid setting to subscriptions and scheduled transactions page
    Fixed order or setting upcoming notifications after automatically marking transactions
    < 4.7.7
    Balance correction transactions removed from home page graph when income/expense tab selected
    (to be consistent with the income and expense total implementations for balance corrections)
    Fixed horizontal separators for more transaction options in full screen
    Added information popup when adding a special type of transaction
    Original due date field exported when exporting CSV
    < 4.7.6
    Can search for transactions based on subcategory name
    Search transactions based on budget name, goal name
    Max width for search bar in search transactions page
    Fixed shadow for wallets list home page widget
    Added loans and scheduled navigation bar pages when in full screen
    Optimized database query calls for account switcher and account list
    < 4.7.5
    Fixed category and accounts list items not showing up if number of transactions was equal to zero
    < 4.7.4
    Long press add transaction button provides options to add different things
    Optimized transaction search page to support lazy rendering 
    Added wifi category icon
    Can select subcategory when changing the category of selected transactions
    Added search keywords for utility category icons
    Fixed search for exchange rates (includes currency name and key)
    Fixed total spent percentage in budget details when using subcategories
    Removed pin from homepage option when editing a goal, users can edit the goals in the edit home page already
    < 4.7.3
    Improved performance of search transactions page
    Improved performance of transactions list page
    Improved performance of edit category page
    Improved performance of edit accounts page
    Improved performance with keyboard popups and MediaQuery calls for rerendering
    Added info when erasing all app data about erasing cloud data
    < 4.7.2
    New category icons
    Period length defaults to 1 for repetitive transactions
    Automatically pay subscriptions loops through multiple overdue
    Emoji category icon selection large button with English locale
    < 4.7.1
    Improved light/dark mode switching animation timing
    CSV template spelling fix
    < 4.7.0
    Important database migration fix
    < 4.6.9
    Exclude transactions from certain all transaction budgets
    Check mark is only shown if multiple can be selected when selecting chips
    Bill splitter supports global multiplication value
    Fixed enter amount popup showing twice
    Added calculations to balance correction and balance transfer
    Updated translations for subcategories info
    Added duplicate transaction option under more options when editing transaction
    Fixed translation for view subcategories on wallet details page
    Fixed line graph for showing time periods of one day
    Added account to CSV template
    Fixed empty account name would create a blank account
    < 4.6.8
    Example subcategories info
    Updated translations
    Added theatre category icon
    Fixed category budget limits today indicator offset when viewing past budget
    Fixed budget history page label for weekly and daily budgets
    Renamed tooltip for expand and compress in budget line graph
    View more button in budget line graph only shown when current date within budget period
    If added only budget with custom time period, line graph accounts for all previous spending not within time range
    Fixed tap action for sub-category icon in edit category page
    Fixed long pressing sub-category chip to edit on edit categories page
    Subscriptions sorted based on due date
    Improved color of converted amount in transaction entry, removed opacity
    Changed empty line graph to show line at bottom of graph
    Sticky header on summary page for bill splitter
    Fixed bottom padding on summary page of bill splitter tool
    < 4.6.7
    Hot fix for creating main categories
    Hot fix for default selected wallet
    < 4.6.6
    Bottom safe area padding for scroll to top button
    Fixed today indicator loading in late when measuring size
    Percent in budget container updates properly when budget date changed
    Fixed lag spike when generating preview data - improper budget start date
    Fixed bottom sheet reassigned controller and scroll when suggesting icon
    Linear gradient fixed for underneath color
    Generate preview data tries to avoid empty monthly budget
    Translation fixes
    < 4.6.5
    Linear gradient fixes when min/max is 0 for line graph
    Fix on press for category icon
    < 4.6.4
    Launch screen logo for (i)
    Removed opacity when snackbar tapped on (i)
    Fixed gradient on budget line graph on (i)
    Quick fix for today indicator size
    < 4.6.3
    Fixed padding for subcategories on large displays
    Fixed syncing for handling null values
    Fixed filters when deselected main category, it now deselects any subcategories
    If export to downloads fails, prompts user to pick directory when saving file
    < 4.6.2
    Improved performance of transaction entries (with SQL joins, avoid lookups)
    All spending summary supports subcategories
    Fixed pie chart touched indices for subcategories
    Limit to first 50 transactions per day show on homepage 
    < 4.6.1
    Support for subcategory selection on budget page
    Rewrote pie chart and spending summary for budget details page to better support subcategories
    (i) layout for subcategories
    < 4.6.0
    Make subcategory into main category
    Merge subcategories support
    Fixed transaction entry if subcategory reference not found
    Can add subcategory directly when creating a category
    CSV export for objective name and subcategory name
    CSV export proper headers when budget has no value
    Animation when changing filters
    Subcategory filters
    No assigned subcategory filter
    Show all subcategories toggle preference saved
    Removed rounded corners for wallets summary list
    < 4.5.9
    Merge categories handles subcategories
    Make subcategory from main category
    Deleting subcategory complete
    Added spacing for FAB on wallet details page
    Added orange juice, barbecue, sauces, and bottles icon
    Try catch test for creating subscription transaction and with notification error catch
    < 4.5.8
    Fixed initial tab value for income/expense when editing category
    Wallet actions in more actions menu when editing
    Decimal precision option in wallet details page
    Removed unused exchange rates from exchange rate page
    Defaulted to currency exchange of 1 if no currencies are downloaded
    Select subcategory sequence in add category
    Titles limit when editing category
    Category spending linear progress color matches circular progress color
    Renamed export and import to backup and restore
    Subcategory list in edit category entry
    Added motor bike, church, microphone, school bus, delivery truck icons
    Fixed symbol for currencies without symbol would take primary wallet symbol
    < 4.5.7
    Subcategories functionality
    Subcategories budget entries
    Subcategories spending limits
    Subcategories creation, reordering, deletion
    Subcategories selection
    Reworked budget summary page 
    Fixed merge and delete category would miss unpaid transactions
    Swahili language
    < 4.5.6
    Account pinning for wallet switcher and wallet list
    New wallet list homepage section
    Net worth new account selection
    Added respective color to pinning budgets and pinning goals list
    New add budget and goal home screen button action
    Fixed net worth default check color to match theme
    Fixed net worth account selection casting variable type
    Remove pinned icon from budget entries - to pin budgets, edit the home page
    Edit home page when in full screen
    Editing home page in full screen supports different layouts (compared to smaller screen)
    Auto-correct and capitalization disabled in email field
    Prepped database for subcategories
    < 4.5.5
    Added ability to modify currency ratios
    Added exchange rates list into settings page
    Added today indicator to category spending limits
    Added compress view to hide extra dates in current budget period line graph
    Pie chart tints color to avoid identical colors next to each other
    Fixed category background colors in light mode
    Current period shown in edit budget page
    Added category spending goals button when editing budget
    Preview data monthly budget will start later in the month based on the current time (It will always look like there are transactions)
    Fixed spending trajectory on budget line graph for custom budget periods
    Fixed category colors for theme color selection
    Fixed formatting of currency page on wider screens
    Fixed side navigation prevented refreshing if currencies changed
    Fixed sidebar clock date
    < 4.5.4
    Fixed loading system color when choosing theme (no longer required restart)
    Removed deep cyan color from unsupported accent color devices
    Date and time selection for correct total balance and transfer account balance
    Date picker range selector follows accent color
    If no transactions in budget listed, added button to view past budget periods
    Removed past history page for custom budget period
    Added transfer balance settings button to account list page
    System color only enabled by default on (A) >=12 version
    Taxi, sandwich, subscription, category icons
    < 4.5.3
    Negative goal percentage shown in transaction entry
    Long press email to copy to clipboard
    Fixed month label offset in no results for transactions list
    If no similar account name found, attempt to trim and lowercase to find similar category/account name when importing CSV
    Fixed emoji icons would not have background in budget category spending entries in light mode
    < 4.5.2
    If no account name reference when importing CSV, a new one will be made
    < 4.5.1
    Data import overwrite warning
    SQL files are saved instead of SQLITE
    Hot fix for default wallet creation database lock
    Fix SQL file selection on (i) limitation
    Database corruption detection (if incorrect file imported)
    < 4.5.0
    Can enable/disable homepage welcome banner
    Feedback popup only shown if changelog is not
    Backup reminder popup if not logged in
    Fixed translations for import/export
    Added description for settings option
    Added arrow icons
    Fixed CSV export on web
    Fixed import SQL file restart popup
    Import and Export DB working on web and (A)
    Enabled color emojis on web
    Some major changes can be tapped bringing the user to the related page 
    < 4.4.9
    Import and export all data (SQL DB) options
    New backups section in settings
    If leaving feedback and suggestions are included, remind user to leave email
    Fixed popup resizing after premium page shown when adding transaction
    Font fallback for every custom font text style (for other language characters)
    Added tablet icon
    < 4.4.8
    Serbian language support
    Homepage reloads when period cycle is selected on all spending page
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
    (i) layout for objectives
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
    Documents access in Files for (i)
    Full snap popup sheet when entering name on home page
    Budget history conversion fix
    < 4.2.3
    Fixed parsing of number input when decimal separator is comma
    Fixed (A) crash on some devices
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
    Fixed format of swipe to delete container on (i)
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
    Removed old (A) Navbar support (Debug Option)
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
    Fixed system color for launch screen on (i)
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
    New header for (i)
    Removed blur components
    New app bar color theming
    Fixed font and colors for rich text
    Upgraded to Flutter 3.13.2
    < 4.0.6
    Secondary header to match (i) style
    Fixed transition backdrop for popup sheet on (i)
    Fixed mixup with status bar icon color on (i)
    < 4.0.5
    Animated text style
    Added plus button to add category, title, budget, wallet in actions in edit page
    FAB always adds a transaction on root page
    New plus button for adding a budget
    Fixed day counter in remaining days of budget
    Discard changes popup when adding new transaction, category, and wallet
    Fixed select category icon bottom sheet sizing
    Fixed status bar icon color
    Changed font for (i) back to default
    Decreased vertical empty space in (i)
    Added 'Done' button when editing multiline notes on transactions page for (i) to minimize keyboard
    < 4.0.4
    Hot fix for adding transactions and budgets
    < 4.0.3
    Fixed discard changes popup when transaction missing period length
    < 4.0.2
    Fixed toggling between category spending limits when from edit budget page would cause inconsistent saving of data
    Fixed income arrow indicator width
    Fixed swipe down background on backups page for (i)
    Reworded Google Drive backup for (i)
    Added per day indication for amount remaining
    Fixed remaining days (added 1) to be more logical
    Can swipe down to dismiss immediately with (i) scroll physics
    Heatmap scroll to load now loads if greater than extent
    Custom product IDs platform based support
    < 4.0.1
    Fixed heatmap popup alignment for (i)
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
    Material date pickers for (i)
    < 3.9.2
    Yearly plan savings (Disabled for now)
    Upgraded to support Flutter 3.13
    < 3.9.1
    Significantly improves speed of CSV import - use batching
    CSV progress fix
    (i) notifications status warning refreshes properly
    (i) Google login fix
    < 3.9.0
    Fixed locale loading for changelog
    SF Pro font for (i) devices
    Notification permission checks for (i)
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
    New navbar on (A)
    < 3.8.3
    Select wallet and select budget now uses radio buttons bottom popup
    Added rounding to decimal precision when converting to money
    Radio item now highlighted when selected
    Radio items support colors
    Only expenses can be added to budgets when using add to budget action bar
    When ask for transaction title disabled, full snap is not used anymore
    Fixed home page graph and selecting budget graph - using old number values for id
    Added bottom spacing to avoid add button for borrowed and lent pages
    Fixed long press actions - such as long press to reorder for categories on (i)
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
    Cashew pro background now extends past scrollable area - support for (i) over-scroll
    Proper currency for editing wallets row entry
    Fixed (i) tappable long press but incomplete would freeze animation
    Swipe along checks to select transaction
    New transaction selection enabled for web
    (i) new selection check icon for transactions
    (i) rounded corners style for more components
    < 3.7.9
    Suggest icon popup and suggestion container
    New divider colors
    New language picker
    Fixed income and expense start date
    Spending goals button to edit budget page
    Budget page progress bars contrast color fixes
    Selection click vibration instead of impacts
    Fixed biometrics crash
    Back button exits app on (A)
    Fixed border on past budgets page when not in (i)
    Edit spending goals button directly above categories on bigger screens
    < 3.7.8
    Bottom safe area for popups
    Extra action now located as a full bottom button for popup
    Refactored select amount widget
    New tappable widget for (i) - Fade animation
    Better horizontal padding resizing
    Increased width when using horizontal padding constrained
    Fixed safe area in horizontal mode, left and right safe areas
    Fixed subtitle animation speed
    Long press vibration on (i)
    Slow open container animation (i)
    Animated budget containers disabled on (i)
    Animated Premium banner disabled on (i)
    Removed blur effects by default on (i)
    < 3.7.7
    Added disable blur option
    Fixed (i) onboarding page
    Changelog can always be opened when forced
    < 3.7.6
    Fixed recommended spending amount sizes
    Backup limit shown in backup popup
    (i) Google backups are branded as Google Drive
    Fixed scroll to top for transactions list page
    Backup limit option hidden
    Premium banner uses open container animation
    Moved translation help to about page 
    < 3.7.5
    Cashew Pro banner in settings
    Removed old implementation of associated titles lookup
    Added vibration when scrubbing through line graphs
    New budget history container for (i)
    Current period in past budget periods is only labelled as current period if it is one
    Fixed scroll animations when scrolled past 0 in (i)
    Fixed past budget periods, if the 31 of the month it fails to show certain past periods, such as Feb
    Removed vibration for (i) bottom sheet
    Universal IO for locale on web
    Translations
    < 3.7.4
    Improved decimal precisions and support for comma locale
    Fixed animations in enter amount
    Added border color to wallet pickers
    (i) homepage scroll animation fix
    Fixed amount range filters getting added on first open
    Spending goals moved to separate page
    New dropdown menu actions for app bar
    Fixed merge category
    Google login warning on (i)
    Add element to database key generation uses auto increment
    Done for: wallets, budgets, transactions, categories, titles, scanner templates
    < 3.7.3
    Edit row action button animated scale switcher
    (i) notification configurations
    Can select primary wallet in edit wallets list page
    Pick custom color gradient outline
    New (i) popup bottom sheet layout
    New (i) edit row entries
    Material You setting moved to accent color for (i)
    Upcoming transaction icon changed
    New (i) navigation bar
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
    Added blur behind app bar for (i)
    Fixed scroll animations for (i)
    Added swipe to go back gesture
    Refactored (i) debug settings
    New (i) header colors and icons
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
    Added quick action shortcuts on (A) - Add transaction and view budgets
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
    Fixed (A) keyboard height issue
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
    (i) scroll physics when swiping page down to dismiss budget page shows proper color
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
    Fixed onWillPopScope and back swipe for (i)
    (i) navigation debug flag
    Splash color disabled on (i)
    Page transitions use new fade in from bottom animation
    Select chips follows height of ChoiceChip
    Select chips scroll to the selected chip
    < 3.2.2
    Officially removed DateTimeCreated - merged into dateCreated
    Removed right arrow on outlines settings containers
    Ask for transaction title disabled by default for devices with older (A) version (since keyboard height changes do not update the UI)
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

    Adaptive icon for (A) 13+
    Upcoming transactions now show up on home page (within 3 days)

    New dropdown menu when selecting transactions to delete - shows amount selected and total cash flow of transactions
    Selected transactions cleared when using back button
    Today, Yesterday, Days of Week labels now include the month and date
    Changed the way Google login permissions work (on (A))
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
        onTap: (context) {
          pushRoute(context, ObjectivesListPage(backButton: true));
        },
      ),
      MajorChanges(
        "major-change-4".tr(),
        Icons.home_rounded,
        info: [
          "major-change-4-1".tr(),
          "major-change-4-2".tr(),
        ],
        onTap: (context) {
          pushRoute(context, EditHomePage());
        },
      ),
      MajorChanges(
        "major-change-5".tr(),
        Icons.emoji_emotions_rounded,
        info: [
          "major-change-5-1".tr(),
        ],
        onTap: (context) {
          pushRoute(context, EditCategoriesPage());
        },
      ),
      // MajorChanges(
      //   "major-change-6".tr(),
      //   Icons.bug_report_rounded,
      //   info: [
      //     "major-change-6-1".tr(),
      //   ],
      // ),
    ],
    "< 4.4.6": [
      MajorChanges(
        "major-change-7".tr(),
        Icons.timelapse_rounded,
        info: [
          "major-change-7-1".tr(),
        ],
        onTap: (context) {
          pushRoute(context, WalletDetailsPage(wallet: null));
        },
      ),
      MajorChanges(
        "major-change-8".tr(),
        Icons.price_change_rounded,
      ),
    ],
    "< 4.5.1": [
      MajorChanges(
        "major-change-9".tr(),
        Icons.file_open_rounded,
        info: [
          "major-change-9-1".tr(),
        ],
        onTap: (context) {
          pushRoute(context, SettingsPageFramework());
        },
      ),
      MajorChanges(
        "major-change-10".tr(),
        Icons.edit_rounded,
        info: [
          "major-change-10-1".tr(),
        ],
        onTap: (context) {
          pushRoute(context, EditHomePage());
        },
      ),
    ],
    "< 4.6.6": [
      MajorChanges(
        "major-change-11".tr(),
        Icons.category_rounded,
        info: [
          "major-change-11-1".tr(),
        ],
        onTap: (context) {
          pushRoute(
            context,
            AddCategoryPage(
              routesToPopAfterDelete: RoutesToPopAfterDelete.None,
            ),
          );
        },
      ),
      MajorChanges(
        "major-change-12".tr(),
        Icons.list_rounded,
        info: [
          "major-change-12-1".tr(),
        ],
        onTap: (context) {
          pushRoute(context, EditHomePage());
        },
      ),
      MajorChanges(
        "major-change-6".tr(),
        Icons.bug_report_rounded,
        info: [
          "major-change-6-1".tr(),
        ],
      ),
    ],
    "< 4.7.9": [
      MajorChanges(
        "major-change-14".tr(),
        Icons.attach_file_rounded,
        info: [
          "major-change-14-1".tr(),
        ],
      ),
    ],
    "< 4.8.8": [
      MajorChanges(
        "major-change-15".tr(),
        Icons.add_box_rounded,
        info: [
          "major-change-15-1".tr(),
        ],
        onTap: (context) {
          openBottomSheet(
            context,
            PopupFramework(
              child: AddMoreThingsPopup(),
            ),
          );
        },
      ),
    ],
    "< 4.8.9": [
      MajorChanges(
        "major-change-16".tr(),
        Icons.receipt_long_rounded,
        info: [
          "major-change-16-1".tr(),
        ],
        onTap: (context) {
          pushRoute(context, WalletDetailsPage(wallet: null));
        },
      ),
    ],
    "< 5.0.3": [
      MajorChanges(
        "major-change-17".tr(),
        Icons.av_timer_rounded,
        info: [
          "major-change-17-1".tr(),
        ],
        onTap: (context) {
          pushRoute(
            context,
            CreditDebtTransactions(
              isCredit: null,
            ),
          );
        },
      ),
    ],
  };
}

bool showChangelog(
  BuildContext context, {
  bool forceShow = false,
  bool majorChangesOnly = false,
  Widget? extraWidget,
}) {
  String version = packageInfoGlobal.version;

  List<Widget>? changelogPoints = getChangelogPointsWidgets(
    context,
    forceShow: forceShow,
    majorChangesOnly:
        Localizations.localeOf(context).toString().toLowerCase() != "en"
            ? true
            : majorChangesOnly,
  );

  updateSettings(
    "lastLoginVersion",
    version,
    pagesNeedingRefresh: [],
    updateGlobalState: false,
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
    return true;
  }
  return false;
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
      if (getPlatform() != PlatformOS.isIOS) {
        string = string.replaceAll("(A)", "Android");
        string = string.replaceAll("(i)", "iOS");
      }
      // Skip android changes on iOS
      if (getPlatform() == PlatformOS.isIOS && string.contains(("(A)"))) {
        continue;
      }
      if (string.startsWith("< ")) {
        if (forceShow) {
          changelogPoints.addAll(getAllMajorChangeWidgetsForVersion(
                  context, string, majorChanges) ??
              []);
        }

        versionBookmark = parseVersionInt(string.replaceAll("< ", ""));
        if (forceShow == false && versionBookmark <= lastLoginVersionInt) {
          continue;
        }

        majorChangelogPointsAtTop.addAll(
            getAllMajorChangeWidgetsForVersion(context, string, majorChanges) ??
                []);

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
  MajorChanges(this.title, this.icon, {this.info, this.onTap});

  String title;
  IconData icon;
  List<String>? info;
  Function(BuildContext context)? onTap;
}

List<Widget>? getAllMajorChangeWidgetsForVersion(BuildContext context,
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
                onTap: majorChange.onTap == null
                    ? null
                    : () => majorChange.onTap!(context),
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
