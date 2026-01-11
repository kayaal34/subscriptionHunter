import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:subscription_tracker/presentation/pages/home_page.dart';
import 'package:subscription_tracker/presentation/providers/subscription_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      // Pre-warm the Hive box
      await ref.read(subscriptionBoxProvider.future);
      
      // Request notification permissions only on first app launch
      final appBox = await Hive.openBox('app_settings');
      final isFirstLaunch = appBox.get('notificationPermissionRequested', defaultValue: false) == false;
      
      if (isFirstLaunch) {
        final notificationService = ref.read(notificationServiceProvider);
        await notificationService.requestNotificationPermission();
        await appBox.put('notificationPermissionRequested', true);
      }
    } catch (_) {
      // Ignore errors here, provider handle them or they will show in UI
    }
    
    // Artificial delay for better UX
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
       // Navigate to Home
       Navigator.of(context).pushReplacement(
         MaterialPageRoute(builder: (_) => const HomePage()),
       );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.subscriptions,
              size: 80,
              color: Colors.white,
            ),
            SizedBox(height: 24),
            Text(
              'Abonelik Takip',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          ],
        ),
      ),
    );
}
