# 🚀 GUIDE DE DÉMARRAGE RAPIDE

## ⚡ En 5 minutes

### 1️⃣ Backend (2 minutes)

```bash
# Installation
cd backend
npm install

# Configuration rapide
echo "NODE_ENV=development
PORT=3000
MONGODB_URI=mongodb://localhost:27017/employee_communication
JWT_SECRET=your_secret_key_here_change_in_production
JWT_EXPIRES_IN=7d
CORS_ORIGIN=*" > .env

# Démarrer MongoDB (nouvelle fenêtre terminal)
mongod

# Démarrer le serveur
npm run dev
```

**✅ Backend prêt sur http://localhost:3000**

---

### 2️⃣ Flutter (3 minutes)

```bash
# Installation
flutter pub get

# Générer les fichiers JSON
flutter pub run build_runner build --delete-conflicting-outputs

# Mettre à jour l'URL de l'API
# Éditer: lib/utils/constants.dart
# Ligne 8: static const String baseUrl = 'http://localhost:3000/api';
# Ligne 9: static const String socketUrl = 'http://localhost:3000';

# Lancer l'application
flutter run
```

**✅ App Flutter lancée!**

---

## 🧪 Tester l'Application

### Test de Connexion

**Sans créer de compte admin:**
1. Ouvrir MongoDB Compass
2. Se connecter à `mongodb://localhost:27017`
3. Base de données: `employee_communication`
4. Collection: `users`
5. Insérer un document:

```json
{
  "firstname": "Admin",
  "lastname": "Test",
  "email": "admin@test.com",
  "password": "$2a$10$rI7GhZQSjLKzHpnZKj6rh.vP7vLLnDnKZrU5R1F5xWHfJGS5zLGPu",
  "role": "admin",
  "active": true,
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

**Credentials:**
- Email: `admin@test.com`
- Password: `admin123`

---

## 📱 Fonctionnalités à Tester

### ✅ Authentification
1. Ouvrir l'app
2. Se connecter avec admin@test.com / admin123
3. ✅ Devrait rediriger vers Home

### ✅ Gestion Utilisateurs (Admin)
1. Aller dans Menu → User Management
2. Cliquer sur "Add User"
3. Créer un employé:
   - Firstname: John
   - Lastname: Doe
   - Email: john@test.com
   - Password: 123456
   - Role: Employee
4. ✅ Utilisateur créé

### ✅ Chat Temps Réel
1. Se connecter avec john@test.com / 123456 (nouvel appareil/émulateur)
2. Aller dans l'onglet Chat
3. Commencer une conversation avec Admin Test
4. Envoyer un message
5. ✅ Le message apparaît en temps réel

### ✅ Notifications
1. En tant qu'Admin, aller dans Menu → Admin Dashboard
2. Section "Send Notification"
3. Titre: "Test"
4. Message: "Hello World"
5. Envoyer
6. ✅ John reçoit la notification

### ✅ GPS Tracking
1. Sur l'appareil de John, activer la localisation
2. Aller dans l'onglet Map
3. ✅ Position affichée sur la carte
4. En tant qu'Admin, ouvrir Map
5. ✅ Voir tous les employés sur la carte

---

## 🔧 Configuration Firebase (Optionnel mais Recommandé)

### Créer Projet Firebase (5 minutes)

1. **Aller sur:** https://console.firebase.google.com
2. **Créer un projet:** "Employee Communication App"
3. **Ajouter Android:**
   - Package name: `com.example.employee_communication_app`
   - Télécharger `google-services.json`
   - Placer dans: `android/app/`

4. **Ajouter iOS:**
   - Bundle ID: `com.example.employeeCommunicationApp`
   - Télécharger `GoogleService-Info.plist`
   - Placer dans: `ios/Runner/`

5. **Activer FCM:**
   - Firebase Console → Cloud Messaging
   - Activer le service

6. **Rebuild l'app:**
```bash
flutter clean
flutter pub get
flutter run
```

**✅ Notifications push activées!**

---

## 🗺️ Configuration Google Maps (5 minutes)

### Obtenir API Key

1. **Google Cloud Console:** https://console.cloud.google.com
2. **Créer projet:** "Employee Communication App"
3. **APIs & Services → Library**
4. **Activer:**
   - Maps SDK for Android
   - Maps SDK for iOS
5. **Credentials → Create API Key**
6. **Copier la clé:** `AIza...`

### Ajouter la clé

**Android:** `android/app/src/main/AndroidManifest.xml`
```xml
<manifest ...>
  <application ...>
    <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="VOTRE_API_KEY_ICI"/>
  </application>
</manifest>
```

**iOS:** `ios/Runner/AppDelegate.swift`
```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("VOTRE_API_KEY_ICI")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

**✅ Google Maps configuré!**

---

## 🐛 Dépannage Rapide

### Backend ne démarre pas
```bash
# Vérifier MongoDB
mongod --version

# Vérifier Node.js
node --version  # Doit être 16+

# Vérifier le port
netstat -ano | findstr :3000
```

### Flutter build error
```bash
# Clean et rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Socket.io ne se connecte pas
```dart
// Vérifier dans lib/utils/constants.dart
static const String socketUrl = 'http://10.0.2.2:3000';  // Pour émulateur Android
// OU
static const String socketUrl = 'http://localhost:3000';  // Pour iOS simulator
// OU
static const String socketUrl = 'http://VOTRE_IP:3000';  // Pour appareil physique
```

### Permissions location
**Android:** Déjà configuré dans `AndroidManifest.xml`
**iOS:** Déjà configuré dans `Info.plist`

Si problème:
```bash
flutter clean
flutter pub get
flutter run
# Accepter les permissions quand demandées
```

---

## 📊 Vérifier que Tout Fonctionne

### Backend Health Check
```bash
curl http://localhost:3000/health
```
**Réponse attendue:**
```json
{
  "status": "success",
  "message": "Server is running",
  "timestamp": "2024-..."
}
```

### Test API Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@test.com","password":"admin123"}'
```
**Réponse attendue:**
```json
{
  "status": "success",
  "token": "eyJhbGciOi...",
  "user": {...}
}
```

---

## 🎯 Prochaines Étapes

### Développement
1. ✅ Tester toutes les fonctionnalités
2. ✅ Personnaliser le design
3. ✅ Ajouter plus d'utilisateurs
4. ✅ Tester chat de groupe

### Production
1. 🔧 MongoDB Atlas (cloud)
2. 🔧 Déployer backend (Heroku/AWS/GCP)
3. 🔧 Configurer domaine
4. 🔧 Publier sur stores

---

## 💡 Astuces

### Hot Reload Flutter
- Appuyer sur `r` dans le terminal = hot reload
- Appuyer sur `R` = hot restart
- Appuyer sur `q` = quitter

### Logs Backend
- Les logs s'affichent dans le terminal
- Format: `[METHOD] /route STATUS - TIME`

### Debug Socket.io
```dart
// Dans lib/services/socket_service.dart
// Ligne 11: logEnabled: true  // Déjà activé
```

---

## 📞 Ressources

- **Documentation Flutter:** https://flutter.dev/docs
- **Documentation Express:** https://expressjs.com
- **Documentation Socket.io:** https://socket.io/docs
- **Documentation MongoDB:** https://docs.mongodb.com
- **Documentation Firebase:** https://firebase.google.com/docs

---

## ✅ Checklist Finale

- [ ] Backend démarre sans erreur
- [ ] MongoDB connecté
- [ ] Flutter compile sans erreur
- [ ] Fichiers .g.dart générés
- [ ] Connexion fonctionne
- [ ] Chat temps réel fonctionne
- [ ] Notifications s'affichent
- [ ] Map s'affiche
- [ ] Admin peut gérer users

---

**🎉 FÉLICITATIONS! Votre application est opérationnelle!**

**Bon développement! 🚀**
