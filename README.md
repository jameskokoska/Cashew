# Budget App
Note to self: Write a more invigorating description here in the future.


# Developer Notes

## Firebase Deployment
* To deploy to firebase run `firebase deploy`

## Generate App Icon
* Run `flutter pub run flutter_launcher_icons:main`
* App icon located in `assets/icons/icon.png`

## Generate Database Tables
* Run `flutter packages pub run build_runner build`
* Don't forget to bump schema version

# Generate Builds
* Remove old build: `flutter clean`
* For web: `flutter build web`
* For Android: `flutter build appbundle`
