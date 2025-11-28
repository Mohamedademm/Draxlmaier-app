import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/location_provider.dart';
import '../utils/constants.dart';
import '../utils/app_localizations.dart';

/// Home screen with bottom navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  /// Initialize services when home screen loads
  Future<void> _initializeServices() async {
    final chatProvider = context.read<ChatProvider>();
    final notificationProvider = context.read<NotificationProvider>();
    final locationProvider = context.read<LocationProvider>();
    
    // Initialize socket connection
    await chatProvider.initializeSocket();
    
    // Initialize notifications
    await notificationProvider.initialize();
    
    // Request location permission
    await locationProvider.requestPermission();
  }

  /// Get pages based on user role
  List<Widget> _getPages() {
    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.canManageUsers) {
      // Admin/Manager view
      return [
        _buildDashboardPage(),
        _buildChatPage(),
        _buildNotificationsPage(),
        _buildMapPage(),
        _buildProfilePage(),
      ];
    } else {
      // Employee view
      return [
        _buildDashboardPage(),
        _buildChatPage(),
        _buildNotificationsPage(),
        _buildProfilePage(),
      ];
    }
  }

  /// Get navigation items based on user role
  List<BottomNavigationBarItem> _getNavigationItems() {
    final authProvider = context.read<AuthProvider>();
    final localizations = AppLocalizations.of(context)!;
    
    final items = [
      BottomNavigationBarItem(
        icon: const Icon(Icons.dashboard),
        label: localizations.translate('home'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.chat),
        label: localizations.translate('chats'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.notifications),
        label: localizations.translate('notifications'),
      ),
    ];
    
    if (authProvider.canManageUsers) {
      items.add(
        BottomNavigationBarItem(
          icon: const Icon(Icons.map),
          label: localizations.translate('map'),
        ),
      );
    }
    
    items.add(
      BottomNavigationBarItem(
        icon: const Icon(Icons.person),
        label: localizations.translate('profile'),
      ),
    );
    
    return items;
  }

  Widget _buildDashboardPage() {
    return _DashboardPage();
  }

  Widget _buildChatPage() {
    return Container(
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, Routes.chatList);
          },
          child: const Text('Go to Chats'),
        ),
      ),
    );
  }

  Widget _buildNotificationsPage() {
    return Container(
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, Routes.notifications);
          },
          child: const Text('View Notifications'),
        ),
      ),
    );
  }

  Widget _buildMapPage() {
    return Container(
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, Routes.map);
          },
          child: const Text('View Team Map'),
        ),
      ),
    );
  }

  Widget _buildProfilePage() {
    return _ProfilePage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _getPages(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _getNavigationItems(),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

/// Dashboard page widget
class _DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${authProvider.currentUser?.firstname ?? 'User'}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            
            if (authProvider.canManageUsers)
              _buildAdminCard(context),
            
            const SizedBox(height: 16),
            _buildQuickActionsGrid(context, authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.admin_panel_settings, color: Colors.blue),
        title: const Text('Admin Dashboard'),
        subtitle: const Text('Manage users and system'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.pushNamed(context, Routes.adminDashboard);
        },
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, AuthProvider authProvider) {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildActionCard(
            context,
            icon: Icons.chat,
            title: 'Messages',
            color: Colors.blue,
            onTap: () => Navigator.pushNamed(context, Routes.chatList),
          ),
          _buildActionCard(
            context,
            icon: Icons.notifications,
            title: 'Notifications',
            color: Colors.orange,
            onTap: () => Navigator.pushNamed(context, Routes.notifications),
          ),
          if (authProvider.canManageUsers)
            _buildActionCard(
              context,
              icon: Icons.map,
              title: 'Team Map',
              color: Colors.green,
              onTap: () => Navigator.pushNamed(context, Routes.map),
            ),
          if (authProvider.canManageUsers)
            _buildActionCard(
              context,
              icon: Icons.people,
              title: 'Users',
              color: Colors.purple,
              onTap: () => Navigator.pushNamed(context, Routes.userManagement),
            ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Profile page widget
class _ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    child: Text(
                      user?.firstname[0] ?? 'U',
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.fullName ?? 'User',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(user?.role.name.toUpperCase() ?? 'EMPLOYEE'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Logout button
          ElevatedButton.icon(
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, Routes.login);
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
