# Firebase Auth setup (email + Google Sign-In)

The app now gates behind a login screen. It will **not build until you generate `firebase_options.dart`** with the FlutterFire CLI. Do these once.

## 1. Tooling
```bash
# Firebase CLI (needs Node). Then log in.
npm install -g firebase-tools
firebase login

# FlutterFire CLI
dart pub global activate flutterfire_cli
```
If `flutterfire` isn't found afterward, add Dart's pub-cache bin to PATH:
```bash
echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc
```

## 2. Create + connect the Firebase project
1. Go to https://console.firebase.google.com → **Add project** (e.g. "Sankofa Twi"). (Or reuse an existing one.)
2. From the app folder, connect it — this generates `lib/firebase_options.dart` and registers the Android app:
```bash
cd ~/SankofaTwi.0.v.0.2/app
flutterfire configure
```
Select your project, and tick **Android** (iOS optional) when prompted.

## 3. Enable the sign-in providers
Firebase Console → **Build → Authentication → Get started → Sign-in method**:
- Enable **Email/Password**.
- Enable **Google** (pick a support email, Save).

## 4. Google Sign-In needs your app's SHA-1 (Android only)
Google sign-in fails on Android until the app's signing fingerprint is registered.
```bash
cd ~/SankofaTwi.0.v.0.2/app/android
./gradlew signingReport
```
Copy the **SHA1** under `Variant: debug` → Firebase Console → Project settings → your Android app → **Add fingerprint** → paste → Save. Then re-run:
```bash
cd ~/SankofaTwi.0.v.0.2/app
flutterfire configure   # refreshes config with the OAuth client
```
(Do the same with the **release** SHA-1 before publishing.)

## 5. Run
```bash
cd ~/SankofaTwi.0.v.0.2/app
flutter pub get
flutter run -d RFCY30BAPTN      # or your emulator id
```
You'll see the login screen first: email sign-in / create account, or **Continue with Google**. After signing in, the 5-tab app appears, with a logout button in the top-right.

## Notes
- `firebase_options.dart` is generated, not committed by hand — don't edit it.
- Email/Password works as soon as steps 1–3 are done. Google needs step 4 too.
- If you see `MissingPluginException` or a build error about `firebase_options.dart`, you haven't run `flutterfire configure` yet.
