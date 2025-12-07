import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../theme/draexlmaier_theme.dart';
import '../widgets/custom_app_bar.dart';

class PendingUsersScreen extends StatefulWidget {
  const PendingUsersScreen({Key? key}) : super(key: key);

  @override
  State<PendingUsersScreen> createState() => _PendingUsersScreenState();
}

class _PendingUsersScreenState extends State<PendingUsersScreen> {
  final _userService = UserService();
  List<User> _pendingUsers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPendingUsers();
  }

  Future<void> _loadPendingUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await _userService.getPendingUsers();
      setState(() {
        _pendingUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showValidationDialog(User user) async {
    final matriculeController = TextEditingController();
    String? selectedTeam;
    final authProvider = context.read<AuthProvider>();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Valider ${user.fullName}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informations du candidat',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildInfoRow('Email', user.email),
              _buildInfoRow('Téléphone', user.phone ?? 'N/A'),
              _buildInfoRow('Poste', user.position ?? 'N/A'),
              _buildInfoRow('Département', user.department ?? 'N/A'),
              _buildInfoRow('Ville', user.city ?? 'N/A'),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              TextField(
                controller: matriculeController,
                decoration: const InputDecoration(
                  labelText: 'Matricule *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedTeam,
                decoration: const InputDecoration(
                  labelText: 'Équipe',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group),
                ),
                items: [
                  'Équipe A',
                  'Équipe B',
                  'Équipe C',
                  'Production',
                  'Qualité',
                ].map((team) {
                  return DropdownMenuItem(
                    value: team,
                    child: Text(team),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedTeam = value;
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
            onPressed: () {
              if (matriculeController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez entrer un matricule'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              _validateUser(
                user.id!,
                matriculeController.text.trim(),
                selectedTeam,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DraexlmaierTheme.completedColor,
            ),
            child: const Text('Valider'),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Êtes-vous sûr de vouloir rejeter cette inscription ?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Raison du rejet (optionnel)',
                border: OutlineInputBorder(),
                hintText: 'Ex: Informations incomplètes, doublon...',
              ),
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
            onPressed: () {
              Navigator.pop(context);
              _rejectUser(user.id!, reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DraexlmaierTheme.accentRed,
            ),
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
  }

  Future<void> _validateUser(String userId, String matricule, String? team) async {
    try {
      await _userService.validateUser(userId, matricule, team);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Utilisateur validé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        _loadPendingUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectUser(String userId, String reason) async {
    try {
      await _userService.rejectUser(userId, reason);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription rejetée'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadPendingUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showUserDetails(User user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: DraexlmaierTheme.primaryBlue,
                  child: Text(
                    user.firstname[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  user.fullName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Chip(
                  label: const Text('EN ATTENTE'),
                  backgroundColor: Colors.orange.withOpacity(0.2),
                  labelStyle: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Informations personnelles'),
              _buildDetailCard([
                _buildInfoRow('Email', user.email),
                _buildInfoRow('Téléphone', user.phone ?? 'Non renseigné'),
              ]),
              const SizedBox(height: 16),
              _buildSectionTitle('Poste et département'),
              _buildDetailCard([
                _buildInfoRow('Poste', user.position ?? 'Non renseigné'),
                _buildInfoRow('Département', user.department ?? 'Non renseigné'),
              ]),
              const SizedBox(height: 16),
              _buildSectionTitle('Localisation'),
              _buildDetailCard([
                _buildInfoRow('Adresse', user.address ?? 'Non renseignée'),
                _buildInfoRow('Ville', user.city ?? 'Non renseignée'),
                _buildInfoRow('Code postal', user.postalCode ?? 'Non renseigné'),
                if (user.latitude != null && user.longitude != null)
                  _buildInfoRow(
                    'GPS',
                    '${user.latitude?.toStringAsFixed(4) ?? "0.0"}, ${user.longitude?.toStringAsFixed(4) ?? "0.0"}',
                  ),
              ]),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showRejectionDialog(user);
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Rejeter'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: DraexlmaierTheme.accentRed,
                        side: BorderSide(color: DraexlmaierTheme.accentRed),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showValidationDialog(user);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Valider'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: DraexlmaierTheme.completedColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: DraexlmaierTheme.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Inscriptions en attente',
        showLogo: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadPendingUsers,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Erreur: $_error',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadPendingUsers,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                : _pendingUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 80,
                              color: DraexlmaierTheme.completedColor,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Aucune inscription en attente',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Toutes les inscriptions ont été traitées',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _pendingUsers.length,
                        itemBuilder: (context, index) {
                          final user = _pendingUsers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12.0),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16.0),
                              leading: CircleAvatar(
                                radius: 28,
                                backgroundColor: DraexlmaierTheme.primaryBlue,
                                child: Text(
                                  user.firstname[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              title: Text(
                                user.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(user.email),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (user.position != null) ...[
                                        Chip(
                                          label: Text(
                                            user.position ?? '',
                                            style: const TextStyle(fontSize: 11),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                      if (user.department != null)
                                        Chip(
                                          label: Text(
                                            user.department ?? '',
                                            style: const TextStyle(fontSize: 11),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () => _showUserDetails(user),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
