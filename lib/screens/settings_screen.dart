import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/modern_theme.dart';
import '../widgets/modern_widgets.dart';

/// Modern Settings Screen with Dark Mode Toggle
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(
        title: 'Paramètres',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ModernTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            _buildSectionTitle('Apparence'),
            const SizedBox(height: ModernTheme.spacingS),
            _buildAppearanceSection(context),
            
            const SizedBox(height: ModernTheme.spacingL),
            
            // Account Section
            _buildSectionTitle('Compte'),
            const SizedBox(height: ModernTheme.spacingS),
            _buildAccountSection(context),
            
            const SizedBox(height: ModernTheme.spacingL),
            
            // About Section
            _buildSectionTitle('À propos'),
            const SizedBox(height: ModernTheme.spacingS),
            _buildAboutSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: ModernTheme.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ModernCard(
          child: Column(
            children: [
              // Dark Mode Toggle
              _buildSettingsTile(
                icon: themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                iconColor: themeProvider.isDarkMode ? const Color(0xFFFFA726) : const Color(0xFFFFD54F),
                title: 'Mode sombre',
                subtitle: themeProvider.isDarkMode 
                    ? 'Activé - Reposez vos yeux' 
                    : 'Désactivé - Thème clair',
                trailing: Transform.scale(
                  scale: 0.9,
                  child: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleThemeMode(value);
                      // Show feedback
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value 
                                ? '🌙 Mode sombre activé' 
                                : '☀️ Mode clair activé',
                          ),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    activeColor: const Color(0xFF6366F1),
                  ),
                ),
              ),
              
              const Divider(height: 1),
              
              // Theme Preview
              _buildSettingsTile(
                icon: Icons.palette_outlined,
                iconColor: ModernTheme.primaryBlue,
                title: 'Aperçu du thème',
                subtitle: 'Voir comment apparaît l\'application',
                trailing: const Icon(Icons.chevron_right, color: ModernTheme.textTertiary),
                onTap: () {
                  _showThemePreview(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return ModernCard(
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.person_outline,
            iconColor: const Color(0xFF10B981),
            title: 'Profil',
            subtitle: user?.email ?? 'Non connecté',
            trailing: const Icon(Icons.chevron_right, color: ModernTheme.textTertiary),
            onTap: () {
              Navigator.pushNamed(context, '/edit-profile');
            },
          ),
          
          const Divider(height: 1),
          
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            iconColor: const Color(0xFFF59E0B),
            title: 'Notifications',
            subtitle: 'Gérer vos préférences',
            trailing: const Icon(Icons.chevron_right, color: ModernTheme.textTertiary),
            onTap: () {
              // Navigate to notifications settings
            },
          ),
          
          const Divider(height: 1),
          
          _buildSettingsTile(
            icon: Icons.lock_outline,
            iconColor: const Color(0xFFEF4444),
            title: 'Sécurité',
            subtitle: 'Mot de passe et confidentialité',
            trailing: const Icon(Icons.chevron_right, color: ModernTheme.textTertiary),
            onTap: () {
              // Navigate to security settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return ModernCard(
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.info_outline,
            iconColor: const Color(0xFF6366F1),
            title: 'Version',
            subtitle: '1.0.0',
            trailing: null,
          ),
          
          const Divider(height: 1),
          
          _buildSettingsTile(
            icon: Icons.help_outline,
            iconColor: const Color(0xFF8B5CF6),
            title: 'Aide & Support',
            subtitle: 'Besoin d\'assistance ?',
            trailing: const Icon(Icons.chevron_right, color: ModernTheme.textTertiary),
            onTap: () {
              // Navigate to help
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: ModernTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: ModernTheme.textSecondary,
        ),
      ),
      trailing: trailing,
    );
  }

  void _showThemePreview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ModernTheme.textTertiary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aperçu du thème',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ModernCard(
                    child: Column(
                      children: [
                        Icon(Icons.wb_sunny, size: 48, color: Colors.orange[400]),
                        const SizedBox(height: 8),
                        const Text('Clair', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ModernCard(
                    child: Column(
                      children: [
                        Icon(Icons.nightlight_round, size: 48, color: Colors.indigo[400]),
                        const SizedBox(height: 8),
                        const Text('Sombre', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: 'Fermer',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
