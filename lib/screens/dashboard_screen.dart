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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bonjour, $name 👋',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ModernTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: ModernTheme.textSecondary,
          ),
        ),
      ],
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

          // Statistics Grid
          if (objectiveProvider.isLoading)
            const DashboardSkeleton()
          else
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
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

          // Recent Objectives Header
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
                index: index + 4, // Offset by 4 because of the 4 stat cards above
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

          // Quick Actions
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

          // Admin Panel Call to Action
          ModernCard(
            onTap: () => Navigator.pushNamed(context, Routes.adminDashboard),
            padding: const EdgeInsets.all(20),
            color: ModernTheme.primaryBlue,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Panneau d\'Administration',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Accéder aux outils avancés',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
          
          const SizedBox(height: ModernTheme.spacingXL),

          // Management Grid
          const Text(
            'Gestion Opérationnelle',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ModernTheme.textPrimary),
          ),
          const SizedBox(height: ModernTheme.spacingM),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _buildManagerCard(
                context,
                icon: Icons.person_add_outlined,
                title: 'Inscriptions',
                subtitle: 'En attente',
                color: const Color(0xFF6366F1),
                onTap: () => Navigator.pushNamed(context, Routes.pendingUsers),
              ),
              _buildManagerCard(
                context,
                icon: Icons.add_task_outlined,
                title: 'Objectifs',
                subtitle: 'Assigner',
                color: const Color(0xFFEF4444),
                onTap: () => Navigator.pushNamed(context, Routes.managerObjectives),
              ),
              _buildManagerCard(
                context,
                icon: Icons.badge_outlined,
                title: 'Matricules',
                subtitle: 'Gérer',
                color: const Color(0xFF10B981),
                onTap: () => Navigator.pushNamed(context, Routes.matriculeManagement),
              ),
              _buildManagerCard(
                context,
                icon: Icons.group_work_outlined,
                title: 'Groupes',
                subtitle: 'Départements',
                color: const Color(0xFF8B5CF6),
                onTap: () => Navigator.pushNamed(context, Routes.departmentGroups),
              ),
            ],
          ),

          const SizedBox(height: ModernTheme.spacingXL),

          // Team Stats
          const Text(
            'Performance Équipe',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ModernTheme.textPrimary),
          ),
          const SizedBox(height: ModernTheme.spacingM),
          if (objectiveProvider.isLoading)
            const DashboardSkeleton()
          else
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                ModernStatCard(
                  title: 'Objectifs',
                  value: objectiveProvider.stats['total'].toString(),
                  icon: Icons.assignment_outlined,
                  gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
                ),
                ModernStatCard(
                  title: 'Terminés',
                  value: objectiveProvider.stats['completed'].toString(),
                  icon: Icons.check_circle_outline,
                  gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                ),
              ],
            ),
          
          const SizedBox(height: ModernTheme.spacingXL),
        ],
      ),
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
    return ModernCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
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
