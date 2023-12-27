This isn't a traditional CHANGELOG.MD. This is more like a verbose output of the commands and changes done to this project.

See Ref 1. Run flutter pub upgrade
See Ref 2. Run flutter pub outdated
See Ref 3. Run flutter pun upgrade --major-versions
4. flutter pub upgrade

  > file 7.0.0 (was 6.1.4)

5. flutter pub outdated

  direct dependencies:
intl          *0.18.1  *0.18.1     *0.18.1     0.19.0
path          *1.8.3   *1.8.3      *1.8.3      1.9.0


6. Renamed globalSnackbar.dart to globalSnackBar.dart to match the implementation across the codebase.

## Deprecation issues

1. lib/pages/notificationsPage.dart
Before:
            onTap: () {
              AppSettings.openNotificationSettings();
            },
After:
            //Updated to fix deprecation
            onTap: () =>
                AppSettings.openAppSettings(type: AppSettingsType.settings),

2. lib/../premiumPage.dart
globalSnackbar wasn't being imported.
part of the credit of this code goes to https://github.com/doankimhuy-it and his fork. Any errors are my implementation.
Doesn't error anymore.

3. lib/../settingsPage.dart &&
Old:
                        AppSettings.openNotificationSettings();
New:
                          AppSettings.openAppSettings(
                              type: AppSettingsType.settings);

##
Few various minor fixes. That kind of thing. Compare code on github if you're curious.

Any issues? Hit me up on discord at @jayspuddles (display name Spuddles)


Below is the outputs for Ref 1, 2 and 3.


Ref 1: {
flutter pub upgrade
Resolving dependencies... (11.5s)
> _fe_analyzer_shared 64.0.0 (was 61.0.0) (65.0.0 available)
> _flutterfire_internals 1.3.16 (was 1.3.3)
> analyzer 6.2.0 (was 5.13.0) (6.3.0 available)
> analyzer_plugin 0.11.3 (was 0.11.2)
> animations 2.0.10 (was 2.0.7)
> app_settings 4.3.1 (was 4.2.0) (5.1.1 available)
> archive 3.4.9 (was 3.3.7)
> build 2.4.1 (was 2.4.0)
> build_daemon 4.0.1 (was 4.0.0)
> build_resolvers 2.4.2 (was 2.4.1)
> build_runner_core 7.2.11 (was 7.2.10)
> built_value 8.8.1 (was 8.6.1)
  cli_util 0.3.5 (0.4.1 available)
> cloud_firestore 4.13.6 (was 4.8.1)
> cloud_firestore_platform_interface 6.0.10 (was 5.15.1)
> cloud_firestore_web 3.8.10 (was 3.6.1)
> code_builder 4.9.0 (was 4.5.0)
> cross_file 0.3.3+8 (was 0.3.3+4)
> csslib 1.0.0 (was 0.17.3)
> csv 5.1.1 (was 5.0.2)
> dart_style 2.3.4 (was 2.3.1)
> dbus 0.7.10 (was 0.7.8)
> device_info_plus 9.1.1 (was 9.1.0)
> drift 2.14.1 (was 2.14.0)
> drift_dev 2.14.1 (was 2.14.0)
> ffi 2.1.0 (was 2.0.2)
  file 6.1.4 (7.0.0 available)
> firebase_auth 4.15.3 (was 4.6.3)
> firebase_auth_platform_interface 7.0.9 (was 6.15.3)
> firebase_auth_web 5.8.12 (was 5.5.3)
> firebase_core 2.24.2 (was 2.14.0)
> firebase_core_platform_interface 5.0.0 (was 4.8.0)
> firebase_core_web 2.10.0 (was 2.6.0)
  fl_chart 0.64.0 (0.66.0 available)
  flutter_charset_detector 1.0.2 (2.0.0 available)
  flutter_charset_detector_android 1.0.0 (2.0.1 available)
  flutter_launcher_icons 0.10.0 (0.13.1 available)
> flutter_lazy_indexed_stack 0.0.6 (was 0.0.5)
> flutter_local_notifications 14.1.4 (was 14.1.1) (16.2.0 available)
> flutter_plugin_android_lifecycle 2.0.17 (was 2.0.15)
> freezed_annotation 2.4.1 (was 2.2.0)
> google_identity_services_web 0.3.0+2 (was 0.2.1)
> google_sign_in 6.2.1 (was 6.1.4)
> google_sign_in_android 6.1.20 (was 6.1.16)
> google_sign_in_ios 5.7.1 (was 5.6.2)
> google_sign_in_platform_interface 2.4.3 (was 2.4.1)
> google_sign_in_web 0.12.3+1 (was 0.12.0+2)
> googleapis 11.4.0 (was 11.2.0) (12.0.0 available)
> home_widget 0.4.1 (was 0.4.0)
> http 1.1.2 (was 0.13.6)
  image 3.3.0 (4.1.3 available)
> image_picker 1.0.5 (was 1.0.4)
> image_picker_android 0.8.9+1 (was 0.8.8+2)
> image_picker_ios 0.8.9 (was 0.8.8+4)
> in_app_purchase 3.1.11 (was 3.1.8)
> in_app_purchase_android 0.3.0+15 (was 0.3.0+11)
> in_app_purchase_platform_interface 1.3.6 (was 1.3.4)
> in_app_purchase_storekit 0.3.7 (was 0.3.6+5)
> in_app_review 2.0.8 (was 2.0.6)
> in_app_review_platform_interface 2.0.5 (was 2.0.4)
  intl 0.18.1 (0.19.0 available)
> local_auth 2.1.7 (was 2.1.6)
> local_auth_android 1.0.36 (was 1.0.32)
> local_auth_ios 1.1.5 (was 1.1.3)
> local_auth_platform_interface 1.0.8 (was 1.0.7)
> local_auth_windows 1.0.10 (was 1.0.8)
  lottie 1.4.3 (2.7.0 available)
  matcher 0.12.16 (0.12.16+1 available)
  material_color_utilities 0.5.0 (0.8.0 available)
  meta 1.10.0 (1.11.0 available)
> package_info_plus 4.2.0 (was 4.0.2) (5.0.1 available)
  path 1.8.3 (1.9.0 available)
> path_provider_android 2.2.2 (was 2.2.1)
  pausable_timer 1.0.0+7 (3.1.0+3 available)
> petitparser 6.0.2 (was 5.4.0)
> platform 3.1.3 (was 3.1.0)
> plugin_platform_interface 2.1.7 (was 2.1.4)
> provider 6.1.1 (was 6.0.5)
> quick_actions 1.0.6 (was 1.0.5)
> quick_actions_android 1.0.9 (was 1.0.7)
> quick_actions_ios 1.0.8 (was 1.0.6)
> quick_actions_platform_interface 1.0.5 (was 1.0.4)
  share_plus 4.5.3 (7.2.1 available)
> share_plus_platform_interface 3.3.1 (was 3.2.1)
  share_plus_windows 3.0.1 (4.0.0 available)
> shared_preferences 2.2.2 (was 2.1.2)
> shared_preferences_android 2.2.1 (was 2.1.4)
> shared_preferences_foundation 2.3.4 (was 2.2.2)
> shared_preferences_linux 2.3.2 (was 2.2.0)
> shared_preferences_platform_interface 2.3.1 (was 2.2.0)
> shared_preferences_web 2.2.2 (was 2.1.0)
> shared_preferences_windows 2.3.2 (was 2.2.0)
  shimmer 2.0.0 (3.0.0 available)
  simple_animations 4.2.0 (5.0.2 available)
> source_gen 1.5.0 (was 1.3.2)
+ sprintf 7.0.0
> sqlite3 2.3.0 (was 2.1.0)
> sqlite3_flutter_libs 0.5.18 (was 0.5.15)
  test_api 0.6.1 (0.7.0 available)
> universal_html 2.2.4 (was 2.2.3)
> url_launcher 6.2.2 (was 6.1.11)
> url_launcher_android 6.2.0 (was 6.0.35)
> url_launcher_ios 6.2.1 (was 6.1.4)
> url_launcher_linux 3.1.1 (was 3.0.5)
> url_launcher_macos 3.1.0 (was 3.0.5)
> url_launcher_platform_interface 2.2.0 (was 2.1.2)
> url_launcher_web 2.2.2 (was 2.0.17)
> url_launcher_windows 3.1.1 (was 3.0.6)
> uuid 4.2.2 (was 3.0.7) (4.3.1 available)
  web 0.3.0 (0.4.0 available)
  web_socket_channel 2.4.0 (2.4.1 available)
> win32 5.1.1 (was 5.0.6)
> win32_registry 1.1.2 (was 1.1.1)
> xdg_directories 1.0.3 (was 1.0.0)
> xml 6.5.0 (was 6.3.0)
These packages are no longer being depended on:
- process 4.2.4
- quiver 3.2.1
Changed 96 dependencies!
28 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
}

Ref 2. {
flutter pub outdated
Showing outdated packages.
[*] indicates versions that are not the latest available.

Package Name                 Current   Upgradable  Resolvable  Latest

direct dependencies:
app_settings                 *4.3.1    *4.3.1      5.1.1       5.1.1
fl_chart                     *0.64.0   *0.64.0     0.66.0      0.66.0
flutter_charset_detector     *1.0.2    *1.0.2      2.0.0       2.0.0
flutter_launcher_icons       *0.10.0   *0.10.0     0.13.1      0.13.1
flutter_local_notifications  *14.1.4   *14.1.4     16.2.0      16.2.0
googleapis                   *11.4.0   *11.4.0     12.0.0      12.0.0
intl                         *0.18.1   *0.18.1     *0.18.1     0.19.0
lottie                       *1.4.3    *1.4.3      2.7.0       2.7.0
package_info_plus            *4.2.0    *4.2.0      5.0.1       5.0.1
path                         *1.8.3    *1.8.3      *1.8.3      1.9.0
pausable_timer               *1.0.0+7  *1.0.0+7    3.1.0+3     3.1.0+3
share_plus                   *4.5.3    *4.5.3      7.2.1       7.2.1
shimmer                      *2.0.0    *2.0.0      3.0.0       3.0.0
simple_animations            *4.2.0    *4.2.0      5.0.2       5.0.2

dev_dependencies: all up-to-date.

12  dependencies are constrained to versions that are older than a resolvable version.
To update these dependencies, edit pubspec.yaml, or run `flutter pub upgrade --major-versions`.

share_plus_windows
    Package share_plus_windows has been discontinued, replaced by share_plus.
}



Ref 3. {
flutter pub upgrade --major-versions
Resolving dependencies... (13.2s)
  _fe_analyzer_shared 64.0.0 (65.0.0 available)
  analyzer 6.2.0 (6.3.0 available)
> app_settings 5.1.1 (was 4.3.1)
> cli_util 0.4.1 (was 0.3.5)
> file 7.0.0 (was 6.1.4)
> fl_chart 0.66.0 (was 0.64.0)
> flutter_charset_detector 2.0.0 (was 1.0.2)
> flutter_charset_detector_android 2.0.1 (was 1.0.0)
> flutter_launcher_icons 0.13.1 (was 0.10.0)
> flutter_local_notifications 16.2.0 (was 14.1.4)
> googleapis 12.0.0 (was 11.4.0)
> image 4.1.3 (was 3.3.0)
  intl 0.18.1 (0.19.0 available)
> lottie 2.7.0 (was 1.4.3)
  matcher 0.12.16 (0.12.16+1 available)
  material_color_utilities 0.5.0 (0.8.0 available)
  meta 1.10.0 (1.11.0 available)
> package_info_plus 5.0.1 (was 4.2.0)
  path 1.8.3 (1.9.0 available)
> pausable_timer 3.1.0+3 (was 1.0.0+7)
> share_plus 7.2.1 (was 4.5.3)
> shimmer 3.0.0 (was 2.0.0)
> simple_animations 5.0.2 (was 4.2.0)
  test_api 0.6.1 (0.7.0 available)
  uuid 4.2.2 (4.3.1 available)
  web 0.3.0 (0.4.0 available)
  web_socket_channel 2.4.0 (2.4.1 available)
These packages are no longer being depended on:
- share_plus_linux 3.0.1
- share_plus_macos 3.0.1
- share_plus_web 3.1.0
- share_plus_windows 3.0.1
Changed 20 dependencies!
11 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.

Changed 12 constraints in pubspec.yaml:
  simple_animations: ^4.1.0 -> ^5.0.2
  fl_chart: ^0.64.0 -> ^0.66.0
  share_plus: ^4.0.4 -> ^7.2.1
  googleapis: ^11.2.0 -> ^12.0.0
  flutter_charset_detector: ^1.0.2 -> ^2.0.0
  shimmer: ^2.0.0 -> ^3.0.0
  flutter_launcher_icons: ^0.10.0 -> ^0.13.1
  package_info_plus: ^4.0.2 -> ^5.0.1
  lottie: ^1.4.3 -> ^2.7.0
  pausable_timer: ^1.0.0+6 -> ^3.1.0+3
  flutter_local_notifications: ^14.0.0+1 -> ^16.2.0
  app_settings: ^4.2.0 -> ^5.1.1
  }

