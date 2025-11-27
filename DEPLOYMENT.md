# 🚀 GUIDE DE DÉPLOIEMENT EN PRODUCTION

## 📋 Vue d'ensemble

Ce guide décrit comment déployer l'application en production sur des services cloud.

---

## 🎯 ARCHITECTURE DE PRODUCTION

```
┌─────────────────────────────────────────────────────────────┐
│                       CLOUD INFRASTRUCTURE                    │
│                                                               │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐│
│  │   Flutter    │────▶│   Backend    │────▶│   MongoDB    ││
│  │   Mobile     │     │   Node.js    │     │    Atlas     ││
│  │     App      │     │   (Heroku)   │     │   (Cloud)    ││
│  └──────────────┘     └──────────────┘     └──────────────┘│
│         │                     │                     │        │
│         │                     │                     │        │
│         ▼                     ▼                     ▼        │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐│
│  │   Firebase   │     │   Socket.io  │     │   Firebase   ││
│  │     FCM      │     │   (Redis)    │     │   Storage    ││
│  └──────────────┘     └──────────────┘     └──────────────┘│
└─────────────────────────────────────────────────────────────┘
```

---

## 1️⃣ DÉPLOIEMENT MONGODB (MongoDB Atlas)

### Étape 1: Créer un Cluster

1. **Aller sur:** https://www.mongodb.com/cloud/atlas
2. **S'inscrire** ou se connecter
3. **Créer un cluster gratuit (M0)**
   - Provider: AWS / GCP / Azure
   - Region: Choisir proche de vos utilisateurs
   - Cluster Name: `employee-communication-prod`

### Étape 2: Configuration Réseau

1. **Network Access:**
   - Cliquer "Add IP Address"
   - Sélectionner "Allow Access from Anywhere" (0.0.0.0/0)
   - Ou ajouter IP spécifique de votre serveur

### Étape 3: Créer Utilisateur DB

1. **Database Access:**
   - Cliquer "Add New Database User"
   - Username: `admin_user`
   - Password: [Générer mot de passe fort]
   - Role: Atlas admin

### Étape 4: Obtenir Connection String

1. **Cliquer "Connect"**
2. **Choisir "Connect your application"**
3. **Copier connection string:**
```
mongodb+srv://admin_user:<password>@cluster0.xxxxx.mongodb.net/employee_communication?retryWrites=true&w=majority
```

4. **Remplacer `<password>` par votre mot de passe**

**✅ MongoDB Atlas configuré!**

---

## 2️⃣ DÉPLOIEMENT BACKEND (Heroku)

### Étape 1: Installation Heroku CLI

```bash
# Windows (PowerShell)
winget install Heroku.HerokuCLI

# Ou télécharger depuis
# https://devcenter.heroku.com/articles/heroku-cli
```

### Étape 2: Connexion

```bash
heroku login
```

### Étape 3: Créer Application

```bash
cd backend
heroku create employee-communication-api
```

### Étape 4: Configurer Variables d'Environnement

```bash
heroku config:set NODE_ENV=production
heroku config:set PORT=3000
heroku config:set MONGODB_URI="mongodb+srv://..."
heroku config:set JWT_SECRET="votre_secret_jwt_production_256_bits"
heroku config:set JWT_EXPIRES_IN="7d"
heroku config:set CORS_ORIGIN="https://votre-domaine.com"
```

### Étape 5: Ajouter Procfile

Créer `backend/Procfile`:
```
web: node server.js
```

### Étape 6: Déployer

```bash
git add .
git commit -m "Prepare for Heroku deployment"
git push heroku main
```

### Étape 7: Vérifier

```bash
heroku logs --tail
heroku open
```

**URL de votre API:** `https://employee-communication-api.herokuapp.com`

**✅ Backend déployé!**

---

## 3️⃣ CONFIGURATION FIREBASE (FCM)

### Étape 1: Créer Projet Production

1. **Firebase Console:** https://console.firebase.google.com
2. **Créer nouveau projet:** "Employee Communication Prod"
3. **Activer Google Analytics:** Oui

### Étape 2: Ajouter Application Android

1. **Cliquer "Ajouter une application"** → Android
2. **Package name:** `com.company.employee_communication_app`
3. **Télécharger** `google-services.json`
4. **Placer dans:** `android/app/`

### Étape 3: Ajouter Application iOS

1. **Cliquer "Ajouter une application"** → iOS
2. **Bundle ID:** `com.company.employeeCommunicationApp`
3. **Télécharger** `GoogleService-Info.plist`
4. **Placer dans:** `ios/Runner/`

### Étape 4: Activer Cloud Messaging

1. **Project Settings** → Cloud Messaging
2. **Activer Cloud Messaging API**
3. **Copier Server Key** (pour backend)

### Étape 5: Configurer Backend

Dans votre backend, ajouter FCM:
```bash
npm install firebase-admin
```

Créer `backend/config/firebase.js`:
```javascript
const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.cert({
    projectId: process.env.FIREBASE_PROJECT_ID,
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n')
  })
});

module.exports = admin;
```

**✅ Firebase configuré!**

---

## 4️⃣ CONFIGURATION GOOGLE MAPS

### Étape 1: Créer API Key Production

1. **Google Cloud Console:** https://console.cloud.google.com
2. **Créer projet:** "Employee Communication Prod"
3. **APIs & Services** → Library
4. **Activer:**
   - Maps SDK for Android
   - Maps SDK for iOS
   - Geocoding API
   - Places API

### Étape 2: Créer Credentials

1. **APIs & Services** → Credentials
2. **Create Credentials** → API Key
3. **Copier la clé:** `AIzaSy...`

### Étape 3: Restreindre la Clé

1. **Éditer API Key**
2. **Application restrictions:**
   - Android: Ajouter package name + SHA-1
   - iOS: Ajouter bundle ID
3. **API restrictions:**
   - Sélectionner uniquement les APIs nécessaires

### Étape 4: Ajouter dans l'App

**Android:** `android/app/src/main/AndroidManifest.xml`
```xml
<meta-data
  android:name="com.google.android.geo.API_KEY"
  android:value="AIzaSy..."/>
```

**iOS:** `ios/Runner/AppDelegate.swift`
```swift
GMSServices.provideAPIKey("AIzaSy...")
```

**✅ Google Maps configuré!**

---

## 5️⃣ BUILD & PUBLICATION FLUTTER

### A. Publication Android (Google Play)

#### Étape 1: Créer Keystore

```bash
keytool -genkey -v -keystore employee-communication.jks -keyalg RSA -keysize 2048 -validity 10000 -alias employee-communication
```

**Sauvegarder:**
- Fichier `.jks` en lieu sûr
- Mot de passe du keystore
- Mot de passe de la clé
- Alias

#### Étape 2: Configurer Signing

Créer `android/key.properties`:
```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=employee-communication
storeFile=../employee-communication.jks
```

Modifier `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

#### Étape 3: Build APK/AAB

```bash
# APK
flutter build apk --release

# AAB (recommandé pour Play Store)
flutter build appbundle --release
```

**Fichiers générés:**
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

#### Étape 4: Publier sur Google Play

1. **Google Play Console:** https://play.google.com/console
2. **Créer application**
3. **Uploader AAB**
4. **Remplir fiche:** Description, captures, icône
5. **Soumettre pour révision**

**✅ Android publié!**

---

### B. Publication iOS (App Store)

#### Étape 1: Certificats & Provisioning

1. **Apple Developer:** https://developer.apple.com
2. **Certificates, IDs & Profiles**
3. **Créer App ID:** `com.company.employeeCommunicationApp`
4. **Créer certificat de distribution**
5. **Créer provisioning profile**

#### Étape 2: Configurer Xcode

```bash
cd ios
open Runner.xcworkspace
```

Dans Xcode:
1. **Signing & Capabilities**
2. **Team:** Sélectionner votre équipe
3. **Bundle Identifier:** `com.company.employeeCommunicationApp`
4. **Signing:** Automatic

#### Étape 3: Build Archive

```bash
flutter build ios --release
```

Dans Xcode:
1. **Product** → Archive
2. **Attendre la compilation**
3. **Distribute App**
4. **App Store Connect**
5. **Upload**

#### Étape 4: App Store Connect

1. **App Store Connect:** https://appstoreconnect.apple.com
2. **Créer nouvelle app**
3. **Remplir métadonnées**
4. **Ajouter captures d'écran**
5. **Soumettre pour révision**

**✅ iOS publié!**

---

## 6️⃣ CONFIGURATION DOMAINE (Optionnel)

### Acheter Domaine

1. **Namecheap / GoDaddy / Google Domains**
2. **Acheter:** `employee-communication.com`

### Configurer DNS

**Pour Heroku:**
```
Type: CNAME
Host: api
Value: employee-communication-api.herokuapp.com
```

**Attendre propagation DNS (24-48h)**

### Activer HTTPS

Heroku active automatiquement HTTPS avec Let's Encrypt.

**Mettre à jour Flutter:**
```dart
// lib/utils/constants.dart
static const String baseUrl = 'https://api.employee-communication.com/api';
static const String socketUrl = 'https://api.employee-communication.com';
```

**✅ Domaine configuré!**

---

## 7️⃣ MONITORING & LOGS

### Backend Monitoring (Heroku)

```bash
# Logs en temps réel
heroku logs --tail

# Métriques
heroku addons:create papertrail:choklad
```

### Error Tracking

Installer Sentry:
```bash
npm install @sentry/node
```

`backend/server.js`:
```javascript
const Sentry = require('@sentry/node');

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV
});
```

### Firebase Analytics

Déjà configuré dans Flutter avec Firebase.

---

## 8️⃣ CHECKLIST PRÉ-PRODUCTION

### Backend ✅
- [ ] Variables d'environnement configurées
- [ ] MongoDB Atlas connecté
- [ ] JWT secret production (256+ bits)
- [ ] CORS configuré avec domaine exact
- [ ] Rate limiting activé
- [ ] Logs configurés
- [ ] Error tracking (Sentry)
- [ ] Health check endpoint fonctionnel

### Frontend ✅
- [ ] API URL de production
- [ ] Firebase projet production
- [ ] Google Maps API key production
- [ ] Keystore Android créé et sécurisé
- [ ] Certificats iOS configurés
- [ ] Version code/name mis à jour
- [ ] Icônes et splash screens
- [ ] Permissions documentées

### Sécurité ✅
- [ ] HTTPS activé partout
- [ ] Secrets en variables d'environnement
- [ ] MongoDB IP whitelist
- [ ] API keys restreintes
- [ ] Rate limiting testé
- [ ] Input validation complète

### Tests ✅
- [ ] Tests unitaires passés
- [ ] Tests d'intégration passés
- [ ] Tests de charge effectués
- [ ] Tests sur vrais appareils
- [ ] Tests iOS et Android

---

## 9️⃣ MAINTENANCE & UPDATES

### Mise à Jour Backend

```bash
# Déployer nouvelle version
git push heroku main

# Rollback si problème
heroku rollback
```

### Mise à Jour Flutter

```bash
# Incrémenter version dans pubspec.yaml
version: 1.0.1+2

# Build et publier
flutter build appbundle --release
# Upload sur Play Console

flutter build ios --release
# Upload sur App Store Connect
```

### Backups MongoDB

MongoDB Atlas fait des backups automatiques.

**Configuration manuelle:**
1. **Atlas Console** → Backup
2. **Enable Cloud Backup**
3. **Configure retention policy**

---

## 🎯 COÛTS ESTIMÉS (Mensuel)

| Service | Plan | Coût |
|---------|------|------|
| MongoDB Atlas | M0 (Free) | $0 |
| Heroku | Hobby | $7 |
| Firebase | Spark (Free) | $0 |
| Google Maps | $200 crédit/mois | ~$0-50 |
| Domaine | Annuel | ~$1/mois |
| **TOTAL** | | **~$8-60/mois** |

**Note:** Pour production à grande échelle, prévoir:
- MongoDB Atlas M10: $57/mois
- Heroku Standard: $25/mois
- Firebase Blaze: Pay-as-you-go

---

## 📞 SUPPORT POST-DÉPLOIEMENT

### Monitoring

- **Heroku Metrics:** Dashboard
- **MongoDB Atlas:** Performance metrics
- **Firebase:** Analytics & Crashlytics
- **Sentry:** Error tracking

### Alertes

Configurer alertes pour:
- Erreurs serveur (5xx)
- Latence élevée
- Utilisation mémoire
- Crash rate app

---

## ✅ DÉPLOIEMENT RÉUSSI!

**Félicitations! Votre application est maintenant en production! 🎉**

### URLs Finales:
- **API:** https://api.employee-communication.com
- **Android:** https://play.google.com/store/apps/...
- **iOS:** https://apps.apple.com/app/...

### Prochaines Étapes:
1. ✅ Surveiller les logs
2. ✅ Collecter feedback utilisateurs
3. ✅ Optimiser performances
4. ✅ Ajouter nouvelles fonctionnalités

**Bon lancement! 🚀**
