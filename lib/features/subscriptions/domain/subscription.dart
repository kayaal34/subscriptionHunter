import 'package:equatable/equatable.dart';

import 'billing_calculator.dart';
import 'billing_cycle.dart';
import 'subscription_category.dart';

/// A single tracked subscription.
///
/// Immutable and storage-agnostic: it knows nothing about Drift, Flutter or
/// notifications. All date maths delegates to [BillingCalculator] so the rules
/// live in exactly one tested place.
class Subscription extends Equatable {
  const Subscription({
    required this.id,
    required this.name,
    required this.price,
    required this.currencyCode,
    required this.billingCycle,
    required this.anchorDate,
    required this.category,
    required this.brandColor,
    required this.createdAt,
    required this.updatedAt,
    this.presetId,
    this.logoAsset,
    this.logoUrl,
    this.notes,
    this.endDate,
    this.isArchived = false,
    this.reminderEnabled = true,
    this.reminderDaysBefore = 1,
    this.reminderHour = 10,
    this.reminderMinute = 0,
  });

  final String id;
  final String name;

  /// Price charged once per [billingCycle], in [currencyCode].
  final double price;
  final String currencyCode;
  final BillingCycle billingCycle;

  /// Date of the first charge. Every future charge is derived from this,
  /// which is why a bare "billing day of month" field no longer exists - it
  /// could not express weekly or yearly plans without ambiguity.
  final DateTime anchorDate;

  final SubscriptionCategory category;

  /// Brand colour as an ARGB int, used for the card accent and chart slice.
  final int brandColor;

  /// Set when the row came from the preset catalog.
  final String? presetId;

  /// Bundled logo, so the list renders correctly with no network.
  final String? logoAsset;

  /// Optional higher-fidelity remote logo, layered over [logoAsset].
  final String? logoUrl;

  final String? notes;

  /// When the user has already scheduled a cancellation.
  final DateTime? endDate;

  final bool isArchived;

  final bool reminderEnabled;
  final int reminderDaysBefore;
  final int reminderHour;
  final int reminderMinute;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Stable non-negative id for flutter_local_notifications, which keys
  /// scheduled alarms by int. Derived from [id] so rescheduling replaces the
  /// previous alarm instead of stacking a duplicate.
  int get notificationId => id.hashCode & 0x7FFFFFFF;

  /// True once [endDate] has passed - the subscription no longer charges.
  bool hasEndedBy(DateTime now) =>
      endDate != null &&
      !BillingCalculator.dateOnly(
        now,
      ).isBefore(BillingCalculator.dateOnly(endDate!));

  /// Counts toward totals and reminders.
  bool isActiveOn(DateTime now) => !isArchived && !hasEndedBy(now);

  DateTime nextBillingDate(DateTime now) => BillingCalculator.nextBillingDate(
    anchor: anchorDate,
    cycle: billingCycle,
    from: now,
  );

  int daysUntilNextBilling(DateTime now) =>
      BillingCalculator.daysUntilNextBilling(
        anchor: anchorDate,
        cycle: billingCycle,
        from: now,
      );

  /// Price normalised to a month, for comparing plans of different cycles.
  double get monthlyCost =>
      BillingCalculator.monthlyEquivalent(price, billingCycle);

  /// Price normalised to a year.
  double get yearlyCost =>
      BillingCalculator.yearlyEquivalent(price, billingCycle);

  Subscription copyWith({
    String? name,
    double? price,
    String? currencyCode,
    BillingCycle? billingCycle,
    DateTime? anchorDate,
    SubscriptionCategory? category,
    int? brandColor,
    String? presetId,
    String? logoAsset,
    String? logoUrl,
    String? notes,
    DateTime? endDate,
    bool clearEndDate = false,
    bool? isArchived,
    bool? reminderEnabled,
    int? reminderDaysBefore,
    int? reminderHour,
    int? reminderMinute,
    DateTime? updatedAt,
  }) => Subscription(
    id: id,
    name: name ?? this.name,
    price: price ?? this.price,
    currencyCode: currencyCode ?? this.currencyCode,
    billingCycle: billingCycle ?? this.billingCycle,
    anchorDate: anchorDate ?? this.anchorDate,
    category: category ?? this.category,
    brandColor: brandColor ?? this.brandColor,
    presetId: presetId ?? this.presetId,
    logoAsset: logoAsset ?? this.logoAsset,
    logoUrl: logoUrl ?? this.logoUrl,
    notes: notes ?? this.notes,
    // A null endDate is meaningful ("no end"), so clearing needs its own flag
    // rather than being indistinguishable from "leave unchanged".
    endDate: clearEndDate ? null : (endDate ?? this.endDate),
    isArchived: isArchived ?? this.isArchived,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
    reminderHour: reminderHour ?? this.reminderHour,
    reminderMinute: reminderMinute ?? this.reminderMinute,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
  );

  @override
  List<Object?> get props => [
    id,
    name,
    price,
    currencyCode,
    billingCycle,
    anchorDate,
    category,
    brandColor,
    presetId,
    logoAsset,
    logoUrl,
    notes,
    endDate,
    isArchived,
    reminderEnabled,
    reminderDaysBefore,
    reminderHour,
    reminderMinute,
    createdAt,
    updatedAt,
  ];
}
