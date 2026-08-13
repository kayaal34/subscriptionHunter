/// How often a subscription charges the user.
///
/// The old model only supported [monthly] and [yearly], which forced users to
/// fake quarterly plans as yearly and skewed every total on the statistics
/// screen. Each value carries the data the billing maths needs so the
/// calculator never has to switch on the enum in more than one place.
enum BillingCycle {
  weekly._(days: 7),
  monthly._(months: 1),
  quarterly._(months: 3),
  yearly._(months: 12);

  const BillingCycle._({this.days = 0, this.months = 0});

  /// Cycle length in days. Zero for month-based cycles.
  final int days;

  /// Cycle length in months. Zero for day-based cycles.
  final int months;

  /// True when the cycle advances by whole months and therefore needs
  /// end-of-month clamping (e.g. the 31st in a 30-day month).
  bool get isMonthBased => months > 0;

  /// Average number of charges per year.
  ///
  /// Weekly uses 52.1775 (365.25 / 7) rather than a flat 52 so a full year of
  /// weekly charges does not quietly under-report by roughly one payment.
  double get chargesPerYear => isMonthBased ? 12 / months : 365.25 / days;
}
