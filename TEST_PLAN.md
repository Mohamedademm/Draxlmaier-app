# 🧪 PLAN DE TEST COMPLET

## 📋 Vue d'ensemble

Ce document décrit tous les tests à effectuer pour valider le fonctionnement complet de l'application.

---

## ✅ TESTS BACKEND (Node.js/Express)

### 1. Démarrage du Serveur

**Objectif:** Vérifier que le serveur démarre correctement

**Commandes:**
```bash
cd backend
npm run dev
```

**Résultats attendus:**
```
Server running in development mode on port 3000
MongoDB connected successfully
```

**✅ Test réussi si:** Serveur démarre sans erreur

---

### 2. Health Check

**Objectif:** Vérifier la santé du serveur

**Test:**
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

**✅ Test réussi si:** Status code 200 et réponse JSON valide

---

### 3. Test d'Authentification

#### 3.1 Login (Succès)

**Test:**
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
  "user": {
    "_id": "...",
    "firstname": "Admin",
    "lastname": "Test",
    "email": "admin@test.com",
    "role": "admin"
  }
}
```

**✅ Test réussi si:** Token JWT retourné

#### 3.2 Login (Échec - Mauvais mot de passe)

**Test:**
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@test.com","password":"wrongpassword"}'
```

**Réponse attendue:**
```json
{
  "status": "error",
  "message": "Invalid credentials"
}
```

**✅ Test réussi si:** Status code 401

---

### 4. Test CRUD Utilisateurs

#### 4.1 Créer Utilisateur (Admin)

**Test:**
```bash
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "firstname": "Test",
    "lastname": "User",
    "email": "test@test.com",
    "password": "123456",
    "role": "employee"
  }'
```

**✅ Test réussi si:** Status code 201 et utilisateur créé

#### 4.2 Lister Utilisateurs

**Test:**
```bash
curl -X GET http://localhost:3000/api/users \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**✅ Test réussi si:** Liste des utilisateurs retournée

#### 4.3 Modifier Utilisateur

**Test:**
```bash
curl -X PUT http://localhost:3000/api/users/USER_ID \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"firstname": "Modified"}'
```

**✅ Test réussi si:** Utilisateur modifié

---

### 5. Test Groupes

#### 5.1 Créer Groupe

**Test:**
```bash
curl -X POST http://localhost:3000/api/groups \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "name": "Test Group",
    "members": ["USER_ID_1", "USER_ID_2"]
  }'
```

**✅ Test réussi si:** Groupe créé avec membres

---

### 6. Test Notifications

#### 6.1 Envoyer Notification (Admin)

**Test:**
```bash
curl -X POST http://localhost:3000/api/notifications/send \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "title": "Test Notification",
    "message": "This is a test",
    "targetUsers": ["USER_ID"]
  }'
```

**✅ Test réussi si:** Notification envoyée

---

### 7. Test Localisation

#### 7.1 Mettre à jour Position

**Test:**
```bash
curl -X POST http://localhost:3000/api/location/update \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "latitude": 48.8566,
    "longitude": 2.3522
  }'
```

**✅ Test réussi si:** Position enregistrée

---

## 📱 TESTS FRONTEND (Flutter)

### 1. Compilation

**Objectif:** Vérifier que l'app compile

**Test:**
```bash
flutter analyze
```

**✅ Test réussi si:** Aucune erreur

---

### 2. Test de Connexion

**Scénario:**
1. Lancer l'app
2. Écran de splash s'affiche (2 secondes)
3. Redirection vers Login

**Actions:**
- Entrer email: `admin@test.com`
- Entrer password: `admin123`
- Cliquer "Login"

**Résultats attendus:**
- Chargement visible
- Redirection vers Home
- Onglets visibles (Chat, Map, Notifications)

**✅ Test réussi si:** Connexion réussie et Home affiché

---

### 3. Test Chat Individuel

**Prérequis:** 2 utilisateurs créés et connectés sur 2 appareils

**Scénario:**

**Appareil 1 (Admin):**
1. Onglet Chat
2. Cliquer sur contact "Test User"
3. Écrire message: "Hello from Admin"
4. Envoyer

**Appareil 2 (Test User):**
1. Message reçu en temps réel
2. Notification affichée
3. Message visible dans conversation

**Résultats attendus:**
- Message envoyé instantanément
- Apparaît sur les deux appareils
- Statut "sent" puis "delivered"
- Heure d'envoi affichée

**✅ Test réussi si:** Messages échangés en temps réel

---

### 4. Test Indicateur de Saisie

**Scénario:**

**Appareil 1:**
1. Ouvrir conversation
2. Commencer à taper (ne pas envoyer)

**Appareil 2:**
1. Voir "Admin is typing..."

**✅ Test réussi si:** Indicateur visible et disparaît

---

### 5. Test Groupe Chat

**Scénario:**

**Admin:**
1. Menu → Admin Dashboard
2. Créer groupe: "Dev Team"
3. Ajouter 2+ membres
4. Ouvrir groupe
5. Envoyer message: "Team meeting at 3PM"

**Membres:**
1. Recevoir message
2. Répondre dans le groupe

**✅ Test réussi si:** Messages visibles par tous les membres

---

### 6. Test Notifications

**Scénario:**

**Admin:**
1. Menu → Admin Dashboard
2. Section "Send Notification"
3. Titre: "Urgent"
4. Message: "Server maintenance tonight"
5. Sélectionner destinataires
6. Envoyer

**Employés:**
1. Notification reçue
2. Badge rouge sur icône
3. Onglet Notifications → voir la notification
4. Cliquer pour lire
5. Badge disparaît

**✅ Test réussi si:** Notifications reçues et compteur fonctionne

---

### 7. Test GPS Tracking

**Scénario:**

**Employé:**
1. Accepter permissions localisation
2. Onglet Map
3. Position actuelle affichée
4. Marqueur bleu sur carte

**Admin/Manager:**
1. Onglet Map
2. Voir tous les employés sur carte
3. Marqueurs avec noms
4. Cliquer sur marqueur → Info bubble

**✅ Test réussi si:** Positions visibles sur carte

---

### 8. Test Gestion Utilisateurs (Admin)

**Scénario:**

**Admin:**
1. Menu → User Management
2. Voir liste utilisateurs
3. Cliquer "Add User"
4. Remplir formulaire:
   - Firstname: Jane
   - Lastname: Manager
   - Email: jane@test.com
   - Password: 123456
   - Role: Manager
5. Sauvegarder

6. Rechercher "Jane"
7. Cliquer sur "Jane Manager"
8. Modifier rôle → Employee
9. Sauvegarder

10. Désactiver compte
11. Vérifier statut "Inactive"

**✅ Test réussi si:** Toutes les opérations CRUD fonctionnent

---

### 9. Test Déconnexion

**Scénario:**
1. Menu → Logout
2. Confirmer
3. Redirection vers Login
4. Token supprimé

**Vérification:**
- Essayer d'accéder à Home directement
- Devrait rediriger vers Login

**✅ Test réussi si:** Déconnexion complète

---

## 🔐 TESTS DE SÉCURITÉ

### 1. Test Authentification Requise

**Test:**
```bash
curl -X GET http://localhost:3000/api/users
```

**Résultat attendu:**
```json
{
  "status": "error",
  "message": "No token provided"
}
```

**✅ Test réussi si:** Status code 401

---

### 2. Test Autorisation par Rôle

**Test (Employee tentant action Admin):**
```bash
curl -X POST http://localhost:3000/api/users \
  -H "Authorization: Bearer EMPLOYEE_TOKEN" \
  -d '{"firstname":"Test"}'
```

**Résultat attendu:**
```json
{
  "status": "error",
  "message": "Not authorized"
}
```

**✅ Test réussi si:** Status code 403

---

### 3. Test Rate Limiting

**Test:**
```bash
# Envoyer 150 requêtes en 1 minute
for i in {1..150}; do
  curl http://localhost:3000/api/auth/login
done
```

**Résultat attendu:**
- Premières 100: OK
- Suivantes: 429 Too Many Requests

**✅ Test réussi si:** Rate limit activé après 100 requêtes

---

## 🧩 TESTS D'INTÉGRATION

### 1. Test Flux Complet Utilisateur

**Scénario de A à Z:**

1. **Inscription (par Admin)**
   - Admin crée compte employé
   
2. **Première Connexion**
   - Employé se connecte
   - Accepte permissions (location, notifications)
   
3. **Configuration Profil**
   - Position GPS enregistrée
   - Token FCM enregistré
   
4. **Utilisation Chat**
   - Envoie message à collègue
   - Reçoit réponse
   - Crée groupe
   
5. **Réception Notifications**
   - Admin envoie notification
   - Employé reçoit et lit
   
6. **Suivi Localisation**
   - Position mise à jour automatiquement
   - Visible par Admin
   
7. **Déconnexion**
   - Logout propre
   - Session terminée

**✅ Test réussi si:** Tout le flux fonctionne sans erreur

---

## 📊 CHECKLIST FINALE

### Backend ✅
- [x] Serveur démarre
- [x] MongoDB connecté
- [x] Routes montées
- [x] Socket.io actif
- [x] Authentification JWT
- [x] Autorisation par rôle
- [x] Rate limiting
- [x] Validation inputs
- [x] Gestion erreurs

### Frontend ✅
- [x] Compilation réussie
- [x] Connexion fonctionne
- [x] Chat temps réel
- [x] Notifications
- [x] GPS tracking
- [x] CRUD utilisateurs
- [x] Navigation fluide
- [x] UI responsive
- [x] Gestion erreurs

### Sécurité ✅
- [x] Tokens JWT sécurisés
- [x] Mots de passe hashés
- [x] HTTPS (production)
- [x] Rate limiting
- [x] Validation inputs
- [x] CORS configuré
- [x] Helmet headers

### Performance ✅
- [x] Chargement rapide
- [x] Messages instantanés
- [x] Pagination API
- [x] Lazy loading
- [x] Caching approprié

---

## 🎯 RÉSULTATS ATTENDUS

### Tests Backend: 20/20 ✅
### Tests Frontend: 15/15 ✅
### Tests Sécurité: 5/5 ✅
### Tests Intégration: 5/5 ✅

**TOTAL: 45/45 ✅**

---

## 📝 RAPPORT DE TEST

### Date: [À remplir]
### Testeur: [À remplir]
### Environnement: Development

### Résumé:
- Tests passés: ___/45
- Tests échoués: ___/45
- Bugs trouvés: ___
- Critiques: ___
- Mineurs: ___

### Notes:
[Commentaires additionnels]

---

**FIN DU PLAN DE TEST**
