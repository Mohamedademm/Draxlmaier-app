# 🚀 NOUVELLES FONCTIONNALITÉS - PHASE 2

## 📋 Vue d'ensemble

Ce document détaille les nouvelles fonctionnalités ajoutées dans la Phase 2 du projet.

---

## ✅ FONCTIONNALITÉS IMPLÉMENTÉES

### 1. 📝 Inscription Publique

**Feature:** Auto-inscription des employés  
**Status:** ✅ Backend implémenté

**Endpoint:** `POST /api/auth/register`

**Description:** Permet aux nouveaux employés de s'inscrire directement sans intervention d'un admin. Le compte est créé avec le statut "pending" et nécessite validation par un manager.

**Request Body:**
```json
{
  "firstname": "John",
  "lastname": "Doe",
  "email": "john.doe@company.com",
  "password": "SecurePass123!",
  "position": "Software Developer",
  "phone": "+33612345678",
  "location": {
    "address": "123 Rue de Paris, 75001 Paris",
    "coordinates": {
      "latitude": 48.8566,
      "longitude": 2.3522
    },
    "busStop": {
      "name": "Arrêt Central",
      "stopId": "507f1f77bcf86cd799439011"
    }
  }
}
```

**Response Success (201):**
```json
{
  "status": "success",
  "message": "Registration successful. Waiting for manager approval.",
  "user": {
    "id": "507f1f77bcf86cd799439012",
    "email": "john.doe@company.com",
    "firstname": "John",
    "lastname": "Doe",
    "status": "pending"
  }
}
```

**Validations:**
- ✅ Email unique
- ✅ Mot de passe min 8 caractères (1 majuscule, 1 minuscule, 1 chiffre)
- ✅ Adresse requise
- ✅ Coordonnées GPS valides
- ✅ Nom arrêt de bus requis

---

### 2. 🔐 Amélioration Connexion

**Status:** ✅ Implémenté

**Modifications Login:**
- Vérification du statut du compte (pending/active/rejected)
- Messages d'erreur spécifiques selon le statut
- Enregistrement de la date de dernière connexion

**Statuts possibles:**
- `pending`: En attente de validation manager
- `active`: Compte validé, accès autorisé
- `rejected`: Inscription rejetée
- `inactive`: Compte désactivé

---

### 3. 📊 Nouveaux Modèles de Données

#### 3.1 User Model (Étendu)

**Nouveaux champs ajoutés:**

```javascript
{
  status: 'pending' | 'active' | 'inactive' | 'rejected',
  employeeId: "EMP001",  // Matricule (optionnel, unique)
  position: "Software Developer",  // Poste de travail
  department: ObjectId,  // Référence Department
  team: ObjectId,  // Référence Team
  
  location: {
    address: "123 Rue de Paris",
    coordinates: {
      latitude: 48.8566,
      longitude: 2.3522
    },
    busStop: {
      name: "Arrêt Central",
      stopId: ObjectId  // Référence BusStop
    }
  },
  
  phone: "+33612345678",
  validatedBy: ObjectId,  // Manager qui a validé
  validatedAt: Date,
  rejectionReason: String,
  lastLogin: Date
}
```

#### 3.2 BusStop Model (Nouveau)

**Schema:**
```javascript
{
  name: "Arrêt Central",
  code: "AC001",
  coordinates: {
    latitude: 48.8566,
    longitude: 2.3522
  },
  address: "Place de la Gare",
  capacity: 50,  // Nombre max d'employés
  schedule: [{
    time: "08:00",
    direction: "toWork" | "fromWork"
  }],
  active: true,
  notes: "Près de la gare"
}
```

**Virtuals:**
- `employeeCount`: Nombre d'employés utilisant cet arrêt

#### 3.3 Objective Model (Nouveau)

**Schema:**
```javascript
{
  title: "Développer nouvelle feature",
  description: "Description détaillée...",
  
  assignedTo: ObjectId,  // Employé
  assignedBy: ObjectId,  // Manager
  team: ObjectId,
  department: ObjectId,
  
  status: "todo" | "in_progress" | "completed" | "blocked",
  priority: "low" | "medium" | "high" | "urgent",
  
  startDate: Date,
  dueDate: Date,
  completedAt: Date,
  progress: 75,  // 0-100
  
  files: [{
    filename: "document.pdf",
    url: "https://...",
    size: 1024,
    uploadedBy: ObjectId,
    uploadedAt: Date
  }],
  
  links: [{
    title: "Documentation",
    url: "https://...",
    addedAt: Date
  }],
  
  notes: "Notes personnelles...",
  
  comments: [{
    userId: ObjectId,
    text: "Commentaire...",
    createdAt: Date
  }],
  
  blockReason: "En attente validation client"
}
```

---

## 🔜 PROCHAINES ÉTAPES

### À implémenter (Backend):

1. **Gestion Inscriptions Manager**
   - `GET /api/users/pending` - Liste inscriptions en attente
   - `PUT /api/users/:id/validate` - Valider inscription
   - `PUT /api/users/:id/reject` - Rejeter inscription

2. **Gestion Bus Stops**
   - `GET /api/bus-stops` - Liste arrêts
   - `POST /api/bus-stops` - Créer arrêt (Admin)
   - `PUT /api/bus-stops/:id` - Modifier arrêt
   - `GET /api/bus-stops/:id/employees` - Employés par arrêt

3. **Gestion Objectifs**
   - `GET /api/objectives/my-objectives` - Mes objectifs
   - `POST /api/objectives/create` - Créer objectif (Manager)
   - `PUT /api/objectives/:id/status` - Changer statut
   - `POST /api/objectives/:id/comments` - Ajouter commentaire
   - `POST /api/objectives/:id/files` - Upload fichier

4. **Notifications Avancées**
   - `POST /api/notifications/create` - Créer notification (Manager)
   - `GET /api/notifications/employee` - Notifications employé
   - Ciblage: tous, équipe, département, spécifiques

5. **Profil Employé**
   - `PUT /api/users/me/location` - Mise à jour localisation
   - `PUT /api/users/:id/position` - Modifier poste (Manager)

### À implémenter (Frontend Flutter):

1. **Page Inscription**
   - Formulaire complet
   - Sélection localisation (map picker)
   - Dropdown arrêts de bus
   - Validation temps réel

2. **Pages Employé**
   - Home (feed notifications)
   - Profil (édition localisation)
   - Objectifs (liste + workspace)
   - Chatroom

3. **Pages Manager**
   - Validation inscriptions
   - Création notifications
   - Gestion objectifs équipe
   - Modification postes

---

## 📝 NOTES D'IMPLÉMENTATION

### Sécurité
- Mots de passe hashés avec bcrypt (10 rounds)
- Validation stricte des coordonnées GPS
- Rate limiting sur inscription (5/15min)
- Status 'pending' par défaut (sécurité)

### Base de données
- Indexes ajoutés pour performance
- Sparse index sur employeeId (unique mais optionnel)
- Geospatial index sur coordonnées bus stops
- Cascade delete à gérer (user → objectives)

### Tests nécessaires
- [ ] Test inscription avec données valides
- [ ] Test inscription email dupliqué
- [ ] Test login statut pending
- [ ] Test login statut rejected
- [ ] Test validation inscriptions
- [ ] Test CRUD bus stops
- [ ] Test CRUD objectives

---

## 🎯 CAHIER DES CHARGES

Le cahier des charges complet est disponible dans: `CAHIER_DES_CHARGES.md`

**Sections principales:**
- Acteurs du système (Admin, Manager, Employé)
- Pages et fonctionnalités par rôle
- Modèles de données détaillés
- Workflows complets
- APIs REST complètes
- Sécurité et performances
- Planning (9 semaines total)

---

## 🚀 LANCEMENT

### Backend
```bash
cd backend
npm start
```

### Tester l'inscription
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "firstname": "Test",
    "lastname": "User",
    "email": "test@company.com",
    "password": "TestPass123!",
    "position": "Developer",
    "phone": "+33612345678",
    "location": {
      "address": "123 Test Street",
      "coordinates": {
        "latitude": 48.8566,
        "longitude": 2.3522
      },
      "busStop": {
        "name": "Test Stop"
      }
    }
  }'
```

---

**Date:** 28 Novembre 2025  
**Version:** 2.0
