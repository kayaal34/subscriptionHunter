import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/currencies.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/providers/settings_providers.dart';
import '../../../../core/services/support_service.dart';
import '../../../../shared/widgets/soft_card.dart';
import '../../../subscriptions/presentation/providers/subscription_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _confirmEraseAll(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsEraseAll),
        content: Text(l10n.settingsEraseConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref.read(subscriptionActionsProvider).deleteAll();
  }

  Future<void> _contactSupport(BuildContext context) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    final launched = await SupportService.composeSupportEmail(
      localeName: context.localeName,
    );

    // No mail app configured is a normal state on a fresh device, so surface
    // the address rather than leaving the tap looking broken.
    if (!launched) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.settingsSupportUnavailable(SupportService.email)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    final currentLanguage = AppConstants.languages.firstWhere(
      (language) => language.code == settings.languageCode,
      orElse: () => AppConstants.languages.first,
    );
    final themeLabel = switch (settings.themeMode) {
      ThemeMode.light => l10n.themeLight,
      ThemeMode.dark => l10n.themeDark,
      ThemeMode.system => l10n.themeSystem,
    };

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(floating: true, title: Text(l10n.settingsTitle)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                96,
              ),
              sliver: SliverList.list(
                children: [
                  // ---- Appearance & language -----------------------------
                  // Collapsed by default to keep the screen minimal, but each
                  // header shows its current value. The language row shows the
                  // endonym ("Türkçe"), so someone stuck in a language they
                  // cannot read can still recognise and find their own.
                  _SectionLabel(l10n.settingsAppearance),
                  SoftCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _SettingsExpansionTile(
                          key: const Key('language-tile'),
                          icon: Icons.language_rounded,
                          title: l10n.settingsLanguage,
                          value: currentLanguage.code == null
                              ? l10n.themeSystem
                              : currentLanguage.endonym,
                          children: [
                            RadioGroup<String?>(
                              groupValue: settings.languageCode,
                              onChanged: controller.setLanguage,
                              child: Column(
                                children: [
                                  for (final language
                                      in AppConstants.languages)
                                    RadioListTile<String?>(
                                      key: Key(
                                        'language-${language.code ?? "system"}',
                                      ),
                                      value: language.code,
                                      title: Text(
                                        language.code == null
                                            ? l10n.themeSystem
                                            : language.endonym,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 1, indent: AppSpacing.lg),
                        _SettingsExpansionTile(
                          key: const Key('theme-tile'),
                          icon: Icons.palette_outlined,
                          title: l10n.settingsTheme,
                          value: themeLabel,
                          children: [
                            RadioGroup<ThemeMode>(
                              groupValue: settings.themeMode,
                              onChanged: (mode) {
                                if (mode != null) {
                                  controller.setThemeMode(mode);
                                }
                              },
                              child: Column(
                                children: [
                                  RadioListTile<ThemeMode>(
                                    key: const Key('theme-system'),
                                    value: ThemeMode.system,
                                    title: Text(l10n.themeSystem),
                                  ),
                                  RadioListTile<ThemeMode>(
                                    key: const Key('theme-light'),
                                    value: ThemeMode.light,
                                    title: Text(l10n.themeLight),
                                  ),
                                  RadioListTile<ThemeMode>(
                                    key: const Key('theme-dark'),
                                    value: ThemeMode.dark,
                                    title: Text(l10n.themeDark),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ---- Currency ------------------------------------------
                  _SectionLabel(l10n.settingsCurrency),
                  SoftCard(
                    child: DropdownButtonFormField<String>(
                      key: const Key('default-currency'),
                      initialValue: settings.currencyCode,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                      items: [
                        for (final currency in Currencies.all)
                          DropdownMenuItem(
                            value: currency.code,
                            child: Text(
                              '${currency.symbol}  ${currency.code} · ${currency.englishName}',
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) controller.setCurrency(value);
                      },
                    ),
                  ),

                  // ---- Notifications -------------------------------------
                  _SectionLabel(l10n.settingsNotifications),
                  SoftCard(
                    padding: EdgeInsets.zero,
                    child: SwitchListTile(
                      key: const Key('notifications-toggle'),
                      value: settings.notificationsEnabled,
                      onChanged: controller.setNotificationsEnabled,
                      title: Text(l10n.settingsNotificationsEnabled),
                      subtitle: Text(l10n.settingsNotificationsSubtitle),
                    ),
                  ),

                  // ---- Support -------------------------------------------
                  _SectionLabel(l10n.settingsSupport),
                  SoftCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      key: const Key('contact-support'),
                      leading: Icon(
                        Icons.mail_outline_rounded,
                        color: context.colors.primary,
                      ),
                      title: Text(l10n.settingsSupport),
                      subtitle: Text(l10n.settingsSupportSubtitle),
                      trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                      onTap: () => _contactSupport(context),
                    ),
                  ),

                  // ---- Legal ---------------------------------------------
                  _SectionLabel(l10n.privacyTitle),
                  SoftCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      key: const Key('privacy-policy'),
                      leading: Icon(
                        Icons.privacy_tip_outlined,
                        color: context.colors.primary,
                      ),
                      title: Text(l10n.settingsPrivacy),
                      subtitle: Text(l10n.settingsPrivacySubtitle),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push(AppRoutes.privacy),
                    ),
                  ),

                  // ---- Data ----------------------------------------------
                  _SectionLabel(l10n.settingsData),
                  SoftCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      key: const Key('erase-all-data'),
                      leading: Icon(
                        Icons.delete_forever_outlined,
                        color: context.colors.error,
                      ),
                      title: Text(
                        l10n.settingsEraseAll,
                        style: TextStyle(color: context.colors.error),
                      ),
                      onTap: () => _confirmEraseAll(context, ref),
                    ),
                  ),

                  // ---- About ---------------------------------------------
                  _SectionLabel(l10n.settingsAbout),
                  SoftCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      leading: const Icon(Icons.info_outline_rounded),
                      title: Text(l10n.appTitle),
                      subtitle: Text(
                        '${l10n.settingsVersion} ${AppConstants.version}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Collapsible settings row showing its current value in the header.
class _SettingsExpansionTile extends StatelessWidget {
  const _SettingsExpansionTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.children,
    super.key,
  });

  final IconData icon;
  final String title;
  final String value;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Theme(
    // ExpansionTile draws its own dividers, which double up with the ones
    // separating the rows in the card.
    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
    child: ExpansionTile(
      leading: Icon(icon, color: context.colors.primary),
      title: Text(title, style: context.text.titleSmall),
      subtitle: Text(
        value,
        style: context.text.bodySmall?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),
      shape: const Border(),
      collapsedShape: const Border(),
      childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
      children: children,
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.xs,
      AppSpacing.xl,
      AppSpacing.xs,
      AppSpacing.sm,
    ),
    child: Text(
      text.toUpperCase(),
      style: context.text.labelSmall?.copyWith(
        color: context.colors.primary,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    ),
  );
}
