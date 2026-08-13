import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_palette.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/providers/settings_providers.dart';
import '../../../core/services/notification_coordinator.dart';
import '../../../l10n/generated/app_localizations.dart';

/// First-launch flow: three intro pages, then a consent gate.
///
/// The user cannot reach the app without accepting the data notice, which is
/// why the final button stays disabled until the checkbox is ticked. The
/// notification permission is deliberately *not* required - a reminder app is
/// still useful without it, and forcing the prompt is a common reason for
/// store rejections.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();

  int _page = 0;
  bool _privacyAccepted = false;
  bool _notificationsRequested = false;
  bool _notificationsGranted = false;

  static const _introPages = 3;
  static const _totalPages = _introPages + 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    HapticFeedback.selectionClick();
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _requestNotifications() async {
    final l10n = context.l10n;
    final service = ref.read(notificationServiceProvider);

    // The channel has to exist before Android will show anything, so init runs
    // here rather than waiting for the coordinator on the next screen.
    await service.init(
      channelName: l10n.notificationChannelName,
      channelDescription: l10n.notificationChannelDescription,
    );
    final granted = await service.requestPermissions();

    if (!mounted) return;
    setState(() {
      _notificationsRequested = true;
      _notificationsGranted = granted;
    });
  }

  Future<void> _finish() async {
    if (!_privacyAccepted) return;
    // Fire-and-forget: awaiting a haptic delays the thing the user actually
    // asked for behind a platform round-trip.
    unawaited(HapticFeedback.mediumImpact());
    // Flipping this redirects the router to the home screen.
    await ref.read(onboardingCompletedProvider.notifier).complete();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLast = _page == _totalPages - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (value) => setState(() => _page = value),
                children: [
                  _IntroPane(
                    icon: Icons.receipt_long_rounded,
                    title: l10n.onboardingTitle1,
                    body: l10n.onboardingBody1,
                  ),
                  _IntroPane(
                    icon: Icons.notifications_active_rounded,
                    title: l10n.onboardingTitle2,
                    body: l10n.onboardingBody2,
                  ),
                  _IntroPane(
                    icon: Icons.insights_rounded,
                    title: l10n.onboardingTitle3,
                    body: l10n.onboardingBody3,
                  ),
                  _ConsentPane(
                    l10n: l10n,
                    privacyAccepted: _privacyAccepted,
                    onPrivacyChanged: (value) =>
                        setState(() => _privacyAccepted = value),
                    notificationsRequested: _notificationsRequested,
                    notificationsGranted: _notificationsGranted,
                    onRequestNotifications: _requestNotifications,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  _PageDots(count: _totalPages, current: _page),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    key: const Key('onboarding-primary-action'),
                    // Disabled rather than hidden on the last page, so the
                    // reason the flow is blocked stays visible.
                    onPressed: isLast
                        ? (_privacyAccepted ? _finish : null)
                        : _next,
                    child: Text(
                      isLast ? l10n.onboardingStart : l10n.onboardingNext,
                    ),
                  ),
                  if (isLast && !_privacyAccepted) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.onboardingConsentRequired,
                      textAlign: TextAlign.center,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroPane extends StatelessWidget {
  const _IntroPane({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.colors.primary,
                    context.colors.primary.withValues(alpha: 0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.3),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: Icon(icon, size: 56, color: context.colors.onPrimary),
            )
            .animate()
            .fadeIn(duration: 420.ms)
            .scaleXY(begin: 0.85, curve: Curves.easeOutBack),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          title,
          textAlign: TextAlign.center,
          style: context.text.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(delay: 120.ms, duration: 380.ms).slideY(begin: 0.15),
        const SizedBox(height: AppSpacing.md),
        Text(
          body,
          textAlign: TextAlign.center,
          style: context.text.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 380.ms).slideY(begin: 0.15),
      ],
    ),
  );
}

/// Final pane: the data notice (required) and the notification prompt
/// (optional).
class _ConsentPane extends StatelessWidget {
  const _ConsentPane({
    required this.l10n,
    required this.privacyAccepted,
    required this.onPrivacyChanged,
    required this.notificationsRequested,
    required this.notificationsGranted,
    required this.onRequestNotifications,
  });

  final AppLocalizations l10n;
  final bool privacyAccepted;
  final ValueChanged<bool> onPrivacyChanged;
  final bool notificationsRequested;
  final bool notificationsGranted;
  final Future<void> Function() onRequestNotifications;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
    children: [
      const SizedBox(height: AppSpacing.xl),
      Text(
        l10n.onboardingConsentTitle,
        style: context.text.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      Text(
        l10n.onboardingConsentIntro,
        style: context.text.bodyMedium?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),

      const SizedBox(height: AppSpacing.xl),
      _ConsentCard(
        icon: Icons.lock_outline_rounded,
        title: l10n.onboardingPrivacyLabel,
        detail: l10n.onboardingPrivacyDetail,
        trailing: Checkbox(
          key: const Key('onboarding-privacy-checkbox'),
          value: privacyAccepted,
          onChanged: (value) => onPrivacyChanged(value ?? false),
        ),
        onTap: () => onPrivacyChanged(!privacyAccepted),
      ),

      const SizedBox(height: AppSpacing.md),
      _ConsentCard(
        icon: Icons.notifications_none_rounded,
        title: l10n.onboardingNotificationsTitle,
        detail: l10n.onboardingNotificationsDetail,
        footer: notificationsRequested
            ? Row(
                children: [
                  Icon(
                    notificationsGranted
                        ? Icons.check_circle_rounded
                        : Icons.info_outline_rounded,
                    size: 18,
                    color: notificationsGranted
                        ? AppPalette.success
                        : context.colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      notificationsGranted
                          ? l10n.onboardingNotificationsGranted
                          : l10n.onboardingNotificationsSkipped,
                      style: context.text.bodySmall,
                    ),
                  ),
                ],
              )
            : OutlinedButton.icon(
                key: const Key('onboarding-allow-notifications'),
                onPressed: onRequestNotifications,
                icon: const Icon(Icons.notifications_active_outlined),
                label: Text(l10n.onboardingAllowNotifications),
              ),
      ),
      const SizedBox(height: AppSpacing.xl),
    ],
  );
}

class _ConsentCard extends StatelessWidget {
  const _ConsentCard({
    required this.icon,
    required this.title,
    required this.detail,
    this.trailing,
    this.footer,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String detail;
  final Widget? trailing;
  final Widget? footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSpacing.cardRadius);
    return Material(
      color: context.colors.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: context.colors.primary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      title,
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ?trailing,
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                detail,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              if (footer != null) ...[
                const SizedBox(height: AppSpacing.lg),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (var i = 0; i < count; i++)
        AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: i == current ? 22 : 6,
          decoration: BoxDecoration(
            color: i == current
                ? context.colors.primary
                : context.colors.outlineVariant,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
    ],
  );
}
