import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/matricule_service.dart';
import '../theme/modern_theme.dart';
import '../utils/constants.dart';

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
  
  String? _nom;
  String? _prenom;
  String? _poste;
  String? _department;

  String? _selectedLocation;
  String? _selectedSubLocation;

  final List<String> _locations = ['Monastir', 'Sousse', 'Siliana', 'El Jem'];
  final Map<String, List<String>> _subLocationsMap = {
    'Monastir': ['Sidi Masoud', 'Jemmal', 'Ksibet el-Médiouni','Sayeda','Kassrahlell','Moknine','taboulba','Bekalta','Bagdadi'],
    'Sousse': ['Sidi Abdelhamid', 'Msaken'],
    'Mahdia': ['zonne', 'centre Mahdia','hiboune','rajiche'],

    'Siliana': ['Zone Industrielle'],
    'El Jem': ['Zone Industrielle'],
  };

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
    
    if (_selectedLocation == null || _selectedSubLocation == null) {
      _showError('Veuillez sélectionner votre localisation et sous-localisation');
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
        address: _selectedSubLocation!,
        city: _selectedLocation!,
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0EA5E9),
              Color(0xFF06B6D4),
              Color(0xFF0891B2),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: const Color(0xFF0EA5E9).withOpacity(0.2),
                        blurRadius: 50,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0EA5E9), Color(0xFF0891B2)],
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(28),
                              topRight: Radius.circular(28),
                            ),
                          ),
                          child: Column(
                            children: [
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 1000),
                                tween: Tween(begin: 0.0, end: 1.0),
                                curve: Curves.elasticOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: child,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 20,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.badge_rounded,
                                    size: 48,
                                    color: Color(0xFF0EA5E9),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Inscription',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Entrez votre matricule pour commencer',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [

                              _buildMatriculeSection(),

                              if (_matriculeVerified) ...[
                                const SizedBox(height: 24),
                                _buildInfoSection(),
                                const SizedBox(height: 24),
                                _buildLocationSection(),
                                const SizedBox(height: 24),
                                _buildAccountSection(),
                                const SizedBox(height: 32),
                                _buildRegisterButton(),
                              ],

                              const SizedBox(height: 24),
                              
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
                                    child: const Text(
                                      'Se connecter',
                                      style: TextStyle(
                                        color: Color(0xFF0EA5E9),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _matriculeVerified
                  ? [const Color(0xFF10B981).withOpacity(0.1), const Color(0xFF059669).withOpacity(0.05)]
                  : [const Color(0xFF0EA5E9).withOpacity(0.1), const Color(0xFF06B6D4).withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _matriculeVerified
                  ? const Color(0xFF10B981).withOpacity(0.4)
                  : const Color(0xFF0EA5E9).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: TextFormField(
            controller: _matriculeController,
            enabled: !_matriculeVerified,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: _matriculeVerified ? const Color(0xFF10B981) : Colors.black87,
            ),
            decoration: InputDecoration(
              labelText: 'Matricule *',
              labelStyle: TextStyle(
                color: _matriculeVerified ? const Color(0xFF10B981) : const Color(0xFF0EA5E9),
                fontWeight: FontWeight.w600,
              ),
              hintText: 'Ex: 001, 014',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _matriculeVerified
                        ? [const Color(0xFF10B981), const Color(0xFF059669)]
                        : [const Color(0xFF0EA5E9), const Color(0xFF06B6D4)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.badge_rounded, color: Colors.white, size: 20),
              ),
              suffixIcon: _matriculeVerified
                  ? Container(
                      margin: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 20),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
            textCapitalization: TextCapitalization.characters,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Matricule requis';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 20),
        
        if (!_matriculeVerified)
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: _isVerifying ? null : _verifyMatricule,
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0EA5E9), Color(0xFF0891B2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0EA5E9).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  child: _isVerifying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Vérifier le matricule',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  'Informations du matricule',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildModernInfoRow('Nom', _nom ?? '-', Icons.person_rounded),
                  const Divider(color: Colors.white24, height: 24),
                  _buildModernInfoRow('Prénom', _prenom ?? '-', Icons.person_outline_rounded),
                  const Divider(color: Colors.white24, height: 24),
                  _buildModernInfoRow('Poste', _poste ?? '-', Icons.work_rounded),
                  const Divider(color: Colors.white24, height: 24),
                  _buildModernInfoRow('Département', _department ?? '-', Icons.business_rounded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
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

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Localisation',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF0F4C81), width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLocation,
              hint: const Row(
                children: [
                  Icon(Icons.business, color: Color(0xFF4B5563)),
                  SizedBox(width: 8),
                  Text('Localisation'),
                ],
              ),
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0F4C81)),
              items: _locations.map((String location) {
                return DropdownMenuItem<String>(
                  value: location,
                  child: Row(
                    children: [
                      const Icon(Icons.business, color: Color(0xFF0F4C81)),
                      const SizedBox(width: 8),
                      Text(location),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedLocation = newValue;
                  _selectedSubLocation = null;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Sous-localisation',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _selectedLocation == null ? Colors.grey.shade100 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSubLocation,
              hint: const Row(
                children: [
                  Icon(Icons.place, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Ex: Centre Monastir'),
                ],
              ),
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down, 
                color: _selectedLocation == null ? Colors.grey : const Color(0xFF4B5563)
              ),
              items: _selectedLocation == null
                  ? []
                  : _subLocationsMap[_selectedLocation!]?.map((String subLocation) {
                      return DropdownMenuItem<String>(
                        value: subLocation,
                        child: Row(
                          children: [
                            const Icon(Icons.place, color: Color(0xFF4B5563)),
                            const SizedBox(width: 8),
                            Text(subLocation),
                          ],
                        ),
                      );
                    }).toList(),
              onChanged: _selectedLocation == null
                  ? null
                  : (newValue) {
                      setState(() {
                        _selectedSubLocation = newValue;
                      });
                    },
            ),
          ),
        ),
      ],
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
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _isRegistering ? null : _register,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            height: 56,
            alignment: Alignment.center,
            child: _isRegistering
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add_rounded, color: Colors.white, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'S\'inscrire',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
