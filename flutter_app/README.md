# Placement Mentor AI Flutter App

Flutter mobile client for the AI Placement Mentor backend.

## Local Run

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

## Release APK

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://your-app.onrender.com
```

APK output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Play Store Bundle

Configure the release signing placeholder in `android/app/build.gradle.kts`, then:

```bash
flutter build appbundle --release --dart-define=API_BASE_URL=https://your-app.onrender.com
```
