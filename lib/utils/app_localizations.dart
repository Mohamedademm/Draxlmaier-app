import 'package:flutter/material.dart';

/// App Localizations Delegate
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // General
      'app_name': 'Employee Communication',
      'welcome': 'Welcome',
      'loading': 'Loading...',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'search': 'Search',
      'refresh': 'Refresh',
      'send': 'Send',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      
      // Auth
      'login': 'Login',
      'logout': 'Logout',
      'email': 'Email',
      'password': 'Password',
      'sign_in': 'Sign In',
      'sign_in_to_continue': 'Sign in to continue',
      'invalid_credentials': 'Invalid credentials',
      'login_success': 'Login successful',
      
      // Navigation
      'home': 'Home',
      'chats': 'Chats',
      'notifications': 'Notifications',
      'map': 'Map',
      'profile': 'Profile',
      'settings': 'Settings',
      
      // Dashboard
      'admin_dashboard': 'Admin Dashboard',
      'total_users': 'Total Users',
      'active_users': 'Active Users',
      'unread': 'Unread',
      'quick_actions': 'Quick Actions',
      'user_management': 'User Management',
      'add_edit_remove_users': 'Add, edit, or remove users',
      'send_notification': 'Send Notification',
      'broadcast_message': 'Broadcast message to employees',
      'view_team_map': 'View Team Map',
      'see_employee_locations': 'See employee locations',
      
      // Users
      'users': 'Users',
      'add_user': 'Add User',
      'first_name': 'First Name',
      'last_name': 'Last Name',
      'role': 'Role',
      'status': 'Status',
      'active': 'Active',
      'inactive': 'Inactive',
      'admin': 'Admin',
      'manager': 'Manager',
      'employee': 'Employee',
      
      // Messages
      'messages': 'Messages',
      'new_message': 'New Message',
      'type_message': 'Type a message...',
      'no_messages': 'No messages yet',
      'conversations': 'Conversations',
      
      // Notifications
      'no_notifications': 'No notifications',
      'notification_title': 'Title',
      'notification_message': 'Message',
      'target_users': 'Target Users',
      'send_to_all': 'Send to all users',
      
      // Location
      'my_location': 'My Location',
      'team_locations': 'Team Locations',
      'location_not_available': 'Location not available on web',
      
      // Errors
      'error': 'Error',
      'something_went_wrong': 'Something went wrong',
      'network_error': 'Network error',
      'try_again': 'Try again',
    },
    'fr': {
      // Général
      'app_name': 'Communication Employés',
      'welcome': 'Bienvenue',
      'loading': 'Chargement...',
      'save': 'Enregistrer',
      'cancel': 'Annuler',
      'delete': 'Supprimer',
      'edit': 'Modifier',
      'search': 'Rechercher',
      'refresh': 'Actualiser',
      'send': 'Envoyer',
      'ok': 'OK',
      'yes': 'Oui',
      'no': 'Non',
      
      // Authentification
      'login': 'Connexion',
      'logout': 'Déconnexion',
      'email': 'Email',
      'password': 'Mot de passe',
      'sign_in': 'Se connecter',
      'sign_in_to_continue': 'Connectez-vous pour continuer',
      'invalid_credentials': 'Identifiants invalides',
      'login_success': 'Connexion réussie',
      
      // Navigation
      'home': 'Accueil',
      'chats': 'Discussions',
      'notifications': 'Notifications',
      'map': 'Carte',
      'profile': 'Profil',
      'settings': 'Paramètres',
      
      // Tableau de bord
      'admin_dashboard': 'Tableau de bord Admin',
      'total_users': 'Utilisateurs totaux',
      'active_users': 'Utilisateurs actifs',
      'unread': 'Non lus',
      'quick_actions': 'Actions rapides',
      'user_management': 'Gestion des utilisateurs',
      'add_edit_remove_users': 'Ajouter, modifier ou supprimer des utilisateurs',
      'send_notification': 'Envoyer une notification',
      'broadcast_message': 'Diffuser un message aux employés',
      'view_team_map': 'Voir la carte d\'équipe',
      'see_employee_locations': 'Voir les emplacements des employés',
      
      // Utilisateurs
      'users': 'Utilisateurs',
      'add_user': 'Ajouter un utilisateur',
      'first_name': 'Prénom',
      'last_name': 'Nom',
      'role': 'Rôle',
      'status': 'Statut',
      'active': 'Actif',
      'inactive': 'Inactif',
      'admin': 'Administrateur',
      'manager': 'Manager',
      'employee': 'Employé',
      
      // Messages
      'messages': 'Messages',
      'new_message': 'Nouveau message',
      'type_message': 'Tapez un message...',
      'no_messages': 'Aucun message',
      'conversations': 'Conversations',
      
      // Notifications
      'no_notifications': 'Aucune notification',
      'notification_title': 'Titre',
      'notification_message': 'Message',
      'target_users': 'Utilisateurs cibles',
      'send_to_all': 'Envoyer à tous',
      
      // Localisation
      'my_location': 'Ma position',
      'team_locations': 'Positions de l\'équipe',
      'location_not_available': 'Localisation non disponible sur web',
      
      // Erreurs
      'error': 'Erreur',
      'something_went_wrong': 'Une erreur s\'est produite',
      'network_error': 'Erreur réseau',
      'try_again': 'Réessayer',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Getters for common translations
  String get appName => translate('app_name');
  String get welcome => translate('welcome');
  String get loading => translate('loading');
  String get login => translate('login');
  String get email => translate('email');
  String get password => translate('password');
  String get home => translate('home');
  String get chats => translate('chats');
  String get notifications => translate('notifications');
  String get adminDashboard => translate('admin_dashboard');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
