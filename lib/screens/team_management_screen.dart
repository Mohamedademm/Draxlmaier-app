import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../providers/team_provider.dart';
import '../models/user_model.dart';
import '../models/team_model.dart';
import '../models/department_model.dart';

/// Advanced Team Management Screen for Admin
class TeamManagementScreen extends StatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  State<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      return Scaffold(
        appBar: AppBar(title: const Text('Accès refusé')),
        body: const Center(
          child: Text('Vous n\'avez pas les permissions nécessaires.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Équipes'),
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.groups), text: 'Équipes'),
            Tab(icon: Icon(Icons.business), text: 'Départements'),
            Tab(icon: Icon(Icons.admin_panel_settings), text: 'Permissions'),
          ],
        ),
      ),
      body: Consumer<TeamProvider>(
        builder: (context, teamProvider, child) {
          if (teamProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (teamProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(teamProvider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTeamsTab(),
              _buildDepartmentsTab(),
              _buildPermissionsTab(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _showCreateTeamDialog();
          } else if (_tabController.index == 1) {
            _showCreateDepartmentDialog();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(_tabController.index == 0 ? 'Équipe' : 'Département'),
      ),
    );
  }

  // ==================== TEAMS TAB ====================
  Widget _buildTeamsTab() {
    return Consumer<TeamProvider>(
      builder: (context, teamProvider, child) {
        if (teamProvider.teams.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.group_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Aucune équipe'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _showCreateTeamDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Créer une équipe'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => teamProvider.loadTeams(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatsCards(teamProvider),
              const SizedBox(height: 16),
              ...teamProvider.teams.map((team) => _buildTeamCard(team)),
            ],
          ),
        );
      },
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
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.groups, size: 32, color: Colors.blue),
                  const SizedBox(height: 8),
                  Text(
                    '$totalTeams',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('Équipes totales'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, size: 32, color: Colors.green),
                  const SizedBox(height: 8),
                  Text(
                    '$activeTeams',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('Actives'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.person, size: 32, color: Colors.orange),
                  const SizedBox(height: 8),
                  Text(
                    '$totalMembers',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('Membres'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamCard(Team team) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _parseColor(team.color),
          child: Text(
            team.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          team.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (team.description != null) Text(team.description!),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  team.isActive ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: team.isActive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  team.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: team.isActive ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.people, size: 16),
                const SizedBox(width: 4),
                Text('${team.totalMembers} membres', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
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
            const PopupMenuItem(value: 'members', child: Text('Gérer les membres')),
            const PopupMenuItem(value: 'edit', child: Text('Modifier')),
            const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (team.leader != null) ...[
                  const Text('Chef d\'équipe:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: CircleAvatar(
                      child: Text(team.leader!.fullName.substring(0, 1).toUpperCase()),
                    ),
                    title: Text(team.leader!.fullName),
                    subtitle: Text(team.leader!.email),
                  ),
                  const Divider(),
                ],
                const Text('Membres:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (team.members.isEmpty)
                  const Text('Aucun membre')
                else
                  ...team.members.map((member) => ListTile(
                        leading: CircleAvatar(
                          child: Text(member.fullName.substring(0, 1).toUpperCase()),
                        ),
                        title: Text(member.fullName),
                        subtitle: Text(member.email),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _removeMemberFromTeam(team, member),
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
  Widget _buildDepartmentsTab() {
    return Consumer<TeamProvider>(
      builder: (context, teamProvider, child) {
        if (teamProvider.departments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.business_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Aucun département'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _showCreateDepartmentDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Créer un département'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => teamProvider.loadDepartments(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: teamProvider.departments.map((dept) => _buildDepartmentCard(dept)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildDepartmentCard(Department department) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.business, color: Colors.white),
        ),
        title: Text(
          department.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (department.description != null) Text(department.description!),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  department.isActive ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: department.isActive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  department.isActive ? 'Actif' : 'Inactif',
                  style: TextStyle(
                    color: department.isActive ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
                if (department.location != null) ...[
                  const SizedBox(width: 16),
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 4),
                  Text(department.location!, style: const TextStyle(fontSize: 12)),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _showEditDepartmentDialog(department);
            } else if (value == 'delete') {
              _confirmDeleteDepartment(department);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Modifier')),
            const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
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
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDepartmentInfoCard(
                        'Employés',
                        '${department.employeeCount}',
                        Icons.people,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (department.manager != null) ...[
                  const Text('Manager:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: CircleAvatar(
                      child: Text(department.manager!.fullName.substring(0, 1).toUpperCase()),
                    ),
                    title: Text(department.manager!.fullName),
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

  Widget _buildDepartmentInfoCard(String label, String value, IconData icon) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ==================== PERMISSIONS TAB ====================
  Widget _buildPermissionsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.admin_panel_settings, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Gestion des permissions'),
          SizedBox(height: 8),
          Text('Fonctionnalité à venir...', style: TextStyle(color: Colors.grey)),
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
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de l\'équipe',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Consumer<TeamProvider>(
                  builder: (context, teamProvider, child) {
                    return DropdownButtonFormField<String>(
                      value: selectedDepartmentId,
                      decoration: const InputDecoration(
                        labelText: 'Département',
                        border: OutlineInputBorder(),
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
                      decoration: const InputDecoration(
                        labelText: 'Chef d\'équipe',
                        border: OutlineInputBorder(),
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
                Row(
                  children: [
                    const Text('Couleur: '),
                    const SizedBox(width: 8),
                    ...[ Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple].map(
                      (color) => GestureDetector(
                        onTap: () => setState(() => selectedColor = color),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: selectedColor == color
                                ? Border.all(color: Colors.black, width: 3)
                                : null,
                          ),
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
                      const SnackBar(content: Text('Équipe créée avec succès')),
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
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de l\'équipe',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Consumer<TeamProvider>(
                  builder: (context, teamProvider, child) {
                    return DropdownButtonFormField<String>(
                      value: selectedDepartmentId,
                      decoration: const InputDecoration(
                        labelText: 'Département',
                        border: OutlineInputBorder(),
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
                      decoration: const InputDecoration(
                        labelText: 'Chef d\'équipe',
                        border: OutlineInputBorder(),
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
                Row(
                  children: [
                    const Text('Couleur: '),
                    const SizedBox(width: 8),
                    ...[Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple].map(
                      (color) => GestureDetector(
                        onTap: () => setState(() => selectedColor = color),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: selectedColor == color
                                ? Border.all(color: Colors.black, width: 3)
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Active'),
                  value: isActive,
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
                      const SnackBar(content: Text('Équipe modifiée avec succès')),
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
        content: Text('Êtes-vous sûr de vouloir supprimer l\'équipe "${team.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final teamProvider = context.read<TeamProvider>();
              await teamProvider.deleteTeam(team.id!);

              if (context.mounted) {
                Navigator.pop(context);
                if (teamProvider.errorMessage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Équipe supprimée avec succès')),
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
                    DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Sélectionner un utilisateur'),
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
                              const SnackBar(content: Text('Membre ajouté avec succès')),
                            );
                          }
                        }
                      },
                    ),
                    const Divider(),
                  ],
                  const Text('Membres actuels:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (team.members.isEmpty)
                    const Text('Aucun membre')
                  else
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: team.members.map((member) {
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(member.fullName.substring(0, 1).toUpperCase()),
                            ),
                            title: Text(member.fullName),
                            subtitle: Text(member.email),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => _removeMemberFromTeam(team, member),
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
        content: Text('Voulez-vous retirer ${member.fullName} de l\'équipe ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
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
          const SnackBar(content: Text('Membre retiré avec succès')),
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
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du département',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Localisation',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: budgetController,
                  decoration: const InputDecoration(
                    labelText: 'Budget',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: employeeCountController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre d\'employés',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return DropdownButtonFormField<String>(
                      value: selectedManagerId,
                      decoration: const InputDecoration(
                        labelText: 'Manager',
                        border: OutlineInputBorder(),
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
                      const SnackBar(content: Text('Département créé avec succès')),
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
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du département',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Localisation',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: budgetController,
                  decoration: const InputDecoration(
                    labelText: 'Budget',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: employeeCountController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre d\'employés',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return DropdownButtonFormField<String>(
                      value: selectedManagerId,
                      decoration: const InputDecoration(
                        labelText: 'Manager',
                        border: OutlineInputBorder(),
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
                      const SnackBar(content: Text('Département modifié avec succès')),
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
        content: Text('Êtes-vous sûr de vouloir supprimer le département "${department.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final teamProvider = context.read<TeamProvider>();
              await teamProvider.deleteDepartment(department.id!);

              if (context.mounted) {
                Navigator.pop(context);
                if (teamProvider.errorMessage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Département supprimé avec succès')),
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
