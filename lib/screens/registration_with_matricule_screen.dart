import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/matricule_provider.dart';
import '../providers/auth_provider.dart';
import '../models/matricule_model.dart';
import '../theme/modern_theme.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class RegistrationWithMatriculeScreen extends StatefulWidget {
  const RegistrationWithMatriculeScreen({super.key});

  @override
  State<RegistrationWithMatriculeScreen> createState() => _RegistrationWithMatriculeScreenState();
}

class _RegistrationWithMatriculeScreenState extends State<RegistrationWithMatriculeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _matriculeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  Matricule? _matriculeData;
  int _currentStep = 0;

  @override
  void dispose() {
    _matriculeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _verifyMatricule() async {
    if (_matriculeController.text.trim().isEmpty) {
      UiHelper.showSnackBar(context, 'Veuillez entrer un matricule', isError: true);
      return;
    }

    final provider = context.read<MatriculeProvider>();
    UiHelper.showLoadingDialog(context);

    try {
      final result = await provider.checkMatricule(_matriculeController.text.trim());
      
      if (!mounted) return;
      UiHelper.hideLoadingDialog(context);

      if (result != null && result.exists && result.available) {
        _matriculeData = Matricule(
          id: '',
          matricule: _matriculeController.text.trim(),
          nom: result.nom ?? '',
          prenom: result.prenom ?? '',
          poste: result.poste ?? '',
          department: result.department ?? '',
          isUsed: false,
          createdBy: 'system',
          createdAt: DateTime.now(),
        );
        
        setState(() {
          _currentStep = 1;
        });
        UiHelper.showSnackBar(
          context,
          '✅ Matricule valide ! Informations chargées.',
          isError: false,
        );
      } else if (result != null && result.exists && !result.available) {
        UiHelper.showSnackBar(
          context,
          'Ce matricule est déjà utilisé',
          isError: true,
        );
      } else {
        UiHelper.showSnackBar(
          context,
          'Matricule non trouvé ou invalide',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      UiHelper.hideLoadingDialog(context);
      UiHelper.showSnackBar(context, 'Erreur: ${e.toString()}', isError: true);
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    if (_matriculeData == null) return;

    final authProvider = context.read<AuthProvider>();
    UiHelper.showLoadingDialog(context);

    try {
      final success = await authProvider.registerWithMatricule(
        matricule: _matriculeData!.matricule,
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      UiHelper.hideLoadingDialog(context);

      if (success) {
        UiHelper.showSnackBar(
          context,
          '✅ Inscription réussie ! Bienvenue ${_matriculeData!.prenom} ${_matriculeData!.nom}',
          isError: false,
        );
        Navigator.pushReplacementNamed(context, Routes.home);
      } else {
        UiHelper.showSnackBar(
          context,
          authProvider.errorMessage ?? 'Erreur lors de l\'inscription',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      UiHelper.hideLoadingDialog(context);
      UiHelper.showSnackBar(context, 'Erreur: ${e.toString()}', isError: true);
    }
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
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(ModernTheme.spacingL),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ModernTheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.badge,
                          size: 50,
                          color: ModernTheme.primary,
                        ),
                      ),
                      const SizedBox(height: ModernTheme.spacingM),

                      Text(
                        'Inscription',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ModernTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentStep == 0
                            ? 'Entrez votre matricule'
                            : 'Complétez votre inscription',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: ModernTheme.spacingL),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStepIndicator(0, 'Matricule', _currentStep >= 0),
                          Container(
                            width: 40,
                            height: 2,
                            color: _currentStep >= 1 ? ModernTheme.primary : Colors.grey.shade300,
                          ),
                          _buildStepIndicator(1, 'Compte', _currentStep >= 1),
                        ],
                      ),
                      const SizedBox(height: ModernTheme.spacingL),

                      Form(
                        key: _formKey,
                        child: _currentStep == 0
                            ? _buildMatriculeStep()
                            : _buildAccountStep(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? ModernTheme.primary : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? ModernTheme.primary : Colors.grey.shade600,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildMatriculeStep() {
    return Column(
      children: [
        TextFormField(
          controller: _matriculeController,
          decoration: InputDecoration(
            labelText: 'Matricule',
            hintText: 'Ex: 001, 014',
            prefixIcon: const Icon(Icons.badge_outlined),
            filled: true,
            fillColor: ModernTheme.surfaceVariant,
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

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _verifyMatricule,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Vérifier le Matricule'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: ModernTheme.spacingM),

        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, Routes.login),
          child: const Text('Déjà un compte ? Se connecter'),
        ),
      ],
    );
  }

  Widget _buildAccountStep() {
    if (_matriculeData == null) {
      return const Center(child: Text('Erreur: Données du matricule manquantes'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                    'Matricule: ${_matriculeData!.matricule}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),
              _buildInfoRow('Nom', _matriculeData!.nom),
              _buildInfoRow('Prénom', _matriculeData!.prenom),
              _buildInfoRow('Poste', _matriculeData!.poste),
              _buildInfoRow('Département', _matriculeData!.department),
            ],
          ),
        ),
        const SizedBox(height: ModernTheme.spacingL),

        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'votre.email@draexlmaier.com',
            prefixIcon: const Icon(Icons.email_outlined),
            filled: true,
            fillColor: ModernTheme.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          keyboardType: TextInputType.emailAddress,
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

        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Mot de passe',
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: ModernTheme.surfaceVariant,
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
              return 'Au moins 6 caractères';
            }
            return null;
          },
        ),
        const SizedBox(height: ModernTheme.spacingM),

        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Confirmer le mot de passe',
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              ),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
            filled: true,
            fillColor: ModernTheme.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Confirmation requise';
            }
            if (value != _passwordController.text) {
              return 'Les mots de passe ne correspondent pas';
            }
            return null;
          },
        ),
        const SizedBox(height: ModernTheme.spacingL),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _submitRegistration,
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'S\'inscrire',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: ModernTheme.spacingM),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _currentStep = 0;
                _matriculeData = null;
              });
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: ModernTheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retour'),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
