# Subscription Hunter

Offline-first subscription tracker for Android. Add what you pay for, see what
it costs per month and per year, and get reminded before each renewal.

- **Material 3** UI with full light/dark support and instant theme switching
- **35 built-in services** (Netflix, Spotify, Disney+, BluTV, Exxen …) with brand
  colours and bundled logos - one tap to add
- **Local reminders** before each charge, scheduled with the device timezone
- **Statistics** with category and 6-month spend charts
- **Turkish / English / Russian**, switchable in-app with no restart

---

## Requirements

| Tool | Version used |
|---|---|
| Flutter | 3.38.5 (stable) |
| Dart | 3.10.4 |
| JDK | **21** (see note below) |
| Android SDK | 35 |
| minSdk / targetSdk | 24 / Flutter default |

### Two environment gotchas

**1. The project path must be ASCII-only.**
Android's native tools (`impellerc`, `aapt`) fail on paths containing non-ASCII
characters with `Illegal byte sequence` / `Could not write file`. This project
was moved from `C:\Masaüstü\…` to `C:\dev\subscriptionHunter` for exactly this
reason. Do not move it back under a folder with `ü`, `ı`, `ş` etc.

**2. Gradle needs JDK 21, not the system default.**
If `java -version` reports 25, running `gradlew` directly fails with a bare
version string as the only error. Flutter is already configured correctly:

```bash
flutter config --jdk-dir "C:\Users\yahya\.jdks\openjdk-21.0.2"
```

Use `flutter build` / `flutter run` rather than calling `gradlew` by hand, or
set `JAVA_HOME` to the JDK 21 path first.

---

## Setup

```bash
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
```

`gen-l10n` generates `lib/l10n/generated/` from the ARB files.
`build_runner` generates the Drift database code (`lib/core/db/app_database.g.dart`).
Both are required before the first build.

Run it:

```bash
flutter run -d DEVICE_ID
```

### Day-to-day workflow

Install once, then push changes without reinstalling. While `flutter run` is
attached:

| Key | Effect |
|---|---|
| `r` | **Hot reload** — code change lands in ~1s, current screen and state kept |
| `R` | **Hot restart** — full restart; needed after provider, database or `main()` changes |
| `q` | Quit and detach |

Hot reload does not pick up changes to native code, `pubspec.yaml`, generated
files or the launcher icon; those need a rebuild. Regenerate icons and splash
after editing `assets/icon/*`:

```bash
dart run flutter_launcher_icons && dart run flutter_native_splash:create
```

---

## Testing

```bash
flutter test
```

Runs 81 unit and widget tests on the host. These cover the billing engine,
money formatting, spend aggregation, card rendering and the language switcher.

```bash
flutter test integration_test/app_test.dart -d DEVICE_ID
```

Runs the end-to-end suite **on a physical device**. These use the real SQLite
database and the real plugin channels, which is the point - only a device can
prove Drift, shared_preferences and the notification channel work together.

Database-backed tests live in `integration_test/` rather than `test/` on
purpose: `NativeDatabase` needs a native SQLite binary, which is supplied by
`sqlite3_flutter_libs` on the device but is not present on the Windows host.

---

## Release build

Play Store uploads need a real keystore. Create one, then add
`android/key.properties` (git-ignored):

```properties
storePassword=…
keyPassword=…
keyAlias=…
storeFile=C:/path/to/upload-keystore.jks
```

`android/app/build.gradle.kts` picks it up automatically and falls back to the
debug key when the file is absent, so debug builds keep working without it.

```bash
flutter build appbundle --release
```

**Before publishing**, confirm `applicationId` in
`android/app/build.gradle.kts`. It is currently `com.subscriptionhunter.app`
and **cannot be changed after the first upload**.

---

## Notes on two deliberate limitations

**Mixed currencies are not converted.** The app has no exchange-rate source, so
totals are grouped by currency and the headline figure covers the selected
currency only; other currencies are disclosed beneath it. Summing $10 and €10
into one number would be plainly wrong. Adding live FX is the natural next step.

**Bundled logos are brand-coloured tiles, not official artwork.**
`assets/logos/*.svg` are generated tiles carrying each brand's colour, with the
monogram drawn by Flutter on top. Real logos are fetched at runtime via
`CachedNetworkImage` when a `logoUrl` is set and the device is online, falling
back to the tile. To ship official artwork, replace the SVG of the same name.

---

## Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) - layer layout and the reasoning behind it
- [CONTRIBUTING.md](CONTRIBUTING.md)
- [TODO.md](TODO.md) - what is genuinely still outstanding
