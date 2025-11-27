# Application Mobile de Communication Interne pour Employés

Application mobile complète de communication interne avec backend Node.js et base de données MongoDB.

## 🏗️ Architecture

### Frontend (Flutter)
- **Framework:** Flutter 3+
- **State Management:** Provider
- **Architecture:** Clean Architecture
- **Design:** Material Design 3

### Backend (Node.js)
- **Framework:** Express.js
- **Database:** MongoDB avec Mongoose ODM
- **Real-time:** Socket.io
- **Authentication:** JWT (JSON Web Tokens)
- **Security:** Helmet, CORS, Rate Limiting

## ✨ Fonctionnalités

### 🔐 Authentification & Autorisation
- Connexion sécurisée avec JWT
- Gestion des rôles (Admin, Manager, Employé)
- Protection des routes par rôle

### 💬 Messagerie Instantanée
- Chat individuel en temps réel
- Groupes de discussion
- Indicateur de saisie
- Statut de lecture des messages
- Historique des conversations

### 🔔 Notifications Push
- Firebase Cloud Messaging (FCM)
- Notifications en temps réel
- Compteur de notifications non lues
- Envoi groupé de notifications (Admin/Manager)

### 📍 Suivi GPS
- Localisation en temps réel
- Carte interactive avec Google Maps
- Historique de localisation
- Suivi d'équipe (Admin/Manager uniquement)

### 👥 Gestion des Utilisateurs
- CRUD complet des utilisateurs
- Activation/Désactivation des comptes
- Recherche d'utilisateurs
- Tableau de bord administrateur

## 📁 Structure du Projet

```
projet flutter/
├── lib/                          # Code Flutter
│   ├── main.dart                # Point d'entrée
│   ├── models/                  # Modèles de données
│   │   ├── user_model.dart
│   │   ├── message_model.dart
│   │   ├── chat_group_model.dart
│   │   ├── notification_model.dart
│   │   └── location_log_model.dart
│   ├── services/                # Services & API
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   ├── socket_service.dart
│   │   ├── location_service.dart
│   │   ├── notification_service.dart
│   │   ├── user_service.dart
│   │   └── chat_service.dart
│   ├── providers/               # State Management
│   │   ├── auth_provider.dart
│   │   ├── chat_provider.dart
│   │   ├── notification_provider.dart
│   │   ├── location_provider.dart
│   │   └── user_provider.dart
│   ├── screens/                 # Écrans UI
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── home_screen.dart
│   │   ├── chat_list_screen.dart
│   │   ├── chat_detail_screen.dart
│   │   ├── notifications_screen.dart
│   │   ├── map_screen.dart
│   │   ├── admin_dashboard_screen.dart
│   │   └── user_management_screen.dart
│   ├── widgets/                 # Widgets réutilisables
│   │   ├── message_bubble.dart
│   │   └── notification_card.dart
│   └── utils/                   # Utilitaires
│       ├── constants.dart
│       ├── app_theme.dart
│       └── helpers.dart
│
├── backend/                     # Backend Node.js
│   ├── server.js               # Point d'entrée
│   ├── package.json            # Dépendances
│   ├── .env.example            # Variables d'environnement
│   ├── config/
│   │   └── jwt.js              # Configuration JWT
│   ├── models/                 # Modèles Mongoose
│   │   ├── User.js
│   │   ├── Message.js
│   │   ├── ChatGroup.js
│   │   ├── Notification.js
│   │   └── LocationLog.js
│   ├── controllers/            # Contrôleurs
│   │   ├── authController.js
│   │   ├── userController.js
│   │   ├── messageController.js
│   │   ├── groupController.js
│   │   ├── notificationController.js
│   │   └── locationController.js
│   ├── routes/                 # Routes API
│   │   ├── authRoutes.js
│   │   ├── userRoutes.js
│   │   ├── messageRoutes.js
│   │   ├── groupRoutes.js
│   │   ├── notificationRoutes.js
│   │   └── locationRoutes.js
│   ├── middleware/             # Middleware
│   │   ├── auth.js
│   │   ├── rateLimiter.js
│   │   ├── errorHandler.js
│   │   └── validation.js
│   └── socket/                 # Socket.io
│       └── socketHandler.js
│
└── pubspec.yaml                # Dépendances Flutter
```

## 🚀 Installation

### Prérequis
- Flutter SDK 3.0+
- Node.js 16+
- MongoDB 5.0+
- Firebase account (pour FCM)
- Google Cloud Platform (pour Google Maps)

### 1. Configuration Backend

```bash
cd backend
npm install
```

Créer le fichier `.env`:
```env
# Server
NODE_ENV=development
PORT=3000

# MongoDB
MONGODB_URI=mongodb://localhost:27017/employee_communication

# JWT
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
JWT_EXPIRES_IN=7d

# CORS
CORS_ORIGIN=*
```

Démarrer le serveur:
```bash
npm run dev
```

### 2. Configuration Flutter

Installer les dépendances:
```bash
flutter pub get
```

Générer les fichiers de sérialisation JSON:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Configuration Firebase:
1. Créer un projet Firebase
2. Télécharger `google-services.json` (Android) et `GoogleService-Info.plist` (iOS)
3. Placer les fichiers dans les dossiers appropriés
4. Activer Firebase Cloud Messaging dans la console

Configuration Google Maps:
1. Créer une clé API Google Maps dans GCP
2. Ajouter la clé dans `AndroidManifest.xml` et `AppDelegate.swift`

Mettre à jour `lib/utils/constants.dart`:
```dart
static const String baseUrl = 'http://localhost:3000/api';
static const String socketUrl = 'http://localhost:3000';
```

Lancer l'application:
```bash
flutter run
```

## 🔑 Authentification

### Rôles Utilisateur
- **Admin:** Accès complet (gestion utilisateurs, notifications, suivi GPS)
- **Manager:** Gestion d'équipe (notifications, suivi GPS)
- **Employee:** Fonctionnalités de base (chat, notifications personnelles)

### Compte Admin par Défaut
Créer manuellement dans MongoDB:
```javascript
db.users.insertOne({
  firstname: "Admin",
  lastname: "System",
  email: "admin@company.com",
  password: "$2a$10$...", // Hash bcrypt de "admin123"
  role: "admin",
  active: true,
  createdAt: new Date()
})
```

## 📡 API Endpoints

### Authentication
- `POST /api/auth/login` - Connexion
- `GET /api/auth/me` - Utilisateur actuel
- `POST /api/auth/fcm-token` - Mise à jour du token FCM

### Users
- `GET /api/users` - Liste des utilisateurs (Admin)
- `GET /api/users/:id` - Détails utilisateur
- `POST /api/users` - Créer utilisateur (Admin)
- `PUT /api/users/:id` - Modifier utilisateur (Admin)
- `DELETE /api/users/:id` - Supprimer utilisateur (Admin)
- `PATCH /api/users/:id/activate` - Activer utilisateur (Admin)
- `PATCH /api/users/:id/deactivate` - Désactiver utilisateur (Admin)

### Messages
- `GET /api/messages/history` - Historique de chat
- `GET /api/messages/conversations` - Liste des conversations
- `POST /api/messages/mark-read` - Marquer comme lu

### Groups
- `GET /api/groups` - Liste des groupes
- `GET /api/groups/:id` - Détails groupe
- `POST /api/groups` - Créer groupe
- `POST /api/groups/:id/members` - Ajouter membres
- `DELETE /api/groups/:id/members/:memberId` - Retirer membre

### Notifications
- `GET /api/notifications` - Liste des notifications
- `GET /api/notifications/unread-count` - Compteur non lues
- `POST /api/notifications/send` - Envoyer notification (Admin/Manager)
- `POST /api/notifications/:id/read` - Marquer comme lu

### Location
- `POST /api/location/update` - Mettre à jour position
- `GET /api/location/team` - Positions équipe (Admin/Manager)
- `GET /api/location/my-history` - Mon historique

## 🔌 Socket.io Events

### Client → Server
- `authenticate` - Authentifier l'utilisateur
- `joinRoom` - Rejoindre une salle
- `leaveRoom` - Quitter une salle
- `sendMessage` - Envoyer un message
- `typing` - Indicateur de saisie
- `messageRead` - Message lu

### Server → Client
- `receiveMessage` - Recevoir un message
- `messageSent` - Confirmation d'envoi
- `userTyping` - Utilisateur en train d'écrire
- `messageStatusUpdate` - Mise à jour statut message
- `userOnline` - Utilisateur en ligne
- `userOffline` - Utilisateur hors ligne
- `error` - Erreur

## 🛡️ Sécurité

- **JWT Authentication:** Tokens sécurisés avec expiration
- **Password Hashing:** bcrypt avec salt rounds
- **Rate Limiting:** Protection contre le brute force
- **Helmet:** En-têtes HTTP sécurisés
- **CORS:** Configuration des origines autorisées
- **Input Validation:** express-validator pour toutes les entrées
- **Role-Based Access Control:** Autorisation par rôle

## 📱 Packages Flutter Principaux

```yaml
dependencies:
  provider: ^6.1.1
  http: ^1.1.2
  socket_io_client: ^2.0.3+1
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  geolocator: ^10.1.0
  google_maps_flutter: ^2.5.0
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2
  intl: ^0.18.1
```

## 🔧 Packages Backend Principaux

```json
{
  "express": "^4.18.2",
  "mongoose": "^8.0.3",
  "socket.io": "^4.6.1",
  "bcryptjs": "^2.4.3",
  "jsonwebtoken": "^9.0.2",
  "helmet": "^7.1.0",
  "cors": "^2.8.5",
  "express-rate-limit": "^7.1.5",
  "express-validator": "^7.0.1"
}
```

## 🧪 Tests

### Backend
```bash
cd backend
npm test
```

### Flutter
```bash
flutter test
```

## 📝 Scripts NPM

- `npm start` - Production
- `npm run dev` - Développement (nodemon)
- `npm test` - Tests
- `npm run lint` - Linting

## 🐛 Debugging

### Logs Backend
Les logs sont affichés dans la console avec Morgan (format 'dev')

### Logs Flutter
```dart
// Activer les logs dans constants.dart
static const bool enableLogging = true;
```

## 📚 Documentation API

Documentation interactive disponible via Postman:
1. Importer `postman_collection.json`
2. Configurer l'environnement (baseUrl, token)
3. Tester les endpoints

## 🤝 Contribution

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT.

## 👨‍💻 Auteur

Application développée pour la communication interne d'entreprise.

## 🔮 Roadmap

- [ ] Tests unitaires et d'intégration
- [ ] CI/CD avec GitHub Actions
- [ ] Documentation Swagger/OpenAPI
- [ ] Support multi-langues (i18n)
- [ ] Mode sombre
- [ ] Appels audio/vidéo
- [ ] Partage de fichiers
- [ ] Réactions aux messages
- [ ] Recherche avancée

## 📞 Support

Pour toute question ou problème:
- Ouvrir une issue sur GitHub
- Contacter l'équipe de développement

---

**Note:** Ce projet est prêt pour la production mais nécessite une configuration appropriée des variables d'environnement et des services externes (Firebase, Google Maps, MongoDB).
