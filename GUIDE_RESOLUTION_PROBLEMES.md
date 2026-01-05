# 🔧 Guide de Résolution des Problèmes

## 📋 Problèmes Identifiés et Solutions

### 1. ❌ Objectifs Non Affichés dans le Dashboard Manager

**Problème** : L'API retourne des objectifs mais le frontend affiche "Aucun objectif trouvé"

**Cause Possible** :
- Problème de parsing de la réponse API
- Erreur dans le modèle Objective

**Solution** :
1. Vérifier que l'API retourne bien `objectives` dans la réponse
2. Ajouter des logs pour déboguer :

```dart
// Dans objective_service.dart, ligne 83
if (response.statusCode == 200) {
  final data = json.decode(response.body);
  print('📊 API Response: $data'); // AJOUTEZ CECI
  final objectives = (data['objectives'] as List)
      .map((obj) => Objective.fromJson(obj))
      .toList();
  return objectives;
}
```

### 2. ✅ Erreur de Création d'Objectif (Résolu)

**Problème** : L'API crée l'objectif avec succès mais le frontend affiche une erreur

**Cause** : Le code est correct, l'objectif est bien créé

**Vérification** :
- L'API retourne `status: "success"` ✅
- L'objectif est dans la base de données ✅
- Le frontend devrait afficher le message de succès

### 3. 🔧 Groupes de Département Manquants

**Problème** : Pas de groupes créés automatiquement dans MongoDB

**Solution Complète** :

#### Étape 1 : Initialiser les Groupes

Exécutez le script d'initialisation :

```bash
cd backend
node scripts/initGroups.js
```

Ce script va :
- ✅ Créer les 6 groupes de département
- ✅ Ajouter automatiquement tous les utilisateurs existants à leur groupe
- ✅ Afficher un résumé des groupes créés

#### Étape 2 : Vérifier dans MongoDB

Connectez-vous à MongoDB et vérifiez :

```javascript
// Dans MongoDB Compass ou shell
db.chatgroups.find({ isDepartmentGroup: true })
```

Vous devriez voir 6 groupes :
- Groupe Qualité
- Groupe Logistique
- Groupe MM shift A
- Groupe MM shift B
- Groupe SZB shift A
- Groupe SZB shift B

#### Étape 3 : Auto-ajout des Nouveaux Utilisateurs

**Déjà implémenté** ✅

Lors de l'inscription d'un nouvel utilisateur, il sera automatiquement ajouté à son groupe de département.

Code ajouté dans `authController.js` :
```javascript
// Auto-add user to their department group
if (finalDepartment) {
  const { addUserToDepartmentGroup } = require('../utils/initDepartmentGroups');
  await addUserToDepartmentGroup(user._id, finalDepartment);
}
```

## 🚀 Actions à Effectuer Maintenant

### 1. Initialiser les Groupes de Département

```bash
# Terminal 1 - Arrêter le backend si nécessaire (Ctrl+C)
cd backend
node scripts/initGroups.js
```

**Résultat Attendu** :
```
🚀 Starting department groups initialization...

✅ Found admin user: Admin System

📋 Processing department: Qualité
   👥 Found 2 users
   ✅ Created group: Groupe Qualité
   📊 Group ID: 6946...
   👥 Members added: 2

... (pour chaque département)

✨ Department groups initialization completed!

📊 Summary:
   Total department groups: 6
   - Groupe Qualité: 2 members
   - Groupe Logistique: 1 members
   ...
```

### 2. Redémarrer le Backend

```bash
npm start
```

### 3. Tester dans l'Application

#### Test 1 : Connexion Employé
1. Connectez-vous avec un compte employé (ex: ADEM ADEM)
2. Allez dans "Groupes de Département"
3. **Résultat Attendu** : Vous voyez uniquement votre département (ex: Qualité)

#### Test 2 : Connexion Admin
1. Connectez-vous avec le compte admin
2. Allez dans "Groupes de Département"
3. **Résultat Attendu** : Vous voyez les 6 groupes de départements

#### Test 3 : Création d'Objectif
1. Connectez-vous en tant qu'admin
2. Allez dans "Gestion des Objectifs"
3. Créez un nouvel objectif
4. **Résultat Attendu** : Message de succès + objectif visible dans la liste

## 🔍 Débogage

### Si les Groupes ne s'Affichent Pas

1. **Vérifier la Console Backend** :
```bash
# Regardez les logs du backend
# Vous devriez voir les requêtes GET /api/groups/department/all
```

2. **Vérifier la Console Frontend** :
```dart
// Ouvrez DevTools (F12) dans Chrome
// Regardez l'onglet Console pour les erreurs
```

3. **Vérifier MongoDB** :
```javascript
// Vérifiez que les groupes existent
db.chatgroups.find({ isDepartmentGroup: true }).pretty()

// Vérifiez que les utilisateurs ont un département
db.users.find({}, { firstname: 1, lastname: 1, department: 1 })
```

### Si les Objectifs ne s'Affichent Pas

1. **Vérifier l'API** :
```bash
# Testez directement l'API avec curl ou Postman
GET http://localhost:3000/api/objectives/team/all
Headers: Authorization: Bearer <votre_token>
```

2. **Ajouter des Logs** :
```dart
// Dans manager_objectives_dashboard_screen.dart
Future<void> _loadData() async {
  setState(() => _isLoading = true);
  
  try {
    final objectives = await _objectiveService.getTeamObjectives();
    print('📊 Objectives loaded: ${objectives.length}'); // AJOUTEZ CECI
    setState(() {
      _objectives = objectives;
      _filteredObjectives = objectives;
    });
  } catch (e) {
    print('❌ Error loading objectives: $e'); // AJOUTEZ CECI
    // ...
  }
}
```

## 📊 Structure de la Base de Données

### Collection: chatgroups
```javascript
{
  "_id": ObjectId("..."),
  "name": "Groupe Qualité",
  "description": "Chat de groupe pour le département Qualité",
  "department": "Qualité",
  "isDepartmentGroup": true,
  "members": [ObjectId("..."), ObjectId("...")],
  "admins": [ObjectId("...")],
  "createdBy": ObjectId("..."),
  "createdAt": ISODate("..."),
  "updatedAt": ISODate("...")
}
```

### Collection: users
```javascript
{
  "_id": ObjectId("..."),
  "firstname": "ADEM",
  "lastname": "ADEM",
  "email": "200@gmail.com",
  "department": "Qualité", // IMPORTANT !
  "role": "employee",
  "active": true,
  "status": "active"
}
```

## ✅ Checklist de Vérification

- [ ] Script d'initialisation exécuté
- [ ] 6 groupes créés dans MongoDB
- [ ] Backend redémarré
- [ ] Frontend rafraîchi (F5)
- [ ] Connexion employé → voit son département
- [ ] Connexion admin → voit tous les départements
- [ ] Création d'objectif fonctionne
- [ ] Objectifs affichés dans le dashboard

## 🆘 Support

Si les problèmes persistent :

1. **Vérifiez les logs** :
   - Backend : Terminal où `npm start` est exécuté
   - Frontend : Console Chrome (F12)
   - MongoDB : Vérifiez les données directement

2. **Nettoyez et recommencez** :
```bash
# Backend
cd backend
rm -rf node_modules
npm install
node scripts/initGroups.js
npm start

# Frontend
cd ..
flutter clean
flutter pub get
flutter run -d chrome --web-port 8080
```

3. **Vérifiez les versions** :
   - Node.js : v14+ recommandé
   - Flutter : v3.0+ recommandé
   - MongoDB : v4.4+ recommandé
