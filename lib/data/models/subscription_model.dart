import 'package:hive/hive.dart';
import 'package:subscription_tracker/domain/entities/subscription.dart';

part 'subscription_model.g.dart';

@HiveType(typeId: 0)
class SubscriptionModel extends HiveObject {

  SubscriptionModel({
    required this.id,
    required this.title,
    required this.cost,
    required this.billingDay,
    required this.icon,
    required this.createdAt,
    required this.startDate,
    String? currency,
    int? notificationHour,
    int? notificationMinute,
    bool? notificationsEnabled,
    int? notificationDaysBefore,
    this.imagePath,
    BillingCycle billingCycle = BillingCycle.monthly,
  })  : _currency = currency ?? 'TRY',
        _notificationHour = notificationHour ?? 10,
        _notificationMinute = notificationMinute ?? 0,
        _notificationsEnabled = notificationsEnabled ?? true,
        _notificationDaysBefore = notificationDaysBefore ?? 1,
        _billingCycle = billingCycle.toString().split('.').last;

  /// Create model from entity
  factory SubscriptionModel.fromEntity(Subscription subscription) {
    final model = SubscriptionModel(
      id: subscription.id,
      title: subscription.title,
      cost: subscription.cost,
      billingDay: subscription.billingDay,
      icon: subscription.icon,
      createdAt: subscription.createdAt,
      currency: subscription.currency,
      notificationHour: subscription.notificationHour,
      notificationMinute: subscription.notificationMinute,
      notificationDaysBefore: subscription.notificationDaysBefore,
      notificationsEnabled: subscription.notificationsEnabled,
      startDate: subscription.startDate,
      billingCycle: subscription.billingCycle,
      imagePath: subscription.imagePath,
    );
    return model;
  }
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late double cost;

  @HiveField(3)
  late int billingDay;

  @HiveField(4)
  late String icon;

  @HiveField(5)
  late DateTime createdAt;

  @HiveField(6)
  String? _currency; // Nullable for migration

  @HiveField(7)
  int? _notificationHour; // Nullable for migration

  @HiveField(8)
  bool? _notificationsEnabled; // Nullable for migration

  @HiveField(9)
  late DateTime startDate;

  @HiveField(10)
  late String _billingCycle; // Stored as string: 'monthly' or 'yearly'

  @HiveField(11)
  int? _notificationDaysBefore; // Nullable for migration

  @HiveField(12)
  int? _notificationMinute; // Nullable for migration 

  @HiveField(13)
  String? imagePath;

  // Getters with default values
  String get currency => _currency?.isEmpty ?? true ? 'TRY' : _currency!;
  int get notificationHour => _notificationHour ?? 10;
  int get notificationMinute => _notificationMinute ?? 0;
  bool get notificationsEnabled => _notificationsEnabled ?? true;
  int get notificationDaysBefore => _notificationDaysBefore ?? 1;
  
  BillingCycle get billingCycle => _billingCycle == 'yearly' ? BillingCycle.yearly : BillingCycle.monthly;

  // Setters
  set currency(String value) => _currency = value;
  set notificationHour(int value) => _notificationHour = value;
  set notificationMinute(int value) => _notificationMinute = value;
  set notificationsEnabled(bool value) => _notificationsEnabled = value;
  set billingCycle(BillingCycle value) => _billingCycle = value.toString().split('.').last;

  /// Convert model to entity
  Subscription toEntity() => Subscription(
      id: id,
      title: title,
      cost: cost,
      billingDay: billingDay,
      icon: icon,
      createdAt: createdAt,
      currency: currency,
      notificationHour: notificationHour,
      notificationMinute: notificationMinute,
      notificationDaysBefore: notificationDaysBefore,
      notificationsEnabled: notificationsEnabled,
      startDate: startDate,
      billingCycle: billingCycle,
      imagePath: imagePath,
    );

  SubscriptionModel copyWith({
    String? id,
    String? title,
    double? cost,
    int? billingDay,
    String? icon,
    DateTime? createdAt,
    String? currency,
    int? notificationHour,
    bool? notificationsEnabled,
    int? notificationDaysBefore,
    DateTime? startDate,
    BillingCycle? billingCycle,
  }) => SubscriptionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      cost: cost ?? this.cost,
      billingDay: billingDay ?? this.billingDay,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      currency: currency ?? this.currency,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationDaysBefore: notificationDaysBefore ?? this.notificationDaysBefore,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      billingCycle: billingCycle ?? this.billingCycle,
    );
}
