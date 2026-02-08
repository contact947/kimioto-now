import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    print('=== SplashScreen initState ===');
    _init();
  }

  Future<void> _init() async {
    print('SplashScreen _init started');
    
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      print('AppProvider obtained');
      
      await provider.init();
      print('AppProvider initialized');
      
      await Future.delayed(const Duration(seconds: 2));
      print('Delay completed');
      
      if (!mounted) {
        print('Widget not mounted, returning');
        return;
      }
      
      print('Navigating to AuthScreen...');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AuthScreen(),
        ),
      );
      print('Navigation completed');
    } catch (e, stackTrace) {
      print('Error in SplashScreen._init: $e');
      print('Stack trace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.event_available,
                size: 60,
                color: Colors.blue.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Local Beat',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '地域とつながる、イベントを楽しむ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
