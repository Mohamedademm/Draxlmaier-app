import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart' as routes_constants;
import '../widgets/draexlmaier_logo.dart';
import '../theme/draexlmaier_theme.dart';
import '../constants/app_constants.dart';

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
      Navigator.pushReplacementNamed(context, routes_constants.Routes.home);
    } else {
      Navigator.pushReplacementNamed(context, routes_constants.Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DraexlmaierTheme.primaryBlue,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              DraexlmaierTheme.primaryBlue,
              DraexlmaierTheme.secondaryBlue,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Draexlmaier avec animation
              const DraexlmaierLogo(
                height: AppConstants.logoSizeLarge,
                isWhite: true,
                animate: true,
                showShadow: true,
              ),
              const SizedBox(height: 32),
              Text(
                'DRAEXLMAIER',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Employee Management',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 1,
                    ),
              ),
              const SizedBox(height: 64),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'Chargement...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
