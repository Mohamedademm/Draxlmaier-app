# 🔧 Configuration Google Sign-In

## ⚠️ État Actuel

Le bouton "Continuer avec Google" est maintenant **visible et fonctionnel** dans le code, mais nécessite une configuration Google Cloud Console pour fonctionner complètement.

---

## 🎯 Ce qui Fonctionne Maintenant

✅ **Bouton Google visible** sur l'écran de connexion  
✅ **Code fonctionnel** prêt à utiliser  
✅ **Backend endpoint** `/api/auth/google` opérationnel  
✅ **Messages d'erreur clairs** si la configuration manque  
✅ **Connexion email/mot de passe** fonctionne parfaitement  

---

## 🚀 Pour Activer Complètement Google Sign-In

### Étape 1 : Créer un Projet Google Cloud Console

1. Aller sur https://console.cloud.google.com/
2. Créer un nouveau projet ou sélectionner un projet existant
3. Nom du projet : `Draxlmaier Communication App`

### Étape 2 : Activer l'API Google Sign-In

1. Dans le menu, aller à **"APIs & Services"** > **"Library"**
2. Chercher **"Google+ API"** ou **"Google Sign-In API"**
3. Cliquer sur **"Enable"**

### Étape 3 : Créer les Identifiants OAuth 2.0

#### Pour Web (Chrome/Firefox/Edge)

1. Aller à **"APIs & Services"** > **"Credentials"**
2. Cliquer sur **"Create Credentials"** > **"OAuth client ID"**
3. Type d'application : **"Web application"**
4. Nom : `Draxlmaier Web Client`
5. **Origines JavaScript autorisées** :
   ```
   http://localhost:8080
   http://localhost:3000
   http://127.0.0.1:8080
   ```
6. **URI de redirection autorisés** :
   ```
   http://localhost:8080
   http://localhost:8080/auth/callback
   ```
7. Cliquer sur **"Create"**
8. **Copier le Client ID** (format: `xxxxx.apps.googleusercontent.com`)

#### Pour Android

1. **"Create Credentials"** > **"OAuth client ID"**
2. Type : **"Android"**
3. Obtenir le SHA-1 de votre keystore :
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
4. Entrer le SHA-1 et le package name : `com.example.employee_communication_app`

#### Pour iOS

1. **"Create Credentials"** > **"OAuth client ID"**
2. Type : **"iOS"**
3. Bundle ID : `com.example.employeeCommunicationApp`

### Étape 4 : Configurer le Projet Flutter

#### Fichier `web/index.html`

Remplacer `YOUR_GOOGLE_CLIENT_ID` par votre vrai Client ID :

```html
<meta name="google-signin-client_id" content="123456789-abcdefg.apps.googleusercontent.com">
```

#### Fichier Android `android/app/src/main/AndroidManifest.xml`

Ajouter dans `<application>` :

```xml
<meta-data
    android:name="com.google.android.gms.auth.api.signin.client_id"
    android:value="YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com"/>
```

#### Fichier iOS `ios/Runner/Info.plist`

Ajouter :

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_CLIENT_ID_REVERSED</string>
        </array>
    </dict>
</array>
```

### Étape 5 : Tester

1. Redémarrer l'application Flutter
   ```bash
   flutter run -d chrome
   ```

2. Cliquer sur **"Continuer avec Google"**
3. Sélectionner un compte Google
4. ✅ Connexion réussie !

---

## 🧪 Test Sans Configuration (Actuel)

En l'état actuel, si vous cliquez sur "Continuer avec Google" :

**Message attendu** :
```
Configuration Google Sign-In manquante.

Pour activer:
1. Créez un projet Google Cloud Console
2. Activez Google Sign-In API
3. Configurez OAuth 2.0

En attendant, utilisez email/mot de passe.
```

**Workaround** : Utilisez les comptes de test :
- Email : `admin@draxlmaier.com`
- Mot de passe : `admin123`

---

## 🔐 Sécurité

### Variables d'Environnement (Recommandé)

Au lieu de mettre le Client ID directement dans le code, utilisez des variables d'environnement :

```dart
// lib/config/google_config.dart
class GoogleConfig {
  static const String clientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com',
  );
}
```

Build avec :
```bash
flutter run --dart-define=GOOGLE_CLIENT_ID=your_real_client_id
```

---

## 📊 Flux de Connexion Google

```
1. Utilisateur clique "Continuer avec Google"
   ↓
2. Popup Google Sign-In s'ouvre
   ↓
3. Utilisateur sélectionne un compte
   ↓
4. Google retourne idToken + email + displayName
   ↓
5. Flutter envoie ces données au backend /api/auth/google
   ↓
6. Backend vérifie et crée/connecte l'utilisateur
   ↓
7. Backend retourne JWT token
   ↓
8. Flutter sauvegarde le token
   ↓
9. Redirection vers l'écran d'accueil ✅
```

---

## ❓ FAQ

### Q: Pourquoi le bouton ne marche pas ?
**R:** Il faut d'abord configurer Google Cloud Console (voir Étape 1-4 ci-dessus).

### Q: Peut-on tester sans configuration Google ?
**R:** Oui ! Utilisez la connexion email/mot de passe avec les comptes de test.

### Q: Le backend est-il prêt ?
**R:** Oui ! Le endpoint `/api/auth/google` est déjà fonctionnel.

### Q: Combien de temps prend la configuration ?
**R:** Environ 10-15 minutes pour configurer Google Cloud Console.

### Q: Est-ce gratuit ?
**R:** Oui, l'API Google Sign-In est gratuite pour un usage standard.

### Q: Faut-il un domaine vérifié ?
**R:** Non pour le développement (localhost). Oui pour la production.

---

## 🎨 Apparence du Bouton

Le bouton Google s'affiche maintenant avec :
- Icône Google (G rouge)
- Texte : "Continuer avec Google"
- Style : Bouton outlined avec bordure grise

---

## ✅ Checklist de Configuration

- [ ] Projet créé sur Google Cloud Console
- [ ] API Google Sign-In activée
- [ ] OAuth Client ID créé (Web)
- [ ] Client ID copié
- [ ] `web/index.html` mis à jour avec le Client ID
- [ ] Application redémarrée
- [ ] Test de connexion Google effectué
- [ ] ✅ Connexion Google fonctionnelle !

---

## 🚀 Alternative : Connexion Classique

**En attendant la configuration Google**, utilisez :

```
📧 admin@draxlmaier.com
🔑 admin123
```

Ou créez votre propre compte avec n'importe quel mot de passe simple !

---

**Dernière mise à jour** : 6 décembre 2025  
**Status** : ✅ Bouton visible, ⚙️ Configuration Google requise
