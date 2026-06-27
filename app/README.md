# Sankofa Twi — Flutter app (MVP)

Native Flutter / Material 3 app. This folder contains the Dart source only; the
Android/iOS platform folders are generated on your machine (see below).

## What's here
- `lib/main.dart` — app shell + one-handed bottom navigation (Symbols / Lessons)
- `lib/theme.dart` — Material 3 theme, Plantain Green (#2E8B57), Coral, Sand, 24px radius
- `lib/data/adinkra_symbols.dart` — all 62 Adinkra symbols (SVG artwork, incl. the slim Sankofa bird)
- `lib/widgets/` — FloatingCard, ContinueButton (label locked to "Continue"), AdinkraGlyph
- `lib/screens/` — Symbols gallery (tap a card for details) + Lessons (reads the bundled unit JSON)
- `assets/content/unit_001.example.json` — sample curriculum unit

## Prerequisites (one-time)
1. Install Flutter: https://docs.flutter.dev/get-started/install (includes Dart).
2. Install Android Studio + the Android SDK, and create an emulator (or plug in an Android phone with USB debugging on).
3. Verify: `flutter doctor` (resolve any ❌ it reports).

## Run it
From this `app/` folder:

```bash
# 1. Generate the android/ ios/ platform folders around this existing source.
#    (Non-destructive: it skips files that already exist, like pubspec.yaml and lib/.)
flutter create --org com.sankofatwi --project-name sankofa_twi .

# 2. Fetch packages
flutter pub get

# 3. Run on a connected device / emulator
flutter run
```

If `flutter create` ever overwrites one of the source files, restore it with
`git checkout -- pubspec.yaml lib/` (the generated `android/`/`ios/` folders are kept).

## Build an installable APK
```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk  (copy to your phone to install)
```
