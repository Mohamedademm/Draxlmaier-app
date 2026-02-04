import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/objective_provider.dart';
import '../providers/notification_provider.dart';
import '../theme/modern_theme.dart';
import '../utils/constants.dart';
import '../widgets/modern_widgets.dart';
import '../widgets/skeleton_loader.dart';
import '../utils/animations.dart';
import 'admin/admin_notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final objectiveProvider = context.read<ObjectiveProvider>();
    final notificationProvider = context.read<NotificationProvider>();
    await objectiveProvider.fetchMyObjectives();
    await objectiveProvider.fetchStats();
    await notificationProvider.loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: ModernAppBar(
        title: authProvider.canManageUsers ? 'Espace Manager' : 'Mon Tableau de Bord',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: ModernTheme.textPrimary),
            onPressed: _loadData,
          ),
          if (authProvider.isAdmin)
            Consumer<NotificationProvider>(
              builder: (context, provider, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.admin_panel_settings_outlined, color: ModernTheme.primary),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminNotificationsScreen(),
                          ),
                        );
                      },
                      tooltip: 'Notifications Admin',
                    ),
                    if (provider.unreadCount > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: ModernTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            provider.unreadCount > 99 ? '99+' : provider.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: ModernTheme.textPrimary),
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.notifications);
                    },
                  ),
                  if (provider.unreadCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: ModernTheme.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          provider.unreadCount > 99 ? '99+' : provider.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: authProvider.canManageUsers
            ? _buildManagerDashboard(context)
            : _buildEmployeeDashboard(context),
      ),
    );
  }

  Widget _buildWelcomeHeader(String name, String subtitle) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.elasticOut,
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: const Text(
                          '👋',
                          style: TextStyle(fontSize: 26),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bonjour, $name',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: ModernTheme.textPrimary,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: ModernTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmployeeDashboard(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final objectiveProvider = context.watch<ObjectiveProvider>();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(ModernTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(
            authProvider.currentUser?.firstname ?? 'Collaborateur',
            'Voici l\'état de vos objectifs actuels',
          ),
          const SizedBox(height: ModernTheme.spacingXL),

          if (objectiveProvider.isLoading)
            const DashboardSkeleton()
          else
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                AppAnimations.staggeredList(
                  index: 0,
                  child: ModernStatCard(
                    title: 'Total',
                    value: objectiveProvider.stats['total'].toString(),
                    icon: Icons.assignment_outlined,
                    gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
                  ),
                ),
                AppAnimations.staggeredList(
                  index: 1,
                  child: ModernStatCard(
                    title: 'Terminés',
                    value: objectiveProvider.stats['completed'].toString(),
                    icon: Icons.check_circle_outline,
                    gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                  ),
                ),
                AppAnimations.staggeredList(
                  index: 2,
                  child: ModernStatCard(
                    title: 'En cours',
                    value: objectiveProvider.stats['inProgress'].toString(),
                    icon: Icons.hourglass_empty_outlined,
                    gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                  ),
                ),
                AppAnimations.staggeredList(
                  index: 3,
                  child: ModernStatCard(
                    title: 'En retard',
                    value: objectiveProvider.stats['overdue'].toString(),
                    icon: Icons.warning_amber_outlined,
                    gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
                  ),
                ),
              ],
            ),
          
          const SizedBox(height: ModernTheme.spacingXL),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Objectifs Récents',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ModernTheme.textPrimary),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/objectives'),
                child: const Text('Voir tout'),
              ),
            ],
          ),
          const SizedBox(height: ModernTheme.spacingS),

          if (objectiveProvider.objectives.isEmpty && !objectiveProvider.isLoading)
            _buildEmptyObjectives()
          else
            ...objectiveProvider.objectives.take(3).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final obj = entry.value;
              return AppAnimations.staggeredList(
                index: index + 4,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ModernCard(
                    onTap: () => Navigator.pushNamed(context, '/objective-detail', arguments: obj.id),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: ModernTheme.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.task_alt, color: ModernTheme.primaryBlue),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(obj.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 4),
                              Text(obj.description, maxLines: 1, overflow: TextOverflow.ellipsis, 
                                style: const TextStyle(fontSize: 13, color: ModernTheme.textSecondary)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 20, color: ModernTheme.textTertiary),
                      ],
                    ),
                  ),
                ),
              );
            }),

          const SizedBox(height: ModernTheme.spacingXL),

          const Text(
            'Actions Rapides',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ModernTheme.textPrimary),
          ),
          const SizedBox(height: ModernTheme.spacingM),
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  context,
                  icon: Icons.chat_bubble_outline,
                  title: 'Messages',
                  color: const Color(0xFF6366F1),
                  onTap: () => Navigator.pushNamed(context, Routes.chatList),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  context,
                  icon: Icons.notifications_none,
                  title: 'Alertes',
                  color: const Color(0xFFF59E0B),
                  onTap: () => Navigator.pushNamed(context, Routes.notifications),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManagerDashboard(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final objectiveProvider = context.watch<ObjectiveProvider>();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(ModernTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(
            authProvider.currentUser?.firstname ?? 'Manager',
            'Gestion de votre équipe et des opérations',
          ),
          const SizedBox(height: ModernTheme.spacingXL),

          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutBack,
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, Routes.adminDashboard),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF14B8A6),
                            Color(0xFF0D9488),
                            Color(0xFF0F766E),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF14B8A6).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: const Color(0xFF14B8A6).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Panneau d\'Administration',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Gestion de votre équipe et des opérations',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: ModernTheme.spacingXL),

          const Text(
            'Gestion Opérationnelle',
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: ModernTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: ModernTheme.spacingM),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1, 
            children: [
              _buildModernManagerCard(
                context,
                icon: Icons.person_add_outlined,
                title: 'Inscriptions',
                subtitle: 'Valider les comptes',
                color: const Color(0xFF4F46E5),
                onTap: () => Navigator.pushNamed(context, Routes.pendingUsers),
              ),
              _buildModernManagerCard(
                context,
                icon: Icons.add_task_outlined,
                title: 'Objectifs',
                subtitle: 'Assigner & Suivre',
                color: const Color(0xFFEF4444),
                onTap: () => Navigator.pushNamed(context, Routes.managerObjectives),
              ),
              _buildModernManagerCard(
                context,
                icon: Icons.badge_outlined,
                title: 'Matricules',
                subtitle: 'Base de données',
                color: const Color(0xFF10B981),
                onTap: () => Navigator.pushNamed(context, Routes.matriculeManagement),
              ),
              if (authProvider.isAdmin)
                _buildModernManagerCard(
                  context,
                  icon: Icons.business_outlined,
                  title: 'Admin Départements',
                  subtitle: 'Créer & Gérer',
                  color: const Color(0xFFF59E0B),
                  onTap: () => Navigator.pushNamed(context, Routes.adminDepartments),
                ),
              _buildModernManagerCard(
                context,
                icon: Icons.hub_outlined,
                title: 'Départements',
                subtitle: 'Groupes de chat',
                color: const Color(0xFF8B5CF6),
                onTap: () => Navigator.pushNamed(context, Routes.departmentGroups),
              ),
            ],
          ),

          const SizedBox(height: ModernTheme.spacingXL),
        ],
      ),
    );
  }

  Widget _buildModernManagerCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.05),
                  color.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: color.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withOpacity(0.2),
                              color.withOpacity(0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: color, size: 28),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ModernTheme.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              height: 1.2,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
      },
    );
  }

  Widget _buildManagerCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ModernCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: ModernTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.08),
            color.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyObjectives() {
    return ModernCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Aucun objectif', style: TextStyle(fontWeight: FontWeight.bold, color: ModernTheme.textSecondary)),
          const SizedBox(height: 4),
          const Text('Vos tâches apparaîtront ici', style: TextStyle(fontSize: 12, color: ModernTheme.textTertiary)),
        ],
      ),
    );
  }
}
