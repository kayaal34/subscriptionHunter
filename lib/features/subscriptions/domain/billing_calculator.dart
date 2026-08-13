import 'billing_cycle.dart';

/// Pure date/money maths for subscriptions.
///
/// Deliberately free of Flutter, storage and `DateTime.now()` defaults that
/// cannot be overridden, so every rule below is directly unit-testable.
///
/// Two classes of bug in the previous implementation are fixed here:
///
/// 1. Day counts were computed with `next.difference(DateTime.now()).inDays`.
///    Because `now` carries a time component, `inDays` truncates: a bill due
///    at 00:00 tomorrow reported "0 days" all of today. Everything below
///    normalises to whole dates first.
/// 2. Day differences were taken on local `DateTime`s. Across a daylight
///    saving boundary a calendar day is 23 or 25 hours long, so `inDays`
///    silently drifts by one. All day arithmetic goes through [_daysBetween],
///    which reprojects onto UTC midnight where every day is exactly 24 hours.
abstract final class BillingCalculator {
  /// Strips the time component, keeping the calendar date in local time.
  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  /// Whole days from [from] to [to], immune to daylight saving shifts.
  static int _daysBetween(DateTime from, DateTime to) {
    final a = DateTime.utc(from.year, from.month, from.day);
    final b = DateTime.utc(to.year, to.month, to.day);
    return b.difference(a).inDays;
  }

  /// Adds [months] to [anchor], clamping to the last valid day of the target
  /// month.
  ///
  /// The clamp always derives from the *original* anchor day, never from a
  /// previously clamped result. A subscription anchored on the 31st therefore
  /// bills on Feb 28, then recovers to Mar 31 - instead of collapsing to the
  /// 28th of every following month, which is what naive month-stepping does.
  static DateTime addMonthsClamped(DateTime anchor, int months) {
    final monthIndex = anchor.month - 1 + months;
    // floor division so negative month offsets roll the year back correctly;
    // `~/` truncates toward zero and would be off by one for negatives.
    final year = anchor.year + (monthIndex / 12).floor();
    final month = monthIndex % 12 + 1; // Dart's % is non-negative here.

    // Day 0 of month+1 is the last day of `month`.
    final lastDayOfMonth = DateTime(year, month + 1, 0).day;
    final day = anchor.day <= lastDayOfMonth ? anchor.day : lastDayOfMonth;
    return DateTime(year, month, day);
  }

  /// The date [count] whole cycles after [anchor].
  static DateTime addCycles(DateTime anchor, BillingCycle cycle, int count) {
    final start = dateOnly(anchor);
    if (cycle.isMonthBased) {
      return addMonthsClamped(start, cycle.months * count);
    }
    return start.add(Duration(days: cycle.days * count));
  }

  /// The first charge date on or after [from].
  ///
  /// Returns [anchor] itself when the subscription has not started yet, and
  /// returns today when a charge falls today - a bill due today has not been
  /// missed.
  static DateTime nextBillingDate({
    required DateTime anchor,
    required BillingCycle cycle,
    required DateTime from,
  }) {
    final start = dateOnly(anchor);
    final today = dateOnly(from);

    // Future-dated subscription: the anchor is the first charge.
    if (!start.isBefore(today)) return start;

    var elapsed = cycle.isMonthBased
        ? ((today.year - start.year) * 12 + (today.month - start.month)) ~/
              cycle.months
        : _daysBetween(start, today) ~/ cycle.days;
    if (elapsed < 0) elapsed = 0;

    // The estimate can land one cycle short (clamped months, partial periods),
    // so walk forward until the candidate is not in the past. Bounded to a
    // couple of iterations by construction.
    var candidate = addCycles(start, cycle, elapsed);
    while (candidate.isBefore(today)) {
      elapsed++;
      candidate = addCycles(start, cycle, elapsed);
    }
    return candidate;
  }

  /// The charge immediately preceding [nextBillingDate]; null when the
  /// subscription has not billed yet.
  static DateTime? previousBillingDate({
    required DateTime anchor,
    required BillingCycle cycle,
    required DateTime from,
  }) {
    final start = dateOnly(anchor);
    final next = nextBillingDate(anchor: anchor, cycle: cycle, from: from);
    if (next == start) return null;

    var count = 0;
    while (addCycles(start, cycle, count + 1).isBefore(next)) {
      count++;
    }
    return addCycles(start, cycle, count);
  }

  /// Whole days from [from] until the next charge. 0 means "due today".
  static int daysUntilNextBilling({
    required DateTime anchor,
    required BillingCycle cycle,
    required DateTime from,
  }) => _daysBetween(
    from,
    nextBillingDate(anchor: anchor, cycle: cycle, from: from),
  );

  /// Every charge date in `[rangeStart, rangeEnd]`, inclusive.
  ///
  /// Used by the statistics screen to total real spend inside a window rather
  /// than extrapolating from an average.
  static List<DateTime> occurrencesInRange({
    required DateTime anchor,
    required BillingCycle cycle,
    required DateTime rangeStart,
    required DateTime rangeEnd,
    DateTime? endDate,
  }) {
    final end = dateOnly(rangeEnd);
    final stop = endDate == null
        ? end
        : (dateOnly(endDate).isBefore(end) ? dateOnly(endDate) : end);

    final result = <DateTime>[];
    var current = nextBillingDate(
      anchor: anchor,
      cycle: cycle,
      from: rangeStart,
    );
    // Guard against a pathological cycle producing an unbounded loop.
    var guard = 0;
    while (!current.isAfter(stop) && guard < 5000) {
      result.add(current);
      current = nextBillingDate(
        anchor: anchor,
        cycle: cycle,
        from: current.add(const Duration(days: 1)),
      );
      guard++;
    }
    return result;
  }

  /// Cost of this subscription normalised to one month.
  ///
  /// Used to compare a yearly plan against a monthly one on the home screen.
  static double monthlyEquivalent(double price, BillingCycle cycle) =>
      price * cycle.chargesPerYear / 12;

  /// Cost of this subscription normalised to one year.
  static double yearlyEquivalent(double price, BillingCycle cycle) =>
      price * cycle.chargesPerYear;

  /// Rounds to 2 decimal places for display and for totals that would
  /// otherwise accumulate binary floating point noise.
  static double roundMoney(double value) => (value * 100).roundToDouble() / 100;
}
