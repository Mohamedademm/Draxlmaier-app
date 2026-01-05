import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/skeleton_loader.dart';
import '../utils/animations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    
    if (user == null) {
      return const Scaffold(
        body: SafeArea(child: SkeletonProfile()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User info card
          AppAnimations.staggeredList(
            index: 0,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: user.profileImage != null && user.profileImage!.isNotEmpty
                          ? (user.profileImage!.startsWith('data:image')
                              ? MemoryImage(
                                  base64Decode(user.profileImage!.split(',').last),
                                ) as ImageProvider
                              : NetworkImage(user.profileImage!))
                          : null,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: user.profileImage == null || user.profileImage!.isEmpty
                          ? Text(
                              user.firstname[0].toUpperCase(),
                              style: const TextStyle(fontSize: 32, color: Colors.white),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.fullName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(user.role.name.toUpperCase()),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Edit Profile button
          AppAnimations.staggeredList(
            index: 1,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, Routes.editProfile);
              },
              icon: const Icon(Icons.edit),
              label: const Text('Modifier le profil'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Settings button
          AppAnimations.staggeredList(
            index: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, Routes.settings);
              },
              icon: const Icon(Icons.settings),
              label: const Text('Paramètres'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Logout button
          AppAnimations.staggeredList(
            index: 3,
            child: ElevatedButton.icon(
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, Routes.login);
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Déconnexion'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
