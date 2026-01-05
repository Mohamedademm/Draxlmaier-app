import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
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
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String targetType = 'all'; 
    String? selectedDepartment;
    List<User> selectedUsers = [];
    List<User> allUsers = [];
    bool isFetchingUsers = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          if (allUsers.isEmpty && !isFetchingUsers && (targetType == 'user' || targetType == 'department')) {
            isFetchingUsers = true;
            final userProvider = context.read<UserProvider>();
            
            void updateUsers() {
              setDialogState(() {
                allUsers = userProvider.users;
                isFetchingUsers = false;
              });
            }

            if (userProvider.users.isEmpty) {
              userProvider.loadUsers().then((_) => updateUsers());
            } else {
              Future.microtask(() => updateUsers());
            }
          }

          final departments = ['Qualité', 'Logistique', 'MM shift A', 'MM shift B', 'SZB shift A', 'SZB shift B', 'Direction', 'IT', 'RH'];

          return AlertDialog(
            title: const Text('Nouvelle Notification'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cible de diffusion', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ModernTheme.textSecondary)),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTargetChip('Tous', 'all', targetType, (val) => setDialogState(() => targetType = val)),
                          const SizedBox(width: 8),
                          _buildTargetChip('Département', 'department', targetType, (val) => setDialogState(() => targetType = val)),
                          const SizedBox(width: 8),
                          _buildTargetChip('Utilisateurs', 'user', targetType, (val) => setDialogState(() => targetType = val)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (targetType == 'department')
                      DropdownButtonFormField<String>(
                        value: selectedDepartment,
                        decoration: InputDecoration(
                          labelText: 'Département cible',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                        items: departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                        onChanged: (val) => setDialogState(() => selectedDepartment = val),
                      ),
                    if (targetType == 'user')
                      isFetchingUsers 
                        ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<User>(
                                decoration: InputDecoration(
                                  labelText: 'Chercher un utilisateur',
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                ),
                                items: allUsers.map((u) => DropdownMenuItem(value: u, child: Text(u.fullName))).toList(),
                                onChanged: (u) {
                                  if (u != null && !selectedUsers.any((user) => user.id == u.id)) {
                                    setDialogState(() => selectedUsers.add(u));
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                children: selectedUsers.map((u) => Chip(
                                  label: Text(u.fullName, style: const TextStyle(fontSize: 12)),
                                  backgroundColor: ModernTheme.primaryBlue.withOpacity(0.1),
                                  side: BorderSide.none,
                                  onDeleted: () => setDialogState(() => selectedUsers.removeWhere((user) => user.id == u.id)),
                                )).toList(),
                              ),
                            ],
                          ),
                    const Divider(height: 40),
                    ModernTextField(
                      controller: titleController,
                      label: 'Titre du message',
                      hint: 'Ex: Maintenance système prévue',
                    ),
                    const SizedBox(height: 16),
                    ModernTextField(
                      controller: messageController,
                      label: 'Contenu du message',
                      hint: 'Détails de l\'annonce...',
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernTheme.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () async {
                  if (titleController.text.isEmpty || messageController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs')));
                    return;
                  }
                  
                  final success = await context.read<NotificationProvider>().sendNotification(
                    title: titleController.text,
                    message: messageController.text,
                    targetUserIds: targetType == 'user' ? selectedUsers.map((u) => u.id).toList() : null,
                    targetDepartment: targetType == 'department' ? selectedDepartment : null,
                    sendToAll: targetType == 'all',
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? 'Notification envoyée' : 'Échec de l\'envoi'),
                        backgroundColor: success ? ModernTheme.success : ModernTheme.error,
                      ),
                    );
                  }
                },
                child: const Text('Diffuser'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTargetChip(String label, String value, String current, Function(String) onSelected) {
    final isSelected = current == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onSelected(value),
      selectedColor: ModernTheme.primaryBlue.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? ModernTheme.primaryBlue : ModernTheme.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
