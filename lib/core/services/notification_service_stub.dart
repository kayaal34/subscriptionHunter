// Stub for non-web platforms
Future<void> sendWebNotification(String title, String body) async {
  // No-op for non-web platforms
}

Future<bool> requestWebNotificationPermission() async {
  return false;
}
