import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
import '../theme/modern_theme.dart';
import '../widgets/modern_widgets.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
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
          _buildModernAppBar(),
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              if (userProvider.isLoading) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF0EA5E9),
                    ),
                  ),
                );
              }

              final authProvider = context.read<AuthProvider>();
              final users = userProvider.users.where((u) {
                if (authProvider.isManager) {
                  return !u.isAdmin;
                }
                return true;
              }).toList();

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
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final user = users[index];
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 400 + (index * 50)),
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
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF0EA5E9).withOpacity(0.2),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0EA5E9).withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(20),
                            leading: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: user.isAdmin
                                      ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                                      : user.isManager
                                          ? [const Color(0xFF0EA5E9), const Color(0xFF0891B2)]
                                          : [const Color(0xFF10B981), const Color(0xFF059669)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (user.isAdmin
                                            ? const Color(0xFFEF4444)
                                            : user.isManager
                                                ? const Color(0xFF0EA5E9)
                                                : const Color(0xFF10B981))
                                        .withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  user.firstname.isNotEmpty
                                      ? user.firstname[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              user.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0EA5E9).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.email_outlined,
                                        size: 14,
                                        color: Color(0xFF0EA5E9),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        user.email,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _buildModernRoleChip(user.role),
                                    const SizedBox(width: 8),
                                    _buildModernStatusChip(user.active),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF0EA5E9).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert_rounded,
                                  color: Color(0xFF0EA5E9),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.edit_outlined,
                                          size: 20,
                                          color: Color(0xFF0EA5E9),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Modifier',
                                          style: TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: user.active ? 'deactivate' : 'activate',
                                    child: Row(
                                      children: [
                                        Icon(
                                          user.active
                                              ? Icons.block_outlined
                                              : Icons.check_circle_outline_rounded,
                                          size: 20,
                                          color: user.active
                                              ? const Color(0xFFEF4444)
                                              : const Color(0xFF10B981),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          user.active ? 'Désactiver' : 'Activer',
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline_rounded,
                                          size: 20,
                                          color: Color(0xFFEF4444),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Supprimer',
                                          style: TextStyle(
                                            color: Color(0xFFEF4444),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) => _handleUserAction(value, user),
                              ),
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
      floatingActionButton: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF0EA5E9), Color(0xFF0891B2)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0EA5E9).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: _showAddUserDialog,
            icon: const Icon(Icons.person_add_rounded, size: 24),
            label: const Text(
              'Nouvel Utilisateur',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 160.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF0EA5E9),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.people_rounded, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Gestion des Utilisateurs',
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
            ),
          ],
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
                right: -50,
                top: -30,
                child: Icon(
                  Icons.people_outline_rounded,
                  size: 200,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -40,
                child: Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 150,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _loadUsers,
            tooltip: 'Actualiser',
          ),
        ),
      ],
    );
  }

  Widget _buildModernRoleChip(UserRole role) {
    Color color;
    IconData icon;
    
    if (role == UserRole.admin) {
      color = const Color(0xFFEF4444);
      icon = Icons.admin_panel_settings_rounded;
    } else if (role == UserRole.manager) {
      color = const Color(0xFF0EA5E9);
      icon = Icons.supervisor_account_rounded;
    } else {
      color = const Color(0xFF10B981);
      icon = Icons.person_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            role.name.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatusChip(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: active
              ? [
                  const Color(0xFF10B981).withOpacity(0.2),
                  const Color(0xFF059669).withOpacity(0.1),
                ]
              : [
                  const Color(0xFFEF4444).withOpacity(0.2),
                  const Color(0xFFDC2626).withOpacity(0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 14,
            color: active ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
          const SizedBox(width: 6),
          Text(
            active ? 'ACTIF' : 'INACTIF',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: active ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            ),
          ),
        ],
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
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0EA5E9), Color(0xFF0891B2)],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.person_add_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Nouvel Utilisateur',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildModernTextField(
                          controller: firstnameController,
                          label: 'Prénom',
                          hint: 'Entrez le prénom',
                          icon: Icons.person_rounded,
                          iconColor: const Color(0xFF0EA5E9),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        _buildModernTextField(
                          controller: lastnameController,
                          label: 'Nom',
                          hint: 'Entrez le nom',
                          icon: Icons.person_outline_rounded,
                          iconColor: const Color(0xFF10B981),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        _buildModernTextField(
                          controller: emailController,
                          label: 'Email',
                          hint: 'exemple@email.com',
                          icon: Icons.email_rounded,
                          iconColor: const Color(0xFF6366F1),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        _buildModernTextField(
                          controller: passwordController,
                          label: 'Mot de passe',
                          hint: '••••••••',
                          icon: Icons.lock_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          obscureText: true,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 16),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Rôle *',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFF0EA5E9).withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: DropdownButtonFormField<UserRole>(
                                value: selectedRole,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                                dropdownColor: Colors.white,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF0EA5E9)),
                                items: UserRole.values.map((role) {
                                  return DropdownMenuItem(
                                    value: role,
                                    child: Text(
                                      role.name.toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) => setState(() => selectedRole = value!),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF64748B),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(
                                      color: const Color(0xFF64748B).withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Annuler',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF0EA5E9), Color(0xFF0891B2)],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0EA5E9).withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () async {
                                      if (firstnameController.text.isEmpty ||
                                          lastnameController.text.isEmpty ||
                                          emailController.text.isEmpty ||
                                          passwordController.text.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Row(
                                              children: [
                                                Icon(Icons.warning_rounded, color: Colors.white),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    'Veuillez remplir tous les champs',
                                                    style: TextStyle(fontWeight: FontWeight.w600),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: const Color(0xFFF59E0B),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      Navigator.pop(context);
                                      final userProvider = context.read<UserProvider>();
                                      final success = await userProvider.createUser(
                                        firstname: firstnameController.text,
                                        lastname: lastnameController.text,
                                        email: emailController.text,
                                        password: passwordController.text,
                                        role: selectedRole,
                                      );

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                Icon(
                                                  success ? Icons.check_circle_rounded : Icons.error_rounded,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    success ? 'Utilisateur créé avec succès' : 'Échec de la création',
                                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(14),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_circle_rounded, color: Colors.white, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Créer',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color iconColor,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [iconColor, iconColor.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              '$label *',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: const Color(0xFF0EA5E9).withOpacity(0.3),
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
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  void _showEditUserDialog(User user) {
    final firstnameController = TextEditingController(text: user.firstname);
    final lastnameController = TextEditingController(text: user.lastname);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phone ?? '');
    final departmentController = TextEditingController(text: user.department ?? '');
    final positionController = TextEditingController(text: user.position ?? '');
    final addressController = TextEditingController(text: user.address ?? '');
    final cityController = TextEditingController(text: user.city ?? '');
    final postalCodeController = TextEditingController(text: user.postalCode ?? '');
    UserRole selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Modifier l\'Utilisateur'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations personnelles',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ModernTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ModernTextField(controller: firstnameController, label: 'Prénom', prefixIcon: Icons.person_outline),
                  const SizedBox(height: 16),
                  ModernTextField(controller: lastnameController, label: 'Nom', prefixIcon: Icons.person_outline),
                  const SizedBox(height: 16),
                  ModernTextField(controller: emailController, label: 'Email', keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email_outlined),
                  const SizedBox(height: 16),
                  ModernTextField(controller: phoneController, label: 'Téléphone', keyboardType: TextInputType.phone, prefixIcon: Icons.phone_outlined),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Informations professionnelles',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ModernTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 16),
                  ModernTextField(controller: departmentController, label: 'Département', prefixIcon: Icons.business_outlined),
                  const SizedBox(height: 16),
                  ModernTextField(controller: positionController, label: 'Poste', prefixIcon: Icons.badge_outlined),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Adresse',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ModernTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ModernTextField(controller: addressController, label: 'Adresse', prefixIcon: Icons.home_outlined),
                  const SizedBox(height: 16),
                  ModernTextField(controller: cityController, label: 'Ville', prefixIcon: Icons.location_city_outlined),
                  const SizedBox(height: 16),
                  ModernTextField(controller: postalCodeController, label: 'Code postal', prefixIcon: Icons.mail_outlined),
                ],
              ),
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
                  phone: phoneController.text,
                  department: departmentController.text,
                  position: positionController.text,
                  address: addressController.text,
                  city: cityController.text,
                  postalCode: postalCodeController.text,
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
