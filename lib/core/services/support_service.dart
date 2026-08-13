import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_constants.dart';

/// Opens the user's mail app pre-filled with a support request.
abstract final class SupportService {
  static const String email = 'kodmod034@gmail.com';

  /// Fixed, not localised: a constant subject keeps the support inbox
  /// filterable regardless of the sender's app language.
  static const String subject = 'SubscriptionHunter Destek Talebi';

  /// Attempts to open a mail composer. Returns false when no mail app can
  /// handle the request, so the caller can show the address instead of
  /// failing silently.
  static Future<bool> composeSupportEmail({String? localeName}) async {
    // Built by hand rather than with Uri(queryParameters:), which encodes
    // spaces as "+". Several Android mail clients render those literally in
    // the subject line.
    final uri = Uri.parse(
      'mailto:$email'
      '?subject=${Uri.encodeComponent(subject)}'
      '&body=${Uri.encodeComponent(_body(localeName))}',
    );

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object catch (error) {
      debugPrint('Could not open mail composer: $error');
      return false;
    }
  }

  /// Pre-fills the environment details that would otherwise be the first
  /// thing support has to ask for.
  static String _body(String? localeName) {
    final buffer = StringBuffer()
      ..writeln()
      ..writeln()
      ..writeln('---')
      ..writeln('App version: ${AppConstants.version}');

    if (!kIsWeb) {
      buffer
        ..writeln('Platform: ${Platform.operatingSystem}')
        ..writeln('OS version: ${Platform.operatingSystemVersion}');
    }
    if (localeName != null) buffer.writeln('Language: $localeName');

    return buffer.toString();
  }
}
