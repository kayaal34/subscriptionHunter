import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscription_tracker/presentation/providers/theme_provider.dart';
import 'package:subscription_tracker/presentation/providers/currency_provider.dart';
import 'package:subscription_tracker/presentation/providers/subscription_providers.dart';
import 'package:subscription_tracker/core/services/currency_service.dart';
import 'package:hive/hive.dart';
import 'package:subscription_tracker/data/models/subscription_model.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late int _notificationHour;
  late int _notificationMinute;
  late bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    final appSettings = Hive.box('app_settings');
    _notificationsEnabled = appSettings.get('notificationsEnabled', defaultValue: true) as bool;
    _notificationHour = appSettings.get('defaultNotificationHour', defaultValue: 10) as int;
    _notificationMinute = appSettings.get('defaultNotificationMinute', defaultValue: 0) as int;
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final isTr = language == AppLanguage.turkish;

    return Scaffold(
      appBar: AppBar(
        title: Text(isTr ? 'Ayarlar' : 'Settings'),
        elevation: 0,
        backgroundColor: const Color(0xFFFFFFFF),
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // NOTIFICATIONS SECTION
          _SettingsSection(
            title: isTr ? 'Bildirimler' : 'Notifications',
            children: [
              // Enable/Disable Notifications
              SwitchListTile(
                title: Text(
                  isTr ? 'Bildirimleri Aç/Kapat' : 'Enable Notifications',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                    final appSettings = Hive.box('app_settings');
                    appSettings.put('notificationsEnabled', value);
                  });
                },
                activeThumbColor: const Color(0xFF007AFF),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              Divider(
                height: 1,
                color: Colors.grey.shade200,
                indent: 16,
                endIndent: 16,
              ),
              // Notification Time
              if (_notificationsEnabled)
                ListTile(
                  title: Text(
                    isTr ? 'Bildirim Saati' : 'Notification Time',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    isTr ? 'Saatinizi ve dakikanızı ayarlayın' : 'Set your hour and minute',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                  trailing: GestureDetector(
                    onTap: () {
                      _showTimePickerDialog(context, isTr);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${_notificationHour.toString().padLeft(2, '0')}:${_notificationMinute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF007AFF),
                        ),
                      ),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // CURRENCY SECTION
          _SettingsSection(
            title: isTr ? 'Para Birimi' : 'Currency',
            children: [
              ListTile(
                title: Text(
                  isTr ? 'Varsayılan Para Birimi' : 'Default Currency',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  isTr ? 'Tutarları göstermek için kullanılacak' : 'Used to display amounts',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                  ),
                ),
                trailing: DropdownButton<String>(
                  value: ref.watch(currencyProvider),
                  underline: const SizedBox(),
                  items: CurrencyService.supportedCurrencies
                      .map((currency) => DropdownMenuItem(
                            value: currency.code,
                            child: Text(
                              '${currency.code} (${currency.symbol})',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(currencyProvider.notifier).currency = value;
                    }
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // LANGUAGE SECTION
          _SettingsSection(
            title: isTr ? 'Dil' : 'Language',
            children: [
              ListTile(
                title: Text(
                  isTr ? 'Uygulama Dili' : 'App Language',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  isTr ? 'Arayüz dilini seçin' : 'Choose interface language',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                  ),
                ),
                trailing: DropdownButton<AppLanguage>(
                  value: language,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: AppLanguage.turkish,
                      child: Text('Türkçe'),
                    ),
                    DropdownMenuItem(
                      value: AppLanguage.english,
                      child: Text('English'),
                    ),
                    DropdownMenuItem(
                      value: AppLanguage.russian,
                      child: Text('Русский'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(languageProvider.notifier).language = value;
                    }
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // DELETE ALL DATA SECTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => _showDeleteAllDataDialog(context, isTr),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF3B30).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isTr ? 'Tüm Verileri Sil' : 'Delete All Data',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showTimePickerDialog(BuildContext context, bool isTr) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 280,
        color: Colors.white,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    isTr ? 'İptal' : 'Cancel',
                    style: const TextStyle(color: Color(0xFF007AFF)),
                  ),
                ),
                Text(
                  isTr ? 'Bildirim Saati' : 'Notification Time',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                CupertinoButton(
                  onPressed: () async {
                    final appSettings = Hive.box('app_settings');
                    appSettings.put('defaultNotificationHour', _notificationHour);
                    appSettings.put('defaultNotificationMinute', _notificationMinute);
                    
                    // Reschedule all notifications with new time
                    await _rescheduleAllNotifications();
                    
                    Navigator.pop(context);
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isTr 
                            ? 'Bildirim saati güncellendi ve tüm bildirimler yeniden zamanlandı' 
                            : 'Notification time updated and all notifications rescheduled'),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  child: Text(
                    isTr ? 'Tamam' : 'Done',
                    style: const TextStyle(color: Color(0xFF007AFF)),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Theme(
                data: ThemeData.light().copyWith(
                  cupertinoOverrideTheme: const CupertinoThemeData(
                    primaryColor: Color(0xFF007AFF), // iOS mavi teması
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        fontSize: 21,
                        color: Color(0xFF007AFF), // Seçili saat rengi
                      ),
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: DateTime(
                    2024,
                    1,
                    1,
                    _notificationHour,
                    _notificationMinute,
                  ),
                  onDateTimeChanged: (DateTime newDateTime) {
                    setState(() {
                      _notificationHour = newDateTime.hour;
                      _notificationMinute = newDateTime.minute;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Reschedule all notifications with new global time
  Future<void> _rescheduleAllNotifications() async {
    try {
      // Get all subscriptions
      final getAllUseCase = await ref.read(getAllSubscriptionsProvider.future);
      final subscriptions = await getAllUseCase();
      
      // Get notification service
      final notificationService = ref.read(notificationServiceProvider);
      
      // Get new time from settings
      final appSettings = Hive.box('app_settings');
      final newHour = appSettings.get('defaultNotificationHour', defaultValue: 10) as int;
      final newMinute = appSettings.get('defaultNotificationMinute', defaultValue: 0) as int;
      
      // Reschedule each subscription
      for (final sub in subscriptions) {
        if (sub.notificationsEnabled) {
          await notificationService.scheduleSubscriptionReminder(
            subscriptionId: sub.id,
            subscriptionTitle: sub.title,
            billingDay: sub.billingDay,
            notificationHour: newHour,
            notificationMinute: newMinute,
            notificationDaysBefore: sub.notificationDaysBefore,
            enabled: true,
          );
        }
      }
    } catch (e) {
      // Log error but don't throw
      debugPrint('Error rescheduling notifications: $e');
    }
  }

  void _showDeleteAllDataDialog(BuildContext context, bool isTr) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isTr ? 'Tüm Verileri Sil?' : 'Delete All Data?',
          style: const TextStyle(color: Color(0xFFFF3B30)),
        ),
        content: Text(
          isTr
              ? 'Bu işlem geri alınamaz. Tüm abonelikleriniz silinecektir.'
              : 'This action cannot be undone. All your subscriptions will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isTr ? 'İptal' : 'Cancel',
              style: const TextStyle(color: Color(0xFF007AFF)),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Clear all subscription data
                await Hive.box<SubscriptionModel>('subscriptions').clear();
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isTr ? 'Tüm veriler silindi' : 'All data deleted',
                      ),
                      backgroundColor: const Color(0xFFFF3B30),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isTr ? 'Silme işleminde hata oluştu: $e' : 'Error deleting data: $e',
                      ),
                      backgroundColor: const Color(0xFFFF3B30),
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF3B30),
            ),
            child: Text(
              isTr ? 'Sil' : 'Delete',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
            letterSpacing: 1.2,
          ),
        ),
      ),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: children,
        ),
      ),
    ],
  );
}
