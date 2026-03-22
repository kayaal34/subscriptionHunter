// Stub for non-web platforms
Future<void> sendWebNotification(String title, String body) async =>
    Future<void>.value();

Future<bool> requestWebNotificationPermission() async => false;
