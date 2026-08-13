# Architecture

Feature-first layout with clean layering inside each feature. 34 hand-written
Dart files, ~4,900 lines.

```
lib/
├── main.dart                       Loads SharedPreferences, then runs the app
│
├── app/                            Composition root
│   ├── app.dart                    MaterialApp.router; binds theme + locale to state
│   ├── router/app_router.dart      GoRouter provider; shell route + onboarding gate
│   └── theme/
│       ├── app_palette.dart        Seed colour, chart series, shadows, spacing
│       └── app_theme.dart          Light + dark ThemeData from one seed
│
├── core/                           Cross-feature infrastructure
│   ├── constants/                  app_constants, currencies, preset_catalog
│   ├── db/app_database.dart        Drift schema + connection
│   ├── extensions/                 context.l10n / .colors / .text, enum labels
│   ├── providers/                  settings (theme, language, currency)
│   ├── services/                   notification_service, notification_coordinator
│   └── utils/money_formatter.dart  Cached, locale-aware currency formatting
│
├── features/
│   ├── subscriptions/
│   │   ├── domain/                 Entity, BillingCycle, BillingCalculator,
│   │   │                           repository interface  ← no Flutter imports
│   │   ├── data/                   Drift-backed repository implementation
│   │   └── presentation/           providers, pages, widgets
│   ├── statistics/presentation/    Aggregation providers + fl_chart screens
│   ├── settings/presentation/      Settings screen
│   └── onboarding/presentation/    First-launch intro + data/notification consent
│
├── l10n/                           app_en.arb, app_tr.arb, app_ru.arb
└── shared/widgets/                 SoftCard, SubscriptionLogo, EmptyState, AppShell
```

## Dependency direction

```
presentation ──► domain ◄── data
      │                      │
      └──────► core ◄────────┘
```

`domain/` imports nothing from Flutter, Drift or Riverpod. That is what makes
`BillingCalculator` directly unit-testable, and it is where the rules that were
previously scattered across widgets now live.

## Key decisions

**Riverpod 3 over BLoC.** The project already used Riverpod. v3 removes
`StateProvider` in favour of `Notifier`, which is what every controller here
uses. Note that v3 auto-disposes providers with no listeners - tests must hold
a subscription or a `StreamProvider` never leaves its loading state.

**Drift over Hive.** `hive` 2.2.3 is discontinued, and the previous model
annotated `@HiveField` on *private* fields, which `hive_generator` cannot
process - so the adapter was never generated and the app did not compile. Drift
generates a typed schema and `sqlite3_flutter_libs` bundles a modern SQLite
binary rather than relying on Android 10's ancient system copy.

**Anchor date, not "billing day".** The old model stored an `int billingDay`,
which cannot express weekly or yearly plans without ambiguity. Every charge is
now derived from `anchorDate` + `BillingCycle`.

**All date maths in one tested place.** `BillingCalculator` handles end-of-month
clamping (a 31st anchor bills on Feb 28 then *recovers* to Mar 31), leap-year
anchors, and computes day counts on UTC-projected dates so a daylight-saving
transition cannot shift a countdown by one.

**No `permission_handler`.** `flutter_local_notifications` 22 exposes
`requestNotificationsPermission()` and `requestExactAlarmsPermission()`
directly. The extra package was redundant, and its Android build script fails
to configure under Flutter's Gradle plugin loader.

**Inexact-alarm fallback.** Reminders ask for exact delivery and degrade to an
inexact alarm when the permission is denied, rather than throwing and losing
the reminder. `USE_EXACT_ALARM` is deliberately *not* declared - Google Play
restricts it to alarm-clock and calendar apps.

**Reminders are rebuilt wholesale.** Any add, edit, delete, language change or
settings toggle calls `rescheduleAll()`. Cheaper to reason about than
incremental updates, and the scheduled set cannot drift out of sync with the
database.

**The router is a provider, and onboarding is a redirect.** `routerProvider`
watches `onboardingCompletedProvider`, and `redirect` sends the user to the
consent screen until it flips. Gating in the router rather than inside a widget
means no screen can be reached by any route while consent is outstanding.

**Logos degrade in three steps.** Real artwork from Google's favicon service
(Clearbit's Logo API was retired and its subdomain no longer resolves), a shimmer while
it loads, and a brand-coloured initial avatar backed by a bundled SVG tile if
anything fails. Presets store a bare `domain`, so the logo provider can be
replaced in one place.

**Indefinite animations break `pumpAndSettle`.** The loading spinner and the
logo shimmer schedule frames forever, so tests that touch them must pump a
bounded window (`settle()` / `waitAndTap()` in the integration suite,
`pumpApp(settle: false)` in widget tests) or they hang rather than fail.

## Version constraints that are pinned on purpose

Both are documented inline in `pubspec.yaml`; raising either breaks the build
with a confusing error:

- `drift` / `drift_dev` `< 2.34.2` — newer versions need `analyzer ^13`, which
  needs `meta ^1.18.0`, but Flutter 3.38.5 pins `meta 1.17.0`.
- `build_runner` `< 2.5.0` — newer versions AOT-compile their build script with
  `dart compile`, which refuses to run while any package in the graph ships
  native build hooks (`path_provider_foundation` → `objective_c`).
