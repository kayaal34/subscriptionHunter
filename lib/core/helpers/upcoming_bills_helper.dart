import 'package:subscription_tracker/domain/entities/subscription.dart';

/// Helper class for upcoming bills calculations
class UpcomingBillsHelper {
  /// Get subscriptions with billing within the next 7 days
  static List<Subscription> getUpcomingBills(
    List<Subscription> subscriptions, {
    int days = 7,
  }) {
    final upcoming = subscriptions.where((sub) {
      final daysUntilBilling = sub.getDaysUntilBilling();
      return daysUntilBilling >= 0 && daysUntilBilling <= days;
    }).toList();

    // Sort by days remaining (soonest first)
    upcoming.sort((a, b) => a.getDaysUntilBilling().compareTo(b.getDaysUntilBilling()));

    return upcoming;
  }

  /// Get total cost for upcoming bills in the next 7 days
  static double getTotalUpcomingCost(
    List<Subscription> subscriptions, {
    int days = 7,
  }) => getUpcomingBills(subscriptions, days: days)
        .fold(0, (sum, sub) => sum + sub.cost);

  /// Check if there are any bills due today
  static List<Subscription> getBillsDueToday(List<Subscription> subscriptions) => subscriptions.where((sub) => sub.isBillingToday()).toList();

  /// Check if there are any bills due soon (< 3 days)
  static List<Subscription> getBillsDueSoon(List<Subscription> subscriptions) => subscriptions
        .where((sub) => sub.isBillingSoon() && !sub.isBillingToday())
        .toList();
}
