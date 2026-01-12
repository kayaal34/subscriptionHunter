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
      
      // Setup app settings box
      final appBox = await Hive.openBox('app_settings');
      final isFirstLaunch = appBox.get('permissionsRequested', defaultValue: false) == false;
      
      if (isFirstLaunch && mounted) {
        // Show permissions dialog
        await _showPermissionsDialog(appBox);
      }
    } catch (_) {
      // Ignore errors here, provider handles them or they will show in UI
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

  Future<void> _showPermissionsDialog(Box appBox) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('İzinleri Etkinleştir'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Uygulama aşağıdaki özellikleri kullanmak için izin gerektirmektedir:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16),
              _PermissionItem(
                icon: Icons.notifications,
                title: 'Bildirimler',
                description: 'Abonelik ödeme tarihlerinde hatırlatma bildirimleri göndermek için',
              ),
              SizedBox(height: 12),
              _PermissionItem(
                icon: Icons.language,
                title: 'İnternet Bağlantısı',
                description: 'Güncel döviz kurlarını almak ve senkronizasyon için',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Mark as requested but declined
              appBox.put('permissionsRequested', true);
              appBox.put('notificationsEnabled', false);
              Navigator.of(context).pop();
            },
            child: const Text('Daha Sonra'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Request permissions
              await _requestPermissions(appBox);
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Kabul Et'),
          ),
        ],
      ),
    );
  }

  Future<void> _requestPermissions(Box appBox) async {
    try {
      // Request notification permission
      final notificationService = ref.read(notificationServiceProvider);
      final notificationGranted = await notificationService.requestNotificationPermission();
      
      // Initialize notifications if granted
      if (notificationGranted) {
        await notificationService.initialize();
        appBox.put('notificationsEnabled', true);
      } else {
        appBox.put('notificationsEnabled', false);
      }
      
      // Mark permissions as requested
      appBox.put('permissionsRequested', true);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              notificationGranted 
                ? 'Bildirimler etkinleştirildi' 
                : 'Bildirimler devre dışı bırakıldı. Ayarlardan etkinleştirebilirsiniz.',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      appBox.put('permissionsRequested', true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İzin isteklerinde bir hata oluştu'),
            duration: Duration(seconds: 2),
          ),
        );
      }
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

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PermissionItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Theme.of(context).primaryColor, size: 24),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8E8E93),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
