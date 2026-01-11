# Contributing to Subscription Tracker

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## Code Style

### Naming Conventions

- **Classes**: PascalCase (e.g., `SubscriptionCard`, `NotificationService`)
- **Files**: snake_case (e.g., `subscription_entity.dart`, `home_page.dart`)
- **Constants**: camelCase with leading underscore for private (e.g., `maxRetries`, `_defaultTimeout`)
- **Variables/Functions**: camelCase (e.g., `getUserData()`, `isLoading`)

### File Organization

```
feature_folder/
├── file1.dart
├── file2.dart
└── subfolder/
    └── file3.dart
```

Keep files under 400 lines. Split larger files into multiple files.

### Imports

Organize imports in this order:
1. Dart imports
2. Flutter imports
3. Package imports
4. Relative imports

```dart
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:riverpod/riverpod.dart';

import '../domain/entities/subscription.dart';
import '../presentation/widgets/subscription_card.dart';
```

## Architecture Guidelines

### Adding New Features

1. **Start with Domain Layer**
   - Create entity class
   - Define repository interface
   - Create usecases

2. **Then Data Layer**
   - Create model class
   - Implement datasource
   - Implement repository

3. **Finally Presentation Layer**
   - Create providers
   - Build widgets/pages
   - Add navigation

### Dependency Injection

Use Riverpod for all dependency injection:

```dart
// ✅ GOOD - Using provider
final myServiceProvider = Provider<MyService>((ref) {
  return MyService();
});

// ❌ BAD - Creating directly
MyService service = MyService();
```

### Error Handling

Always handle errors gracefully:

```dart
// ✅ GOOD
try {
  await repository.addSubscription(subscription);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Subscription added')),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e')),
  );
}

// ❌ BAD - Silent failure
await repository.addSubscription(subscription);
```

## Testing Requirements

All changes require tests:

### Unit Tests (Domain Layer)
```dart
test('usecase does X when called with Y', () async {
  final result = await usecase.call(param);
  expect(result, expectedValue);
});
```

### Widget Tests (Presentation Layer)
```dart
testWidgets('widget displays correctly', (tester) async {
  await tester.pumpWidget(MyWidget());
  expect(find.byType(Text), findsWidgets);
});
```

Run tests before submitting:
```bash
flutter test
```

## Code Quality Checklist

Before submitting a pull request:

- [ ] Code follows style guidelines
- [ ] Functions have documentation
- [ ] No unused imports
- [ ] Tests pass: `flutter test`
- [ ] No lint warnings: `dart analyze`
- [ ] Generated code updated: `flutter pub run build_runner build`
- [ ] README updated (if needed)
- [ ] ARCHITECTURE.md updated (if needed)

## Pull Request Process

1. **Fork the repository**
2. **Create feature branch**: `git checkout -b feature/your-feature`
3. **Make changes** following guidelines above
4. **Commit** with clear messages: `git commit -am "Add feature X"`
5. **Push** to your fork: `git push origin feature/your-feature`
6. **Open Pull Request** with description of changes

## Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Example:
```
feat(notifications): add daily digest notification

- Implement digest logic
- Add user preference for digest time
- Schedule notification using NotificationService

Closes #123
```

## Code Review

All pull requests require code review. Be open to feedback and:

- Respond promptly to comments
- Make requested changes in new commits
- Explain reasoning when disagreeing
- Thank reviewers for their time

## Documentation

Keep documentation up to date:

### Code Comments
Comment complex logic, not obvious code:

```dart
// ✅ GOOD - Explains why
// Calculate next billing date considering month boundaries
final nextMonth = now.day >= billingDay ? now.month + 1 : now.month;

// ❌ BAD - States the obvious
// Add one to month
final nextMonth = now.month + 1;
```

### Docstrings
Add doc comments to public APIs:

```dart
/// Calculates days until next billing date.
/// 
/// Returns 0 if billing is today, and future days otherwise.
/// For day 31 subscriptions, uses 28/29/30 for months with fewer days.
int getDaysUntilBilling() {
  // ...
}
```

## Reporting Issues

When reporting bugs, include:

1. **Description**: Clear summary of the issue
2. **Steps to reproduce**: Numbered steps to recreate
3. **Expected behavior**: What should happen
4. **Actual behavior**: What actually happens
5. **Environment**: 
   - Flutter version (`flutter --version`)
   - Device/OS
   - App version

Example:
```
**Title**: Notification not triggering for day 31 subscriptions

**Steps to reproduce**:
1. Add subscription with billing day 31
2. Go to system date 30th of month
3. Wait until 10:00 AM

**Expected**: Notification triggers
**Actual**: No notification appears

**Environment**:
- Flutter 3.10.0
- Android 13
- App v1.0.0
```

## Release Process

Releases follow [Semantic Versioning](https://semver.org/):

- **Major (1.0.0)**: Breaking changes
- **Minor (1.1.0)**: New features
- **Patch (1.0.1)**: Bug fixes

Update version in:
1. `pubspec.yaml` - `version: X.Y.Z+BUILD`
2. `CHANGELOG.md` - Document changes
3. Create git tag: `git tag v1.0.0`

## Questions?

Ask questions in:
- GitHub Issues (for bug reports)
- GitHub Discussions (for questions)
- Pull Request comments (for review feedback)

We're here to help! 🚀
