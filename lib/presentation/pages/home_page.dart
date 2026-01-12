import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscription_tracker/core/localization/strings.dart';
import 'package:subscription_tracker/domain/entities/subscription.dart';
import 'package:subscription_tracker/presentation/pages/add_subscription_page.dart';
import 'package:subscription_tracker/presentation/pages/settings_page.dart';
import 'package:subscription_tracker/presentation/pages/statistics_page.dart';
import 'package:subscription_tracker/presentation/providers/subscription_providers.dart';
import 'package:subscription_tracker/presentation/providers/theme_provider.dart';
import 'package:subscription_tracker/presentation/widgets/subscription_card.dart';
import 'package:subscription_tracker/presentation/widgets/total_cost_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
      body: _buildPageContent(_currentIndex),
      bottomNavigationBar: Consumer(
        builder: (context, ref, _) {
          final language = ref.watch(languageProvider);
          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFFFFFFFF),
            elevation: 8,
            selectedItemColor: const Color(0xFF007AFF),
            unselectedItemColor: const Color(0xFF8E8E93),
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: getString('home', language),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.bar_chart),
                label: getString('statistics', language),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.add_circle),
                label: getString('addSubscription', language),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings),
                label: getString('settings', language),
              ),
            ],
          );
        },
      ),
    );

  Widget _buildPageContent(int index) {
    switch (index) {
      case 0:
        return const _HomePageContent();
      case 1:
        return const StatisticsPage();
      case 2:
        return AddSubscriptionPage(
          onSaved: () {
            // Navigate to home tab after saving
            setState(() {
              _currentIndex = 0;
            });
          },
        );
      case 3:
        return const SettingsPage();
      default:
        return const _HomePageContent();
    }
  }
}

class _HomePageContent extends ConsumerStatefulWidget {
  const _HomePageContent({Key? key}) : super(key: key);

  @override
  ConsumerState<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends ConsumerState<_HomePageContent> {
  String? _selectedCategory;
  String? _expandedSubscriptionId;

  @override
  Widget build(BuildContext context) {
    final sortedSubscriptionsAsync = ref.watch(sortedSubscriptionsProvider);
    final totalCostAsync = ref.watch(totalMonthlyCostProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Aboneliklerim',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFFFFFFFF),
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      body: sortedSubscriptionsAsync.when(
        data: (subscriptions) {
          // Calculate categories
          final categories = subscriptions
              .map((s) => s.icon)
              .toSet()
              .toList();
          categories.sort();

          // Filter subscriptions if category selected
          final filteredSubs = _selectedCategory == null 
              ? subscriptions 
              : subscriptions.where((s) => s.icon == _selectedCategory).toList();

          return totalCostAsync.when(
            data: (total) => Column(
              children: [
                // Total Cost Card
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: TotalCostCard(
                    totalCost: total,
                    subscriptionCount: subscriptions.length,
                  ),
                ),

                // Category Filter
                if (categories.isNotEmpty)
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: const Text(
                                'Tümü',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              selected: _selectedCategory == null,
                              onSelected: (selected) {
                                if (selected) setState(() => _selectedCategory = null);
                              },
                              backgroundColor: Colors.grey.shade100,
                              selectedColor: const Color(0xFF007AFF),
                              side: BorderSide(
                                color: _selectedCategory == null ? const Color(0xFF007AFF) : Colors.grey.shade200,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          );
                        }
                        final category = categories[index - 1];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              category,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: _selectedCategory == category ? Colors.white : Colors.black,
                              ),
                            ),
                            selected: _selectedCategory == category,
                            onSelected: (selected) {
                              setState(() => _selectedCategory = selected ? category : null);
                            },
                            backgroundColor: Colors.grey.shade100,
                            selectedColor: const Color(0xFF007AFF),
                            side: BorderSide(
                              color: _selectedCategory == category ? const Color(0xFF007AFF) : Colors.grey.shade200,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        );
                      },
                    ),
                  ),

                Expanded(
                  child: _buildSubscriptionList(filteredSubs, context, ref),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Center(child: Text('Error: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSubscriptionList(List<Subscription> subs, BuildContext context, WidgetRef ref) {
    if (subs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 60,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Abonelik bulunamadı',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: subs.length,
      itemBuilder: (context, index) {
        final subscription = subs[index];
        final isExpanded = _expandedSubscriptionId == subscription.id;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              SubscriptionCard(
                subscription: subscription,
                onTap: () {
                  setState(() {
                    _expandedSubscriptionId = isExpanded ? null : subscription.id;
                  });
                },
                onEdit: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddSubscriptionPage(
                        subscription: subscription,
                      ),
                    ),
                  );
                },
                onDelete: () {
                  _showDeleteDialog(context, subscription, ref);
                },
              ),
              // Expandable Details
              if (isExpanded)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    border: Border(
                      left: BorderSide(color: Colors.grey.shade300, width: 1.5),
                      right: BorderSide(color: Colors.grey.shade300, width: 1.5),
                      bottom: BorderSide(color: Colors.grey.shade300, width: 1.5),
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  child: _buildSubscriptionDetails(context, subscription),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubscriptionDetails(BuildContext context, Subscription subscription) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlangıç Tarihi
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.blue.shade400, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Başlangıç',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '${subscription.startDate.day}.${subscription.startDate.month}.${subscription.startDate.year}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        
        // Bitiş Tarihi (varsa)
        if (subscription.endDate != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.event_busy, color: Colors.orange.shade400, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Bitiş Tarihi',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${subscription.endDate!.day}.${subscription.endDate!.month}.${subscription.endDate!.year}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // Not (varsa)
        if (subscription.notes != null && subscription.notes!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.note, color: Colors.purple.shade400, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Not',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.purple.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  subscription.notes!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.purple.shade900,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  
  void _showDeleteDialog(BuildContext context, Subscription subscription, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sil?'),
        content: Text('${subscription.title} silinsin mi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final deleteUseCase = await ref.read(deleteSubscriptionProvider.future);
                await deleteUseCase(subscription.id);
                final notificationService = ref.read(notificationServiceProvider);
                await notificationService.cancelNotification(subscription.id);
              } catch (e) {
                // Handle error
              }
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

