# Contributing

## Before you start

Two generators must run before the project compiles. Neither output is
hand-editable:

```bash
flutter gen-l10n                                      # lib/l10n/generated/
dart run build_runner build --delete-conflicting-outputs  # *.g.dart
```

Re-run `gen-l10n` after touching any `.arb`, and `build_runner` after touching
the Drift schema in `lib/core/db/app_database.dart`.

## Code style

`analysis_options.yaml` is the authority — `flutter analyze` must report
**zero** errors, warnings and infos before a change is considered done.

- Files `snake_case`, classes `PascalCase`.
- Imports inside `lib/` are **relative** (`prefer_relative_imports` is on).
- Order: `dart:` → `package:flutter` → other `package:` → relative.
- Comments explain *why*, not *what*. If a line encodes a non-obvious
  constraint (a version cap, a platform quirk, an ordering requirement), say so
  where it lives.

## Layering

```
presentation ──► domain ◄── data
```

`features/*/domain/` must not import Flutter, Drift or Riverpod. That is what
keeps `BillingCalculator` unit-testable, so keep new business rules there
rather than in a widget or a provider.

## Tests

| Command | Scope |
|---|---|
| `flutter test` | Unit + widget, runs on the host |
| `flutter test integration_test/app_test.dart -d DEVICE_ID` | End-to-end, needs a real device |

- Anything touching the database belongs in `integration_test/`: the host has
  no native SQLite binary.
- In integration tests use the local `settle()` helper, never `pumpAndSettle()`.
  A loading spinner schedules frames forever, so `pumpAndSettle` hangs instead
  of failing.
- Riverpod 3 disposes providers with no listeners. In `ProviderContainer`
  tests, hold a `container.listen(...)` or a `StreamProvider` never leaves its
  loading state.
- Prefer `Key`s over icon or text lookups for anything a test drives; icons and
  labels change with translations.

## Pitfalls that have already bitten this project

- Do **not** call `ref.listen` in `build()` for a provider nothing else has
  created yet — creating it mid-build throws "setState() called during build".
  Use `ref.listenManual` in `initState`.
- `AppDatabase` is a process-wide singleton. Constructing a second one against
  the same file makes Drift warn about corruption.
- Version caps on `drift`/`drift_dev` and `build_runner` in `pubspec.yaml` are
  deliberate and commented. Read the comment before raising them.
- Keep the project on an ASCII-only path; Android's native tools fail otherwise.
