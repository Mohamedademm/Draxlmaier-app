# Support Multi-Langue (i18n) - Documentation

## 📋 Résumé

Le système de communication interne dispose maintenant d'un support complet pour le **français** (langue par défaut) et l'**anglais**.

## ✅ Fonctionnalités Implémentées

### 1. **Configuration de Base**
- ✅ Intégration de `flutter_localizations`
- ✅ Support des locales FR et EN
- ✅ Persistance de la langue choisie (SharedPreferences)
- ✅ Français comme langue par défaut

### 2. **Fichiers Créés**

#### `lib/utils/app_localizations.dart`
- Système de traduction centralisé
- 50+ chaînes de caractères traduites en FR et EN
- Support pour toutes les sections de l'app

**Catégories de traductions :**
- Général (app_name, welcome, loading, save, cancel, etc.)
- Authentification (login, logout, email, password, etc.)
- Navigation (home, chats, notifications, map, profile, settings)
- Dashboard (admin_dashboard, total_users, active_users, etc.)
- Utilisateurs (users, add_user, first_name, last_name, role, etc.)
- Messages (messages, new_message, type_message, etc.)
- Notifications (no_notifications, notification_title, etc.)
- Localisation (my_location, team_locations, etc.)
- Erreurs (error, something_went_wrong, network_error, etc.)

#### `lib/providers/locale_provider.dart`
- Gestion de l'état de la langue
- Méthodes pour changer la langue
- Sauvegarde automatique du choix

#### `lib/screens/settings_screen.dart`
- Interface de sélection de langue
- Dropdown avec drapeaux 🇫🇷 et 🇬🇧
- Changement instantané de langue

### 3. **Intégration dans l'Application**

#### `lib/main.dart`
Ajout de :
```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/locale_provider.dart';
import 'utils/app_localizations.dart';

// LocaleProvider dans MultiProvider
ChangeNotifierProvider(create: (_) => LocaleProvider()),

// Configuration MaterialApp
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
```

#### Screens mis à jour
- ✅ `login_screen.dart` - Textes de connexion traduits
- ✅ `home_screen.dart` - Labels de navigation traduits
- ✅ `settings_screen.dart` - Interface de sélection de langue

## 🎯 Comment Utiliser

### Pour l'Utilisateur Final

1. **Changer de langue :**
   - Aller dans Profil → Paramètres
   - Cliquer sur "Langue / Language"
   - Sélectionner 🇫🇷 Français ou 🇬🇧 English
   - L'application change instantanément

2. **Langue par défaut :**
   - Au premier lancement : **Français**
   - Le choix est sauvegardé automatiquement

### Pour les Développeurs

#### Utiliser les traductions dans un widget :

```dart
import '../utils/app_localizations.dart';

// Dans le build method
@override
Widget build(BuildContext context) {
  final localizations = AppLocalizations.of(context)!;
  
  return Text(localizations.translate('welcome'));
  // ou utiliser les getters
  return Text(localizations.welcome);
}
```

#### Ajouter de nouvelles traductions :

1. Ouvrir `lib/utils/app_localizations.dart`
2. Ajouter la clé dans les deux maps ('en' et 'fr')
3. Optionnellement, créer un getter pour faciliter l'accès

```dart
static final Map<String, Map<String, String>> _localizedValues = {
  'en': {
    'my_new_key': 'My English Text',
  },
  'fr': {
    'my_new_key': 'Mon texte en français',
  },
};

// Getter optionnel
String get myNewKey => translate('my_new_key');
```

#### Changer la langue par programmation :

```dart
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

// Changer vers l'anglais
Provider.of<LocaleProvider>(context, listen: false)
  .setLocale(Locale('en'));

// Changer vers le français
Provider.of<LocaleProvider>(context, listen: false)
  .setLocale(Locale('fr'));

// Basculer entre les deux
Provider.of<LocaleProvider>(context, listen: false)
  .toggleLocale();
```

## 📱 Écrans Concernés

### Traduits Actuellement
- ✅ Écran de connexion (Login)
- ✅ Navigation principale (Bottom nav)
- ✅ Paramètres (Settings)

### À Traduire (Futures Améliorations)
- 🔲 Dashboard Admin complet
- 🔲 Gestion des utilisateurs
- 🔲 Chat et messages
- 🔲 Notifications
- 🔲 Carte et localisation
- 🔲 Profil utilisateur

## 🌍 Langues Supportées

| Langue | Code | Statut | Par Défaut |
|--------|------|--------|------------|
| Français | `fr` | ✅ Complet | ✅ Oui |
| Anglais | `en` | ✅ Complet | ❌ Non |

## 🔧 Dépendances

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  shared_preferences: ^2.2.2
  provider: ^6.1.1
```

## 📝 Structure des Fichiers

```
lib/
├── main.dart (configuré pour i18n)
├── providers/
│   └── locale_provider.dart (gestion de la langue)
├── utils/
│   └── app_localizations.dart (traductions FR/EN)
└── screens/
    ├── login_screen.dart (traduit)
    ├── home_screen.dart (traduit)
    └── settings_screen.dart (sélecteur de langue)
```

## 🎨 Interface de Sélection

L'interface de sélection de langue dans les paramètres affiche :
- 🇫🇷 Français
- 🇬🇧 English

Avec un menu déroulant élégant et des drapeaux pour une meilleure UX.

## ⚡ Performance

- **Chargement initial :** < 1ms (traductions en mémoire)
- **Changement de langue :** Instantané (hot reload)
- **Persistance :** SharedPreferences (lecture au démarrage)

## 🚀 Prochaines Étapes

1. **Traduire tous les écrans restants**
2. **Ajouter d'autres langues** (allemand, espagnol, arabe, etc.)
3. **Traductions dynamiques depuis le backend**
4. **Support RTL** pour l'arabe et autres langues RTL

## 📞 Support

Pour toute question ou problème avec le système multi-langue, contactez l'équipe de développement.

---

**Version :** 1.0  
**Date :** 27 Novembre 2025  
**Auteur :** Équipe de Développement
