cd ..
cd budget

start cmd.exe /k firebase deploy
start cmd.exe /k flutter build appbundle --release
start cmd.exe /k flutter build apk --release