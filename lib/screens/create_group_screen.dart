import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../models/chat_group_model.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../services/chat_service.dart';
import '../theme/draexlmaier_theme.dart';

/// Create Group Screen
/// Allows managers to create custom chat groups and add employees
class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _chatService = ChatService();
  
  final List<String> _selectedMemberIds = [];
  bool _isLoading = false;

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
  void dispose() {
    _groupNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMemberIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un membre'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final group = await _chatService.createChatGroup(
        name: _groupNameController.text.trim(),
        memberIds: _selectedMemberIds,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Groupe "${group.name}" créé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleMemberSelection(String userId) {
    setState(() {
      if (_selectedMemberIds.contains(userId)) {
        _selectedMemberIds.remove(userId);
      } else {
        _selectedMemberIds.add(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un groupe'),
        backgroundColor: DraexlmaierTheme.primaryBlue,
      ),
      body: Consumer2<UserProvider, AuthProvider>(
        builder: (context, userProvider, authProvider, _) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Get all users except the current user
          final currentUserId = authProvider.currentUser?.id;
          final availableUsers = userProvider.users
              .where((user) => user.id != currentUserId)
              .toList();

          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Group Name
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Informations du groupe',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _groupNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nom du groupe',
                                    prefixIcon: Icon(Icons.group),
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Veuillez entrer un nom de groupe';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _descriptionController,
                                  decoration: const InputDecoration(
                                    labelText: 'Description (optionnelle)',
                                    prefixIcon: Icon(Icons.description),
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Members Selection
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Sélectionner des membres',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Chip(
                                      label: Text('${_selectedMemberIds.length} sélectionné(s)'),
                                      backgroundColor: DraexlmaierTheme.secondaryBlue.withOpacity(0.2),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                if (availableUsers.isEmpty)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Text('Aucun utilisateur disponible'),
                                    ),
                                  )
                                else
                                  ...availableUsers.map((user) {
                                    final isSelected = _selectedMemberIds.contains(user.id);
                                    return CheckboxListTile(
                                      value: isSelected,
                                      onChanged: (_) => _toggleMemberSelection(user.id),
                                      title: Text('${user.firstname} ${user.lastname}'),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(user.email),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Chip(
                                                label: Text(
                                                  user.role.name.toUpperCase(),
                                                  style: const TextStyle(fontSize: 10),
                                                ),
                                                padding: EdgeInsets.zero,
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                              if (user.department != null) ...[
                                                const SizedBox(width: 8),
                                                Chip(
                                                  label: Text(
                                                    user.department!,
                                                    style: const TextStyle(fontSize: 10),
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                      secondary: CircleAvatar(
                                        backgroundColor: isSelected 
                                            ? DraexlmaierTheme.primaryBlue 
                                            : Colors.grey,
                                        child: Text(
                                          user.firstname[0],
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      activeColor: DraexlmaierTheme.primaryBlue,
                                    );
                                  }).toList(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Create Button
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _createGroup,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.group_add),
                      label: Text(_isLoading ? 'Création...' : 'Créer le groupe'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DraexlmaierTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
