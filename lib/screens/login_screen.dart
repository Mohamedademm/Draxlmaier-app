import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/app_localizations.dart';
import '../widgets/draexlmaier_logo.dart';
import '../services/google_auth_service.dart';

/// Login screen for user authentication
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _googleAuthService = GoogleAuthService();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle login button press
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    
    // Show loading dialog
    UiHelper.showLoadingDialog(context);
    
    // Attempt login
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    
    if (!mounted) return;
    
    // Hide loading dialog
    UiHelper.hideLoadingDialog(context);
    
    if (success) {
      // Navigate to home screen
      Navigator.pushReplacementNamed(context, Routes.home);
    } else {
      // Show error message
      UiHelper.showSnackBar(
        context,
        authProvider.errorMessage ?? ErrorMessages.invalidCredentials,
        isError: true,
      );
    }
  }

  /// Handle Google Sign In
  Future<void> _handleGoogleSignIn() async {
    try {
      // Show loading dialog
      UiHelper.showLoadingDialog(context);

      final result = await _googleAuthService.signInWithGoogle();

      if (!mounted) return;

      // Hide loading dialog
      UiHelper.hideLoadingDialog(context);

      if (result != null && result['token'] != null) {
        // Navigate to home screen
        Navigator.pushReplacementNamed(context, Routes.home);
      } else if (result == null) {
        // User cancelled sign in
        UiHelper.showSnackBar(
          context,
          'Connexion Google annulée',
          isError: false,
        );
      } else {
        UiHelper.showSnackBar(
          context,
          'Erreur: Token non reçu du serveur',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      UiHelper.hideLoadingDialog(context);
      
      String errorMessage = e.toString();
      
      // Message plus clair selon l'erreur
      if (errorMessage.contains('MissingPluginException')) {
        errorMessage = 'Configuration Google Sign-In manquante.\n\nPour activer:\n'
            '1. Créez un projet Google Cloud Console\n'
            '2. Activez Google Sign-In API\n'
            '3. Configurez OAuth 2.0\n\n'
            'En attendant, utilisez email/mot de passe.';
      } else if (errorMessage.contains('PlatformException')) {
        errorMessage = 'Erreur de plateforme Google.\nUtilisez email/mot de passe.';
      }
      
      UiHelper.showSnackBar(
        context,
        errorMessage,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo Dräxlmaier
                  const DraexlmaierLogo(
                    height: 120,
                    showShadow: false,
                  ),
                  const SizedBox(height: 24),
                  
                  // Title
                  Builder(
                    builder: (context) {
                      final localizations = AppLocalizations.of(context)!;
                      return Column(
                        children: [
                          Text(
                            localizations.translate('welcome'),
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            localizations.translate('sign_in_to_continue'),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 48),
                  
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!ValidationHelper.isValidEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (!ValidationHelper.isValidPassword(value)) {
                        return 'Le mot de passe doit contenir au moins 3 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // Login button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(fontSize: 16),
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OU',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Google Sign In button
                  OutlinedButton.icon(
                    onPressed: _handleGoogleSignIn,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    icon: const Icon(Icons.g_mobiledata, size: 24, color: Colors.red),
                    label: const Text(
                      'Continuer avec Google',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Registration link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Pas encore de compte ?',
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/registration');
                        },
                        child: const Text(
                          'S\'inscrire',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
