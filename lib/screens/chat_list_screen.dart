import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/modern_theme.dart';
import '../widgets/modern_widgets.dart';
import '../utils/constants.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: ModernAppBar(
        title: 'Messages',
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: () {
              Navigator.pushNamed(context, Routes.departmentGroups);
            },
            tooltip: 'Groupes de département',
          ),
        ],
      ),
      body: Center(
        child: EmptyState(
          icon: Icons.chat_bubble_outline,
          title: 'Messages',
          message: 'Fonctionnalité de chat en développement',
          action: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, Routes.departmentGroups);
            },
            icon: const Icon(Icons.group),
            label: const Text('Voir les groupes de département'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
      ),
    );
  }
}
