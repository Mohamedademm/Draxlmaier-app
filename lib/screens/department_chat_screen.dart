import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_group_model.dart';
import '../services/chat_service.dart';
import '../providers/auth_provider.dart';
import 'group_chat_screen.dart';

/// Department Chat Screen Wrapper
/// Loads the department group and then delegates to GroupChatScreen
class DepartmentChatScreen extends StatefulWidget {
  const DepartmentChatScreen({super.key});

  @override
  State<DepartmentChatScreen> createState() => _DepartmentChatScreenState();
}

class _DepartmentChatScreenState extends State<DepartmentChatScreen> {
  final ChatService _chatService = ChatService();
  ChatGroup? _departmentGroup;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDepartmentGroup();
  }

  Future<void> _loadDepartmentGroup() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1. Get the department group
      final group = await _chatService.getDepartmentGroup();
      
      // 2. Ensure current user is in the group (optional, but good for safety)
      final currentUser = context.read<AuthProvider>().currentUser;
      if (currentUser != null && !group.members.contains(currentUser.id)) {
        // Just in case backend didn't add them, we could optionally add them here or just proceed.
        // Usually getDepartmentGroup returns the group the user belongs to.
      }

      setState(() {
        _departmentGroup = group;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Département')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Département')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Erreur: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDepartmentGroup,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_departmentGroup == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Département')),
        body: const Center(child: Text('Aucun groupe de département trouvé.')),
      );
    }

    // Delegate to the full-featured GroupChatScreen
    return GroupChatScreen(group: _departmentGroup!);
  }
}
