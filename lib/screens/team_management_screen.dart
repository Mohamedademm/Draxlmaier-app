import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../providers/team_provider.dart';
import '../models/user_model.dart';
import '../models/team_model.dart';
import '../models/department_model.dart';
import '../theme/modern_theme.dart';
import '../widgets/modern_widgets.dart';

/// Advanced Team Management Screen for Admin
class TeamManagementScreen extends StatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  State<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final teamProvider = context.read<TeamProvider>();
    final userProvider = context.read<UserProvider>();

    await Future.wait([
      teamProvider.loadAll(),
      userProvider.loadUsers(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Check admin permission
    if (!authProvider.canManageUsers) {
      return const Scaffold(
        appBar: ModernAppBar(title: 'Accès refusé'),
        body: Center(
          child: EmptyState(
            icon: Icons.lock_outline,
            title: 'Accès Refusé',
            message: 'Vous n\'avez pas les permissions nécessaires.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 140.0,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: ModernTheme.primaryBlue,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Gestion des Équipes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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
                        right: -20,
                        bottom: -20,
                        child: Icon(
                          Icons.groups_outlined,
                          size: 150,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(icon: Icon(Icons.groups), text: 'Équipes'),
                  Tab(icon: Icon(Icons.business), text: 'Départements'),
                  Tab(icon: Icon(Icons.admin_panel_settings), text: 'Rôles'),
                ],
              ),
            ),
          ];
        },
        body: Consumer<TeamProvider>(
          builder: (context, teamProvider, child) {
            if (teamProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (teamProvider.errorMessage != null) {
              return Center(
                child: EmptyState(
                  icon: Icons.error_outline,
                  title: 'Erreur',
                  message: teamProvider.errorMessage!,
                  action: ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Réessayer'),
                  ),
                ),
              );
            }

            return TabBarView(
              controller: _tabController,
              children: [
                _buildTeamsTab(teamProvider),
                _buildDepartmentsTab(teamProvider),
                _buildPermissionsTab(),
              ],
            );
          },
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController.animation!,
        builder: (context, child) {
          final index = _tabController.index;
          if (index == 2) return const SizedBox.shrink(); // No FAB for Permissions tab
          
          return FloatingActionButton.extended(
            onPressed: () {
              if (index == 0) {
                _showCreateTeamDialog();
              } else if (index == 1) {
                _showCreateDepartmentDialog();
              }
            },
            icon: const Icon(Icons.add),
            label: Text(index == 0 ? 'Équipe' : 'Département'),
            backgroundColor: ModernTheme.primaryBlue,
            elevation: 4,
          );
        },
      ),
    );
  }

  // ==================== TEAMS TAB ====================
  Widget _buildTeamsTab(TeamProvider teamProvider) {
    if (teamProvider.teams.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.group_off,
          title: 'Aucune équipe',
          message: 'Commencez par créer une équipe.',
          action: ElevatedButton.icon(
            onPressed: _showCreateTeamDialog,
            icon: const Icon(Icons.add),
            label: const Text('Créer une équipe'),
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: () => teamProvider.loadTeams(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatsCards(teamProvider),
            const SizedBox(height: 24),
            ...teamProvider.teams.map((team) => _buildTeamCard(team)),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(TeamProvider teamProvider) {
    final totalTeams = teamProvider.teams.length;
    final activeTeams = teamProvider.teams.where((t) => t.isActive).length;
    final totalMembers = teamProvider.teams.fold<int>(
      0,
      (sum, team) => sum + team.totalMembers,
    );

    return Row(
      children: [
        Expanded(
          child: ModernStatCard(
            title: 'Équipes',
            value: '$totalTeams',
            icon: Icons.groups,
            gradient: const LinearGradient(colors: [Color(0xFF003DA5), Color(0xFF00A9E0)]),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ModernStatCard(
            title: 'Actives',
            value: '$activeTeams',
            icon: Icons.check_circle,
            gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)]),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ModernStatCard(
            title: 'Membres',
            value: '$totalMembers',
            icon: Icons.person,
            gradient: const LinearGradient(colors: [Color(0xFFED6C02), Color(0xFFFFB74D)]),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamCard(Team team) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _parseColor(team.color).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              team.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: _parseColor(team.color),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        title: Text(
          team.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (team.description != null) ...[
              const SizedBox(height: 4),
              Text(team.description!, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                StatusBadge(
                  label: team.isActive ? 'ACTIVE' : 'INACTIVE',
                  color: team.isActive ? Colors.green : Colors.red,
                  icon: team.isActive ? Icons.check_circle : Icons.cancel,
                ),
                const SizedBox(width: 12),
                Icon(Icons.people_outline, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text('${team.totalMembers} membres', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) {
            if (value == 'edit') {
              _showEditTeamDialog(team);
            } else if (value == 'delete') {
              _confirmDeleteTeam(team);
            } else if (value == 'members') {
              _showManageMembersDialog(team);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'members',
              child: Row(children: [Icon(Icons.people, size: 20), SizedBox(width: 8), Text('Gérer les membres')]),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Modifier')]),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 8), Text('Supprimer', style: TextStyle(color: Colors.red))]),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (team.leader != null) ...[
                  const Text('CHEF D\'ÉQUIPE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: ModernTheme.primaryBlue.withOpacity(0.1),
                      child: Text(team.leader!.fullName.substring(0, 1).toUpperCase(), style: const TextStyle(color: ModernTheme.primaryBlue)),
                    ),
                    title: Text(team.leader!.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(team.leader!.email),
                  ),
                  const Divider(),
                ],
                const Text('MEMBRES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                if (team.members.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Aucun membre assigné', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                  )
                else
                  ...team.members.map((member) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          child: Text(member.fullName.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.black87)),
                        ),
                        title: Text(member.fullName),
                        subtitle: Text(member.email),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () => _removeMemberFromTeam(team, member),
                          tooltip: 'Retirer',
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== DEPARTMENTS TAB ====================
  Widget _buildDepartmentsTab(TeamProvider teamProvider) {
    if (teamProvider.departments.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.business_outlined,
          title: 'Aucun département',
          message: 'Commencez par créer un département.',
          action: ElevatedButton.icon(
            onPressed: _showCreateDepartmentDialog,
            icon: const Icon(Icons.add),
            label: const Text('Créer un département'),
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: () => teamProvider.loadDepartments(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...teamProvider.departments.map((dept) => _buildDepartmentCard(dept)),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentCard(Department department) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.business, color: Colors.blue, size: 24),
          ),
        ),
        title: Text(
          department.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (department.description != null) ...[
              const SizedBox(height: 4),
              Text(department.description!, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                StatusBadge(
                  label: department.isActive ? 'ACTIF' : 'INACTIF',
                  color: department.isActive ? Colors.green : Colors.red,
                  icon: department.isActive ? Icons.check_circle : Icons.cancel,
                ),
                if (department.location != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(department.location!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) {
            if (value == 'edit') {
              _showEditDepartmentDialog(department);
            } else if (value == 'delete') {
              _confirmDeleteDepartment(department);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Modifier')]),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 8), Text('Supprimer', style: TextStyle(color: Colors.red))]),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDepartmentInfoCard(
                        'Budget',
                        department.formattedBudget,
                        Icons.attach_money,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDepartmentInfoCard(
                        'Employés',
                        '${department.employeeCount}',
                        Icons.people,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (department.manager != null) ...[
                  const Text('MANAGER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.withOpacity(0.1),
                      child: Text(department.manager!.fullName.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.purple)),
                    ),
                    title: Text(department.manager!.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(department.manager!.email),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentInfoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color.withOpacity(0.8),
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  // ==================== PERMISSIONS TAB ====================
  Widget _buildPermissionsTab() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildRoleCard(
            title: 'Administrateur',
            description: 'Accès complet à toutes les fonctionnalités du système.',
            color: Colors.red,
            icon: Icons.admin_panel_settings,
            capabilities: [
              'Gestion des utilisateurs et rôles',
              'Gestion des équipes et départements',
              'Configuration du système',
              'Accès à tous les rapports',
            ],
          ),
          const SizedBox(height: 16),
          _buildRoleCard(
            title: 'Manager',
            description: 'Gestion des équipes et supervision opérationnelle.',
            color: Colors.blue,
            icon: Icons.supervisor_account,
            capabilities: [
              'Gestion de son équipe',
              'Validation des demandes',
              'Accès aux rapports d\'équipe',
              'Création d\'objectifs',
            ],
          ),
          const SizedBox(height: 16),
          _buildRoleCard(
            title: 'Employé',
            description: 'Accès standard aux fonctionnalités de travail.',
            color: Colors.green,
            icon: Icons.person,
            capabilities: [
              'Pointage et présence',
              'Messagerie d\'équipe',
              'Consultation des objectifs',
              'Demandes de congés',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String description,
    required Color color,
    required IconData icon,
    required List<String> capabilities,
  }) {
    return ModernCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'CAPACITÉS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          ...capabilities.map((capability) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, size: 16, color: color),
                const SizedBox(width: 8),
                Text(capability, style: const TextStyle(fontSize: 14)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ==================== CREATE TEAM DIALOG ====================
  void _showCreateTeamDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String? selectedDepartmentId;
    String? selectedLeaderId;
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Créer une équipe'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ModernTextField(
                  controller: nameController,
                  label: 'Nom de l\'équipe',
                  prefixIcon: Icons.group,
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  controller: descController,
                  label: 'Description',
                  maxLines: 3,
                  prefixIcon: Icons.description,
                ),
                const SizedBox(height: 16),
                Consumer<TeamProvider>(
                  builder: (context, teamProvider, child) {
                    return DropdownButtonFormField<String>(
                      value: selectedDepartmentId,
                      decoration: InputDecoration(
                        labelText: 'Département',
                        prefixIcon: const Icon(Icons.business),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: teamProvider.departments.map((dept) {
                        return DropdownMenuItem(
                          value: dept.id,
                          child: Text(dept.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedDepartmentId = value);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return DropdownButtonFormField<String>(
                      value: selectedLeaderId,
                      decoration: InputDecoration(
                        labelText: 'Chef d\'équipe',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: userProvider.users.map((user) {
                        return DropdownMenuItem(
                          value: user.id,
                          child: Text(user.fullName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedLeaderId = value);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Couleur', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ...[Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple].map(
                      (color) => GestureDetector(
                        onTap: () => setState(() => selectedColor = color),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: selectedColor == color
                                ? Border.all(color: Colors.black, width: 2)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: selectedColor == color 
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
              ),
              onPressed: () async {
                if (nameController.text.isEmpty || selectedDepartmentId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez remplir tous les champs requis')),
                  );
                  return;
                }

                final teamProvider = context.read<TeamProvider>();
                await teamProvider.createTeam(
                  name: nameController.text,
                  description: descController.text.isEmpty ? null : descController.text,
                  departmentId: selectedDepartmentId!,
                  leaderId: selectedLeaderId ?? '',
                  color: '#${selectedColor.value.toRadixString(16).substring(2)}',
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  if (teamProvider.errorMessage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Équipe créée avec succès'), backgroundColor: Colors.green),
                    );
                  }
                }
              },
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== EDIT TEAM DIALOG ====================
  void _showEditTeamDialog(Team team) {
    final nameController = TextEditingController(text: team.name);
    final descController = TextEditingController(text: team.description ?? '');
    String? selectedDepartmentId = team.department?.id;
    String? selectedLeaderId = team.leader?.id;
    Color selectedColor = _parseColor(team.color);
    bool isActive = team.isActive;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Modifier l\'équipe'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ModernTextField(
                  controller: nameController,
                  label: 'Nom de l\'équipe',
                  prefixIcon: Icons.group,
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  controller: descController,
                  label: 'Description',
                  maxLines: 3,
                  prefixIcon: Icons.description,
                ),
                const SizedBox(height: 16),
                Consumer<TeamProvider>(
                  builder: (context, teamProvider, child) {
                    return DropdownButtonFormField<String>(
                      value: selectedDepartmentId,
                      decoration: InputDecoration(
                        labelText: 'Département',
                        prefixIcon: const Icon(Icons.business),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: teamProvider.departments.map((dept) {
                        return DropdownMenuItem(
                          value: dept.id,
                          child: Text(dept.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedDepartmentId = value);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return DropdownButtonFormField<String>(
                      value: selectedLeaderId,
                      decoration: InputDecoration(
                        labelText: 'Chef d\'équipe',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: userProvider.users.map((user) {
                        return DropdownMenuItem(
                          value: user.id,
                          child: Text(user.fullName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedLeaderId = value);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Couleur', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ...[Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple].map(
                      (color) => GestureDetector(
                        onTap: () => setState(() => selectedColor = color),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: selectedColor == color
                                ? Border.all(color: Colors.black, width: 2)
                                : null,
                          ),
                          child: selectedColor == color 
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Active'),
                  value: isActive,
                  activeColor: ModernTheme.primaryBlue,
                  onChanged: (value) => setState(() => isActive = value),
                ),
              ],
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
              ),
              onPressed: () async {
                if (nameController.text.isEmpty || selectedDepartmentId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez remplir tous les champs requis')),
                  );
                  return;
                }

                final teamProvider = context.read<TeamProvider>();
                await teamProvider.updateTeam(
                  teamId: team.id!,
                  name: nameController.text,
                  description: descController.text.isEmpty ? null : descController.text,
                  departmentId: selectedDepartmentId,
                  leaderId: selectedLeaderId ?? '',
                  color: '#${selectedColor.value.toRadixString(16).substring(2)}',
                  isActive: isActive,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  if (teamProvider.errorMessage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Équipe modifiée avec succès'), backgroundColor: Colors.green),
                    );
                  }
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== DELETE TEAM ====================
  void _confirmDeleteTeam(Team team) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'équipe'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Text('Êtes-vous sûr de vouloir supprimer l\'équipe "${team.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final teamProvider = context.read<TeamProvider>();
              await teamProvider.deleteTeam(team.id!);

              if (context.mounted) {
                Navigator.pop(context);
                if (teamProvider.errorMessage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Équipe supprimée avec succès'), backgroundColor: Colors.green),
                  );
                }
              }
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  // ==================== MANAGE MEMBERS ====================
  void _showManageMembersDialog(Team team) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Membres de ${team.name}'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: SizedBox(
          width: double.maxFinite,
          child: Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final availableUsers = userProvider.users.where((user) {
                return !team.members.any((member) => member.id == user.id);
              }).toList();

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (availableUsers.isNotEmpty) ...[
                    const Text('Ajouter un membre:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: InputDecoration(
                        hintText: 'Sélectionner un utilisateur',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.person_add_alt),
                      ),
                      items: availableUsers.map((user) {
                        return DropdownMenuItem(
                          value: user.id,
                          child: Text(user.fullName),
                        );
                      }).toList(),
                      onChanged: (userId) async {
                        if (userId != null) {
                          final teamProvider = context.read<TeamProvider>();
                          await teamProvider.addMemberToTeam(team.id!, userId);
                          
                          if (context.mounted && teamProvider.errorMessage == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Membre ajouté avec succès'), backgroundColor: Colors.green),
                            );
                          }
                        }
                      },
                    ),
                    const Divider(height: 32),
                  ],
                  const Text('Membres actuels:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (team.members.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Aucun membre', style: TextStyle(color: Colors.grey)),
                    )
                  else
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: team.members.map((member) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey.shade200,
                              child: Text(member.fullName.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.black87)),
                            ),
                            title: Text(member.fullName),
                            subtitle: Text(member.email),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () => _removeMemberFromTeam(team, member),
                              tooltip: 'Retirer',
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _removeMemberFromTeam(Team team, User member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirer le membre'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Text('Voulez-vous retirer ${member.fullName} de l\'équipe ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final teamProvider = context.read<TeamProvider>();
      await teamProvider.removeMemberFromTeam(team.id!, member.id!);

      if (mounted && teamProvider.errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Membre retiré avec succès'), backgroundColor: Colors.green),
        );
      }
    }
  }

  // ==================== CREATE DEPARTMENT DIALOG ====================
  void _showCreateDepartmentDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final locationController = TextEditingController();
    final budgetController = TextEditingController();
    final employeeCountController = TextEditingController();
    String? selectedManagerId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Créer un département'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ModernTextField(
                  controller: nameController,
                  label: 'Nom du département',
                  prefixIcon: Icons.business,
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  controller: descController,
                  label: 'Description',
                  maxLines: 3,
                  prefixIcon: Icons.description,
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  controller: locationController,
                  label: 'Localisation',
                  prefixIcon: Icons.location_on,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ModernTextField(
                        controller: budgetController,
                        label: 'Budget',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.attach_money,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ModernTextField(
                        controller: employeeCountController,
                        label: 'Nb Employés',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.people,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return DropdownButtonFormField<String>(
                      value: selectedManagerId,
                      decoration: InputDecoration(
                        labelText: 'Manager',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: userProvider.users.map((user) {
                        return DropdownMenuItem(
                          value: user.id,
                          child: Text(user.fullName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedManagerId = value);
                      },
                    );
                  },
                ),
              ],
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
              ),
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez remplir le nom')),
                  );
                  return;
                }

                final teamProvider = context.read<TeamProvider>();
                await teamProvider.createDepartment(
                  name: nameController.text,
                  description: descController.text.isEmpty ? null : descController.text,
                  location: locationController.text.isEmpty ? null : locationController.text,
                  budget: budgetController.text.isEmpty ? 0 : (int.tryParse(budgetController.text) ?? 0),
                  managerId: selectedManagerId ?? '',
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  if (teamProvider.errorMessage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Département créé avec succès'), backgroundColor: Colors.green),
                    );
                  }
                }
              },
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== EDIT DEPARTMENT DIALOG ====================
  void _showEditDepartmentDialog(Department department) {
    final nameController = TextEditingController(text: department.name);
    final descController = TextEditingController(text: department.description ?? '');
    final locationController = TextEditingController(text: department.location ?? '');
    final budgetController = TextEditingController(text: department.budget?.toString() ?? '');
    final employeeCountController = TextEditingController(text: department.employeeCount?.toString() ?? '');
    String? selectedManagerId = department.manager?.id;
    bool isActive = department.isActive;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Modifier le département'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ModernTextField(
                  controller: nameController,
                  label: 'Nom du département',
                  prefixIcon: Icons.business,
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  controller: descController,
                  label: 'Description',
                  maxLines: 3,
                  prefixIcon: Icons.description,
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  controller: locationController,
                  label: 'Localisation',
                  prefixIcon: Icons.location_on,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ModernTextField(
                        controller: budgetController,
                        label: 'Budget',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.attach_money,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ModernTextField(
                        controller: employeeCountController,
                        label: 'Nb Employés',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.people,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return DropdownButtonFormField<String>(
                      value: selectedManagerId,
                      decoration: InputDecoration(
                        labelText: 'Manager',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: userProvider.users.map((user) {
                        return DropdownMenuItem(
                          value: user.id,
                          child: Text(user.fullName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedManagerId = value);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Actif'),
                  value: isActive,
                  activeColor: ModernTheme.primaryBlue,
                  onChanged: (value) => setState(() => isActive = value),
                ),
              ],
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
              ),
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez remplir le nom')),
                  );
                  return;
                }

                final teamProvider = context.read<TeamProvider>();
                await teamProvider.updateDepartment(
                  departmentId: department.id!,
                  name: nameController.text,
                  description: descController.text.isEmpty ? null : descController.text,
                  location: locationController.text.isEmpty ? null : locationController.text,
                  budget: budgetController.text.isEmpty ? 0 : (int.tryParse(budgetController.text) ?? 0),
                  employeeCount: employeeCountController.text.isEmpty ? 0 : (int.tryParse(employeeCountController.text) ?? 0),
                  managerId: selectedManagerId ?? '',
                  isActive: isActive,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  if (teamProvider.errorMessage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Département modifié avec succès'), backgroundColor: Colors.green),
                    );
                  }
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== DELETE DEPARTMENT ====================
  void _confirmDeleteDepartment(Department department) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le département'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Text('Êtes-vous sûr de vouloir supprimer le département "${department.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final teamProvider = context.read<TeamProvider>();
              await teamProvider.deleteDepartment(department.id!);

              if (context.mounted) {
                Navigator.pop(context);
                if (teamProvider.errorMessage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Département supprimé avec succès'), backgroundColor: Colors.green),
                  );
                }
              }
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  // ==================== HELPER METHODS ====================
  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return Colors.blue;
    try {
      final hex = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }
}
