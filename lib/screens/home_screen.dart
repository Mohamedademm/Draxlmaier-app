import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/location_provider.dart';
import '../providers/objective_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/stat_card.dart';
import '../widgets/objective_card.dart';
import '../theme/draexlmaier_theme.dart';
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
class _DashboardPage extends StatefulWidget {
  @override
  State<_DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<_DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final objectiveProvider = context.read<ObjectiveProvider>();
      objectiveProvider.fetchMyObjectives();
      objectiveProvider.fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Dashboard',
        showLogo: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final objectiveProvider = context.read<ObjectiveProvider>();
          await objectiveProvider.fetchMyObjectives();
          await objectiveProvider.fetchStats();
        },
        child: authProvider.canManageUsers
            ? _buildManagerDashboard(context)
            : _buildEmployeeDashboard(context),
      ),
    );
  }

  Widget _buildEmployeeDashboard(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final objectiveProvider = context.watch<ObjectiveProvider>();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Text(
            'Bienvenue, ${authProvider.currentUser?.firstname ?? 'User'}!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Voici un aperçu de vos objectifs',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),

          // Statistics Cards
          if (objectiveProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                StatCard(
                  title: 'Total',
                  value: objectiveProvider.stats['total'].toString(),
                  icon: Icons.assignment,
                  color: DraexlmaierTheme.primaryBlue,
                  onTap: () => Navigator.pushNamed(context, '/objectives'),
                ),
                StatCard(
                  title: 'Terminés',
                  value: objectiveProvider.stats['completed'].toString(),
                  icon: Icons.check_circle,
                  color: DraexlmaierTheme.completedColor,
                ),
                StatCard(
                  title: 'En cours',
                  value: objectiveProvider.stats['inProgress'].toString(),
                  icon: Icons.hourglass_empty,
                  color: DraexlmaierTheme.inProgressColor,
                ),
                StatCard(
                  title: 'En retard',
                  value: objectiveProvider.stats['overdue'].toString(),
                  icon: Icons.warning,
                  color: DraexlmaierTheme.accentRed,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Objectives
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Objectifs récents',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/objectives'),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (objectiveProvider.objectives.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun objectif pour le moment',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vos objectifs apparaîtront ici une fois assignés',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...objectiveProvider.objectives.take(3).map((objective) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ObjectiveCard(
                    objective: objective,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/objective-detail',
                        arguments: objective.id,
                      );
                    },
                  ),
                );
              }).toList(),
          ],

          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Actions rapides',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildActionCard(
                context,
                icon: Icons.chat,
                title: 'Messages',
                color: DraexlmaierTheme.secondaryBlue,
                onTap: () => Navigator.pushNamed(context, Routes.chatList),
              ),
              _buildActionCard(
                context,
                icon: Icons.notifications,
                title: 'Notifications',
                color: Colors.orange,
                onTap: () => Navigator.pushNamed(context, Routes.notifications),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManagerDashboard(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final objectiveProvider = context.watch<ObjectiveProvider>();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Text(
            'Bienvenue, ${authProvider.currentUser?.firstname ?? 'Manager'}!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tableau de bord Manager',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),

          // Management Cards
          Card(
            color: DraexlmaierTheme.primaryBlue,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/pending-users');
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.person_add, color: Colors.white, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Inscriptions en attente',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Valider les nouveaux employés',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            color: DraexlmaierTheme.accentRed,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/manager-objectives');
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.add_task, color: Colors.white, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gérer les objectifs',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Créer et assigner des objectifs',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            color: DraexlmaierTheme.secondaryBlue,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/department-chat');
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.group_outlined, color: Colors.white, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Chat de Département',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Communiquer avec l\'équipe',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Team Statistics
          Text(
            'Statistiques de l\'équipe',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          if (objectiveProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                StatCard(
                  title: 'Objectifs',
                  value: objectiveProvider.stats['total'].toString(),
                  icon: Icons.assignment,
                  color: DraexlmaierTheme.primaryBlue,
                ),
                StatCard(
                  title: 'Terminés',
                  value: objectiveProvider.stats['completed'].toString(),
                  icon: Icons.check_circle,
                  color: DraexlmaierTheme.completedColor,
                ),
                StatCard(
                  title: 'En cours',
                  value: objectiveProvider.stats['inProgress'].toString(),
                  icon: Icons.hourglass_empty,
                  color: DraexlmaierTheme.inProgressColor,
                ),
                StatCard(
                  title: 'Bloqués',
                  value: objectiveProvider.stats['blocked'].toString(),
                  icon: Icons.block,
                  color: DraexlmaierTheme.blockedColor,
                ),
              ],
            ),

          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Actions rapides',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildActionCard(
                context,
                icon: Icons.map,
                title: 'Carte',
                color: Colors.green,
                onTap: () => Navigator.pushNamed(context, Routes.map),
              ),
              _buildActionCard(
                context,
                icon: Icons.people,
                title: 'Utilisateurs',
                color: Colors.purple,
                onTap: () => Navigator.pushNamed(context, Routes.userManagement),
              ),
              _buildActionCard(
                context,
                icon: Icons.chat,
                title: 'Messages',
                color: DraexlmaierTheme.secondaryBlue,
                onTap: () => Navigator.pushNamed(context, Routes.chatList),
              ),
              _buildActionCard(
                context,
                icon: Icons.notifications,
                title: 'Notifications',
                color: Colors.orange,
                onTap: () => Navigator.pushNamed(context, Routes.notifications),
              ),
            ],
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
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
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
          
          // Edit Profile button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, Routes.editProfile);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Modifier le profil'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 8),
          
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
