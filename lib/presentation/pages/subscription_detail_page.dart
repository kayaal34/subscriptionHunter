import 'package:flutter/material.dart';
import 'package:subscription_tracker/domain/entities/subscription.dart';
import 'package:subscription_tracker/core/services/currency_service.dart';
import 'package:subscription_tracker/core/constants/currencies.dart';

class SubscriptionDetailPage extends StatefulWidget {
  const SubscriptionDetailPage({
    Key? key,
    required this.subscription,
  }) : super(key: key);

  final Subscription subscription;

  @override
  State<SubscriptionDetailPage> createState() => _SubscriptionDetailPageState();
}

class _SubscriptionDetailPageState extends State<SubscriptionDetailPage> {
  bool _expandDetails = false;

  @override
  Widget build(BuildContext context) {
    // Get currency symbol
    final currencySymbol = CurrencyService.supportedCurrencies
        .firstWhere(
          (c) => c.code == widget.subscription.currency,
          orElse: () => Currency(code: widget.subscription.currency, symbol: widget.subscription.currency, name: ''),
        )
        .symbol;

    final formattedCost = '$currencySymbol${widget.subscription.cost.toStringAsFixed(2)}';
    final nextBillingDate = widget.subscription.getNextBillingDate();
    final formattedBillingDate = '${nextBillingDate.day}.${nextBillingDate.month}.${nextBillingDate.year}';
    final billingCycleText = widget.subscription.billingCycle == BillingCycle.monthly ? 'Aylık' : 'Yıllık';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subscription.title),
        elevation: 0,
        backgroundColor: const Color(0xFFFFFFFF),
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Info Card
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fiyat',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        formattedCost,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Billing Cycle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ödeme Döngüsü',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        billingCycleText,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF007AFF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Next Billing Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sonraki Ödeme',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        formattedBillingDate,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  if (widget.subscription.endDate != null) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bitiş Tarihi',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${widget.subscription.endDate!.day}.${widget.subscription.endDate!.month}.${widget.subscription.endDate!.year}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Notes Section
            if (widget.subscription.notes != null && widget.subscription.notes!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notlar',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      widget.subscription.notes!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

            // Details Section - Expandable
            GestureDetector(
              onTap: () => setState(() => _expandDetails = !_expandDetails),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ayrıntılar',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          _expandDetails ? Icons.expand_less : Icons.expand_more,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                    // Details Content
                    if (_expandDetails) ...[
                      const SizedBox(height: 16),
                      _buildDetailRow(context, 'Kategori', widget.subscription.icon),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      _buildDetailRow(context, 'Para Birimi', widget.subscription.currency),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        context,
                        'Başlangıç Tarihi',
                        '${widget.subscription.startDate.day}.${widget.subscription.startDate.month}.${widget.subscription.startDate.year}',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
