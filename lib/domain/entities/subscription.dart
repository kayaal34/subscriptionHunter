import 'package:equatable/equatable.dart';

enum BillingCycle { monthly, yearly }

class Subscription extends Equatable { // Monthly or Yearly

  const Subscription({
    required this.id,
    required this.title,
    required this.cost,
    required this.billingDay,
    required this.icon,
    required this.createdAt,
    this.currency = 'TRY',
    this.notificationHour = 10,
    this.notificationMinute = 0,
    this.notificationDaysBefore = 1,
    this.notificationsEnabled = true,
    this.imagePath,
    DateTime? startDate,
    this.billingCycle = BillingCycle.monthly,
    this.notes,
    this.endDate,
  }) : startDate = startDate ?? createdAt;
  final String id;
  final String title;
  final double cost;
  final int billingDay;
  final String icon;
  final String? imagePath;
  final DateTime createdAt;
  final String currency; // Currency code (e.g., 'TRY', 'USD')
  final int notificationHour; // Hour for daily notification (0-23)
  final int notificationMinute; // Minute for notification (0-59)
  final int notificationDaysBefore; // Days before billing to notify
  final bool notificationsEnabled; // Toggle notifications
  final DateTime? endDate; // Optional subscription end date
  final DateTime startDate; // Subscription start date
  final BillingCycle billingCycle;
  final String? notes; // User notes about subscription

  /// Calculate days remaining until next billing date
  int getDaysUntilBilling() {
    final now = DateTime.now();
    
    if (billingCycle == BillingCycle.yearly) {
      return _getDaysUntilYearlyBilling(now);
    } else {
      return _getDaysUntilMonthlyBilling(now);
    }
  }

  /// Get next billing date
  DateTime getNextBillingDate() {
    final now = DateTime.now();
    
    if (billingCycle == BillingCycle.yearly) {
      int nextYear = startDate.year;
      if (now.isAfter(DateTime(nextYear, startDate.month, startDate.day))) {
        nextYear++;
      }
      return DateTime(nextYear, startDate.month, startDate.day);
    } else {
      final currentMonth = now.month;
      final currentYear = now.year;
      int nextMonth = currentMonth;
      int nextYear = currentYear;

      if (now.day >= billingDay) {
        nextMonth = currentMonth + 1;
        if (nextMonth > 12) {
          nextMonth = 1;
          nextYear = currentYear + 1;
        }
      }

      return DateTime(nextYear, nextMonth, billingDay);
    }
  }

  int _getDaysUntilMonthlyBilling(DateTime now) {
    final currentMonth = now.month;
    final currentYear = now.year;
    int nextMonth = currentMonth;
    int nextYear = currentYear;

    if (now.day >= billingDay) {
      nextMonth = currentMonth + 1;
      if (nextMonth > 12) {
        nextMonth = 1;
        nextYear = currentYear + 1;
      }
    }

    final nextBillingDate = DateTime(nextYear, nextMonth, billingDay);
    final difference = nextBillingDate.difference(now).inDays;
    return difference >= 0 ? difference : 0;
  }

  int _getDaysUntilYearlyBilling(DateTime now) {
    int nextYear = startDate.year;
    if (now.isAfter(DateTime(nextYear, startDate.month, startDate.day))) {
      nextYear++;
    }
    final nextBillingDate = DateTime(nextYear, startDate.month, startDate.day);
    final difference = nextBillingDate.difference(now).inDays;
    return difference >= 0 ? difference : 0;
  }

  /// Check if billing is due soon (< 3 days)
  bool isBillingSoon() => getDaysUntilBilling() < 3 && getDaysUntilBilling() >= 0;

  /// Check if billing is overdue
  bool isBillingToday() => getDaysUntilBilling() == 0;

  @override
  List<Object?> get props => [
    id,
    title,
    cost,
    billingDay,
    icon,
    createdAt,
    currency,
    notificationHour,
    notificationDaysBefore,
    notificationsEnabled,
    startDate,
    billingCycle,
    notes,
    endDate,
  ];
}
