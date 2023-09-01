
<h1 align="center" style="font-size:28px; line-height:1"><b>Cashew</b></h1>

<a href="https://budget-track.web.app/">
  <div align="center">
    <img alt="Icon" src="promotional/icons/icon.png" width="150px">
  </div>
</a>

---

Cashew is a full-fledged, feature-rich application designed to empower users in managing their finances effectively. Built using Flutter - with Drift's SQL package, and Firebase at its core - this app offers a seamless and intuitive user experience across various devices. Development started in September 2021.

---

## Release
This application is only available on Android via invite only, as of now. I hope to release on Android very soon.

The web version is public: https://budget-track.web.app/.

### Developer Note

This application is still in heavy development. The main features complete, but budget and transaction sharing is far off. I have put so much work into building this app and making it as useful as possible for tracking your spending. Tracking your spending is important because it provides you with a clear understanding of where your money is going, empowering you to make informed financial decisions, identify saving opportunities, control your expenses, and work towards your financial goals. I think it's even more important to carefully watch spending habits in the current times we are living in.

### Changelog

Changes and progress about development is all heavily documented in GitHub [commits](https://github.com/jameskokoska/Cashew/commits/main) and in the [changelog](https://github.com/jameskokoska/Cashew/blob/main/budget/lib/widgets/showChangelog.dart)

## Key Features

### Budget Management
- Custom Budgets and Time Periods: Set up personalized budgets with flexible time periods, such as monthly, weekly, daily, or any custom time period that suits your financial planning needs. A custom time period is useful if you plan on setting a one-time travel budget!
- Added Budgets: Selectively add transactions to specific budgets, allowing you to focus on specific expense categories.
- Category Spending Limits per Budget: Set limits for each category within a budget, ensuring responsible spending.
- Past Budget History Viewing: Analyze your spending habits over time by accessing past budget history, enabling comparison and tracking of financial progress.

### Transaction Management
- Support for Different Transaction Types: Categorize transactions effectively based on types such as upcoming, subscription, repeating, debts (borrowed), and credit (lent). Each type behaves in certain ways in the interface. Pay your upcoming transactions when you're ready, or mark your lent out transactions as collected.
- Custom Categories: Create personalized categories to organize transactions according to your unique spending habits. Search through multiple icons and select the default option as expenses or income when adding transactions.
- Custom Titles: Automatically assign transactions with the same name to specific categories, saving time and ensuring consistency. These titles are stored in memory and popup when you add another transaction with a similar name.
- Search and Filters: Easily search and filter transactions based on various criteria such as date, category, amount, or custom tags, enabling quick access to information.
- Easy Editing: Long-press and swipe to select multiple budgets, edit accordingly as needed or delete multiple at once.

### Financial Flexibility
- Multiple Currencies and Wallets: Manage finances across different currencies and wallets with up-to-date conversion rates for accurate calculations and effortless currency conversions. The interface shows the original amount added and the converted amount to the selected wallet.
- Switch Wallets and Currencies with Ease: On the homepage, easily select a different wallet and currency and everything will be converted automatically in an instant.

### Enhanced Security and Accessibility
- Biometric Lock: Secure budget data using biometric authentication, adding an extra layer of privacy.
- Google Login: Conveniently log in to the app using your Google account, ensuring a streamlined and hassle-free authentication process.

### User Experience and Design
- Material You Design: Enjoy a visually appealing and modern interface, following the principles of Material You design for a delightful user experience.
- Custom Accent Color: Personalize the app by selecting a custom accent color that suits your style, or follow that of the system.
- Light and Dark Mode: Seamlessly switch between light and dark themes to optimize visibility and reduce eye strain.
- Customizable Home Screen: Tailor the home screen layout and widgets to display the financial information that matters most to you, providing a personalized and efficient dashboard.
- Detailed Graph Visuals: Gain valuable insights into spending patterns through detailed and interactive graphs, visualizing financial data at a glance.
- Beautiful Adaptive UI: A responsive user interface that adapts flawlessly to both web and mobile platforms, providing an immersive and consistent user experience across devices.

### Collaboration and Backup
- Cross-Device Sync: Keep budget data synchronized across all devices, ensuring access to financial information wherever you go.
- Google Drive Backup: Safeguard budget data by utilizing Google Drive's backup functionality, allowing easy restoration of data if needed.
- Budget Sharing (Alpha): Collaborate with family members, friends, or colleagues by sharing budgets, enabling collective tracking and management of shared expenses.

### Smart Automation
- Notifications: Stay informed about important financial events and receive timely reminders for budget goals, transactions, and upcoming due dates.
- Import CSV Files: Seamlessly import financial data by uploading CSV files, facilitating a smooth transition from other applications or platforms.
- Auto Email Transaction Parsing (Beta): Automatically parse transaction details from email receipts, making expense tracking effortless and efficient.

## Platforms
This application has been tested primarily on `Web` and `Android`. It has successfully compiled to `iOS` but with broken features (Such as Google login and notifications). These issues are planned in the future.

## Bundled Packages
This repository contains, bundled in, modified versions of the discontinued packages listed below. They can be found in the folder `/budget/packages`
* https://pub.dev/packages/implicitly_animated_reorderable_list
* https://pub.dev/packages/sliding_sheet

## Translations
The translations are available here: https://docs.google.com/spreadsheets/d/1QQqt28cmrby6JqxLm-oxUXCuM3alniLJ6IRhcPJDOtk/edit?usp=sharing.

### To Update Translations
1. Export Google Sheet as CSV
2. Place CSV in `/budget/assets/translations` and rename to `translations.csv`
3. Run `generate-translations.py`
4. Restart the application

## Developer Notes

### Android Release
* To build an app-bundle Android release, run `flutter build appbundle --release`.

Note: required Android SDK.

### iOS Release
* To build an IPA iOS release, run `flutter build ipa`.

Note: requires MacOS.

### Firebase Deployment
* To deploy to firebase, run `firebase deploy`

Note: required Firebase.

### Develop Wirelessly on Android
* `adb tcpip 5555`
* `adb connect <IP>`
* Get the phone's IP by going to `About Phone` > `Status Information` > `IP Address`

### Update Database Tables
* Run `dart run build_runner build`
* Don't forget to bump schema version

### Get Platform
* Use `getPlatform()` from `functions.dart`
* Since `Platform` is not supported on web, we must create a wrapper and always use this to determine the current platform 

### Push Route
* If we want to navigate to a new page, stick to `pushRoute(context, page)` function from `functions.dart`
* It handles the platform routing and `PageRouteBuilder`