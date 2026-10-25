# START HERE: get the Skillify APK (no coding needed)

This project is complete Flutter source code. GitHub can turn it into an installable
APK for free, automatically. You only upload files and click a few buttons.

## Method A: build the APK in the cloud (recommended, about 15 minutes)

1. **Unzip** `skillify_project.zip` on your computer (GitHub cannot read a zip).
2. Make a free account at https://github.com and sign in.
3. Click **+ > New repository**. Name it `skillify`, choose **Private**, click **Create repository**.
4. Click **uploading an existing file**. Open the unzipped folder and **drag everything inside it**
   (folders `lib`, `assets`, `tools`, `backend`, `.github`, and the files `pubspec.yaml`, etc.)
   into the page. Wait for the upload bar to finish, then click **Commit changes**.
5. Open the **Actions** tab. You should see **Build Android APK** running (yellow dot).
   Wait about 8-15 minutes for a **green check**.
   - If nothing is running: click **Build Android APK** in the left list > **Run workflow**.
   - If **Build Android APK** does not appear at all, the hidden `.github` folder was skipped.
     Fix: **Add file > Create new file**, type the name `.github/workflows/build-apk.yml`, paste in
     the contents of that file from the unzipped folder, and click **Commit changes**.
6. Click the finished run. Under **Artifacts** download **Skillify-debug-apk**. Unzip it: inside is **app-debug.apk**.

## Install on your Android phone

1. Copy `app-debug.apk` to your phone (USB cable, Google Drive, WhatsApp "Saved messages", email to yourself).
2. Tap the file on the phone. If asked, allow **Install unknown apps** for the app you opened it from.
3. If Google Play Protect warns about an unknown app, tap **Install anyway**. This is normal for test builds
   that are not from the Play Store.
4. Open **Skillify**.

## If the build fails (red cross)

Open the failed run, click the red step, copy the last red error lines, and send them to Claude.
Compile errors are fixed quickly from that text.

## Method B: build on your own computer

1. Install Flutter (https://docs.flutter.dev/get-started/install) and Android Studio (for the Android SDK).
2. In a terminal, from the project folder:

```
flutter create --org com.skillify --project-name skillify --platforms=android build_app
cp pubspec.yaml build_app/pubspec.yaml
rm -rf build_app/lib build_app/test
cp -r lib build_app/lib
cp -r assets build_app/assets
python3 tools/patch_manifest.py build_app/android/app/src/main/AndroidManifest.xml
cd build_app
flutter pub get
dart run flutter_launcher_icons
flutter build apk --debug
```

The APK is at `build_app/build/app/outputs/flutter-apk/app-debug.apk`.
(On Windows use `copy`/`xcopy` instead of `cp`, and `python` instead of `python3`.)

## Later: a signed release APK or App Bundle

A debug APK is only for testing. For sharing widely or the Play Store:

1. Create a keystore (keep the file and passwords safe; losing them means you cannot update the app):
   `keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. Follow the official signing steps: https://docs.flutter.dev/deployment/android
   (create `android/key.properties`, then point `android/app/build.gradle(.kts)` at it).
3. Build:
   - Installable signed APK: `flutter build apk --release`
   - Play Store bundle: `flutter build appbundle --release`
4. Play Store needs a Google Play developer account (one-time fee) and a privacy policy.

## Testing checklist for your phone

- Welcome and onboarding, then create an account (stored on the phone only).
- Take the skill assessment and start a path. Check the Learn tab: tasks, lessons, quiz, projects.
- Jobs tab: demo listings are labelled DEMO DATA. Tap **Find live remote jobs** (needs internet).
- Resume tab: fill in details, export a PDF, write a cover letter, add portfolio projects.
- Assistant tab: try the suggestion chips.
