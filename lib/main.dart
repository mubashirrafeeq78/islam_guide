name: Build Final Masail ka Hal
on:
  push:
    branches: [ "main" ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
      
      - name: Clean & Get Packages
        run: |
          flutter clean
          flutter pub get
      
      - name: Force Generate Icons
        run: flutter pub run flutter_launcher_icons

      - name: Build Optimized APK
        run: flutter build apk --release --split-per-abi

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: Masail-ka-Hal-Final
          path:
