# 📋 CAHIER DES CHARGES - APPLICATION DE COMMUNICATION D'ENTREPRISE

## 📌 INFORMATIONS GÉNÉRALES

**Nom du projet:** Draxlmaier Employee Communication App  
**Version:** 2.0  
**Date:** 28 Novembre 2025  
**Client:** Draxlmaier  
**Type:** Application Web & Mobile (Flutter)

---

## 🎯 1. CONTEXTE ET OBJECTIFS

### 1.1 Contexte
Application de communication interne pour entreprise permettant la gestion des employés, la communication en temps réel, et le suivi des objectifs professionnels.

### 1.2 Objectifs principaux
- Faciliter la communication entre employés et managers
- Gérer les notifications RH et alertes importantes
- Permettre l'auto-inscription des employés
- Gérer les données de transport (localisation, arrêts de bus)
- Suivre les objectifs et tâches des employés
- Centraliser les informations de profil et poste de travail

---

## 👥 2. ACTEURS DU SYSTÈME

### 2.1 Administrateur (Admin)
**Responsabilités:**
- Gestion complète des utilisateurs (CRUD)
- Gestion des départements et équipes
- Configuration du système
- Accès à toutes les fonctionnalités
- Génération de rapports
- Gestion des permissions

**Pages accessibles:**
- Dashboard Admin
- Gestion Utilisateurs
- Gestion Départements
- Gestion Équipes
- Paramètres Système
- Analytics
- Chat & Messages
- Notifications
- Carte (Map)
- Profil

### 2.2 Manager / RH (Manager)
**Responsabilités:**
- Création et envoi de notifications globales
- Gestion de son équipe
- Validation des inscriptions employés
- Modification des postes de travail
- Envoi de messages aux employés via chatroom
- Suivi des objectifs de l'équipe
- Gestion des arrêts de bus

**Pages accessibles:**
- Dashboard Manager
- Gestion Équipe
- Création Notifications
- Chatroom (envoi messages)
- Objectifs Équipe
- Carte (Map)
- Profil
- Gestion Localisation Bus

### 2.3 Employé (Employee)
**Responsabilités:**
- Auto-inscription au système
- Mise à jour de ses coordonnées
- Consultation des notifications
- Définition de sa localisation et arrêt de bus
- Gestion de ses objectifs
- Réception de messages superviseur
- Mise à jour profil personnel

**Pages accessibles:**
- Home (Notifications)
- Profil
- Objectifs
- Chatroom (réception messages)

---

## 🔐 3. GESTION DES UTILISATEURS

### 3.1 Inscription (Nouveau Feature)

#### 3.1.1 Formulaire d'inscription publique
**URL:** `/register`  
**Accès:** Public (non authentifié)

**Champs obligatoires:**
- ✅ Nom (firstname)
- ✅ Prénom (lastname)
- ✅ Email professionnel
- ✅ Mot de passe (min 8 caractères, 1 majuscule, 1 chiffre)
- ✅ Confirmation mot de passe
- ✅ Poste de travail (position)
- ✅ Adresse complète (address)
- ✅ Coordonnées GPS localisation (latitude, longitude)
- ✅ Nom de l'arrêt de bus souhaité (busStopName)

**Champs optionnels:**
- ⭕ Matricule (employeeId)
- ⭕ Téléphone

**Validation:**
- Email format valide et unique
- Mot de passe sécurisé (complexité)
- Localisation GPS valide
- Arrêt de bus existe dans la liste

**Workflow:**
1. Employé remplit formulaire
2. Système valide les données
3. Compte créé avec statut `pending` (en attente)
4. Notification envoyée aux Managers/Admin
5. Manager/Admin valide ou rejette l'inscription
6. Si validé → statut `active`, email de confirmation
7. Si rejeté → email avec raison du rejet

### 3.2 Connexion
**URL:** `/login`  
**Champs:**
- Email
- Mot de passe

**Processus:**
1. Vérification identifiants
2. Vérification compte actif
3. Génération token JWT
4. Redirection selon rôle

### 3.3 Profil Utilisateur

#### Structure de données User (Étendue)
```javascript
{
  _id: ObjectId,
  firstname: String,
  lastname: String,
  email: String (unique),
  passwordHash: String,
  role: Enum ['admin', 'manager', 'employee'],
  active: Boolean,
  status: Enum ['pending', 'active', 'inactive', 'rejected'],
  
  // Nouvelles données
  employeeId: String (matricule, optionnel),
  position: String (poste de travail),
  department: ObjectId (référence),
  
  // Localisation
  location: {
    address: String,
    coordinates: {
      latitude: Number,
      longitude: Number
    },
    busStop: {
      name: String,
      stopId: ObjectId (référence BusStop)
    }
  },
  
  phone: String,
  fcmToken: String,
  createdAt: Date,
  updatedAt: Date,
  validatedBy: ObjectId (Manager/Admin qui a validé),
  validatedAt: Date
}
```

---

## 📄 4. PAGES ET FONCTIONNALITÉS PAR RÔLE

### 4.1 PAGES EMPLOYÉ (Employee)

#### 4.1.1 Page HOME (Dashboard Employé)
**Route:** `/home`  
**Objectif:** Vue d'ensemble des notifications et actualités

**Sections:**
1. **Header**
   - Salutation personnalisée (Welcome, [Prénom]!)
   - Photo de profil
   - Notification badge

2. **Notifications Feed**
   - Liste des notifications RH
   - Filtres: Toutes / Non lues / Importantes
   - Types de notifications:
     - 🔔 Annonces RH
     - 📅 Événements
     - ⚠️ Alertes urgentes
     - 🎉 Célébrations (anniversaires, succès)
     - 🚌 Changements d'horaires bus
   
3. **Quick Actions**
   - Bouton "Voir Profil"
   - Bouton "Mes Objectifs"
   - Bouton "Messages"

4. **Statistiques Rapides**
   - Objectifs complétés ce mois
   - Messages non lus
   - Prochaine échéance

**API:**
- `GET /api/notifications/employee` - Liste notifications
- `PUT /api/notifications/:id/read` - Marquer comme lu

#### 4.1.2 Page PROFIL
**Route:** `/profile`  
**Objectif:** Gestion informations personnelles

**Sections:**

1. **Informations Personnelles** (Lecture seule pour certains champs)
   - 👤 Nom: [Lastname] (lecture seule)
   - 👤 Prénom: [Firstname] (lecture seule)
   - 📧 Email: [email] (lecture seule)
   - 🏢 Poste de travail: [Position] (modifiable par Manager uniquement)
   - 🆔 Matricule: [EmployeeId] (lecture seule si défini)
   - 📱 Téléphone: [Phone] (modifiable)
   - 🏛️ Département: [Department] (lecture seule)

2. **Localisation & Transport** (Modifiable)
   - 📍 Adresse complète: [Champ texte]
   - 🗺️ Coordonnées GPS: [Latitude, Longitude]
   - 🔄 Bouton "Utiliser ma position actuelle"
   - 🚌 Arrêt de bus préféré: [Dropdown liste des arrêts]
   - 📋 Note: "Votre localisation aide à organiser le transport d'entreprise"

3. **Sécurité**
   - 🔒 Changer mot de passe
   - 📱 Gérer sessions actives

4. **Actions**
   - 💾 Bouton "Enregistrer les modifications"
   - 🔄 Bouton "Annuler"

**Règles de gestion:**
- Seul l'employé peut modifier: adresse, GPS, arrêt bus, téléphone
- Seul Manager peut modifier: poste de travail, département, matricule
- Admin peut tout modifier

**API:**
- `GET /api/users/me` - Récupérer profil
- `PUT /api/users/me/profile` - Mise à jour profil
- `PUT /api/users/me/location` - Mise à jour localisation
- `PUT /api/users/me/password` - Changer mot de passe

#### 4.1.3 Page OBJECTIFS
**Route:** `/objectives`  
**Objectif:** Suivi travail et objectifs personnels

**Sections:**

1. **Vue d'ensemble**
   - 📊 Progression globale: [Barre de progression %]
   - 🎯 Objectifs complétés: X/Y
   - ⏰ Échéances à venir: [Nombre]

2. **Liste des Objectifs**
   Chaque objectif affiche:
   - ✓ Statut: [À faire / En cours / Complété / Bloqué]
   - 📝 Titre de l'objectif
   - 📄 Description détaillée
   - 👤 Assigné par: [Manager name]
   - 📅 Date limite: [Date]
   - ⚡ Priorité: [Basse / Moyenne / Haute / Urgente]
   - 📈 Progression: [Barre %]
   - 💬 Commentaires: [Section commentaires]

3. **Filtres & Tri**
   - Par statut
   - Par priorité
   - Par date limite
   - Par département

4. **Espace de travail** (Nouveau)
   - 📂 Documents liés à l'objectif
   - 📎 Fichiers à télécharger
   - 🔗 Liens utiles
   - ✍️ Notes personnelles

5. **Actions Employé**
   - ✅ Marquer comme "En cours"
   - ✅ Marquer comme "Complété"
   - 💬 Ajouter commentaire
   - 📎 Joindre fichier
   - 🚫 Signaler blocage

**API:**
- `GET /api/objectives/my-objectives` - Mes objectifs
- `PUT /api/objectives/:id/status` - Changer statut
- `POST /api/objectives/:id/comments` - Ajouter commentaire
- `POST /api/objectives/:id/files` - Upload fichier

#### 4.1.4 Page CHATROOM
**Route:** `/chatroom`  
**Objectif:** Communication avec superviseur/manager

**Fonctionnalités:**

1. **Liste des Conversations**
   - 👔 Conversations avec Manager
   - 👥 Groupes d'équipe
   - 🏢 Annonces RH (lecture seule)

2. **Zone de Chat**
   - 💬 Historique messages
   - ⌚ Horodatage
   - ✓✓ Statut de lecture
   - 📎 Pièces jointes
   - 😊 Emojis

3. **Types de messages reçus:**
   - Messages individuels du superviseur
   - Annonces d'équipe
   - Notifications RH importantes

4. **Restrictions Employé:**
   - ❌ Ne peut pas initier conversation avec autres employés
   - ✅ Peut répondre aux messages du manager
   - ✅ Peut lire les annonces groupe

**API:**
- `GET /api/messages/conversations` - Liste conversations
- `GET /api/messages/:conversationId` - Messages d'une conversation
- `POST /api/messages` - Envoyer message (réponse uniquement)
- Socket.io pour temps réel

---

### 4.2 PAGES MANAGER

#### 4.2.1 Dashboard Manager
**Route:** `/manager/dashboard`

**Sections:**
- Vue d'ensemble équipe
- Statistiques employés
- Notifications en attente
- Inscriptions à valider
- Objectifs d'équipe

#### 4.2.2 Création de Notifications
**Route:** `/manager/notifications/create`

**Formulaire:**
- 📝 Titre de la notification
- 📄 Message/Contenu
- 🎯 Type: [Annonce / Alerte / Événement / Info]
- 👥 Destinataires:
  - Tous les employés
  - Mon équipe uniquement
  - Département spécifique
  - Employés sélectionnés
- ⚡ Priorité: [Normal / Important / Urgent]
- 📅 Date de publication: [Maintenant / Programmée]
- 📎 Pièces jointes (optionnel)

**API:**
- `POST /api/notifications/create` - Créer notification
- `GET /api/users/by-department` - Liste employés par département

#### 4.2.3 Validation des Inscriptions
**Route:** `/manager/registrations/pending`

**Fonctionnalités:**
- Liste des inscriptions en attente
- Détails complets du profil candidat
- Vérification localisation sur carte
- Actions:
  - ✅ Approuver inscription
  - ❌ Rejeter (avec raison)
  - ✏️ Modifier informations avant validation
  - 💬 Demander informations complémentaires

**API:**
- `GET /api/users/pending` - Liste inscriptions en attente
- `PUT /api/users/:id/validate` - Valider inscription
- `PUT /api/users/:id/reject` - Rejeter inscription

#### 4.2.4 Gestion Équipe & Postes
**Route:** `/manager/team`

**Fonctionnalités:**
- Liste membres équipe
- Modifier poste de travail employé
- Assigner/Réassigner département
- Définir matricule
- Gérer arrêts de bus équipe

#### 4.2.5 Chatroom Manager
**Route:** `/manager/chatroom`

**Fonctionnalités:**
- Envoyer messages à employés individuels
- Créer annonces groupe
- Messages broadcast équipe
- Suivi des messages lus/non lus

---

### 4.3 PAGES ADMIN

*(Toutes les fonctionnalités Manager + permissions étendues)*

#### Fonctionnalités supplémentaires:
- Gestion globale utilisateurs
- Configuration système
- Gestion des arrêts de bus
- Analytics complets
- Logs système
- Gestion départements et équipes

---

## 🗄️ 5. MODÈLES DE DONNÉES

### 5.1 Collection: Users (Étendu)
```javascript
{
  _id: ObjectId,
  firstname: String (required),
  lastname: String (required),
  email: String (required, unique, lowercase),
  passwordHash: String (required, select: false),
  role: String (enum: ['admin', 'manager', 'employee'], default: 'employee'),
  status: String (enum: ['pending', 'active', 'inactive', 'rejected'], default: 'pending'),
  
  // Informations professionnelles
  employeeId: String (matricule, unique, sparse),
  position: String (poste de travail, required),
  department: ObjectId (ref: 'Department'),
  team: ObjectId (ref: 'Team'),
  
  // Localisation & Transport
  location: {
    address: String (required),
    coordinates: {
      latitude: Number (required),
      longitude: Number (required)
    },
    busStop: {
      name: String,
      stopId: ObjectId (ref: 'BusStop')
    }
  },
  
  // Contact
  phone: String,
  
  // Validation
  validatedBy: ObjectId (ref: 'User'),
  validatedAt: Date,
  rejectionReason: String,
  
  // Sécurité
  active: Boolean (default: true),
  fcmToken: String,
  lastLogin: Date,
  
  timestamps: true
}
```

### 5.2 Collection: BusStops (Nouveau)
```javascript
{
  _id: ObjectId,
  name: String (required, unique),
  code: String (unique),
  coordinates: {
    latitude: Number (required),
    longitude: Number (required)
  },
  address: String,
  capacity: Number (nombre max d'employés),
  schedule: [{
    time: String (HH:mm),
    direction: String (enum: ['toWork', 'fromWork'])
  }],
  active: Boolean (default: true),
  employees: [ObjectId] (ref: 'User'),
  createdAt: Date,
  updatedAt: Date
}
```

### 5.3 Collection: Notifications (Étendu)
```javascript
{
  _id: ObjectId,
  title: String (required),
  message: String (required),
  type: String (enum: ['announcement', 'alert', 'event', 'info', 'bus'], required),
  priority: String (enum: ['normal', 'important', 'urgent'], default: 'normal'),
  
  // Expéditeur
  createdBy: ObjectId (ref: 'User', required),
  
  // Destinataires
  recipients: {
    type: String (enum: ['all', 'team', 'department', 'specific']),
    userIds: [ObjectId] (ref: 'User'),
    departmentIds: [ObjectId] (ref: 'Department'),
    teamIds: [ObjectId] (ref: 'Team')
  },
  
  // Contenu
  attachments: [{
    filename: String,
    url: String,
    size: Number
  }],
  
  // Publication
  publishAt: Date (default: now),
  expiresAt: Date,
  
  // Statistiques
  readBy: [{
    userId: ObjectId (ref: 'User'),
    readAt: Date
  }],
  
  active: Boolean (default: true),
  timestamps: true
}
```

### 5.4 Collection: Objectives (Nouveau)
```javascript
{
  _id: ObjectId,
  title: String (required),
  description: String (required),
  
  // Assignment
  assignedTo: ObjectId (ref: 'User', required),
  assignedBy: ObjectId (ref: 'User', required),
  team: ObjectId (ref: 'Team'),
  department: ObjectId (ref: 'Department'),
  
  // Statut & Priorité
  status: String (enum: ['todo', 'in_progress', 'completed', 'blocked'], default: 'todo'),
  priority: String (enum: ['low', 'medium', 'high', 'urgent'], default: 'medium'),
  
  // Dates
  startDate: Date,
  dueDate: Date,
  completedAt: Date,
  
  // Progression
  progress: Number (0-100, default: 0),
  
  // Workspace
  files: [{
    filename: String,
    url: String,
    uploadedBy: ObjectId (ref: 'User'),
    uploadedAt: Date
  }],
  links: [{
    title: String,
    url: String
  }],
  notes: String,
  
  // Commentaires
  comments: [{
    userId: ObjectId (ref: 'User'),
    text: String,
    createdAt: Date
  }],
  
  timestamps: true
}
```

### 5.5 Collection: Messages (Étendu)
```javascript
{
  _id: ObjectId,
  conversationId: String (required),
  
  sender: ObjectId (ref: 'User', required),
  recipients: [{
    userId: ObjectId (ref: 'User'),
    readAt: Date
  }],
  
  // Type de conversation
  conversationType: String (enum: ['individual', 'group', 'announcement']),
  
  // Contenu
  text: String,
  attachments: [{
    filename: String,
    url: String,
    type: String (image/document/video)
  }],
  
  // Restrictions
  replyAllowed: Boolean (default: true),
  
  timestamps: true
}
```

---

## 🔄 6. FLUX DE TRAVAIL (WORKFLOWS)

### 6.1 Workflow: Inscription Employé

```
1. Employé accède à /register
   ↓
2. Remplit formulaire inscription
   - Informations personnelles
   - Localisation GPS
   - Arrêt de bus
   ↓
3. Validation formulaire côté client
   ↓
4. Envoi API: POST /api/auth/register
   ↓
5. Backend valide données
   - Email unique ?
   - Mot de passe fort ?
   - Localisation valide ?
   ↓
6. Création compte avec status='pending'
   ↓
7. Notification envoyée aux Managers/Admin
   - Email
   - Notification in-app
   ↓
8. Manager reçoit notification
   ↓
9. Manager consulte détails inscription
   - Vérifie informations
   - Vérifie localisation sur carte
   ↓
10. Manager prend décision:
    
    → APPROUVER:
      - PUT /api/users/:id/validate
      - Status = 'active'
      - Assignation département/équipe
      - Génération matricule (optionnel)
      - Email confirmation envoyé
      - Employé peut se connecter
    
    → REJETER:
      - PUT /api/users/:id/reject
      - Status = 'rejected'
      - Email avec raison rejet
      - Compte désactivé
    
    → DEMANDER INFO:
      - Email à l'employé
      - Status reste 'pending'
```

### 6.2 Workflow: Création Notification RH

```
1. Manager accède à /manager/notifications/create
   ↓
2. Remplit formulaire
   - Titre
   - Message
   - Type & Priorité
   - Destinataires
   ↓
3. Prévisualisation
   ↓
4. Envoi: POST /api/notifications/create
   ↓
5. Backend traite:
   - Détermine liste destinataires
   - Enregistre notification
   - Envoie push notifications
   ↓
6. Employés reçoivent:
   - Notification push (si FCM token)
   - Badge notification in-app
   ↓
7. Employé consulte Home
   - Liste notifications
   - Marque comme lu
   ↓
8. Manager voit statistiques:
   - Nombre de vues
   - Qui a lu
```

### 6.3 Workflow: Gestion Objectifs

```
MANAGER CRÉE OBJECTIF:
1. Manager accède /manager/objectives/create
2. Définit objectif:
   - Titre, description
   - Assigné à (employé)
   - Priorité, date limite
3. POST /api/objectives/create
4. Notification envoyée à l'employé
   ↓

EMPLOYÉ TRAVAILLE SUR OBJECTIF:
1. Employé consulte /objectives
2. Voit nouvel objectif (status: todo)
3. Clique "Commencer"
   - PUT /api/objectives/:id/status {status: 'in_progress'}
4. Travaille sur l'objectif:
   - Ajoute commentaires
   - Upload fichiers
   - Met à jour progression
5. Si blocage:
   - PUT /api/objectives/:id/status {status: 'blocked'}
   - Notification au manager
6. Si terminé:
   - PUT /api/objectives/:id/status {status: 'completed'}
   - Notification au manager
   ↓

MANAGER VALIDE:
1. Manager reçoit notification
2. Consulte travail effectué
3. Valide ou demande modifications
```

---

## 🔐 7. SÉCURITÉ

### 7.1 Authentification
- JWT tokens (expiration 24h)
- Refresh tokens (expiration 7 jours)
- Hash bcrypt pour mots de passe (salt rounds: 10)
- Rate limiting: 5 tentatives connexion / 15 min

### 7.2 Autorisation
- Middleware de vérification rôle
- Permissions granulaires par endpoint
- Validation propriétaire ressource

### 7.3 Données sensibles
- HTTPS obligatoire en production
- Mots de passe jamais en clair
- Localisation GPS chiffrée
- Logs des accès aux données personnelles

### 7.4 Validation
- Validation côté client (Flutter)
- Validation côté serveur (express-validator)
- Sanitisation des entrées (XSS prevention)
- Protection CSRF

---

## 📱 8. INTERFACE UTILISATEUR

### 8.1 Design System

**Couleurs:**
- Primary: #2196F3 (Bleu)
- Secondary: #FFC107 (Orange)
- Success: #4CAF50 (Vert)
- Warning: #FF9800 (Orange)
- Error: #F44336 (Rouge)
- Background: #F5F5F5 (Gris clair)

**Typography:**
- Headings: Roboto Bold
- Body: Roboto Regular
- Tailles: 12px, 14px, 16px, 18px, 24px

**Composants:**
- Cards avec ombres
- Boutons arrondis (border-radius: 8px)
- Icons: Material Design
- Animations fluides (200-300ms)

### 8.2 Responsive Design
- Mobile First
- Breakpoints: 600px, 960px, 1280px
- Navigation adaptative (drawer sur mobile)

### 8.3 Accessibilité
- Contraste WCAG AA
- Labels ARIA
- Navigation clavier
- Lecteurs d'écran

---

## 🚀 9. APIS REST

### 9.1 Authentication
```
POST   /api/auth/register          - Inscription employé
POST   /api/auth/login             - Connexion
GET    /api/auth/me                - Profil actuel
POST   /api/auth/refresh           - Refresh token
POST   /api/auth/logout            - Déconnexion
POST   /api/auth/forgot-password   - Mot de passe oublié
POST   /api/auth/reset-password    - Reset mot de passe
```

### 9.2 Users
```
GET    /api/users                  - Liste utilisateurs (Admin/Manager)
GET    /api/users/:id              - Détail utilisateur
GET    /api/users/me               - Mon profil
PUT    /api/users/me/profile       - Mettre à jour mon profil
PUT    /api/users/me/location      - Mettre à jour ma localisation
PUT    /api/users/me/password      - Changer mot de passe
GET    /api/users/pending          - Inscriptions en attente (Manager)
PUT    /api/users/:id/validate     - Valider inscription (Manager)
PUT    /api/users/:id/reject       - Rejeter inscription (Manager)
PUT    /api/users/:id/position     - Modifier poste (Manager)
```

### 9.3 Notifications
```
GET    /api/notifications                    - Mes notifications
GET    /api/notifications/employee           - Notifications employé
POST   /api/notifications/create             - Créer notification (Manager)
PUT    /api/notifications/:id/read           - Marquer comme lu
DELETE /api/notifications/:id                - Supprimer (Admin)
GET    /api/notifications/:id/statistics     - Stats notification (Manager)
```

### 9.4 Objectives
```
GET    /api/objectives/my-objectives         - Mes objectifs
GET    /api/objectives/team                  - Objectifs équipe (Manager)
POST   /api/objectives/create                - Créer objectif (Manager)
GET    /api/objectives/:id                   - Détail objectif
PUT    /api/objectives/:id/status            - Changer statut
PUT    /api/objectives/:id/progress          - Mettre à jour progression
POST   /api/objectives/:id/comments          - Ajouter commentaire
POST   /api/objectives/:id/files             - Upload fichier
DELETE /api/objectives/:id                   - Supprimer (Manager)
```

### 9.5 Messages
```
GET    /api/messages/conversations           - Mes conversations
GET    /api/messages/:conversationId         - Messages conversation
POST   /api/messages                         - Envoyer message
PUT    /api/messages/:id/read                - Marquer comme lu
POST   /api/messages/broadcast               - Message broadcast (Manager)
```

### 9.6 Bus Stops
```
GET    /api/bus-stops                        - Liste arrêts
GET    /api/bus-stops/:id                    - Détail arrêt
POST   /api/bus-stops                        - Créer arrêt (Admin)
PUT    /api/bus-stops/:id                    - Modifier arrêt (Admin)
DELETE /api/bus-stops/:id                    - Supprimer arrêt (Admin)
GET    /api/bus-stops/:id/employees          - Employés de l'arrêt
```

### 9.7 Departments & Teams
```
GET    /api/departments                      - Liste départements
POST   /api/departments                      - Créer département (Admin)
GET    /api/teams                            - Liste équipes
POST   /api/teams                            - Créer équipe (Manager)
```

---

## 📊 10. PERFORMANCES

### 10.1 Optimisations Backend
- Indexation MongoDB (email, role, status)
- Pagination (20 items par page)
- Cache Redis (sessions, données fréquentes)
- Compression gzip
- CDN pour fichiers statiques

### 10.2 Optimisations Frontend
- Lazy loading pages
- Images optimisées (WebP)
- Code splitting
- Service Worker (PWA)
- Cache stratégique

### 10.3 Objectifs Performance
- Time to First Byte: < 200ms
- First Contentful Paint: < 1s
- Temps de chargement page: < 2s
- API response time: < 300ms

---

## 🧪 11. TESTS

### 11.1 Tests Backend
- Tests unitaires (Jest)
- Tests d'intégration (Supertest)
- Tests API (Postman/Newman)
- Coverage: > 80%

### 11.2 Tests Frontend
- Tests widgets (Flutter Test)
- Tests d'intégration
- Tests E2E (Flutter Driver)

### 11.3 Tests Manuels
- Test cases par rôle
- Scénarios utilisateur
- Tests de régression

---

## 📈 12. DÉPLOIEMENT

### 12.1 Environnements
- **Development:** localhost
- **Staging:** staging.draxlmaier-app.com
- **Production:** app.draxlmaier.com

### 12.2 CI/CD
- GitHub Actions
- Tests automatiques
- Build automatique
- Déploiement automatique (staging)
- Déploiement manuel (production)

### 12.3 Monitoring
- Logs centralisés (Winston + CloudWatch)
- Monitoring performances (New Relic)
- Alertes erreurs (Sentry)
- Analytics (Google Analytics)

---

## 📋 13. PLANIFICATION

### Phase 1: Fondations (2 semaines) ✅ COMPLÉTÉ
- Configuration projet
- Modèles de base
- Authentification
- CRUD utilisateurs

### Phase 2: Inscription & Profils (2 semaines) 🔄 EN COURS
- Formulaire inscription publique
- Validation inscriptions (Manager)
- Extension modèle User (localisation, matricule)
- Page profil employé
- Gestion arrêts de bus

### Phase 3: Notifications (1 semaine)
- Système notifications
- Interface création notifications (Manager)
- Affichage notifications employé
- Push notifications (FCM)

### Phase 4: Objectifs (2 semaines)
- Modèle Objectives
- Interface création (Manager)
- Page objectifs employé
- Workspace (fichiers, commentaires)
- Suivi progression

### Phase 5: Chatroom (1 semaine)
- Interface chatroom
- Messages Manager → Employé
- Messages broadcast
- Notifications temps réel

### Phase 6: Polish & Tests (1 semaine)
- Tests complets
- Corrections bugs
- Optimisations
- Documentation

**TOTAL: 9 semaines**

---

## 📞 14. SUPPORT & MAINTENANCE

### 14.1 Documentation
- Documentation technique (API)
- Guide utilisateur par rôle
- FAQ
- Vidéos tutoriels

### 14.2 Maintenance
- Mises à jour sécurité mensuelles
- Corrections bugs prioritaires: 24h
- Évolutions: planifiées trimestriellement

---

## ✅ 15. CRITÈRES D'ACCEPTATION

### 15.1 Inscription
- ✅ Formulaire accessible publiquement
- ✅ Validation email unique
- ✅ Localisation GPS obligatoire
- ✅ Sélection arrêt de bus
- ✅ Status 'pending' après inscription
- ✅ Notification Manager
- ✅ Validation/Rejet par Manager
- ✅ Email confirmation

### 15.2 Profil Employé
- ✅ Affichage informations complètes
- ✅ Modification localisation
- ✅ Modification arrêt bus
- ✅ Restrictions selon rôle
- ✅ Sauvegarde en temps réel

### 15.3 Notifications
- ✅ Création par Manager
- ✅ Ciblage destinataires
- ✅ Affichage employé
- ✅ Marquer comme lu
- ✅ Badge compteur

### 15.4 Objectifs
- ✅ Création par Manager
- ✅ Visualisation employé
- ✅ Changement statut
- ✅ Ajout commentaires
- ✅ Upload fichiers
- ✅ Suivi progression

### 15.5 Chatroom
- ✅ Messages Manager → Employé
- ✅ Réponses employé
- ✅ Temps réel (Socket.io)
- ✅ Historique persisté
- ✅ Notifications messages

---

## 📎 ANNEXES

### A. Glossaire
- **Matricule:** Identifiant unique employé (optionnel)
- **Arrêt de bus:** Point de ramassage transport entreprise
- **Objectif:** Tâche ou mission assignée
- **Workspace:** Espace de travail partagé pour objectif
- **Status pending:** En attente de validation

### B. Références
- Flutter: https://flutter.dev
- Node.js: https://nodejs.org
- MongoDB: https://mongodb.com
- Socket.io: https://socket.io

---

**Document rédigé le:** 28 Novembre 2025  
**Dernière mise à jour:** 28 Novembre 2025  
**Version:** 2.0  
**Auteur:** Équipe Développement Draxlmaier

