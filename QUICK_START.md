# Quick Start Checklist

Complete this checklist to get the Subscription Tracker app running on your machine.

## ✅ Prerequisites (5 minutes)

- [ ] Flutter SDK 3.0+ installed
  ```bash
  flutter --version
  ```
- [ ] Dart 3.0+ installed (comes with Flutter)
  ```bash
  dart --version
  ```
- [ ] Android emulator or device ready (optional for Android)
- [ ] Xcode/iOS simulator ready (optional for iOS)

## ✅ Project Setup (5 minutes)

- [ ] Navigate to project directory
  ```bash
  cd c:\Users\yahya\uygulama\subscription_tracker
  ```

- [ ] Get Flutter dependencies
  ```bash
  flutter pub get
  ```

- [ ] Generate code (Hive adapters, etc.)
  ```bash
  flutter pub run build_runner build
  ```

- [ ] Verify no errors
  ```bash
  flutter doctor
  ```

## ✅ First Run (2 minutes)

- [ ] Run the app
  ```bash
  flutter run
  ```

- [ ] App launches successfully
- [ ] See "Subscription Tracker" title in app
- [ ] See empty state with message
- [ ] See floating action button (+) at bottom right

## ✅ Basic Testing (5 minutes)

- [ ] Tap **+** button to add subscription
- [ ] Enter subscription details:
  - Title: "Netflix"
  - Price: "15.99"
  - Billing Day: Pick day 15
  - Category: Click streaming icon 🎬
- [ ] Tap **Add** button
- [ ] Subscription appears in list
- [ ] Total cost updated (shows $15.99)
- [ ] Card shows "X days left" badge
- [ ] Green badge if 3+ days, red if < 3 days

## ✅ Notification Testing (3 minutes)

- [ ] Add subscription with billing day = tomorrow
- [ ] App schedules notification automatically
- [ ] Check system notifications are enabled:
  - **Android**: Settings > Apps > Subscription Tracker > Notifications
  - **iOS**: Settings > Subscription Tracker > Notifications

## ✅ Feature Testing (5 minutes)

### Editing
- [ ] Tap menu (⋮) on subscription card
- [ ] Select "Edit"
- [ ] Change title or price
- [ ] Tap "Update"
- [ ] Changes reflected in list

### Deleting
- [ ] Tap menu (⋮) on subscription card
- [ ] Select "Delete"
- [ ] Confirm deletion
- [ ] Subscription removed from list
- [ ] Notification cancelled
- [ ] Total cost updated

### Multiple Subscriptions
- [ ] Add 3-4 more subscriptions
- [ ] Verify sorted by billing date
- [ ] Check total cost calculates correctly
- [ ] Verify visual warnings (red for < 3 days)

## ✅ Code Quality (5 minutes)

- [ ] Run analyzer
  ```bash
  dart analyze
  ```
  ✓ Should show no errors

- [ ] Run tests
  ```bash
  flutter test
  ```
  ✓ All tests should pass

- [ ] Check linting
  ```bash
  dart analyze lib/
  ```
  ✓ No warnings (configurable in analysis_options.yaml)

## ✅ Development Workflow (5 minutes)

### Hot Reload
- [ ] Make a small UI change (e.g., change app title in main.dart)
- [ ] Press `r` in terminal
- [ ] Changes appear instantly (no app restart)

### Hot Restart
- [ ] Press `R` in terminal
- [ ] App fully restarts with fresh state
- [ ] Data persists (Hive database)

### Debugging
- [ ] Set breakpoint by clicking line number
- [ ] App pauses at breakpoint
- [ ] Inspect variables in debug console
- [ ] Press `c` to continue

## ✅ Documentation Review (5 minutes)

- [ ] Read [README.md](README.md) for features overview
- [ ] Skim [ARCHITECTURE.md](ARCHITECTURE.md) for code structure
- [ ] Check [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed setup

## ✅ Optional: Advanced Setup (10 minutes)

### Build Signed APK (Android)
```bash
# Create keystore (first time only)
keytool -genkey -v -keystore subscription_tracker.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias subscription_tracker

# Build release APK
flutter build apk --release

# Output: build/app/outputs/apk/release/app-release.apk
```

- [ ] APK generated successfully
- [ ] Install on device (optional)

### Build for iOS (macOS only)
```bash
flutter build ios --release

# Then use Xcode to upload to App Store Connect (optional)
```

- [ ] Build completes without errors

## ✅ Next Steps

Choose your next action:

### I want to...

**Understand the code** → Read [ARCHITECTURE.md](ARCHITECTURE.md)
- Domain, Data, Presentation layers explained
- Dependency flow visualized
- Clean Architecture principles

**Add a new feature** → Read [CONTRIBUTING.md](CONTRIBUTING.md)
- Coding standards and conventions
- Testing requirements
- Pull request process

**Deploy the app** → Read [SETUP_GUIDE.md](SETUP_GUIDE.md)
- Android Play Store deployment
- iOS App Store deployment
- Signing and certificates

**Customize the app** → Modify:
- [lib/main.dart](lib/main.dart) - Theme and colors
- [lib/core/constants/app_constants.dart](lib/core/constants/app_constants.dart) - Config
- [lib/presentation/pages/home_page.dart](lib/presentation/pages/home_page.dart) - Home UI

**Run on different platform**:
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run with specific flags
flutter run --release  # Release mode
flutter run --profile  # Profile mode (no debug)
```

## ✅ Troubleshooting

**Problem**: "Hive box not found"
- **Solution**: Run `flutter pub run build_runner build`

**Problem**: "Notification permissions not granted"
- **Solution**: 
  - Android: Go to Settings > Apps > Subscription Tracker > Notifications > Allow
  - iOS: Settings > Subscription Tracker > Notifications > Allow

**Problem**: "Build fails with version conflict"
- **Solution**: 
  ```bash
  flutter pub get
  flutter pub upgrade
  flutter clean
  ```

**Problem**: "Hot reload not working"
- **Solution**: Press `R` for hot restart instead

**Problem**: "Code generation failed"
- **Solution**:
  ```bash
  flutter pub run build_runner clean
  flutter pub run build_runner build
  ```

## ✅ Getting Help

1. **Check docs**
   - [README.md](README.md) - Features
   - [ARCHITECTURE.md](ARCHITECTURE.md) - Design
   - [SETUP_GUIDE.md](SETUP_GUIDE.md) - Setup

2. **Check Flutter docs**
   - https://flutter.dev/docs
   - https://api.flutter.dev

3. **Check package docs**
   - Riverpod: https://riverpod.dev
   - Hive: https://docs.hivedb.dev
   - flutter_local_notifications: Package docs in pub.dev

4. **Debug with logs**
   ```dart
   import 'package:logger/logger.dart';
   Logger().i('Info message');
   Logger().e('Error message', error: exception);
   ```

## ✅ Performance Tips

- Use **Profile mode** for performance testing:
  ```bash
  flutter run --profile
  ```

- Monitor frame rate in DevTools:
  ```bash
  flutter run
  # In terminal, press 't' to show timeline
  ```

- Check memory usage:
  ```bash
  # In DevTools: Memory tab
  ```

- Optimize builds:
  ```bash
  # Faster builds with split APK per ABI
  flutter build apk --split-per-abi
  ```

## ✅ Final Verification

Run this final checklist:

```bash
# Clean everything
flutter clean

# Get fresh dependencies
flutter pub get

# Generate code
flutter pub run build_runner build

# Run analyzer
dart analyze

# Run tests
flutter test

# Run app
flutter run
```

✅ **All steps complete!** Your app is ready to develop, test, and deploy.

---

**Estimated Total Time**: 30-45 minutes (first time)

**Support**: See documentation files or check [CONTRIBUTING.md](CONTRIBUTING.md) for reporting issues.

**Next**: Open [lib/main.dart](lib/main.dart) and start exploring the code! 🚀
