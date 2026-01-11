# Subscription Tracker

A clean, offline-first mobile app for tracking subscription services with local notifications and persistent storage.

## Features

✅ **Offline-First Architecture** - All data stored locally using Hive  
✅ **Subscription Management** - Add, edit, and delete subscriptions  
✅ **Smart Sorting** - List sorted by closest billing date  
✅ **Total Cost Calculation** - Track total monthly expenses at a glance  
✅ **Visual Alerts** - Cards highlight red when billing is within 3 days  
✅ **Local Notifications** - Automatic reminders 1 day before billing at 10:00 AM  
✅ **Clean Architecture** - Production-ready code with separation of concerns  
✅ **Responsive Design** - Material Design 3 UI with smooth interactions

## Tech Stack

- **Framework**: Flutter 3.0+
- **State Management**: Riverpod (Provider Pattern)
- **Local Storage**: Hive (NoSQL database)
- **Notifications**: flutter_local_notifications + timezone
- **Code Quality**: Equatable, uuid, intl
- **Architecture**: Clean Architecture (Domain, Data, Presentation layers)

## Project Structure

```
lib/
├── config/              # App configuration
├── core/
│   ├── constants/       # App constants
│   ├── extensions/      # Dart extensions
│   └── services/        # Core services (notifications)
├── data/
│   ├── datasources/     # Local data sources
│   ├── models/          # Data models
│   └── repositories/    # Repository implementations
├── domain/
│   ├── entities/        # Business entities
│   ├── repositories/    # Repository abstractions
│   └── usecases/        # Business logic
├── presentation/
│   ├── pages/           # Screen pages
│   ├── widgets/         # Reusable widgets
│   └── providers/       # Riverpod providers
└── main.dart           # App entry point
```

## Getting Started

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart 3.0 or higher

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd subscription_tracker
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate code (Hive adapters)**
```bash
flutter pub run build_runner build
```

4. **Run the app**
```bash
flutter run
```

## Data Model

Each subscription contains:
- `id` - Unique identifier (UUID v4)
- `title` - Subscription name (e.g., "Netflix")
- `cost` - Monthly price in USD
- `billingDay` - Day of month when bill is due (1-31)
- `icon` - Category (streaming, music, cloud, fitness, etc.)
- `createdAt` - Creation timestamp

## Usage

### Adding a Subscription
1. Tap the **+** button in the bottom-right corner
2. Fill in the subscription details:
   - Title: Name of the service
   - Monthly Price: Cost per month
   - Billing Day: Day of the month when charged
   - Category: Choose an emoji category
3. Tap **Add** to save

The app automatically schedules a notification 1 day before the billing date at 10:00 AM.

### Managing Subscriptions
- **View**: Subscriptions are sorted by closest billing date
- **Edit**: Tap the menu icon on a card and select "Edit"
- **Delete**: Tap the menu icon and select "Delete"

### Understanding the UI
- **Blue card at top**: Total monthly cost of all subscriptions
- **Green badge**: Normal billing status (3+ days remaining)
- **Red badge**: Warning (less than 3 days until billing)
- **TODAY**: Billing date is today

## Clean Architecture Benefits

This app follows clean architecture principles:

1. **Separation of Concerns** - Each layer has distinct responsibilities
2. **Testability** - Easy to unit test business logic independently
3. **Maintainability** - Clear file organization and folder structure
4. **Scalability** - Easy to add new features without affecting existing code
5. **Reusability** - Domain entities and usecases can be reused across the app

## Core Layers

### Domain Layer
- Contains business logic and entities
- Independent of frameworks
- Defines interfaces (repository contracts)
- `entities/` - Pure data classes
- `repositories/` - Repository interfaces
- `usecases/` - Business logic handlers

### Data Layer
- Implements repository interfaces
- Manages data sources
- Converts between models and entities
- `datasources/` - Data access logic
- `models/` - Data transfer objects
- `repositories/` - Repository implementations

### Presentation Layer
- UI components and pages
- State management with Riverpod
- User interactions and navigation
- `pages/` - Full-screen widgets
- `widgets/` - Reusable UI components
- `providers/` - Riverpod providers for state

## Key Features Implementation

### Sorting by Billing Date
Subscriptions are automatically sorted using the `getDaysUntilBilling()` method which calculates remaining days until the next billing date.

### Smart Notifications
- Automatically calculates the next billing date
- Schedules notification 1 day before at 10:00 AM
- Uses timezone-aware scheduling for reliability
- Handled even when app is closed

### Cost Calculation
Total monthly cost is calculated in real-time whenever subscriptions change using Riverpod's `StreamProvider`.

### Visual Warnings
- Subscriptions due in less than 3 days display with red background
- "TODAY" badge appears on billing date
- "X days left" indicator updates automatically

## Database

Hive provides:
- Zero configuration
- Offline-first capability
- Type-safe queries
- Strong encryption support

All data persists across app restarts without any backend required.

## Notifications

The app uses `flutter_local_notifications`:
- Android: FCM-like behavior with channels
- iOS: Native UNUserNotificationCenter
- Reliable scheduling with timezone support
- Works when app is backgrounded or closed

## Code Quality Standards

- **Linting**: Configured with 100+ lint rules via `analysis_options.yaml`
- **Naming Conventions**: Clear, descriptive names
- **Documentation**: Code comments for complex logic
- **Error Handling**: Try-catch with user feedback
- **Type Safety**: Strong typing throughout

## Production Checklist

Before deploying:
- [ ] Update app version in `pubspec.yaml`
- [ ] Configure app signing (Android: signing.jks, iOS: provisioning profile)
- [ ] Test on multiple devices and Android/iOS versions
- [ ] Verify notification permissions are properly requested
- [ ] Test data persistence across app updates
- [ ] Review and optimize all UI/UX flows

## Contributing

When adding new features:
1. Follow the Clean Architecture pattern
2. Add entities to domain layer
3. Implement data layer with models
4. Create usecases for business logic
5. Build presentation layer with widgets
6. Update this README with new features

## License

This project is production-ready and open for use. Maintain the code quality standards established here.

## Support

For issues or questions:
1. Check if notification permissions are enabled
2. Verify local storage has space available
3. Ensure timezone data is current on device
4. Check app logs in the console
