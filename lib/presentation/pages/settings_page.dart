import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscription_tracker/core/localization/localization_helper.dart';
import 'package:subscription_tracker/presentation/providers/theme_provider.dart';
import 'package:subscription_tracker/presentation/providers/currency_provider.dart';
import 'package:subscription_tracker/core/services/currency_service.dart';
import 'package:hive/hive.dart';
import 'package:subscription_tracker/data/models/subscription_model.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title: const Text('Ayarlar'),
          elevation: 0,
          backgroundColor: const Color(0xFFFFFFFF),
          surfaceTintColor: Colors.transparent,
        ),
        backgroundColor: const Color(0xFFFFFFFF),
        body: _SettingsBody(ref: ref),
      );
}

class _SettingsBody extends ConsumerWidget {
  const _SettingsBody({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final l10n = LocalizationHelper(language);
    final isTr = language == AppLanguage.turkish;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // PREFERENCES SECTION
        _SettingsSection(
          title: isTr ? 'Tercihler' : 'Preferences',
          children: [
            // Language
            ListTile(
              title: Text(
                l10n.appLanguage,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              leading: const Icon(
                Icons.language,
                color: Color(0xFF007AFF),
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
            Divider(
              height: 1,
              color: Colors.grey.shade200,
              indent: 16,
              endIndent: 16,
            ),
            // Default Currency
            ListTile(
              title: Text(
                isTr ? 'Varsayılan Para Birimi' : 'Default Currency',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              leading: const Icon(
                Icons.currency_exchange,
                color: Color(0xFF007AFF),
              ),
              trailing: DropdownButton<String>(
                value: ref.watch(currencyProvider),
                underline: const SizedBox(),
                items: CurrencyService.supportedCurrencies
                    .map((currency) => DropdownMenuItem(
                          value: currency.code,
                          child: Text('${currency.code} (${currency.symbol})'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(currencyProvider.notifier).currency = value;
                  }
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // NOTIFICATIONS SECTION
        _SettingsSection(
          title: isTr ? 'Bildirimler' : 'Notifications',
          children: [
            Consumer(
              builder: (context, ref, _) {
                // Get notification states from Hive or defaults
                final appSettings = Hive.box('app_settings');
                final phoneNotifEnabled = appSettings.get('phoneNotifEnabled', defaultValue: true) as bool;
                final gmailNotifEnabled = appSettings.get('gmailNotifEnabled', defaultValue: false) as bool;

                return Column(
                  children: [
                    SwitchListTile(
                      title: Text(
                        isTr ? 'Telefon Bildirimleri' : 'Phone Notifications',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        isTr ? 'Fatura hatırlatıcıları' : 'Bill reminders',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                      secondary: const Icon(
                        Icons.notifications_active,
                        color: Color(0xFF007AFF),
                      ),
                      value: phoneNotifEnabled,
                      activeThumbColor: const Color(0xFF007AFF),
                      onChanged: (val) {
                        appSettings.put('phoneNotifEnabled', val);
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey.shade200,
                      indent: 16,
                      endIndent: 16,
                    ),
                    SwitchListTile(
                      title: Text(
                        isTr ? 'Gmail Bildirimleri' : 'Gmail Notifications',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: const Text(
                        'Gmail',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                      secondary: const Icon(
                        Icons.mail_outline,
                        color: Color(0xFF007AFF),
                      ),
                      value: gmailNotifEnabled,
                      activeThumbColor: const Color(0xFF007AFF),
                      onChanged: (val) {
                        appSettings.put('gmailNotifEnabled', val);
                        if (val) {
                          showDialog(
                            context: context,
                            builder: (context) => _GmailNotificationDialog(language: language),
                          );
                        }
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey.shade200,
                      indent: 16,
                      endIndent: 16,
                    ),
                    ListTile(
                      title: Text(
                        isTr ? 'Bildirim Sesi' : 'Notification Sound',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: const Text(
                        'Default',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                      leading: const Icon(
                        Icons.music_note,
                        color: Color(0xFF007AFF),
                      ),
                      onTap: () {},
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ],
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // DATA SECTION
        _SettingsSection(
          title: isTr ? 'Veri & Yedekleme' : 'Data & Backup',
          children: [
            ListTile(
              title: Text(
                isTr ? 'Verileri Dışa Aktar (CSV)' : 'Export Data',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              leading: const Icon(
                Icons.file_upload,
                color: Color(0xFF007AFF),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isTr ? 'Dışa aktarma başlatıldı...' : 'Exporting data...')),
                );
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            Divider(
              height: 1,
              color: Colors.grey.shade200,
              indent: 16,
              endIndent: 16,
            ),
            ListTile(
              title: Text(
                isTr ? 'Verileri İçe Aktar' : 'Import Data',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              leading: const Icon(
                Icons.file_download,
                color: Color(0xFF007AFF),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isTr ? 'Dosya seçici açılıyor...' : 'Opening file picker...')),
                );
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            Divider(
              height: 1,
              color: Colors.grey.shade200,
              indent: 16,
              endIndent: 16,
            ),
            ListTile(
              title: Text(
                l10n.deleteAccount,
                style: const TextStyle(
                  color: Color(0xFFFF3B30),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              leading: const Icon(
                Icons.delete_forever,
                color: Color(0xFFFF3B30),
              ),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.deleteAccount),
                    content: Text(l10n.deleteConfirm),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF3B30)),
                        child: Text(l10n.delete),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  // Clear stored subscriptions from Hive
                  await Hive.box<SubscriptionModel>('subscriptions').clear();
                  if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All data deleted')),
                      );
                  }
                }
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // SUPPORT SECTION
        _SettingsSection(
          title: isTr ? 'Destek & Hakkında' : 'Support & About',
          children: [
            ListTile(
              title: Text(
                isTr ? 'Uygulamayı Puanla' : 'Rate Us',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              leading: const Icon(
                Icons.star,
                color: Color(0xFF007AFF),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: Color(0xFFC7C7CC),
              ),
              onTap: () {},
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            Divider(
              height: 1,
              color: Colors.grey.shade200,
              indent: 16,
              endIndent: 16,
            ),
            ListTile(
              title: Text(
                isTr ? 'Gizlilik Politikası' : 'Privacy Policy',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              leading: const Icon(
                Icons.privacy_tip,
                color: Color(0xFF007AFF),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: Color(0xFFC7C7CC),
              ),
              onTap: () {},
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            Divider(
              height: 1,
              color: Colors.grey.shade200,
              indent: 16,
              endIndent: 16,
            ),
            ListTile(
              title: Text(
                l10n.about,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              subtitle: const Text(
                'v1.0.0',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8E8E93),
                ),
              ),
              leading: const Icon(
                Icons.info,
                color: Color(0xFF007AFF),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ],
        ),
        
        const SizedBox(height: 30),
      ],
    );
  }
}

class _EmailReminderDialog extends StatefulWidget {
  const _EmailReminderDialog({required this.language});
  final AppLanguage language;

  @override
  State<_EmailReminderDialog> createState() => _EmailReminderDialogState();
}

class _EmailReminderDialogState extends State<_EmailReminderDialog> {
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTr = widget.language == AppLanguage.turkish;
    
    return AlertDialog(
      title: Text(isTr ? 'E-mail Hatırlatıcısı' : 'Email Reminders'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isTr 
              ? 'E-mail adresinizi girin ve abonelik değişiklikleri hakkında haberdar olun'
              : 'Enter your email address to receive subscription notifications',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: 'example@mail.com',
              labelText: isTr ? 'E-mail Adresi' : 'Email Address',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(isTr ? 'İptal' : 'Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (emailController.text.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isTr
                      ? 'E-mail adresi kaydedildi: ${emailController.text}'
                      : 'Email saved: ${emailController.text}',
                  ),
                ),
              );
              Navigator.pop(context);
            }
          },
          child: Text(isTr ? 'Kaydet' : 'Save'),
        ),
      ],
    );
  }
}

class _GmailNotificationDialog extends StatefulWidget {
  const _GmailNotificationDialog({
    required this.language,
  });
  final AppLanguage language;

  @override
  State<_GmailNotificationDialog> createState() => _GmailNotificationDialogState();
}

class _GmailNotificationDialogState extends State<_GmailNotificationDialog> {
  late TextEditingController gmailController;
  bool isValidEmail = false;

  @override
  void initState() {
    super.initState();
    gmailController = TextEditingController();
    gmailController.addListener(_validateEmail);
  }

  void _validateEmail() {
    final email = gmailController.text;
    final isValid = email.contains('@gmail.com') || email.contains('@googlemail.com');
    setState(() {
      isValidEmail = isValid;
    });
  }

  @override
  void dispose() {
    gmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTr = widget.language == AppLanguage.turkish;
    
    return AlertDialog(
      title: Text(isTr ? 'Gmail Bildirimleri' : 'Gmail Notifications'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isTr 
              ? 'Gmail adresinizi girin ve abonelik bildirimleri alın'
              : 'Enter your Gmail address to receive subscription notifications',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: gmailController,
            decoration: InputDecoration(
              hintText: 'example@gmail.com',
              labelText: isTr ? 'Gmail Adresi' : 'Gmail Address',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.mail),
              suffixIcon: isValidEmail 
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
              errorText: gmailController.text.isNotEmpty && !isValidEmail
                ? (isTr ? 'Geçerli Gmail adresi girin' : 'Enter valid Gmail address')
                : null,
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isTr
                ? '💡 Gmail hesabınızın iki adımlı doğrulaması açık olmalıdır'
                : '💡 Two-factor authentication must be enabled on your Gmail account',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(isTr ? 'İptal' : 'Cancel'),
        ),
        ElevatedButton(
          onPressed: isValidEmail
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isTr
                        ? 'Gmail adresi doğrulandı: ${gmailController.text}'
                        : 'Gmail verified: ${gmailController.text}',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              }
            : null,
          child: Text(isTr ? 'Doğrula' : 'Verify'),
        ),
      ],
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
