import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';
import '../services/team_service.dart';
import '../models/user_model.dart';
import '../models/team_model.dart';
import '../theme/modern_theme.dart';
import '../widgets/modern_widgets.dart';

class PendingUsersScreen extends StatefulWidget {
  const PendingUsersScreen({super.key});

  @override
  State<PendingUsersScreen> createState() => _PendingUsersScreenState();
}

class _PendingUsersScreenState extends State<PendingUsersScreen> with SingleTickerProviderStateMixin {
  final _userService = UserService();
  final _teamService = TeamService();
  List<User> _pendingUsers = [];
  bool _isLoading = true;
  String? _error;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  // Cache teams
  List<Team> _teams = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await _userService.getPendingUsers();
      // Try to fetch teams, but don't fail if it errors (dropdown is optional)
      try {
        _teams = await _teamService.getTeams(isActive: true);
      } catch (e) {
        print('Error loading teams: $e');
        _teams = [];
      }
      
      if (mounted) {
        setState(() {
          _pendingUsers = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }
  
  // Alias for refresh button
  Future<void> _loadPendingUsers() => _loadData();

  Future<void> _showValidationDialog(User user) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Valider ${user.fullName}'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Voulez-vous valider cet utilisateur et activer son compte ?', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            _buildInfoRow('Email', user.email),
            _buildInfoRow('Poste', user.position ?? 'N/A'),
            _buildInfoRow('Département', user.department ?? 'N/A'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernTheme.success,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _validateUser(user.id!, null, null);
            },
            child: const Text('Confirmer l\'accès'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRejectionDialog(User user) async {
    final reasonController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rejeter ${user.fullName}'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Êtes-vous sûr de vouloir rejeter cette inscription ?', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            ModernTextField(
              controller: reasonController,
              label: 'Raison du rejet (optionnel)',
              hint: 'Ex: Informations incomplètes...',
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernTheme.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _rejectUser(user.id!, reasonController.text.trim());
            },
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
  }

  Future<void> _validateUser(String userId, String? matricule, String? team) async {
    try {
      await _userService.validateUser(userId, matricule, team);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur validé avec succès'), backgroundColor: ModernTheme.success),
        );
        _loadPendingUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: ModernTheme.error),
        );
      }
    }
  }

  Future<void> _rejectUser(String userId, String reason) async {
    try {
      await _userService.rejectUser(userId, reason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inscription rejetée'), backgroundColor: Colors.orange),
        );
        _loadPendingUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: ModernTheme.error),
        );
      }
    }
  }

  void _showUserDetails(User user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: ModernTheme.primaryBlue.withOpacity(0.1),
                            child: Text(user.firstname[0].toUpperCase(), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: ModernTheme.primaryBlue)),
                          ),
                          const SizedBox(height: 16),
                          Text(user.fullName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                            child: const Text('EN ATTENTE', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Informations de contact'),
                    ModernCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildInfoRow('Email', user.email),
                            const Divider(height: 24),
                            _buildInfoRow('Téléphone', user.phone ?? 'Non renseigné'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Poste et Département'),
                    ModernCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildInfoRow('Poste', user.position ?? 'Non renseigné'),
                            const Divider(height: 24),
                            _buildInfoRow('Département', user.department ?? 'Non renseigné'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Localisation'),
                    ModernCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildInfoRow('Ville', user.city ?? 'Non renseignée'),
                            const Divider(height: 24),
                            _buildInfoRow('Adresse', user.address ?? 'Non renseignée'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ModernTheme.error,
                              side: const BorderSide(color: ModernTheme.error),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _showRejectionDialog(user);
                            },
                            child: const Text('Rejeter'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ModernTheme.success,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _showValidationDialog(user);
                            },
                            child: const Text('Valider'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ModernTheme.textSecondary)),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(color: ModernTheme.textTertiary, fontSize: 13))),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
      ],
    );
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
                'Inscriptions en attente',
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
                        Icons.person_add_outlined,
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
                onPressed: _loadPendingUsers,
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
                    onPressed: _loadPendingUsers,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ),
              ),
            )
          else if (_pendingUsers.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: EmptyState(
                  icon: Icons.check_circle_outline,
                  title: 'Aucune inscription',
                  message: 'Toutes les demandes ont été traitées.',
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final user = _pendingUsers[index];
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ModernCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: ModernTheme.primaryBlue.withOpacity(0.1),
                            child: Text(
                              user.firstname.isNotEmpty ? user.firstname[0].toUpperCase() : '?',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ModernTheme.primaryBlue),
                            ),
                          ),
                          title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(user.email, style: const TextStyle(fontSize: 13)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  if (user.position != null)
                                    _buildSmallChip(user.position!),
                                  if (user.department != null) ...[
                                    const SizedBox(width: 8),
                                    _buildSmallChip(user.department!),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right, color: ModernTheme.textTertiary),
                          onTap: () => _showUserDetails(user),
                        ),
                      ),
                    );
                  },
                  childCount: _pendingUsers.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSmallChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: ModernTheme.surfaceVariant, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: const TextStyle(fontSize: 10, color: ModernTheme.textSecondary, fontWeight: FontWeight.w500)),
    );
  }
}
