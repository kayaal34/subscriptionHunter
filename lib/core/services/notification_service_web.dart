// Web-specific notification implementation
import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<void> sendWebNotification(String title, String body) async {
  final permission = web.Notification.permission.toString();
  if (permission == 'granted') {
    web.Notification(
      title,
      web.NotificationOptions(
        body: body,
        icon: '/favicon.png',
      ),
    );
  } else if (permission == 'default') {
    final requestedPermission = (await web.Notification.requestPermission().toDart).toString();
    if (requestedPermission == 'granted') {
      web.Notification(
        title,
        web.NotificationOptions(
          body: body,
          icon: '/favicon.png',
        ),
      );
    }
  }
}

Future<bool> requestWebNotificationPermission() async {
  final permission = (await web.Notification.requestPermission().toDart).toString();
  return permission == 'granted';
}
