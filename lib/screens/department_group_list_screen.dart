import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_group_model.dart';
import '../providers/auth_provider.dart';
import '../services/chat_service.dart';
import '../theme/modern_theme.dart';
import '../utils/department_constants.dart';
import '../widgets/modern_widgets.dart';
import 'group_chat_screen.dart';

/// Screen showing department group chats
/// Employees see only their department group
/// Admins see all department groups
class DepartmentGroupListScreen extends StatefulWidget {
  const DepartmentGroupListScreen({super.key});

  @override
  State<DepartmentGroupListScreen> createState() => _DepartmentGroupListScreenState();
}

class _DepartmentGroupListScreenState extends State<DepartmentGroupListScreen> with SingleTickerProviderStateMixin {
  final ChatService _chatService = ChatService();
  List<ChatGroup> _groups = [];
  bool _isLoading = true;
  String? _error;
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

    _loadDepartmentGroups();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadDepartmentGroups() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Get all department groups
      final allGroups = await _chatService.getDepartmentGroups();

      // Filter based on user role
      List<ChatGroup> filteredGroups;
      if (authProvider.isAdmin) {
        // Admin sees all department groups
        filteredGroups = allGroups;
      } else {
        // Employee sees only their department group
        final userDepartment = currentUser.department;
        if (userDepartment == null || !DepartmentConstants.isValidDepartment(userDepartment)) {
          throw Exception('Département non valide ou non assigné');
        }
        
        filteredGroups = allGroups.where((group) {
          return group.department == userDepartment;
        }).toList();
      }

      setState(() {
        _groups = filteredGroups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createDepartmentGroup(String department) async {
    try {
      await _chatService.createDepartmentGroup(
        name: 'Groupe $department',
        department: department,
        description: 'Chat de groupe pour le département $department',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Groupe $department créé avec succès'),
            backgroundColor: ModernTheme.success,
          ),
        );
        _loadDepartmentGroups();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: ModernTheme.error,
          ),
        );
      }
    }
  }

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer un groupe de département'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: DepartmentConstants.allowedDepartments.map((dept) {
              // Check if group already exists
              final exists = _groups.any((g) => g.department == dept);
              final color = _parseColor(DepartmentConstants.getDepartmentColor(dept));
              
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    DepartmentConstants.getDepartmentIcon(dept),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                title: Text(dept, style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: exists
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.add_circle_outline, color: ModernTheme.primaryBlue),
                enabled: !exists,
                onTap: exists
                    ? null
                    : () {
                        Navigator.pop(context);
                        _createDepartmentGroup(dept);
                      },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

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
                'Groupes de Département',
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
                        Icons.forum_outlined,
                        size: 150,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              if (authProvider.isAdmin)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  onPressed: _showCreateGroupDialog,
                  tooltip: 'Créer un groupe',
                ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadDepartmentGroups,
                tooltip: 'Actualiser',
              ),
            ],
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: EmptyState(
                  icon: Icons.error_outline,
                  title: 'Erreur',
                  message: _error!,
                  action: ElevatedButton.icon(
                    onPressed: _loadDepartmentGroups,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ),
              ),
            )
          else if (_groups.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: EmptyState(
                  icon: Icons.group_outlined,
                  title: 'Aucun groupe',
                  message: authProvider.isAdmin
                      ? 'Créez un groupe de département pour commencer'
                      : 'Aucun groupe disponible pour votre département',
                  action: authProvider.isAdmin
                      ? ElevatedButton.icon(
                          onPressed: _showCreateGroupDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Créer un groupe'),
                        )
                      : null,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(ModernTheme.spacingM),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final group = _groups[index];
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildGroupCard(group),
                    );
                  },
                  childCount: _groups.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(ChatGroup group) {
    final department = group.department ?? 'Inconnu';
    final color = _parseColor(DepartmentConstants.getDepartmentColor(department));
    final icon = DepartmentConstants.getDepartmentIcon(department);

    return ModernCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupChatScreen(group: group),
          ),
        );
      },
      margin: const EdgeInsets.only(bottom: ModernTheme.spacingM),
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: ModernTheme.cardRadius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Colored Side Indicator
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Department Icon
              Center(
                child: Hero(
                  tag: 'group_icon_${group.id}',
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Group Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        group.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: ModernTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        department.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildMemberBadge(group.memberCount),
                          const SizedBox(width: 8),
                          if (group.isDepartmentGroup)
                            const StatusBadge(
                              label: 'OFFICIEL',
                              color: ModernTheme.primaryBlue,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Action Icon
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: ModernTheme.textTertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: ModernTheme.textSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline, size: 14, color: ModernTheme.textSecondary),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: ModernTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return ModernTheme.primaryBlue;
    }
  }
}
