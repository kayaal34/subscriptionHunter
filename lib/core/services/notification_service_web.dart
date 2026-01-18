// Web-specific notification implementation
import 'dart:html' as html;

Future<void> sendWebNotification(String title, String body) async {
  final permission = html.Notification.permission;
  if (permission == 'granted') {
    html.Notification(title, body: body, icon: '/favicon.png');
  } else if (permission == 'default') {
    await html.Notification.requestPermission();
    if (html.Notification.permission == 'granted') {
      html.Notification(title, body: body, icon: '/favicon.png');
    }
  }
}

Future<bool> requestWebNotificationPermission() async {
  final permission = await html.Notification.requestPermission();
  return permission == 'granted';
}
