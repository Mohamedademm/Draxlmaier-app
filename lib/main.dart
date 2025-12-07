import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/location_provider.dart';
import 'providers/user_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/team_provider.dart';
import 'providers/objective_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/chat_detail_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/map_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/user_management_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/pending_users_screen.dart';
import 'screens/objectives_screen.dart';
import 'screens/objective_detail_screen.dart';
import 'screens/manager_objectives_screen.dart';
import 'screens/department_chat_screen.dart';
import 'screens/debug_user_creation_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'theme/draexlmaier_theme.dart';
import 'utils/constants.dart';
import 'utils/app_localizations.dart';

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
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
        ChangeNotifierProvider(create: (_) => ObjectiveProvider()),
      ],
      child: Consumer2<AuthProvider, LocaleProvider>(
        builder: (context, authProvider, localeProvider, _) {
          return MaterialApp(
            title: 'Draexlmaier',
            debugShowCheckedModeBanner: false,
            theme: DraexlmaierTheme.lightTheme,
            darkTheme: DraexlmaierTheme.darkTheme,
            themeMode: ThemeMode.light,
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('fr', ''), // Français (par défaut)
              Locale('en', ''), // English
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
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
              Routes.debugUserCreation: (context) => const DebugUserCreationScreen(),
              Routes.editProfile: (context) => const EditProfileScreen(),
              '/registration': (context) => const RegistrationScreen(),
              '/pending-users': (context) => const PendingUsersScreen(),
              '/objectives': (context) => const ObjectivesScreen(),
              '/manager-objectives': (context) => const ManagerObjectivesScreen(),
              '/department-chat': (context) => const DepartmentChatScreen(),
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
              if (settings.name == '/objective-detail') {
                final objectiveId = settings.arguments as String?;
                if (objectiveId != null) {
                  return MaterialPageRoute(
                    builder: (context) => ObjectiveDetailScreen(objectiveId: objectiveId),
                  );
                }
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
