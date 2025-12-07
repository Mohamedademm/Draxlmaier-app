# 🔧 Guide Complet - Activer Google Sign-In

## ✅ Étape 1 : Créer un Projet Google Cloud Console

### 1.1 Aller sur Google Cloud Console
```
https://console.cloud.google.com/
```

### 1.2 Créer un nouveau projet
1. Cliquer sur **"Select a project"** en haut
2. Cliquer sur **"NEW PROJECT"**
3. Nom du projet : `Draxlmaier App`
4. Cliquer sur **"CREATE"**
5. Attendre 30 secondes que le projet soit créé
6. ✅ Sélectionner le projet créé

---

## ✅ Étape 2 : Activer l'API Google Sign-In

### 2.1 Aller dans APIs & Services
1. Menu hamburger (☰) en haut à gauche
2. Cliquer sur **"APIs & Services"**
3. Cliquer sur **"Library"**

### 2.2 Activer Google Sign-In API
1. Dans la barre de recherche, taper : `Google Sign-In`
2. Cliquer sur **"Google+ API"**
3. Cliquer sur **"ENABLE"**
4. Attendre 10 secondes
5. ✅ L'API est activée

---

## ✅ Étape 3 : Créer OAuth 2.0 Client ID pour Web

### 3.1 Configurer l'écran de consentement OAuth
1. Aller dans **"APIs & Services"** > **"OAuth consent screen"**
2. Choisir **"External"**
3. Cliquer sur **"CREATE"**
4. Remplir les informations :
   ```
   App name: Draxlmaier Communication App
   User support email: [votre email]
   Developer contact: [votre email]
   ```
5. Cliquer sur **"SAVE AND CONTINUE"**
6. Scopes : Cliquer sur **"SAVE AND CONTINUE"** (garder par défaut)
7. Test users : Cliquer sur **"SAVE AND CONTINUE"**
8. ✅ Écran de consentement configuré

### 3.2 Créer les Credentials OAuth
1. Aller dans **"APIs & Services"** > **"Credentials"**
2. Cliquer sur **"+ CREATE CREDENTIALS"**
3. Choisir **"OAuth client ID"**
4. Type d'application : **"Web application"**
5. Nom : `Draxlmaier Web Client`

### 3.3 Configurer les URIs autorisés
**Origines JavaScript autorisées :**
```
http://localhost:8080
http://localhost:3000
http://127.0.0.1:8080
```

**URIs de redirection autorisés :**
```
http://localhost:8080
http://localhost:8080/auth/callback
```

6. Cliquer sur **"CREATE"**
7. ✅ **COPIER LE CLIENT ID** (format: `123456789-abc.apps.googleusercontent.com`)
8. **Conserver cette fenêtre ouverte** pour copier le Client ID

---

## ✅ Étape 4 : Configurer l'Application Flutter

### 4.1 Mettre à jour web/index.html

**Fichier** : `web/index.html`

Remplacer la ligne :
```html
<meta name="google-signin-client_id" content="YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com">
```

Par (avec votre vrai Client ID) :
```html
<meta name="google-signin-client_id" content="123456789-abc.apps.googleusercontent.com">
```

### 4.2 Réactiver le bouton Google dans login_screen.dart

**Fichier** : `lib/screens/login_screen.dart`

Trouver cette ligne (vers ligne 235) :
```dart
const SizedBox(height: 24),
```

Remplacer par :
```dart
const SizedBox(height: 16),

// Divider
Row(
  children: [
    Expanded(child: Divider(color: Colors.grey[300])),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'OU',
        style: TextStyle(color: Colors.grey[600]),
      ),
    ),
    Expanded(child: Divider(color: Colors.grey[300])),
  ],
),
const SizedBox(height: 16),

// Google Sign In button
OutlinedButton.icon(
  onPressed: _handleGoogleSignIn,
  style: OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 12),
    side: BorderSide(color: Colors.grey[300]!),
  ),
  icon: const Icon(Icons.g_mobiledata, size: 24, color: Colors.red),
  label: const Text(
    'Continuer avec Google',
    style: TextStyle(fontSize: 14, color: Colors.black87),
  ),
),
const SizedBox(height: 24),
```

---

## ✅ Étape 5 : Redémarrer l'Application

### 5.1 Arrêter Flutter
Dans le terminal PowerShell où Flutter tourne :
- Appuyer sur **Q** ou **Ctrl+C**

### 5.2 Relancer Flutter
```powershell
flutter run -d chrome --web-port 8080
```

### 5.3 Attendre la compilation
- Attendre environ 1-2 minutes
- ✅ L'application s'ouvre dans Chrome

---

## ✅ Étape 6 : Tester Google Sign-In

### 6.1 Ouvrir l'application
```
http://localhost:8080/#/login
```

### 6.2 Cliquer sur "Continuer avec Google"
1. Une popup Google s'ouvre
2. Sélectionner votre compte Google
3. Autoriser l'application
4. ✅ **Vous êtes connecté automatiquement !**

---

## 🎯 Résumé des Étapes

```
1. Google Cloud Console → Créer projet "Draxlmaier App"
2. Activer "Google+ API"
3. Configurer OAuth consent screen
4. Créer OAuth Client ID (Web)
5. Copier le Client ID
6. Mettre à jour web/index.html avec le Client ID
7. Réactiver le bouton dans login_screen.dart
8. Redémarrer Flutter
9. Tester la connexion Google ✅
```

---

## 📋 Checklist Rapide

- [ ] Projet créé sur Google Cloud Console
- [ ] Google+ API activée
- [ ] OAuth consent screen configuré
- [ ] OAuth Client ID créé (Web)
- [ ] Client ID copié
- [ ] web/index.html mis à jour avec le vrai Client ID
- [ ] login_screen.dart mis à jour (bouton réactivé)
- [ ] Flutter redémarré
- [ ] Application testée
- [ ] ✅ Google Sign-In fonctionne !

---

## ⏱️ Temps Estimé

- **Étape 1-3** : 5-7 minutes (Configuration Google Cloud)
- **Étape 4** : 2 minutes (Modifier les fichiers)
- **Étape 5** : 2 minutes (Redémarrer Flutter)
- **Étape 6** : 1 minute (Tester)

**Total** : ~10-15 minutes

---

## 🎨 Ce que Vous Verrez

### Avant Configuration
```
┌─────────────────────┐
│  [Logo]             │
│  Email              │
│  Password           │
│  [Login]            │
│  S'inscrire         │
└─────────────────────┘
```

### Après Configuration
```
┌─────────────────────┐
│  [Logo]             │
│  Email              │
│  Password           │
│  [Login]            │
│  ─── OU ───         │
│  [G] Continuer      │
│      avec Google    │
│  S'inscrire         │
└─────────────────────┘
```

---

## 🔐 Sécurité

### Variables d'Environnement (Production)

Pour la production, ne mettez pas le Client ID en dur. Utilisez :

**Fichier** : `.env` (à créer à la racine)
```
GOOGLE_CLIENT_ID=123456789-abc.apps.googleusercontent.com
```

**Puis dans le code** :
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

final clientId = dotenv.env['GOOGLE_CLIENT_ID'];
```

---

## ❓ FAQ

### Q: Où trouver mon Client ID ?
**R:** Google Cloud Console > APIs & Services > Credentials > Votre OAuth 2.0 Client ID

### Q: L'erreur 401 persiste ?
**R:** Vérifiez que :
1. Le Client ID dans `web/index.html` est correct
2. `http://localhost:8080` est dans les origines JavaScript autorisées
3. Vous avez redémarré Flutter après les modifications

### Q: La popup Google ne s'ouvre pas ?
**R:** 
1. Vérifiez que le Client ID est correctement configuré
2. Videz le cache du navigateur (Ctrl+Shift+Delete)
3. Essayez en mode incognito

### Q: "redirect_uri_mismatch" ?
**R:** Ajoutez `http://localhost:8080` dans les URIs de redirection autorisés

### Q: Faut-il un domaine vérifié ?
**R:** Non pour localhost. Oui pour déployer en production sur un domaine public.

---

## 🚀 Alternative : Sans Configuration Google

**En attendant de configurer Google**, utilisez :

```
📧 admin@draxlmaier.com
🔑 admin123
```

Ou créez votre propre compte avec l'inscription (mot de passe simple accepté).

---

## 📞 Support

Si vous rencontrez des problèmes :

1. **Vérifier les logs** : Console Chrome (F12)
2. **Vérifier le backend** : Terminal backend doit afficher "✅ Server running"
3. **Vérifier Flutter** : Aucune erreur de compilation

---

**Suivez ces étapes dans l'ordre et Google Sign-In fonctionnera parfaitement ! 🎉**

**Date** : 6 décembre 2025  
**Temps estimé** : 10-15 minutes  
**Difficulté** : Facile (suivez le guide étape par étape)
