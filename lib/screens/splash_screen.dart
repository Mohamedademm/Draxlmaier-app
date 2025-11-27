import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

/// Splash screen - Initial screen that checks authentication
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  /// Check if user is authenticated and navigate accordingly
  Future<void> _checkAuthentication() async {
    final authProvider = context.read<AuthProvider>();
    
    // Wait for 2 seconds (splash screen display time)
    await Future.delayed(const Duration(seconds: 2));
    
    // Check authentication
    final isAuthenticated = await authProvider.checkAuthentication();
    
    if (!mounted) return;
    
    // Navigate to appropriate screen
    if (isAuthenticated) {
      Navigator.pushReplacementNamed(context, Routes.home);
    } else {
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo placeholder
            const Icon(
              Icons.business,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              AppConstants.companyName,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
