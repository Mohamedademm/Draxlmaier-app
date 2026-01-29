import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../theme/modern_theme.dart';
import '../widgets/modern_widgets.dart';
import '../models/user_model.dart';
import 'team_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final userProvider = context.read<UserProvider>();
    final notificationProvider = context.read<NotificationProvider>();
    
    await userProvider.loadUsers();
    await notificationProvider.loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(ModernTheme.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Statistiques Système', Icons.analytics_outlined),
                    const SizedBox(height: ModernTheme.spacingM),
                    _buildStatsGrid(),
                    const SizedBox(height: ModernTheme.spacingXL),
                    _buildSectionHeader('Actions Administratives', Icons.admin_panel_settings_outlined),
                    const SizedBox(height: ModernTheme.spacingM),
                    _buildActionCards(),
                    const SizedBox(height: ModernTheme.spacingXL),
                    _buildSectionHeader('État du Système', Icons.dns_outlined),
                    const SizedBox(height: ModernTheme.spacingM),
                    _buildSystemStatus(),
                    const SizedBox(height: ModernTheme.spacingXL),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final authProvider = context.watch<AuthProvider>();
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: ModernTheme.primaryBlue,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ModernTheme.primaryBlue,
                ModernTheme.primaryBlue.withBlue(180),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.white.withOpacity(0.05),
                ),
              ),
              Positioned(
                left: 20,
                bottom: 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour, ${authProvider.currentUser?.firstname ?? "Admin"}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Panneau de contrôle administrateur',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _loadData,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: ModernTheme.primaryBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ModernTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Consumer2<UserProvider, NotificationProvider>(
      builder: (context, userProvider, notificationProvider, _) {
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: ModernTheme.spacingS,
          crossAxisSpacing: ModernTheme.spacingS,
          childAspectRatio: 1.5,
          children: [
            _buildPremiumStatCard(
              'Utilisateurs',
              '${userProvider.users.length}',
              Icons.people_alt_outlined,
              [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
            ),
            _buildPremiumStatCard(
              'Utilisateurs Actifs',
              '${userProvider.activeUsers.length}',
              Icons.verified_user_outlined,
              [const Color(0xFF10B981), const Color(0xFF059669)],
            ),
            _buildPremiumStatCard(
              'Notifications',
              '${notificationProvider.notifications.length}',
              Icons.notifications_active_outlined,
              [const Color(0xFFF59E0B), const Color(0xFFD97706)],
            ),
            _buildPremiumStatCard(
              'Alertes Non Lues',
              '${notificationProvider.unreadCount}',
              Icons.mark_email_unread_outlined,
              [const Color(0xFFEF4444), const Color(0xFFDC2626)],
            ),
          ],
        );
      },
    );
  }

  Widget _buildPremiumStatCard(String title, String value, IconData icon, List<Color> colors) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(icon, size: 80, color: Colors.white.withOpacity(0.15)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCards() {
    return Column(
      children: [
        _buildPremiumActionCard(
          icon: Icons.manage_accounts_outlined,
          title: 'Gestion des Utilisateurs',
          subtitle: 'Contrôlez les accès et les rôles',
          color: const Color(0xFF6366F1),
          onTap: () => Navigator.pushNamed(context, Routes.userManagement),
        ),
        _buildPremiumActionCard(
          icon: Icons.send_to_mobile_outlined,
          title: 'Envoyer une Notification',
          subtitle: 'Communication ciblée par département',
          color: const Color(0xFFF59E0B),
          onTap: _showSendNotificationDialog,
        ),
        _buildPremiumActionCard(
          icon: Icons.history_edu_outlined,
          title: 'Historique des Alertes',
          subtitle: 'Consultez les messages envoyés',
          color: const Color(0xFF10B981),
          onTap: () => Navigator.pushNamed(context, Routes.notifications),
        ),
        _buildPremiumActionCard(
          icon: Icons.account_tree_outlined,
          title: 'Structure & Équipes',
          subtitle: 'Gérer les départements et groupes',
          color: const Color(0xFF8B5CF6),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TeamManagementScreen())),
        ),
        _buildPremiumActionCard(
          icon: Icons.forum_outlined,
          title: 'Groupes de Discussion',
          subtitle: 'Gérer les canaux par département',
          color: const Color(0xFFEC4899),
          onTap: () => Navigator.pushNamed(context, Routes.departmentGroups),
        ),
        _buildPremiumActionCard(
          icon: Icons.color_lens_outlined,
          title: 'Personnalisation UI',
          subtitle: 'Thèmes et identité visuelle',
          color: const Color(0xFF06B6D4),
          onTap: () => Navigator.pushNamed(context, Routes.themeCustomization),
        ),
        _buildPremiumActionCard(
          icon: Icons.badge_outlined,
          title: 'Gestion des Matricules',
          subtitle: 'Base de données des badges',
          color: const Color(0xFF64748B),
          onTap: () => Navigator.pushNamed(context, Routes.matriculeManagement),
        ),
      ],
    );
  }

  Widget _buildPremiumActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ModernCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ModernTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: ModernTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatus() {
    return ModernCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStatusRow('Serveur API', 'Opérationnel', true),
          const Divider(height: 24),
          _buildStatusRow('Base de données', 'Connecté', true),
          const Divider(height: 24),
          _buildStatusRow('Service Push', 'Actif', true),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String status, bool isOk) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: ModernTheme.textSecondary)),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isOk ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              status,
              style: TextStyle(
                color: isOk ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showSendNotificationDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Notification',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => _NotificationDialog(),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: child, // The Scaling is handled inside the dialog for more control
        );
      },
    );
  }

  Widget _buildTargetChip(String label, String value, String current, Function(String) onSelected) {
    // This is now handled inside _NotificationDialog, but keeping it if needed elsewhere or removing it if unused.
    // Since it was only used in the dialog, we can remove it or update it.
    // For now, let's remove it as the new dialog has its own implementation.
    return const SizedBox.shrink(); 
  }
}

class _NotificationDialog extends StatefulWidget {
  @override
  State<_NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<_NotificationDialog> with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _targetType = 'all'; // all, department, user
  String? _selectedDepartment;
  List<User> _selectedUsers = [];
  bool _isFetchingUsers = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  final List<String> _departments = ['Qualité', 'Logistique', 'MM shift A', 'MM shift B', 'SZB shift A', 'SZB shift B', 'Direction', 'IT', 'RH'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _checkLoadUsers() {
    if ((_targetType == 'user' || _targetType == 'department') && 
        context.read<UserProvider>().users.isEmpty && !_isFetchingUsers) {
      setState(() => _isFetchingUsers = true);
      context.read<UserProvider>().loadUsers().then((_) {
        if (mounted) setState(() => _isFetchingUsers = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 800),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ModernTheme.primaryBlue, ModernTheme.primaryBlue.withBlue(180)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_active_outlined, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nouvelle Notification',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Diffuser un message aux équipes',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Cible de diffusion'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _buildTargetOption('Tous', 'all'),
                            _buildTargetOption('Département', 'department'),
                            _buildTargetOption('Utilisateurs', 'user'),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          children: [
                            if (_targetType == 'department')
                              DropdownButtonFormField<String>(
                                value: _selectedDepartment,
                                decoration: _buildInputDecoration('Département cible'),
                                items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                                onChanged: (val) => setState(() => _selectedDepartment = val),
                              ),
                            
                            if (_targetType == 'user')
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Consumer<UserProvider>(
                                    builder: (context, provider, _) {
                                      if (provider.users.isEmpty && _isFetchingUsers) {
                                        return const Center(child: LinearProgressIndicator());
                                      }
                                      return DropdownButtonFormField<User>(
                                        decoration: _buildInputDecoration('Ajouter un utilisateur'),
                                        items: provider.users.map((u) => DropdownMenuItem(value: u, child: Text(u.fullName))).toList(),
                                        onChanged: (u) {
                                          if (u != null && !_selectedUsers.any((user) => user.id == u.id)) {
                                            setState(() => _selectedUsers.add(u));
                                          }
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _selectedUsers.map((u) => Chip(
                                      avatar: CircleAvatar(
                                        backgroundColor: ModernTheme.primaryBlue,
                                        child: Text(u.firstname[0].toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white)),
                                      ),
                                      label: Text(u.fullName, style: const TextStyle(fontSize: 12)),
                                      backgroundColor: ModernTheme.primaryBlue.withOpacity(0.05),
                                      deleteIcon: const Icon(Icons.close, size: 16, color: ModernTheme.primaryBlue),
                                      onDeleted: () => setState(() => _selectedUsers.removeWhere((user) => user.id == u.id)),
                                      side: BorderSide(color: ModernTheme.primaryBlue.withOpacity(0.2)),
                                    )).toList(),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle('Message'),
                      const SizedBox(height: 12),
                      ModernTextField(
                        controller: _titleController,
                        label: 'Titre', 
                        hint: 'Ex: Maintenance système',
                        prefixIcon: Icons.title,
                      ),
                      const SizedBox(height: 16),
                      ModernTextField(
                        controller: _messageController,
                        label: 'Contenu',
                        hint: 'Tapez votre message ici...',
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Text('Annuler', style: TextStyle(color: Colors.grey.shade700)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _sendMessage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [ModernTheme.primaryBlue, Color(0xFF2563EB)]),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: ModernTheme.primaryBlue.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded, color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text('Diffuser', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTargetOption(String label, String value) {
    final isSelected = _targetType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _targetType = value);
          _checkLoadUsers();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ] : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? ModernTheme.primaryBlue : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ModernTheme.primaryBlue)),
    );
  }

  Future<void> _sendMessage() async {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs')));
      return;
    }
    
    final success = await context.read<NotificationProvider>().sendNotification(
      title: _titleController.text,
      message: _messageController.text,
      targetUserIds: _targetType == 'user' ? _selectedUsers.map((u) => u.id).toList() : null,
      targetDepartment: _targetType == 'department' ? _selectedDepartment : null,
      sendToAll: _targetType == 'all',
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Notification envoyée' : 'Échec de l\'envoi'),
          backgroundColor: success ? ModernTheme.success : ModernTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}
