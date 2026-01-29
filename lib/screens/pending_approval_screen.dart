import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/modern_theme.dart';
import '../widgets/modern_widgets.dart';
import '../utils/constants.dart';

class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: ModernTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(ModernTheme.spacingL),
              child: ModernCard(
                padding: const EdgeInsets.all(ModernTheme.spacingXL),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated Status Icon
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_controller.value * 0.1),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: ModernTheme.warning.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.access_time_filled_rounded,
                              size: 40,
                              color: ModernTheme.warning,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: ModernTheme.spacingL),
                    
                    Text(
                      'Compte en attente',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: ModernTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: ModernTheme.spacingM),
                    
                    Text(
                      'Votre inscription a bien été enregistrée.\nUn administrateur doit valider votre compte avant que vous puissiez accéder à l\'application.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: ModernTheme.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: ModernTheme.spacingXL),
                    
                    // Information Box
                    Container(
                      padding: const EdgeInsets.all(ModernTheme.spacingM),
                      decoration: BoxDecoration(
                        color: ModernTheme.background,
                        borderRadius: BorderRadius.circular(ModernTheme.radiusM),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: ModernTheme.primaryBlue),
                          const SizedBox(width: ModernTheme.spacingS),
                          Expanded(
                            child: Text(
                              'Vous recevrez une notification une fois votre compte validé.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: ModernTheme.spacingXL),
                    
                    GradientButton(
                      text: 'Retour à la connexion',
                      onPressed: () {
                        context.read<AuthProvider>().logout();
                        Navigator.pushNamedAndRemoveUntil(
                          context, 
                          Routes.login,
                          (route) => false,
                        );
                      },
                      icon: Icons.arrow_back,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
