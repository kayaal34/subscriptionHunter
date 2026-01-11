# Subscription Tracker - Setup & Development Guide

## Initial Setup

### 1. Prerequisites Installation

**On Windows:**
```powershell
# Install Flutter (if not already installed)
# Download from https://flutter.dev/docs/get-started/install/windows

# Verify installation
flutter --version
dart --version
```

### 2. Project Setup

```bash
# Navigate to project directory
cd subscription_tracker

# Get all dependencies
flutter pub get

# Generate Hive adapters and code generation
flutter pub run build_runner build

# Clean and rebuild (if needed)
flutter clean
flutter pub get
```

### 3. Android Setup (Optional)

```bash
# Check Android setup
flutter doctor -v

# Accept Android licenses
flutter doctor --android-licenses

# For emulator
flutter emulators --launch Pixel_5_API_31
```

### 4. iOS Setup (Optional, macOS only)

```bash
# Install pods
cd ios
pod install
cd ..

# Run on simulator
flutter run -d "iPhone 14 Pro"
```

## Running the App

### Development Mode
```bash
# Run on default device
flutter run

# Run with hot reload (automatic)
# Press 'r' to hot reload in terminal
# Press 'R' to hot restart (full rebuild)

# Run on specific device
flutter run -d <device-id>

# List available devices
flutter devices
```

### Release Mode
```bash
# Generate signed APK (Android)
flutter build apk --release

# Generate signed App Bundle (Android, for Play Store)
flutter build appbundle --release

# Build for iOS
flutter build ios --release
```

## Project Configuration

### pubspec.yaml Overview

Key dependencies:
- **riverpod**: State management and dependency injection
- **hive**: Local database
- **flutter_local_notifications**: Push notifications
- **intl**: Internationalization and date formatting
- **uuid**: Generate unique subscription IDs
- **equatable**: Value object equality

### Code Generation

Some packages require code generation:

```bash
# Generate all code (adapters, freezed, etc.)
flutter pub run build_runner build

# Watch mode (regenerate on file changes)
flutter pub run build_runner watch

# Delete old generated files
flutter pub run build_runner clean
```

This generates:
- `subscription_model.g.dart` - Hive adapter
- Type-safe database serialization

## Development Workflow

### 1. Creating a New Page

```dart
// File: lib/presentation/pages/my_new_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyNewPage extends ConsumerWidget {
  const MyNewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access providers here
    return Scaffold(
      appBar: AppBar(title: const Text('My Page')),
      body: Center(child: Text('Content here')),
    );
  }
}
```

### 2. Creating a New Widget

```dart
// File: lib/presentation/widgets/my_widget.dart
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const MyWidget({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(title),
    );
  }
}
```

### 3. Creating a New Entity

```dart
// File: lib/domain/entities/my_entity.dart
import 'package:equatable/equatable.dart';

class MyEntity extends Equatable {
  final String id;
  final String name;

  const MyEntity({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
```

### 4. Creating a New UseCase

```dart
// File: lib/domain/usecases/my_usecases.dart
import 'package:subscription_tracker/domain/repositories/my_repository.dart';

class MyUseCase {
  final MyRepository repository;

  MyUseCase(this.repository);

  Future<void> call(String param) async {
    return await repository.doSomething(param);
  }
}
```

### 5. Creating a New Provider

```dart
// Add to: lib/presentation/providers/subscription_providers.dart
final myProvider = Provider<MyService>((ref) {
  return MyService();
});

final myStreamProvider = StreamProvider((ref) async* {
  final service = ref.watch(myProvider);
  yield* service.watchData();
});
```

## Debugging

### Enable Logging

The app uses the `logger` package. Configure in `core/services/notification_service.dart`:

```dart
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
  ),
);
```

### Common Issues

**Issue: "Hive box not found"**
```dart
// Solution: Ensure initialization before access
await Hive.initFlutter();
if (!Hive.isAdapterRegistered(0)) {
  Hive.registerAdapter(SubscriptionModelAdapter());
}
```

**Issue: "Notification permissions not granted"**
```dart
// Android: Ensure in AndroidManifest.xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

// iOS: User must grant permissions at runtime (automatic prompt)
```

**Issue: "Code generation not working"**
```bash
# Clean and rebuild
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

## Testing

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/domain/entities/subscription_test.dart
```

### Run with Coverage
```bash
flutter test --coverage

# View coverage report (install lcov first)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Example Unit Test

```dart
// File: test/domain/entities/subscription_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_tracker/domain/entities/subscription.dart';

void main() {
  group('Subscription', () {
    test('getDaysUntilBilling returns correct count', () {
      final sub = Subscription(
        id: '1',
        title: 'Netflix',
        cost: 9.99,
        billingDay: 15,
        icon: 'streaming',
        createdAt: DateTime.now(),
      );
      
      final days = sub.getDaysUntilBilling();
      expect(days, isA<int>());
      expect(days, greaterThanOrEqualTo(0));
    });

    test('isBillingSoon returns true when < 3 days', () {
      final tomorrow = DateTime.now().add(Duration(days: 1));
      final sub = Subscription(
        id: '1',
        title: 'Netflix',
        cost: 9.99,
        billingDay: tomorrow.day,
        icon: 'streaming',
        createdAt: DateTime.now(),
      );
      
      expect(sub.isBillingSoon(), true);
    });
  });
}
```

## Code Quality

### Run Analyzer
```bash
# Check for issues
dart analyze

# Fix common issues automatically
dart fix --apply
```

### Linting Rules
Configured in `analysis_options.yaml` with 100+ rules ensuring:
- Consistent code style
- Performance best practices
- Security guidelines
- Flutter-specific recommendations

## Deployment

### Android Play Store

1. **Generate signed key**:
```bash
keytool -genkey -v -keystore subscription_tracker.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias subscription_tracker
```

2. **Create signing configuration** (`android/key.properties`):
```properties
storeFile=../subscription_tracker.jks
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=subscription_tracker
```

3. **Build release bundle**:
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

4. **Upload to Play Store** via [Google Play Console](https://play.google.com/console)

### iOS App Store

1. **Configure signing in Xcode** (open `ios/Runner.xcworkspace`)
   - Select Runner target
   - General → Signing & Capabilities
   - Choose your team and provisioning profile

2. **Build release**:
```bash
flutter build ios --release
```

3. **Archive and upload** via Xcode or [App Store Connect](https://appstoreconnect.apple.com)

## Performance Optimization

### Memory Usage
- Hive caches data in memory after first read
- Large lists are paginated if needed
- Unused providers are garbage collected

### Build Time
- Use `--split-per-abi` for Android release builds
- Use `flutter build web --caching` for faster web builds

### App Size
- Strip debug symbols: `flutter build apk --split-per-abi --release`
- Typical size: ~50MB on Android, ~100MB on iOS

## Useful Commands

```bash
# Get project info
flutter pub pubspec

# Check for outdated packages
flutter pub outdated

# Update packages (safe)
flutter pub upgrade

# Upgrade packages (breaking changes possible)
flutter pub upgrade --major-versions

# Analyze package dependencies
flutter pub deps

# Generate lock file
flutter pub get
```

## Documentation

- **Architecture**: See [ARCHITECTURE.md](ARCHITECTURE.md)
- **README**: See [README.md](README.md)
- **API Reference**: Use IDE autocomplete and documentation hover

## Support

For questions or issues:
1. Check [ARCHITECTURE.md](ARCHITECTURE.md) for design patterns
2. Review [README.md](README.md) for feature documentation
3. Check Flutter docs: https://flutter.dev/docs
4. Check Riverpod docs: https://riverpod.dev
5. Check Hive docs: https://docs.hivedb.dev

## Next Steps

1. Complete initial setup using commands above
2. Review [ARCHITECTURE.md](ARCHITECTURE.md) to understand code organization
3. Run the app: `flutter run`
4. Explore the codebase, starting with `lib/main.dart`
5. Add new subscriptions to test the app
6. Review notifications trigger 1 day before billing

Happy coding! 🚀
