import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscription_tracker/domain/entities/subscription.dart';
import 'package:subscription_tracker/core/services/currency_service.dart';
import 'package:subscription_tracker/core/constants/currencies.dart';
import 'package:subscription_tracker/core/localization/strings.dart';
import 'package:subscription_tracker/presentation/providers/theme_provider.dart';

class SubscriptionCard extends ConsumerWidget {

  const SubscriptionCard({
    Key? key,
    required this.subscription,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);
  
  final Subscription subscription;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final daysLeft = subscription.getDaysUntilBilling();
    final isSoon = subscription.isBillingSoon();
    
    // Determine symbol
    final currencySymbol = CurrencyService.supportedCurrencies
        .firstWhere((c) => c.code == subscription.currency, orElse: () => Currency(code: subscription.currency, symbol: subscription.currency, name: ''))
        .symbol;
    
    final formattedCost = '$currencySymbol${subscription.cost.toStringAsFixed(2)}';
    
    // Get next billing date
    final nextBillingDate = subscription.getNextBillingDate();
    final formattedDate = '${nextBillingDate.day}.${nextBillingDate.month}.${nextBillingDate.year}';

    return Container(
      color: const Color(0xFFFFFFFF), // Pure white background
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE5E5EA), // Very light gray border
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                // Subscription Name (Left)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E8E93),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Price and Days (Middle)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formattedCost,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      daysLeft == 0 ? getString('today', language) : '$daysLeft ${getString('daysLeft', language)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isSoon ? const Color(0xFFFF9500) : const Color(0xFF34C759),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                // 3-Dot Menu (Right)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit, color: Color(0xFF007AFF), size: 18),
                          const SizedBox(width: 12),
                          Text(
                            getString('edit', language),
                            style: const TextStyle(color: Color(0xFF007AFF)),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: Color(0xFFFF3B30), size: 18),
                          const SizedBox(width: 12),
                          Text(
                            getString('delete', language),
                            style: const TextStyle(color: Color(0xFFFF3B30)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert, color: Color(0xFF8E8E93), size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
