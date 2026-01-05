import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../services/matricule_service.dart';
import '../theme/modern_theme.dart';
import '../widgets/modern_widgets.dart';
import '../utils/constants.dart';
import '../utils/location_data.dart';
import '../utils/password_generator.dart';

/// Écran d'inscription moderne avec système de matricule professionnel
class ModernRegistrationScreen extends StatefulWidget {
  const ModernRegistrationScreen({super.key});

  @override
  State<ModernRegistrationScreen> createState() => _ModernRegistrationScreenState();
}

class _ModernRegistrationScreenState extends State<ModernRegistrationScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _matriculeController = TextEditingController();
  final _emailController = TextEditingController();
  
  final _authService = AuthService();
  final _matriculeService = MatriculeService();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isVerifying = false;
  bool _isRegistering = false;
  bool _matriculeVerified = false;
  
  // Données du matricule vérifié
  String? _nom;
  String? _prenom;
  String? _poste;
  String? _department;
  
  // Localisation
  String? _selectedCity;
  String? _selectedSubLocation;
  
  // Mot de passe généré
  String? _generatedPassword;
  String? _generatedEmail;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _matriculeController.dispose();
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _verifyMatricule() async {
    if (_matriculeController.text.isEmpty) {
      _showSnackBar('Veuillez entrer un matricule', isError: true);
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final result = await _matriculeService.checkMatricule(
        _matriculeController.text.toUpperCase(),
      );

      if (result.exists && result.available) {
        setState(() {
          _matriculeVerified = true;
          _nom = result.nom ?? '';
          _prenom = result.prenom ?? '';
          _poste = result.poste ?? '';
          _department = result.department ?? '';
        });
        
        _showSnackBar('✓ Matricule valide', isError: false);
      } else if (!result.exists) {
        _showSnackBar('Ce matricule n\'existe pas', isError: true);
      } else if (!result.available) {
        _showSnackBar('Ce matricule est déjà utilisé', isError: true);
      }
    } catch (e) {
      _showSnackBar('Erreur: $e', isError: true);
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_matriculeVerified) {
      _showSnackBar('Veuillez d\'abord vérifier votre matricule', isError: true);
      return;
    }
    
    if (_selectedCity == null || _selectedSubLocation == null) {
      _showSnackBar('Veuillez sélectionner votre localisation', isError: true);
      return;
    }

    setState(() => _isRegistering = true);

    try {
      // Générer le mot de passe
      _generatedPassword = PasswordGenerator.generateFromName(_prenom!, _nom!);
      _generatedEmail = _emailController.text.trim();
      
      final response = await _authService.register(
        matricule: _matriculeController.text.toUpperCase(),
        firstname: _prenom!,
        lastname: _nom!,
        email: _generatedEmail!,
        password: _generatedPassword!,
        phone: '',
        position: _poste!,
        department: _department!,
        address: _selectedSubLocation!,
        city: _selectedCity!,
        postalCode: '',
      );

      if (response['status'] == 'success') {
        if (mounted) {
          setState(() => _isRegistering = false);
          
          // Check if pending status
          final userStatus = response['user'] != null ? response['user']['status'] : null;
          if (userStatus == 'pending') {
             Navigator.pushNamedAndRemoveUntil(
              context, 
              Routes.pendingApproval,
              (route) => false,
            );
          } else {
            _showSuccessDialog();
          }
        }
      } else {
        _showSnackBar(response['message'] ?? 'Erreur lors de l\'inscription', isError: true);
      }
    } catch (e) {
      _showSnackBar('Erreur: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône de succès animée
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 50,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 24),
              
              // Titre
              const Text(
                'Inscription réussie!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ModernTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              Text(
                'Votre compte a été créé avec succès!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Informations de connexion
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ModernTheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: ModernTheme.primary.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: ModernTheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Vos identifiants:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ModernTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Email
                    _buildCredentialRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: _generatedEmail ?? 'Quelqu\'un',
                      canCopy: false,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Mot de passe avec copie
                    _buildCredentialRow(
                      icon: Icons.lock_outlined,
                      label: 'Mot de passe',
                      value: _generatedPassword ?? '',
                      canCopy: true,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Avertissement
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 20,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Veuillez noter ce mot de passe, vous en aurez besoin pour vous connecter.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Info email
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.mail_outline,
                      size: 20,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Un email a été envoyé à ${_generatedEmail ?? 'votre adresse'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Bouton de connexion
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacementNamed(context, Routes.login);
                  },
                  icon: const Icon(Icons.login),
                  label: const Text(
                    'Se connecter',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ModernTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialRow({
    required IconData icon,
    required String label,
    required String value,
    required bool canCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ModernTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (canCopy)
            IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                _showSnackBar('Mot de passe copié!', isError: false);
              },
              icon: const Icon(Icons.copy, size: 20),
              color: ModernTheme.primary,
              tooltip: 'Copier',
            ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
        backgroundColor: ModernTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ModernTheme.primary,
              ModernTheme.primary.withOpacity(0.05),
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: ModernCard(
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Logo DRX
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: ModernTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                'DRX',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: ModernTheme.primary,
                                  letterSpacing: 2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Étape 1: Matricule
                            _buildMatriculeSection(),
                            
                            // Étape 2: Informations automatiques
                            if (_matriculeVerified) ...[
                              const SizedBox(height: 24),
                              _buildAutoFilledInfo(),
                              const SizedBox(height: 24),
                              _buildLocationSection(),
                              const SizedBox(height: 24),
                              _buildEmailSection(),
                              const SizedBox(height: 32),
                              _buildRegisterButton(),
                            ],
                            
                            const SizedBox(height: 24),
                            
                            // Lien connexion
                            _buildLoginLink(),
                          ],
                        ),
                      ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Matricule',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        
        TextFormField(
          controller: _matriculeController,
          enabled: !_matriculeVerified,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
          decoration: InputDecoration(
            hintText: 'Ex: 014, MAT001',
            prefixIcon: Icon(
              _matriculeVerified ? Icons.verified : Icons.badge_outlined,
              color: _matriculeVerified ? Colors.green : ModernTheme.primary,
            ),
            suffixIcon: _matriculeVerified
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            filled: true,
            fillColor: _matriculeVerified 
                ? Colors.green.shade50 
                : ModernTheme.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: ModernTheme.primary,
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Matricule requis';
            }
            return null;
          },
        ),
        
        if (!_matriculeVerified) ...[
          const SizedBox(height: 12),
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
                  : const Icon(Icons.search),
              label: Text(
                _isVerifying ? 'Vérification...' : 'Vérifier',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAutoFilledInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade50,
            Colors.green.shade100.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: Colors.green.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Informations automatiques',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildInfoRow('Nom', _nom ?? '-'),
          const SizedBox(height: 12),
          _buildInfoRow('Prénom', _prenom ?? '-'),
          const SizedBox(height: 12),
          _buildInfoRow('Poste de travail', _poste ?? '-'),
          const SizedBox(height: 12),
          _buildInfoRow('Département', _department ?? '-'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ModernTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    final cities = LocationData.cities;
    final subLocations = _selectedCity != null 
        ? LocationData.getSubLocations(_selectedCity!)
        : <String>[];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Localisation',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        
        // Ville
        DropdownButtonFormField<String>(
          value: _selectedCity,
          decoration: InputDecoration(
            hintText: 'Sélectionnez votre ville',
            prefixIcon: const Icon(Icons.location_city),
            filled: true,
            fillColor: ModernTheme.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: ModernTheme.primary,
                width: 2,
              ),
            ),
          ),
          items: cities.map((city) {
            return DropdownMenuItem(
              value: city,
              child: Text(city),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCity = value;
              _selectedSubLocation = null; // Reset sous-localisation
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez sélectionner une ville';
            }
            return null;
          },
        ),
        
        if (_selectedCity != null) ...[
          const SizedBox(height: 16),
          
          Text(
            'Sous-localisation',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          
          // Sous-localisation
          DropdownButtonFormField<String>(
            value: _selectedSubLocation,
            decoration: InputDecoration(
              hintText: 'Ex: Centre ${_selectedCity ?? "ville"}',
              prefixIcon: const Icon(Icons.place),
              filled: true,
              fillColor: ModernTheme.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: ModernTheme.primary,
                  width: 2,
                ),
              ),
            ),
            items: subLocations.map((subLoc) {
              return DropdownMenuItem(
                value: subLoc,
                child: Text(subLoc),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSubLocation = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez sélectionner une sous-localisation';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildEmailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'E-mail',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'votre.email@example.com',
            prefixIcon: const Icon(Icons.email_outlined),
            filled: true,
            fillColor: ModernTheme.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: ModernTheme.primary,
                width: 2,
              ),
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
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isRegistering ? null : _register,
        icon: _isRegistering
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.check_circle_outline),
        label: Text(
          _isRegistering ? 'Inscription en cours...' : 'Ajouter',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: ModernTheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: ModernTheme.primary.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, Routes.login);
        },
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            children: const [
              TextSpan(text: 'Déjà inscrit ? '),
              TextSpan(
                text: 'Se connecter',
                style: TextStyle(
                  color: ModernTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
