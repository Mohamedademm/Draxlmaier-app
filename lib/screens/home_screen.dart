import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/location_provider.dart';
import '../utils/app_localizations.dart';
import '../widgets/modern_layout.dart';
import 'dashboard_screen.dart';
import 'department_group_list_screen.dart';
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
    
    // Initialize socket connection
    await chatProvider.initializeSocket();
    
    // Initialize notifications
    await notificationProvider.initialize();
    
    // Location permission removed - not required for app functionality
  }

  /// Get pages based on user role
  List<Widget> _getPages() {
    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.canManageUsers) {
      // Admin/Manager view
      return [
        const DashboardScreen(),
        const DepartmentGroupListScreen(),
        const ProfileScreen(),
      ];
    } else {
      // Employee view
      return [
        const DashboardScreen(),
        const DepartmentGroupListScreen(),
        const ProfileScreen(),
      ];
    }
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
    final localizations = AppLocalizations.of(context)!;
    
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
        icon: Icons.person_outline,
        label: localizations.translate('profile'),
      ),
    ];
    
    return items;
  }
}
