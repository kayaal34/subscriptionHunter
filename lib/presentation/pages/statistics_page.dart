import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscription_tracker/core/constants/currencies.dart';
import 'package:subscription_tracker/core/localization/strings.dart';
import 'package:subscription_tracker/domain/entities/subscription.dart';
import 'package:subscription_tracker/presentation/providers/subscription_providers.dart';
import 'package:subscription_tracker/presentation/providers/theme_provider.dart';
import 'package:subscription_tracker/presentation/widgets/subscription_avatar.dart';
import 'package:subscription_tracker/presentation/providers/currency_provider.dart';
import 'package:subscription_tracker/core/services/currency_service.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(watchSubscriptionsProvider);
    final language = ref.watch(languageProvider);
    final currencyCode = ref.watch(currencyProvider);

    return Scaffold(
      body: subscriptionsAsync.when(
        data: (subscriptions) {
          if (subscriptions.isEmpty) {
            return _EmptyState(language: language);
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _MonthlyCostCard(subscriptions: subscriptions, language: language, currencyCode: currencyCode),
              const SizedBox(height: 16),
              _AnnualCostCard(subscriptions: subscriptions, language: language, currencyCode: currencyCode),
              const SizedBox(height: 16),
              _CategoriesCard(subscriptions: subscriptions, language: language, currencyCode: currencyCode),
              const SizedBox(height: 16),
              _MostExpensiveCard(subscriptions: subscriptions, language: language, currencyCode: currencyCode),
              const SizedBox(height: 16),
              _CheapestCard(subscriptions: subscriptions, language: language, currencyCode: currencyCode),
            ],
          );
        },
        loading: () => _EmptyState(language: language),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.language});
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    // localized text
    final message = language == AppLanguage.turkish
        ? 'Abonelik eklediğinizde burada yıllık harcama analizleriniz ve grafikleriniz görünecek.'
        : 'When you add subscriptions, your annual spending analysis and charts will appear here.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder Graph
            CustomPaint(
              size: const Size(200, 120),
              painter: _EmptyChartPainter(),
            ),
            const SizedBox(height: 32),
            Text(
              getString('noSubscriptions', language),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw elegant bar chart with Apple-like design
    final spacing = size.width / 6;
    final baseY = size.height * 0.75;

    // Draw bars with varying heights - more elegant
    final heights = [0.35, 0.65, 0.45, 0.80, 0.55, 0.40];
    for (int i = 0; i < heights.length; i++) {
      final x = spacing * i + spacing * 0.2;
      final barHeight = size.height * heights[i];
      final rect = Rect.fromLTWH(x, baseY - barHeight, spacing * 0.6, barHeight);
      
      // Gradient effect for bars
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.blue.shade400,
          Colors.blue.shade600,
        ],
      );
      
      final paint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        paint,
      );
    }

    // Draw subtle grid line at bottom
    final linePaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, baseY),
      Offset(size.width, baseY),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MonthlyCostCard extends StatelessWidget {

  const _MonthlyCostCard({
    required this.subscriptions,
    required this.language,
    required this.currencyCode,
  });
  final List<Subscription> subscriptions;
  final AppLanguage language;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    double monthlyCost = 0;
    
    for (final sub in subscriptions) {
      if (sub.billingCycle == BillingCycle.monthly) {
        monthlyCost += CurrencyConverter.convert(
          amount: sub.cost,
          fromCurrency: sub.currency,
          toCurrency: currencyCode,
        );
      } else {
        monthlyCost += CurrencyConverter.convert(
          amount: sub.cost / 12,
          fromCurrency: sub.currency,
          toCurrency: currencyCode,
        );
      }
    }

    final currencyService = CurrencyService();
    final formattedTotal = currencyService.getFormattedTotal(monthlyCost, currencyCode);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                getString('monthlySpending', language),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${subscriptions.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formattedTotal,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnualCostCard extends StatelessWidget {

  const _AnnualCostCard({
    required this.subscriptions,
    required this.language,
    required this.currencyCode,
  });
  final List<Subscription> subscriptions;
  final AppLanguage language;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    double annualCost = 0;
    
    for (final sub in subscriptions) {
      if (sub.billingCycle == BillingCycle.yearly) {
        annualCost += CurrencyConverter.convert(
          amount: sub.cost,
          fromCurrency: sub.currency,
          toCurrency: currencyCode,
        );
      } else {
        annualCost += CurrencyConverter.convert(
          amount: sub.cost * 12,
          fromCurrency: sub.currency,
          toCurrency: currencyCode,
        );
      }
    }

    final currencyService = CurrencyService();
    final formattedTotal = currencyService.getFormattedTotal(annualCost, currencyCode);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getString('annualSpending', language),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            formattedTotal,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (annualCost / 100000).clamp(0, 1),
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(Colors.white.withValues(alpha: 0.8)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesCard extends StatelessWidget {

  const _CategoriesCard({
    required this.subscriptions,
    required this.language,
    required this.currencyCode,
  });
  final List<Subscription> subscriptions;
  final AppLanguage language;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final categories = <String, double>{};
    
    for (final sub in subscriptions) {
      final cost = CurrencyConverter.convert(
        amount: sub.cost,
        fromCurrency: sub.currency,
        toCurrency: currencyCode,
      );
      categories[sub.icon] = (categories[sub.icon] ?? 0) + cost;
    }
    
    final currencyService = CurrencyService();

    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getString('spendingByCategory', language),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ...categories.entries.map((entry) {
                final formattedCost = currencyService.getFormattedTotal(entry.value, currencyCode);
                return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (entry.value / categories.values.reduce((a, b) => a + b)).clamp(0, 1),
                        minHeight: 6,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation(
                          Colors.primaries[entry.key.hashCode % Colors.primaries.length].shade400,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      formattedCost,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
              }
              ),
          ],
        ),
      ),
    );
  }
}

class _MostExpensiveCard extends StatelessWidget {

  const _MostExpensiveCard({
    required this.subscriptions,
    required this.language,
    required this.currencyCode,
  });
  final List<Subscription> subscriptions;
  final AppLanguage language;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    if (subscriptions.isEmpty) {
      return const SizedBox.shrink();
    }

    final sorted = List<Subscription>.from(subscriptions);
    sorted.sort((a, b) {
      final aCost = CurrencyConverter.convert(amount: a.cost, fromCurrency: a.currency, toCurrency: currencyCode);
      final bCost = CurrencyConverter.convert(amount: b.cost, fromCurrency: b.currency, toCurrency: currencyCode);
      return bCost.compareTo(aCost);
    });

    final most = sorted.first;
    final cost = CurrencyConverter.convert(
      amount: most.cost,
      fromCurrency: most.currency,
      toCurrency: currencyCode,
    );
    
    final currencyService = CurrencyService();
    final formattedCost = currencyService.getFormattedTotal(cost, currencyCode);

    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getString('mostExpensive', language),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SubscriptionAvatar(subscription: most, size: 44, fontSize: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        most.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        formattedCost,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CheapestCard extends StatelessWidget {

  const _CheapestCard({
    required this.subscriptions,
    required this.language,
    required this.currencyCode,
  });
  final List<Subscription> subscriptions;
  final AppLanguage language;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    if (subscriptions.isEmpty) {
      return const SizedBox.shrink();
    }

    final sorted = List<Subscription>.from(subscriptions);
    sorted.sort((a, b) {
      final aCost = CurrencyConverter.convert(amount: a.cost, fromCurrency: a.currency, toCurrency: currencyCode);
      final bCost = CurrencyConverter.convert(amount: b.cost, fromCurrency: b.currency, toCurrency: currencyCode);
      return aCost.compareTo(bCost);
    });

    final cheapest = sorted.first;
    final cost = CurrencyConverter.convert(
      amount: cheapest.cost,
      fromCurrency: cheapest.currency,
      toCurrency: currencyCode,
    );
    
    final currencyService = CurrencyService();
    final formattedCost = currencyService.getFormattedTotal(cost, currencyCode);

    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getString('cheapest', language),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SubscriptionAvatar(subscription: cheapest, size: 44, fontSize: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cheapest.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        formattedCost,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
