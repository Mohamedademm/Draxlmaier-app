import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
import '../theme/modern_theme.dart';
import '../widgets/modern_widgets.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> with SingleTickerProviderStateMixin {
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
      _loadUsers();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: ModernTheme.primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Gestion des Utilisateurs',
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
                      top: -20,
                      child: Icon(
                        Icons.people_outline,
                        size: 150,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadUsers,
                tooltip: 'Actualiser',
              ),
            ],
          ),
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              if (userProvider.isLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final users = userProvider.users;

              if (users.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: EmptyState(
                      icon: Icons.people_outline,
                      title: 'Aucun utilisateur',
                      message: 'Aucun utilisateur trouvé dans le système.',
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final user = users[index];
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ModernCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: ModernTheme.primaryBlue.withOpacity(0.1),
                              child: Text(
                                user.firstname.isNotEmpty ? user.firstname[0].toUpperCase() : '?',
                                style: const TextStyle(color: ModernTheme.primaryBlue, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(user.email, style: const TextStyle(fontSize: 13, color: ModernTheme.textSecondary)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildRoleChip(user.role),
                                    const SizedBox(width: 8),
                                    _buildStatusChip(user.active),
                                  ],
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: ModernTheme.textTertiary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 20, color: ModernTheme.primaryBlue),
                                      SizedBox(width: 12),
                                      Text('Modifier'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: user.active ? 'deactivate' : 'activate',
                                  child: Row(
                                    children: [
                                      Icon(
                                        user.active ? Icons.block_outlined : Icons.check_circle_outline,
                                        size: 20,
                                        color: user.active ? ModernTheme.error : ModernTheme.success,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(user.active ? 'Désactiver' : 'Activer'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                      SizedBox(width: 12),
                                      Text('Supprimer', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) => _handleUserAction(value, user),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: users.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nouvel Utilisateur'),
        backgroundColor: ModernTheme.primaryBlue,
        elevation: 4,
      ),
    );
  }

  Widget _buildRoleChip(UserRole role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: ModernTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(role.name.toUpperCase(), 
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: ModernTheme.textSecondary)),
    );
  }

  Widget _buildStatusChip(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (active ? ModernTheme.success : ModernTheme.error).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(active ? 'ACTIF' : 'INACTIF', 
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: active ? ModernTheme.success : ModernTheme.error)),
    );
  }

  void _handleUserAction(String action, User user) async {
    final userProvider = context.read<UserProvider>();

    switch (action) {
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'activate':
        final success = await userProvider.activateUser(user.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(success ? 'Utilisateur activé' : 'Échec de l\'activation'), 
              backgroundColor: success ? ModernTheme.success : ModernTheme.error),
          );
        }
        break;
      case 'deactivate':
        final success = await userProvider.deactivateUser(user.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(success ? 'Utilisateur désactivé' : 'Échec de la désactivation'), 
              backgroundColor: success ? ModernTheme.success : ModernTheme.error),
          );
        }
        break;
      case 'delete':
        _showDeleteConfirmation(user);
        break;
    }
  }

  void _showAddUserDialog() {
    final firstnameController = TextEditingController();
    final lastnameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    UserRole selectedRole = UserRole.employee;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nouvel Utilisateur'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ModernTextField(controller: firstnameController, label: 'Prénom', prefixIcon: Icons.person_outline),
                const SizedBox(height: 16),
                ModernTextField(controller: lastnameController, label: 'Nom', prefixIcon: Icons.person_outline),
                const SizedBox(height: 16),
                ModernTextField(controller: emailController, label: 'Email', keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email_outlined),
                const SizedBox(height: 16),
                ModernTextField(controller: passwordController, label: 'Mot de passe', obscureText: true, prefixIcon: Icons.lock_outline),
                const SizedBox(height: 16),
                DropdownButtonFormField<UserRole>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Rôle',
                    prefixIcon: const Icon(Icons.admin_panel_settings_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(value: role, child: Text(role.name.toUpperCase()));
                  }).toList(),
                  onChanged: (value) => setState(() => selectedRole = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernTheme.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final userProvider = context.read<UserProvider>();
                final success = await userProvider.createUser(
                  firstname: firstnameController.text,
                  lastname: lastnameController.text,
                  email: emailController.text,
                  password: passwordController.text,
                  role: selectedRole,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? 'Utilisateur créé' : 'Échec de la création'), 
                      backgroundColor: success ? ModernTheme.success : ModernTheme.error),
                  );
                }
              },
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(User user) {
    final firstnameController = TextEditingController(text: user.firstname);
    final lastnameController = TextEditingController(text: user.lastname);
    final emailController = TextEditingController(text: user.email);
    UserRole selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Modifier l\'Utilisateur'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ModernTextField(controller: firstnameController, label: 'Prénom', prefixIcon: Icons.person_outline),
                const SizedBox(height: 16),
                ModernTextField(controller: lastnameController, label: 'Nom', prefixIcon: Icons.person_outline),
                const SizedBox(height: 16),
                ModernTextField(controller: emailController, label: 'Email', keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email_outlined),
                const SizedBox(height: 16),
                DropdownButtonFormField<UserRole>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Rôle',
                    prefixIcon: const Icon(Icons.admin_panel_settings_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(value: role, child: Text(role.name.toUpperCase()));
                  }).toList(),
                  onChanged: (value) => setState(() => selectedRole = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernTheme.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final userProvider = context.read<UserProvider>();
                final success = await userProvider.updateUser(
                  userId: user.id,
                  firstname: firstnameController.text,
                  lastname: lastnameController.text,
                  email: emailController.text,
                  role: selectedRole,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? 'Utilisateur mis à jour' : 'Échec de la mise à jour'), 
                      backgroundColor: success ? ModernTheme.success : ModernTheme.error),
                  );
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'Utilisateur'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Text('Voulez-vous vraiment supprimer ${user.fullName} ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernTheme.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final userProvider = context.read<UserProvider>();
              final success = await userProvider.deleteUser(user.id);
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? 'Utilisateur supprimé' : 'Échec de la suppression'), 
                    backgroundColor: success ? ModernTheme.success : ModernTheme.error),
                );
              }
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
