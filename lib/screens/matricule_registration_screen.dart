import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/matricule_service.dart';
import '../theme/modern_theme.dart';
import '../widgets/modern_widgets.dart';
import '../utils/constants.dart';

/// Écran d'inscription moderne avec système de matricule
class MatriculeRegistrationScreen extends StatefulWidget {
  const MatriculeRegistrationScreen({super.key});

  @override
  State<MatriculeRegistrationScreen> createState() => _MatriculeRegistrationScreenState();
}

class _MatriculeRegistrationScreenState extends State<MatriculeRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _matriculeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final _authService = AuthService();
  
  bool _isVerifying = false;
  bool _isRegistering = false;
  bool _matriculeVerified = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // Données du matricule vérifié
  String? _nom;
  String? _prenom;
  String? _poste;
  String? _department;

  @override
  void dispose() {
    _matriculeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _verifyMatricule() async {
    if (_matriculeController.text.isEmpty) {
      _showError('Veuillez entrer un matricule');
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final service = MatriculeService();
      final result = await service.checkMatricule(_matriculeController.text.toUpperCase());

      if (result.exists && result.available) {
        setState(() {
          _matriculeVerified = true;
          _nom = result.nom ?? '';
          _prenom = result.prenom ?? '';
          _poste = result.poste ?? '';
          _department = result.department ?? '';
        });
        
        _showSuccess('Matricule valide ✓');
      } else if (!result.exists) {
        _showError('Ce matricule n\'existe pas');
      } else if (!result.available) {
        _showError('Ce matricule est déjà utilisé');
      }
    } catch (e) {
      _showError('Erreur lors de la vérification: $e');
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_matriculeVerified) {
      _showError('Veuillez d\'abord vérifier votre matricule');
      return;
    }

    setState(() => _isRegistering = true);

    try {
      final response = await _authService.register(
        matricule: _matriculeController.text.toUpperCase(),
        firstname: _prenom!,
        lastname: _nom!,
        email: _emailController.text,
        password: _passwordController.text,
        phone: '',
        position: _poste!,
        department: _department!,
        address: '',
        city: '',
        postalCode: '',
      );

      if (response['status'] == 'success') {
        if (mounted) {
          _showSuccess('Inscription réussie ! Connexion...');
          await Future.delayed(const Duration(seconds: 1));
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        _showError(response['message'] ?? 'Erreur lors de l\'inscription');
      }
    } catch (e) {
      _showError('Erreur: $e');
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: ModernCard(
                  padding: const EdgeInsets.all(ModernTheme.spacingXL),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo
                        const Icon(
                          Icons.badge,
                          size: 64,
                          color: ModernTheme.primary,
                        ),
                        const SizedBox(height: ModernTheme.spacingM),
                        
                        // Titre
                        const Text(
                          'Inscription',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: ModernTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: ModernTheme.spacingS),
                        Text(
                          'Entrez votre matricule pour commencer',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: ModernTheme.spacingXL),

                        // Étape 1: Matricule
                        _buildMatriculeSection(),

                        // Étape 2: Informations (affichées après vérification)
                        if (_matriculeVerified) ...[
                          const SizedBox(height: ModernTheme.spacingL),
                          _buildInfoSection(),
                          const SizedBox(height: ModernTheme.spacingL),
                          _buildAccountSection(),
                          const SizedBox(height: ModernTheme.spacingXL),
                          _buildRegisterButton(),
                        ],

                        const SizedBox(height: ModernTheme.spacingL),
                        
                        // Lien vers connexion
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Déjà inscrit ? ',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, Routes.login);
                              },
                              child: const Text('Se connecter'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatriculeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _matriculeController,
          enabled: !_matriculeVerified,
          decoration: InputDecoration(
            labelText: 'Matricule *',
            hintText: 'Ex: 001, 014',
            prefixIcon: const Icon(Icons.badge),
            suffixIcon: _matriculeVerified
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            filled: true,
            fillColor: _matriculeVerified 
                ? Colors.green.shade50 
                : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          textCapitalization: TextCapitalization.characters,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Matricule requis';
            }
            return null;
          },
        ),
        const SizedBox(height: ModernTheme.spacingM),
        
        if (!_matriculeVerified)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isVerifying ? null : _verifyMatricule,
              icon: _isVerifying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(_isVerifying ? 'Vérification...' : 'Vérifier le matricule'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(ModernTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Informations du matricule',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildInfoRow('Nom', _nom ?? '-'),
          _buildInfoRow('Prénom', _prenom ?? '-'),
          _buildInfoRow('Poste', _poste ?? '-'),
          _buildInfoRow('Département', _department ?? '-'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Créer votre compte',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: ModernTheme.spacingM),
        
        // Email
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email *',
            hintText: 'votre.email@draexlmaier.com',
            prefixIcon: const Icon(Icons.email),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email requis';
            }
            if (!value.contains('@')) {
              return 'Email invalide';
            }
            return null;
          },
        ),
        const SizedBox(height: ModernTheme.spacingM),
        
        // Mot de passe
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Mot de passe *',
            hintText: 'Min. 6 caractères',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Mot de passe requis';
            }
            if (value.length < 6) {
              return 'Minimum 6 caractères';
            }
            return null;
          },
        ),
        const SizedBox(height: ModernTheme.spacingM),
        
        // Confirmer mot de passe
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Confirmer mot de passe *',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
              },
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value != _passwordController.text) {
              return 'Les mots de passe ne correspondent pas';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isRegistering ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isRegistering
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'S\'inscrire',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
