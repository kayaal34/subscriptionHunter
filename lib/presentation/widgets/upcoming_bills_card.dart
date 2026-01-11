import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:subscription_tracker/domain/entities/subscription.dart';
import 'package:subscription_tracker/core/helpers/upcoming_bills_helper.dart';

class UpcomingBillsCard extends StatelessWidget {

  const UpcomingBillsCard({
    Key? key,
    required this.subscriptions,
    this.onViewAll,
  }) : super(key: key);
  final List<Subscription> subscriptions;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final upcomingBills = UpcomingBillsHelper.getUpcomingBills(subscriptions);

    if (upcomingBills.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: Colors.green[400],
                ),
                const SizedBox(height: 8),
                const Text(
                  'No upcoming bills',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upcoming Bills (7 days)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('View All'),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: upcomingBills.length,
            itemBuilder: (context, index) {
              final subscription = upcomingBills[index];
              final daysRemaining = subscription.getDaysUntilBilling();
              final isSoon = daysRemaining < 3;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSoon ? Colors.orange[400]! : Colors.grey[300]!,
                      width: isSoon ? 2 : 1,
                    ),
                  ),
                  child: Container(
                    width: 120,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: isSoon
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.orange[50]!,
                                Colors.orange[100]!,
                              ],
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: _buildIcon(subscription.icon),
                          ),
                        ),

                        // Title
                        Text(
                          subscription.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        // Days remaining
                        Column(
                          children: [
                            Text(
                              daysRemaining == 0 ? 'Today' : '$daysRemaining days',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSoon ? Colors.orange[700] : Colors.grey[600],
                              ),
                            ),
                            Text(
                              '₺${subscription.cost.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIcon(String iconName) {
    try {
      // Try to get the icon from material_design_icons_flutter
      final iconData = _getIconData(iconName);
      return Icon(iconData, size: 28, color: Colors.blue[600]);
    } catch (e) {
      return Icon(Icons.receipt, size: 28, color: Colors.blue[600]);
    }
  }

  IconData _getIconData(String iconName) {
    final lowerName = iconName.toLowerCase();
    
    // Map common icon names to MaterialCommunityIcons
    final iconMap = {
      'netflix': MdiIcons.netflix,
      'spotify': MdiIcons.spotify,
      'youtube': MdiIcons.youtube,
      'google': MdiIcons.google,
      'facebook': MdiIcons.facebook,
      'instagram': MdiIcons.instagram,
      'twitter': MdiIcons.twitter,
      'dropbox': MdiIcons.dropbox,
      'slack': MdiIcons.slack,
      'telegram': MdiIcons.send,
      'whatsapp': MdiIcons.whatsapp,
      'zoom': MdiIcons.video,
      'receipt': MdiIcons.receipt,
    };

    return iconMap[lowerName] ?? MdiIcons.receipt;
  }
}
