import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/location_provider.dart';
import 'providers/user_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/chat_detail_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/map_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/user_management_screen.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'Employee Communication',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            initialRoute: Routes.splash,
            routes: {
              Routes.splash: (context) => const SplashScreen(),
              Routes.login: (context) => const LoginScreen(),
              Routes.home: (context) => const HomeScreen(),
              Routes.chatList: (context) => const ChatListScreen(),
              Routes.notifications: (context) => const NotificationsScreen(),
              Routes.map: (context) => const MapScreen(),
              Routes.adminDashboard: (context) => const AdminDashboardScreen(),
              Routes.userManagement: (context) => const UserManagementScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == Routes.chatDetail) {
                final args = settings.arguments as Map<String, dynamic>?;
                return MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(
                    chatId: args?['chatId'] ?? '',
                    recipientId: args?['recipientId'],
                    recipientName: args?['recipientName'] ?? 'Chat',
                    isGroupChat: args?['isGroupChat'] ?? false,
                  ),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
