import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/location_provider.dart';
import 'providers/user_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/team_provider.dart';
import 'providers/objective_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/matricule_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/chat_detail_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/map_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/user_management_screen.dart';
import 'screens/pending_users_screen.dart';
import 'screens/objective_detail_screen.dart';
import 'screens/manager_objectives_dashboard_screen.dart';
import 'screens/department_group_list_screen.dart';
import 'screens/debug_user_creation_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/theme_customization_screen.dart';
import 'screens/matricule_management_screen.dart';
import 'screens/matricule_registration_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/pending_approval_screen.dart';
import 'screens/admin/admin_departments_screen.dart';
import 'theme/modern_theme.dart';
import 'utils/constants.dart';
import 'utils/app_localizations.dart';
import 'utils/animations.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase ONLY on mobile (Android/iOS), not on web
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
      
      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      
      // Initialize notification service
      final notificationService = NotificationService();
      await notificationService.initialize();
      
      // Request notification permission
      await notificationService.requestPermission();
      
      // Get and send FCM token to backend
      final token = await notificationService.getFcmToken();
      if (token != null) {
        // Token will be sent to backend after login
        debugPrint('FCM Token obtained');
      }
    } catch (e) {
      debugPrint('Firebase initialization error: $e');
    }
  }
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Open boxes (we will register adapters later)
  await Hive.openBox('settings');
  await Hive.openBox('cache');
  
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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MatriculeProvider()),
      ],
      child: Consumer3<AuthProvider, LocaleProvider, ThemeProvider>(
        builder: (context, authProvider, localeProvider, themeProvider, _) {
          return MaterialApp(
            title: 'Draexlmaier',
            debugShowCheckedModeBanner: false,
            theme: ModernTheme.dynamicTheme(
              context, 
              themeProvider.primaryColor, 
              themeProvider.accentColor, 
              false
            ),
            darkTheme: ModernTheme.darkTheme(
              context, 
              primary: themeProvider.primaryColor, 
              secondary: themeProvider.accentColor, 
            ),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
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
              Routes.chatList: (context) => const DepartmentGroupListScreen(),
              Routes.notifications: (context) => const NotificationsScreen(),
              Routes.map: (context) => const MapScreen(),
              Routes.adminDashboard: (context) => const AdminDashboardScreen(),
              Routes.userManagement: (context) => const UserManagementScreen(),
              Routes.debugUserCreation: (context) => const DebugUserCreationScreen(),
              Routes.editProfile: (context) => const EditProfileScreen(),
              Routes.themeCustomization: (context) => const ThemeCustomizationScreen(),
              Routes.matriculeManagement: (context) => const MatriculeManagementScreen(),
              Routes.pendingUsers: (context) => const PendingUsersScreen(),
              Routes.managerObjectives: (context) => const ManagerObjectivesDashboardScreen(),
              Routes.departmentGroups: (context) => const DepartmentGroupListScreen(),
              Routes.adminDepartments: (context) => const AdminDepartmentsScreen(),
              Routes.settings: (context) => const SettingsScreen(),
              Routes.matriculeRegistration: (context) => const MatriculeRegistrationScreen(),
              Routes.pendingApproval: (context) => const PendingApprovalScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == Routes.chatDetail) {
                final args = settings.arguments as Map<String, dynamic>?;
                return PageTransitions.slideFadeTransition(
                  ChatDetailScreen(
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
                  return PageTransitions.slideFadeTransition(
                    ObjectiveDetailScreen(objectiveId: objectiveId),
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
