# Subscription Tracker - Architecture Documentation

## Overview

This application follows **Clean Architecture** principles, ensuring separation of concerns, testability, and maintainability. The codebase is organized into three main layers: Domain, Data, and Presentation.

```
┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                     │
│         (Pages, Widgets, State Management)              │
├─────────────────────────────────────────────────────────┤
│                    DOMAIN LAYER                          │
│         (Entities, Repositories, UseCases)              │
├─────────────────────────────────────────────────────────┤
│                     DATA LAYER                           │
│     (Models, DataSources, Repository Implementations)    │
├─────────────────────────────────────────────────────────┤
│                    EXTERNAL SERVICES                     │
│         (Hive, Notifications, System APIs)              │
└─────────────────────────────────────────────────────────┘
```

## Layer Breakdown

### 1. Domain Layer (`lib/domain/`)

The domain layer is the **innermost** layer containing pure business logic with NO dependencies on Flutter or any external packages (except Equatable for value objects).

#### Entities (`domain/entities/`)
- **Subscription** - Pure data class representing a subscription
- Immutable and framework-agnostic
- Contains business logic methods like `getDaysUntilBilling()` and `isBillingSoon()`

#### Repositories (`domain/repositories/`)
- **SubscriptionRepository** - Abstract interface defining contract for subscription storage
- Doesn't know HOW data is stored, only WHAT operations are needed
- Enables switching between local/remote/hybrid storage easily

#### UseCases (`domain/usecases/`)
- **GetAllSubscriptions** - Fetch all subscriptions
- **AddSubscription** - Add new subscription
- **UpdateSubscription** - Update existing subscription
- **DeleteSubscription** - Remove subscription
- **WatchSubscriptions** - Stream of subscription changes
- Each usecase has a single responsibility
- Takes repository as dependency (Dependency Injection)

### 2. Data Layer (`lib/data/`)

Implements domain layer interfaces and handles all data operations.

#### Models (`data/models/`)
- **SubscriptionModel** - Data Transfer Object (DTO)
- Extends HiveObject for Hive serialization
- Includes `toEntity()` to convert to domain entity
- Includes `fromEntity()` factory for reverse conversion
- Includes generated adapter code for Hive serialization

#### DataSources (`data/datasources/`)
- **LocalSubscriptionDataSource** - Abstract interface
- **LocalSubscriptionDataSourceImpl** - Hive implementation
- Handles raw database operations
- No business logic, just CRUD operations
- Can be swapped for Firebase, REST API, etc.

#### Repositories (`data/repositories/`)
- **SubscriptionRepositoryImpl** - Implements domain repository interface
- Bridges domain layer with data sources
- Converts models ↔ entities
- Handles any data transformation logic

### 3. Presentation Layer (`lib/presentation/`)

Handles UI rendering and user interactions.

#### Providers (`presentation/providers/`)
- **subscription_providers.dart** - All Riverpod providers
- `subscriptionBoxProvider` - Lazily opens Hive box
- `localDataSourceProvider` - Creates data source
- `subscriptionRepositoryProvider` - Creates repository
- `getAllSubscriptionsProvider` - Loads all subscriptions
- `addSubscriptionProvider` - Create usecase
- `sortedSubscriptionsProvider` - Streams sorted subscriptions
- `totalMonthlyCostProvider` - Computes total cost

#### Pages (`presentation/pages/`)
- **HomePage** - Main subscription list screen
- **AddSubscriptionPage** - Add/Edit subscription screen
- Full-screen widgets with navigation responsibility

#### Widgets (`presentation/widgets/`)
- **SubscriptionCard** - Reusable subscription display card
- **TotalCostCard** - Monthly cost summary card
- Stateless, reusable components
- Receive data as parameters

## Dependency Flow

```
UI (HomePage) 
    ↓
Riverpod Providers (subscription_providers.dart)
    ↓
UseCases (AddSubscription, GetAllSubscriptions, etc.)
    ↓
Repository (SubscriptionRepository)
    ↓
DataSource (LocalSubscriptionDataSource)
    ↓
Hive (Local Database)
```

**Key Principle**: Dependencies point INWARD. The domain layer never depends on outer layers.

## Data Flow Example: Adding a Subscription

```
1. User fills form (AddSubscriptionPage)
           ↓
2. User taps "Add" button
           ↓
3. Create Subscription entity with data
           ↓
4. Get AddSubscription usecase from provider
           ↓
5. Call usecase(subscription)
           ↓
6. Usecase calls repository.addSubscription(subscription)
           ↓
7. Repository creates SubscriptionModel from entity
           ↓
8. Repository calls dataSource.addSubscription(model)
           ↓
9. DataSource saves to Hive box
           ↓
10. Hive triggers watchers
           ↓
11. watchSubscriptionsProvider emits new list
           ↓
12. HomePage rebuilds with new subscription
           ↓
13. NotificationService schedules reminder
```

## State Management with Riverpod

### Provider Types Used

**FutureProvider** - For async initialization:
```dart
final subscriptionBoxProvider = FutureProvider<Box<SubscriptionModel>>((ref) async {
  // Returns Future that completes when box is ready
});
```

**StreamProvider** - For continuous data updates:
```dart
final watchSubscriptionsProvider = StreamProvider((ref) async* {
  // Yields new list whenever subscriptions change
});
```

**Provider** - For sync dependencies:
```dart
final notificationServiceProvider = Provider<NotificationService>((ref) {
  // Always returns same instance
});
```

### Riverpod Benefits

- No BuildContext needed for access
- Strong type safety
- Automatic dependency resolution
- Built-in error/loading states
- Easy testing with overrides

## Services

### NotificationService (`core/services/notification_service.dart`)

Handles all local notification operations:

```dart
// Initialize once at app startup
await notificationService.initialize();

// Schedule for 1 day before billing
await notificationService.scheduleSubscriptionReminder(
  subscriptionId: '123',
  subscriptionTitle: 'Netflix',
  billingDay: 15,
);

// Cancel single or all notifications
await notificationService.cancelNotification('123');
await notificationService.cancelAllNotifications();
```

**Android Implementation**:
- Creates NotificationChannel for subscription reminders
- Uses `zonedSchedule` with `AndroidScheduleMode.exactAllowWhileIdle`
- Survives app process death

**iOS Implementation**:
- Uses UNUserNotificationCenter
- Requests permission for sound, badge, alert
- Works with app backgrounded or closed

## Constants

Located in `core/constants/app_constants.dart`:

```dart
// Icon categories for subscriptions
subscriptionIcons = ['streaming', 'music', 'cloud', 'fitness', ...]

// Billing days 1-31
billingDays = [1, 2, 3, ..., 31]

// Warning threshold for billing alerts
warningThresholdDays = 3

// Notification timing
notificationHour = 10
notificationMinute = 0
```

## Extensions

Located in `core/extensions/extensions.dart`:

- **DateTimeExtension** - Format dates, calculate next billing date
- **DoubleExtension** - Format currency with proper symbols
- **StringExtension** - Map icon names to emoji

```dart
// Usage
double cost = 9.99;
cost.toCurrency() // Returns "$9.99"

DateTime.getNextBillingDate(15) // Returns next 15th of month

"streaming".toIconEmoji() // Returns "🎬"
```

## Database - Hive

### Why Hive?

- **Offline-first** - Works without internet
- **Zero config** - No setup required
- **Type-safe** - Strongly typed queries
- **Fast** - In-memory cache
- **Embeddable** - No external service needed

### Data Structure

```dart
@HiveType(typeId: 0)
class SubscriptionModel extends HiveObject {
  @HiveField(0) late String id;
  @HiveField(1) late String title;
  @HiveField(2) late double cost;
  @HiveField(3) late int billingDay;
  @HiveField(4) late String icon;
  @HiveField(5) late DateTime createdAt;
}
```

### Box Operations

```dart
// Open box
Box<SubscriptionModel> box = await Hive.openBox('subscriptions');

// Add/Update (put uses key)
await box.put('sub-123', model);

// Read
SubscriptionModel? model = box.get('sub-123');

// Read all
List<SubscriptionModel> all = box.values.toList();

// Delete
await box.delete('sub-123');

// Watch for changes
box.watch().listen((event) {
  print('Data changed!');
});
```

## Adding a New Feature

### Example: Adding Subscription Notes

1. **Update Domain** (`lib/domain/entities/subscription.dart`):
```dart
class Subscription extends Equatable {
  // ... existing fields
  final String notes; // NEW
}
```

2. **Update Data** (`lib/data/models/subscription_model.dart`):
```dart
@HiveField(6) // NEW
late String notes;

// Update fromEntity() and toEntity()
```

3. **Update Database** (`lib/data/datasources/`):
   - No changes needed - DataSource is generic

4. **Update Repository** (`lib/data/repositories/`):
   - No changes needed - Repository handles conversion

5. **Update UI** (`lib/presentation/pages/add_subscription_page.dart`):
```dart
// Add TextField for notes
TextField(
  controller: _notesController,
  decoration: InputDecoration(hintText: 'Add notes...'),
)

// Include in subscription creation
notes: _notesController.text,
```

6. **Update Widget** (`lib/presentation/widgets/subscription_card.dart`):
```dart
// Display notes in card
if (subscription.notes.isNotEmpty)
  Text(subscription.notes, style: TextStyle(fontStyle: FontStyle.italic))
```

This example shows how each layer only changes what concerns it, without affecting other layers.

## Testing Strategy

### Unit Tests (Domain)
Test UseCases and Entities independently:
```dart
test('getDaysUntilBilling returns correct value', () {
  final sub = Subscription(
    id: '1', title: 'Test', cost: 9.99,
    billingDay: 15, icon: 'test', createdAt: DateTime.now(),
  );
  expect(sub.getDaysUntilBilling(), isA<int>());
});
```

### Integration Tests (Data)
Test DataSource with real Hive:
```dart
testWidgets('LocalDataSource saves subscription', (tester) async {
  final dataSource = LocalSubscriptionDataSourceImpl(box);
  final model = SubscriptionModel(...);
  
  await dataSource.addSubscription(model);
  
  final result = await dataSource.getSubscriptionById(model.id);
  expect(result, isNotNull);
});
```

### Widget Tests (Presentation)
Test UI components:
```dart
testWidgets('SubscriptionCard displays title', (tester) async {
  await tester.pumpWidget(
    SubscriptionCard(
      subscription: mockSubscription,
      onEdit: () {},
      onDelete: () {},
    ),
  );
  
  expect(find.text('Netflix'), findsOneWidget);
});
```

## Performance Considerations

1. **Hive Caching** - Data stays in memory after first read
2. **StreamProvider** - Only rebuilds affected widgets
3. **Sorted List** - Computed once per change, then cached
4. **Lazy Loading** - Dependencies created on-demand via Riverpod
5. **Notification Scheduling** - Calculated at add/update time, not on every frame

## Security Considerations

1. **Data Storage** - Hive can be encrypted with cipher
2. **Sensitive Data** - No API keys or passwords stored
3. **Permissions** - Request notification permissions at runtime
4. **Input Validation** - Validate form inputs before saving
5. **Error Messages** - Don't expose internal errors to users

## Future Enhancements

- [ ] Add Firestore sync for cloud backup
- [ ] Support for recurring billing (weekly, yearly)
- [ ] Receipt photo storage and attachment
- [ ] Subscription sharing with family
- [ ] Analytics dashboard with spending trends
- [ ] Export to CSV/PDF for tax purposes
- [ ] Dark mode support
- [ ] Multiple currency support
- [ ] Subscription recommendations
