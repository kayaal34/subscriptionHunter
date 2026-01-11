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

  @override
  Widget build(BuildContext context) {
    final sortedSubscriptionsAsync = ref.watch(sortedSubscriptionsProvider);
    final totalCostAsync = ref.watch(totalMonthlyCostProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aboneliklerim'),
        elevation: 0,
        backgroundColor: const Color(0xFFFFFFFF),
        surfaceTintColor: Colors.transparent,
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
                TotalCostCard(totalCost: total),

                // Category Filter
                if (categories.isNotEmpty)
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: categories.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: const Text(
                                'Tümü',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              selected: _selectedCategory == null,
                              onSelected: (selected) {
                                if (selected) setState(() => _selectedCategory = null);
                              },
                              backgroundColor: const Color(0xFFF2F2F7),
                              selectedColor: const Color(0xFF007AFF),
                              side: BorderSide(
                                color: _selectedCategory == null ? const Color(0xFF007AFF) : const Color(0xFFE5E5EA),
                                width: 1,
                              ),
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
                                fontWeight: FontWeight.w500,
                                color: _selectedCategory == category ? Colors.white : Colors.black,
                              ),
                            ),
                            selected: _selectedCategory == category,
                            onSelected: (selected) {
                              setState(() => _selectedCategory = selected ? category : null);
                            },
                            backgroundColor: const Color(0xFFF2F2F7),
                            selectedColor: const Color(0xFF007AFF),
                            side: BorderSide(
                              color: _selectedCategory == category ? const Color(0xFF007AFF) : const Color(0xFFE5E5EA),
                              width: 1,
                            ),
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
        child: Text(
          'Abonelik bulunamadı',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: subs.length,
      itemBuilder: (context, index) {
         final subscription = subs[index];
         return SubscriptionCard(
            subscription: subscription,
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
          );
      },
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

