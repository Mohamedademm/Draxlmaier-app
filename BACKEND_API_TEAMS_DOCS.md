# 🎉 Backend Teams & Departments API - Documentation

## ✅ Statut: Phase 1 Complétée!

### 📊 Ce qui a été fait

**Models créés:**
- ✅ `backend/models/Team.js` - Schéma complet avec méthodes
- ✅ `backend/models/Department.js` - Schéma avec virtuals

**Controllers créés:**
- ✅ `backend/controllers/teamController.js` - 8 méthodes CRUD
- ✅ `backend/controllers/departmentController.js` - 7 méthodes CRUD

**Routes créées:**
- ✅ `backend/routes/teams.js` - Routes protégées avec authorization
- ✅ `backend/routes/departments.js` - Routes protégées avec authorization

**Utilitaires créés:**
- ✅ `backend/utils/appError.js` - Custom error class
- ✅ `backend/utils/catchAsync.js` - Async error wrapper

**Scripts utilitaires:**
- ✅ `backend/populate-teams.js` - Script de peuplement (4 teams, 3 départements)

**Intégration:**
- ✅ Routes ajoutées à `backend/server.js`
- ✅ Serveur backend actif sur port 3000

---

## 📚 API Endpoints

### 🔐 Authentification

Tous les endpoints nécessitent un token JWT dans le header:
```
Authorization: Bearer <token>
```

Pour obtenir un token, utilisez:
```bash
POST http://localhost:3000/api/auth/login
Content-Type: application/json

{
  "email": "admin@company.com",
  "password": "admin123"
}
```

---

## 👥 Teams API

### GET /api/teams
**Description:** Récupère toutes les équipes  
**Auth:** Tous les utilisateurs connectés  
**Query params:**
- `isActive` (boolean): Filtrer par statut actif
- `department` (string): Filtrer par département ID

**Response:**
```json
{
  "status": "success",
  "results": 4,
  "data": [
    {
      "_id": "...",
      "name": "Development Team",
      "description": "Core software development",
      "department": {
        "_id": "...",
        "name": "IT & Technology"
      },
      "leader": {
        "_id": "...",
        "firstname": "Jean",
        "lastname": "Dupont"
      },
      "members": [...],
      "color": "#2196F3",
      "isActive": true,
      "memberCount": 2
    }
  ]
}
```

---

### GET /api/teams/:id
**Description:** Récupère une équipe spécifique  
**Auth:** Tous les utilisateurs connectés

---

### POST /api/teams
**Description:** Crée une nouvelle équipe  
**Auth:** Admin, Manager  
**Body:**
```json
{
  "name": "New Team",
  "description": "Team description",
  "department": "departmentId",
  "leader": "userId",
  "members": ["userId1", "userId2"],
  "color": "#FF5722"
}
```

---

### PUT /api/teams/:id
**Description:** Met à jour une équipe  
**Auth:** Admin, Manager  
**Body:** (tous les champs optionnels)
```json
{
  "name": "Updated Name",
  "description": "New description",
  "isActive": false
}
```

---

### DELETE /api/teams/:id
**Description:** Supprime une équipe (soft delete)  
**Auth:** Admin seulement

---

### GET /api/teams/:id/members
**Description:** Récupère tous les membres d'une équipe  
**Auth:** Tous les utilisateurs connectés

---

### POST /api/teams/:id/members
**Description:** Ajoute un membre à une équipe  
**Auth:** Admin, Manager  
**Body:**
```json
{
  "userId": "userId"
}
```

---

### DELETE /api/teams/:id/members/:userId
**Description:** Retire un membre d'une équipe  
**Auth:** Admin, Manager

---

## 🏢 Departments API

### GET /api/departments
**Description:** Récupère tous les départements  
**Auth:** Tous les utilisateurs connectés  
**Query params:**
- `isActive` (boolean): Filtrer par statut actif

**Response:**
```json
{
  "status": "success",
  "results": 3,
  "data": [
    {
      "_id": "...",
      "name": "IT & Technology",
      "description": "IT and Software Development",
      "manager": {
        "_id": "...",
        "firstname": "Jean",
        "lastname": "Dupont"
      },
      "location": "Building A, Floor 3",
      "budget": 500000,
      "employeeCount": 3,
      "color": "#2196F3",
      "isActive": true
    }
  ]
}
```

---

### GET /api/departments/:id
**Description:** Récupère un département spécifique avec ses équipes  
**Auth:** Tous les utilisateurs connectés

---

### POST /api/departments
**Description:** Crée un nouveau département  
**Auth:** Admin seulement  
**Body:**
```json
{
  "name": "New Department",
  "description": "Department description",
  "manager": "userId",
  "location": "Building C",
  "budget": 250000,
  "color": "#E91E63"
}
```

---

### PUT /api/departments/:id
**Description:** Met à jour un département  
**Auth:** Admin, Manager  
**Body:** (tous les champs optionnels)
```json
{
  "name": "Updated Name",
  "budget": 300000,
  "employeeCount": 5
}
```

---

### DELETE /api/departments/:id
**Description:** Supprime un département (soft delete)  
**Auth:** Admin seulement  
**Note:** Impossible si le département a des équipes actives

---

### GET /api/departments/:id/teams
**Description:** Récupère toutes les équipes d'un département  
**Auth:** Tous les utilisateurs connectés

---

### GET /api/departments/:id/stats
**Description:** Récupère les statistiques d'un département  
**Auth:** Tous les utilisateurs connectés

**Response:**
```json
{
  "status": "success",
  "data": {
    "department": {
      "id": "...",
      "name": "IT & Technology"
    },
    "stats": {
      "totalTeams": 2,
      "totalEmployees": 3,
      "avgTeamSize": 1.5,
      "budget": 500000
    }
  }
}
```

---

## 📝 Données de Test

### Comptes Utilisateurs
```
Admin:    admin@company.com / admin123
Manager:  jean.dupont@company.com / jean123
Employee: sarah.martin@company.com / sarah123
Employee: marie.dubois@company.com / marie123
Employee: adem@gamil.com / adem123
```

### Départements Créés
1. **IT & Technology** (Manager: Jean Dupont)
   - Budget: 500,000€
   - Location: Building A, Floor 3

2. **Human Resources** (Manager: Sarah Martin)
   - Budget: 200,000€
   - Location: Building B, Floor 1

3. **Sales & Marketing** (Manager: Marie Dubois)
   - Budget: 350,000€
   - Location: Building A, Floor 2

### Équipes Créées
1. **Development Team** (Leader: Jean, 2 membres)
2. **HR Operations** (Leader: Sarah, 1 membre)
3. **Sales Team** (Leader: Marie, 1 membre)
4. **Technical Support** (Leader: Adem, 1 membre)

---

## 🧪 Tester l'API

### Avec cURL

1. **Login et récupérer le token:**
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@company.com","password":"admin123"}'
```

2. **Récupérer toutes les équipes:**
```bash
curl http://localhost:3000/api/teams \
  -H "Authorization: Bearer YOUR_TOKEN"
```

3. **Créer une nouvelle équipe:**
```bash
curl -X POST http://localhost:3000/api/teams \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "QA Team",
    "description": "Quality Assurance",
    "leader": "USER_ID",
    "members": [],
    "color": "#9C27B0"
  }'
```

### Avec PowerShell

```powershell
# Login
$response = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/login" `
  -Method Post `
  -ContentType "application/json" `
  -Body '{"email":"admin@company.com","password":"admin123"}'

$token = $response.token

# Get teams
Invoke-RestMethod -Uri "http://localhost:3000/api/teams" `
  -Headers @{"Authorization"="Bearer $token"}
```

---

## 🔄 Prochaines Étapes (Semaine 2)

### Frontend Integration
- [ ] Créer `lib/models/team_model.dart`
- [ ] Créer `lib/models/department_model.dart`
- [ ] Créer `lib/services/team_service.dart`
- [ ] Créer `lib/services/department_service.dart`
- [ ] Créer `lib/providers/team_provider.dart`
- [ ] Connecter `team_management_screen.dart` avec l'API réelle
- [ ] Remplacer les données mock par des appels API

### Tests
- [ ] Tests unitaires controllers
- [ ] Tests d'intégration endpoints
- [ ] Tests de permissions (admin vs manager vs employee)

---

## 📋 Notes Importantes

### Permissions
- **Employee:** Lecture seule (GET teams, departments)
- **Manager:** Lecture + Création/Modification équipes et départements
- **Admin:** Tous les droits incluant suppression

### Soft Delete
- Les suppressions sont logiques (isActive=false)
- Les données ne sont jamais vraiment supprimées
- Filtrer par `isActive=true` pour récupérer uniquement les actifs

### Validation
- Noms d'équipes/départements uniques
- Leader et Manager doivent exister
- Membres doivent exister
- Impossible de retirer le leader d'une équipe
- Impossible de supprimer un département avec des équipes actives

---

## 🎯 Résumé

✅ **Backend Teams & Departments API complètement fonctionnel!**

- 8 endpoints Teams
- 7 endpoints Departments
- Authentication & Authorization
- Data validation
- Error handling
- Test data populated

**Serveur actif:** http://localhost:3000  
**Status:** ✅ Prêt pour intégration frontend!
