import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/location_provider.dart';
import '../utils/constants.dart';
import '../utils/app_localizations.dart';
import '../widgets/modern_layout.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';

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
        const DashboardScreen(),
        _buildChatPage(),
        _buildNotificationsPage(),
        _buildMapPage(),
        const ProfileScreen(),
      ];
    } else {
      // Employee view
      return [
        const DashboardScreen(),
        _buildChatPage(),
        _buildNotificationsPage(),
        const ProfileScreen(),
      ];
    }
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

  @override
  Widget build(BuildContext context) {
    return ModernMainLayout(
      currentIndex: _currentIndex,
      onNavigationChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: _getModernNavigationItems(),
      body: IndexedStack(
        index: _currentIndex,
        children: _getPages(),
      ),
    );
  }

  /// Get modern navigation items based on user role
  List<NavigationItem> _getModernNavigationItems() {
    final authProvider = context.read<AuthProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    final localizations = AppLocalizations.of(context)!;
    
    final unreadCount = notificationProvider.unreadCount;
    
    final items = [
      NavigationItem(
        icon: Icons.dashboard_outlined,
        label: localizations.translate('home'),
      ),
      NavigationItem(
        icon: Icons.chat_bubble_outline,
        label: localizations.translate('chats'),
      ),
      NavigationItem(
        icon: Icons.notifications_outlined,
        label: localizations.translate('notifications'),
        badgeCount: unreadCount > 0 ? unreadCount : null,
      ),
    ];
    
    if (authProvider.canManageUsers) {
      items.add(
        NavigationItem(
          icon: Icons.map_outlined,
          label: localizations.translate('map'),
        ),
      );
    }
    
    items.add(
      NavigationItem(
        icon: Icons.person_outline,
        label: localizations.translate('profile'),
      ),
    );
    
    return items;
  }
}
