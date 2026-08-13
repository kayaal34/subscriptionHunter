import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/support_service.dart';
import '../../../../shared/widgets/soft_card.dart';

/// The privacy policy, readable inside the app.
///
/// Google Play also requires a publicly hosted copy, linked from the store
/// listing - see [AppConstants.privacyPolicyUrl] and PRIVACY_POLICY.md. This
/// screen exists in addition to that, so the policy is available offline and
/// in the user's own language rather than only in English on a web page.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  Future<void> _openHostedCopy(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.parse(AppConstants.privacyPolicyUrl);
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    // Show the address itself when no browser can handle it, so the link is
    // still usable rather than the tap doing nothing.
    if (!launched) {
      messenger.showSnackBar(
        const SnackBar(content: Text(AppConstants.privacyPolicyUrl)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          Text(
            l10n.privacyUpdated,
            style: context.text.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.privacyIntro,
            style: context.text.bodyMedium?.copyWith(height: 1.55),
          ),
          const SizedBox(height: AppSpacing.xl),

          _Section(
            icon: Icons.storage_rounded,
            title: l10n.privacyStorageTitle,
            body: l10n.privacyStorageBody,
          ),
          _Section(
            icon: Icons.cloud_outlined,
            title: l10n.privacyNetworkTitle,
            body: l10n.privacyNetworkBody,
          ),
          _Section(
            icon: Icons.notifications_none_rounded,
            title: l10n.privacyNotificationsTitle,
            body: l10n.privacyNotificationsBody,
          ),
          _Section(
            icon: Icons.mail_outline_rounded,
            title: l10n.privacySupportTitle,
            body: l10n.privacySupportBody,
          ),
          _Section(
            icon: Icons.block_rounded,
            title: l10n.privacyNoTrackingTitle,
            body: l10n.privacyNoTrackingBody,
          ),
          _Section(
            icon: Icons.delete_outline_rounded,
            title: l10n.privacyControlTitle,
            body: l10n.privacyControlBody,
          ),
          _Section(
            icon: Icons.child_care_rounded,
            title: l10n.privacyChildrenTitle,
            body: l10n.privacyChildrenBody,
          ),
          _Section(
            icon: Icons.alternate_email_rounded,
            title: l10n.privacyContactTitle,
            body: l10n.privacyContactBody(SupportService.email),
          ),

          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            key: const Key('privacy-view-online'),
            onPressed: () => _openHostedCopy(context),
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(l10n.privacyViewOnline),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: context.colors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            body,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              height: 1.55,
            ),
          ),
        ],
      ),
    ),
  );
}
