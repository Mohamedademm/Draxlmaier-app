import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  
  bool _isLoading = false;
  String? _profileImageBase64;
  
  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _departmentController;
  late TextEditingController _positionController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    
    _firstnameController = TextEditingController(text: user?.firstname ?? '');
    _lastnameController = TextEditingController(text: user?.lastname ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _departmentController = TextEditingController(text: user?.department ?? '');
    _positionController = TextEditingController(text: user?.position ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _postalCodeController = TextEditingController(text: user?.postalCode ?? '');
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _positionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  ImageProvider? _getProfileImage(User? user) {
    if (_profileImageBase64 != null && _profileImageBase64!.isNotEmpty) {
      try {
        final base64String = _profileImageBase64!.contains(',')
            ? _profileImageBase64!.split(',').last
            : _profileImageBase64!;
        return MemoryImage(base64Decode(base64String));
      } catch (e) {
        print('Error decoding base64 image: $e');
      }
    }
    
    if (user?.profileImage != null && user!.profileImage!.isNotEmpty) {
      if (user.profileImage!.startsWith('data:image')) {
        try {
          final base64String = user.profileImage!.split(',').last;
          return MemoryImage(base64Decode(base64String));
        } catch (e) {
          print('Error decoding user base64 image: $e');
        }
      } else if (user.profileImage!.startsWith('http')) {
        return NetworkImage(user.profileImage!);
      }
    }
    
    return null;
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        
        String mimeType = 'image/jpeg';
        if (image.name.toLowerCase().endsWith('.png')) {
          mimeType = 'image/png';
        }
        
        setState(() {
          _profileImageBase64 = 'data:$mimeType;base64,$base64String';
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final updateData = <String, dynamic>{};
      
      final firstname = _firstnameController.text.trim();
      final lastname = _lastnameController.text.trim();
      
      if (firstname.isNotEmpty) updateData['firstname'] = firstname;
      if (lastname.isNotEmpty) updateData['lastname'] = lastname;
      
      final phone = _phoneController.text.trim();
      final department = _departmentController.text.trim();
      final position = _positionController.text.trim();
      final address = _addressController.text.trim();
      final city = _cityController.text.trim();
      final postalCode = _postalCodeController.text.trim();
      
      if (phone.isNotEmpty) updateData['phone'] = phone;
      if (department.isNotEmpty) updateData['department'] = department;
      if (position.isNotEmpty) updateData['position'] = position;
      if (address.isNotEmpty) updateData['address'] = address;
      if (city.isNotEmpty) updateData['city'] = city;
      if (postalCode.isNotEmpty) updateData['postalCode'] = postalCode;
      
      if (_profileImageBase64 != null && _profileImageBase64!.isNotEmpty) {
        updateData['profileImageBase64'] = _profileImageBase64!;
        print('Sending profile image: ${_profileImageBase64!.substring(0, 50)}...');
      }

      print('Update data keys: ${updateData.keys.toList()}');
      
      final result = await _userService.updateUserProfile(userId, updateData);
      final bool addressChanged = result['addressChanged'] ?? false;

      await authProvider.refreshUser();

      if (mounted) {
        final message = addressChanged
            ? 'Profil mis à jour! Les administrateurs ont été notifiés du changement d\'adresse.'
            : 'Profil mis à jour avec succès';
        
        final icon = addressChanged ? Icons.notifications_active : Icons.check_circle;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: addressChanged ? const Color(0xFF0EA5E9) : Colors.green,
            duration: addressChanged ? const Duration(seconds: 5) : const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF0EA5E9),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text(
                'Modifier le profil',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              background: Container(
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
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -20,
                      child: Icon(
                        Icons.edit_rounded,
                        size: 150,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: _isLoading
                ? SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0EA5E9),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: child,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0xFF0EA5E9).withOpacity(0.2),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0EA5E9).withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF0EA5E9), Color(0xFF0891B2)],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF0EA5E9).withOpacity(0.5),
                                              blurRadius: 20,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: CircleAvatar(
                                            radius: 60,
                                            backgroundColor: const Color(0xFF0EA5E9),
                                            backgroundImage: _getProfileImage(user),
                                            child: _profileImageBase64 == null && 
                                                   (user?.profileImage == null || user?.profileImage?.isEmpty == true)
                                                ? Text(
                                                    user?.firstname.substring(0, 1).toUpperCase() ?? 'U',
                                                    style: const TextStyle(
                                                      fontSize: 48,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 5,
                                        right: 5,
                                        child: GestureDetector(
                                          onTap: _pickImage,
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                                              ),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 3),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFFEF4444).withOpacity(0.4),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.camera_alt_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    '${user?.firstname ?? ''} ${user?.lastname ?? ''}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: user?.isAdmin == true
                                            ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                                            : user?.isManager == true
                                                ? [const Color(0xFF0EA5E9), const Color(0xFF0891B2)]
                                                : [const Color(0xFF10B981), const Color(0xFF059669)],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      user?.role.name.toUpperCase() ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          _buildModernSection(
                            title: 'Informations personnelles',
                            icon: Icons.person_rounded,
                            children: [
                              _buildModernTextField(
                                controller: _firstnameController,
                                label: 'Prénom',
                                icon: Icons.person_rounded,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Le prénom est requis';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildModernTextField(
                                controller: _lastnameController,
                                label: 'Nom',
                                icon: Icons.person_outline_rounded,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Le nom est requis';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildModernTextField(
                                controller: _emailController,
                                label: 'Email',
                                icon: Icons.email_rounded,
                                enabled: false,
                              ),
                              const SizedBox(height: 16),
                              _buildModernTextField(
                                controller: _phoneController,
                                label: 'Téléphone',
                                icon: Icons.phone_rounded,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          _buildModernSection(
                            title: 'Informations professionnelles',
                            icon: Icons.work_rounded,
                            children: [
                              _buildModernTextField(
                                controller: _departmentController,
                                label: 'Département',
                                icon: Icons.business_rounded,
                                enabled: user?.isAdmin == true || user?.isManager == true,
                              ),
                              const SizedBox(height: 16),
                              _buildModernTextField(
                                controller: _positionController,
                                label: 'Poste',
                                icon: Icons.badge_rounded,
                                enabled: user?.isAdmin == true || user?.isManager == true,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          _buildModernSection(
                            title: 'Adresse',
                            icon: Icons.location_on_rounded,
                            children: [
                              _buildModernTextField(
                                controller: _addressController,
                                label: 'Adresse',
                                icon: Icons.home_rounded,
                              ),
                              const SizedBox(height: 16),
                              _buildModernTextField(
                                controller: _cityController,
                                label: 'Ville',
                                icon: Icons.location_city_rounded,
                              ),
                              const SizedBox(height: 16),
                              _buildModernTextField(
                                controller: _postalCodeController,
                                label: 'Code postal',
                                icon: Icons.mail_rounded,
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _saveProfile,
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
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.save_rounded, color: Colors.white, size: 24),
                                        SizedBox(width: 12),
                                        Text(
                                          'Enregistrer les modifications',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF0EA5E9).withOpacity(0.15),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0EA5E9), Color(0xFF0891B2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      style: TextStyle(
        color: enabled ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: enabled ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: enabled
                  ? [const Color(0xFF0EA5E9).withOpacity(0.15), const Color(0xFF06B6D4).withOpacity(0.1)]
                  : [const Color(0xFF94A3B8).withOpacity(0.1), const Color(0xFF94A3B8).withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: enabled ? const Color(0xFF0891B2) : const Color(0xFF94A3B8),
            size: 20,
          ),
        ),
        filled: true,
        fillColor: enabled ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: const Color(0xFF0EA5E9).withOpacity(0.2),
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: const Color(0xFF0EA5E9).withOpacity(0.2),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF0EA5E9),
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: const Color(0xFF94A3B8).withOpacity(0.2),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFEF4444),
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFEF4444),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }
}
