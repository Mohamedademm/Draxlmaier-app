# 📋 PLAN DE TRAVAIL COMPLÉTÉ - Prochaines Étapes

## ✅ TRAVAIL ACCOMPLI (27-28 Nov 2025)

### Phase 1: Corrections & Fonctionnalités de Base ✅
- [x] Support multi-langue FR/EN complet
- [x] Gestion avancée des équipes (interface)
- [x] Correction bugs setState
- [x] Correction erreur notifications 400
- [x] Correction Google Maps web
- [x] Création comptes employés test
- [x] Documentation complète (3 documents)

---

## 🎯 PLAN D'ACTION PRIORITAIRE (Semaines 1-4)

### SEMAINE 1: Corrections & Backend Teams (29 Nov - 5 Déc)

#### Jour 1-2: Finir Corrections Critiques
- [ ] **Fix compilation errors** - team_management_screen.dart ✅ EN COURS
- [ ] **Tester tous les comptes utilisateurs**:
  ```
  Admin: admin@company.com / admin123
  Manager: jean.dupont@company.com / jean123
  Employee: adem@gamil.com / adem123
  Employee: sarah.martin@company.com / sarah123
  Employee: marie.dubois@company.com / marie123
  ```
- [ ] **Vérifier fonctionnalités par rôle**:
  - Admin: Accès Team Management, User Management, Dashboard
  - Manager: Accès limité (pas de delete users)
  - Employee: Vue basique (chat, notifications, profil)

#### Jour 3-5: Backend Équipes & Départements
**Fichiers à créer:**

```javascript
// backend/models/Team.js
const mongoose = require('mongoose');

const teamSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  description: String,
  department: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Department'
  },
  leader: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  members: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  avatar: String,
  isActive: {
    type: Boolean,
    default: true
  }
}, { timestamps: true });

module.exports = mongoose.model('Team', teamSchema);
```

```javascript
// backend/models/Department.js
const mongoose = require('mongoose');

const departmentSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  description: String,
  manager: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  location: String,
  isActive: {
    type: Boolean,
    default: true
  }
}, { timestamps: true });

module.exports = mongoose.model('Department', departmentSchema);
```

```javascript
// backend/controllers/teamController.js
const Team = require('../models/Team');

// GET /api/teams
exports.getTeams = async (req, res, next) => {
  try {
    const teams = await Team.find({ isActive: true })
      .populate('department', 'name')
      .populate('leader', 'firstname lastname email')
      .populate('members', 'firstname lastname email');
    
    res.json({
      status: 'success',
      data: teams
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/teams
exports.createTeam = async (req, res, next) => {
  try {
    const { name, description, department, leader, members } = req.body;
    
    const team = new Team({
      name,
      description,
      department,
      leader,
      members
    });
    
    await team.save();
    await team.populate(['department', 'leader', 'members']);
    
    res.status(201).json({
      status: 'success',
      data: team
    });
  } catch (error) {
    next(error);
  }
};

// PUT /api/teams/:id
exports.updateTeam = async (req, res, next) => {
  try {
    const team = await Team.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    ).populate(['department', 'leader', 'members']);
    
    if (!team) {
      return res.status(404).json({
        status: 'error',
        message: 'Team not found'
      });
    }
    
    res.json({
      status: 'success',
      data: team
    });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/teams/:id
exports.deleteTeam = async (req, res, next) => {
  try {
    const team = await Team.findByIdAndUpdate(
      req.params.id,
      { isActive: false },
      { new: true }
    );
    
    if (!team) {
      return res.status(404).json({
        status: 'error',
        message: 'Team not found'
      });
    }
    
    res.json({
      status: 'success',
      message: 'Team deleted successfully'
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/teams/:id/members/:userId
exports.addMember = async (req, res, next) => {
  try {
    const team = await Team.findById(req.params.id);
    
    if (!team) {
      return res.status(404).json({
        status: 'error',
        message: 'Team not found'
      });
    }
    
    if (!team.members.includes(req.params.userId)) {
      team.members.push(req.params.userId);
      await team.save();
    }
    
    await team.populate('members');
    
    res.json({
      status: 'success',
      data: team
    });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/teams/:id/members/:userId
exports.removeMember = async (req, res, next) => {
  try {
    const team = await Team.findById(req.params.id);
    
    if (!team) {
      return res.status(404).json({
        status: 'error',
        message: 'Team not found'
      });
    }
    
    team.members = team.members.filter(
      m => m.toString() !== req.params.userId
    );
    
    await team.save();
    await team.populate('members');
    
    res.json({
      status: 'success',
      data: team
    });
  } catch (error) {
    next(error);
  }
};
```

```javascript
// backend/routes/teams.js
const express = require('express');
const router = express.Router();
const teamController = require('../controllers/teamController');
const { protect, restrictTo } = require('../middleware/auth');

// Protect all routes
router.use(protect);

// Routes
router
  .route('/')
  .get(teamController.getTeams)
  .post(restrictTo('admin', 'manager'), teamController.createTeam);

router
  .route('/:id')
  .put(restrictTo('admin', 'manager'), teamController.updateTeam)
  .delete(restrictTo('admin'), teamController.deleteTeam);

router
  .route('/:id/members/:userId')
  .post(restrictTo('admin', 'manager'), teamController.addMember)
  .delete(restrictTo('admin', 'manager'), teamController.removeMember);

module.exports = router;
```

**Tâches:**
- [ ] Créer `backend/models/Team.js`
- [ ] Créer `backend/models/Department.js`
- [ ] Créer `backend/controllers/teamController.js`
- [ ] Créer `backend/controllers/departmentController.js`
- [ ] Créer `backend/routes/teams.js`
- [ ] Créer `backend/routes/departments.js`
- [ ] Ajouter routes dans `backend/server.js`
- [ ] Tester avec Postman/Thunder Client

---

### SEMAINE 2: Intégration Frontend-Backend (6-12 Déc)

#### Jour 1-3: Services & Providers
```dart
// lib/services/team_service.dart
class TeamService {
  final ApiService _apiService = ApiService();
  
  Future<List<Team>> getTeams() async {
    final response = await _apiService.get('/teams');
    return (response['data'] as List)
        .map((json) => Team.fromJson(json))
        .toList();
  }
  
  Future<Team> createTeam(Map<String, dynamic> data) async {
    final response = await _apiService.post('/teams', data);
    return Team.fromJson(response['data']);
  }
  
  Future<Team> updateTeam(String id, Map<String, dynamic> data) async {
    final response = await _apiService.put('/teams/$id', data);
    return Team.fromJson(response['data']);
  }
  
  Future<void> deleteTeam(String id) async {
    await _apiService.delete('/teams/$id');
  }
  
  Future<Team> addMember(String teamId, String userId) async {
    final response = await _apiService.post('/teams/$teamId/members/$userId');
    return Team.fromJson(response['data']);
  }
  
  Future<Team> removeMember(String teamId, String userId) async {
    final response = await _apiService.delete('/teams/$teamId/members/$userId');
    return Team.fromJson(response['data']);
  }
}

// lib/providers/team_provider.dart
class TeamProvider with ChangeNotifier {
  final TeamService _teamService = TeamService();
  
  List<Team> _teams = [];
  List<Department> _departments = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<Team> get teams => _teams;
  List<Department> get departments => _departments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<void> loadTeams() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _teams = await _teamService.getTeams();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> createTeam(Map<String, dynamic> data) async {
    try {
      final team = await _teamService.createTeam(data);
      _teams.add(team);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  // ... autres méthodes
}
```

**Tâches:**
- [ ] Créer `lib/models/team_model.dart`
- [ ] Créer `lib/models/department_model.dart`
- [ ] Créer `lib/services/team_service.dart`
- [ ] Créer `lib/services/department_service.dart`
- [ ] Créer `lib/providers/team_provider.dart`
- [ ] Intégrer TeamProvider dans main.dart
- [ ] Connecter team_management_screen avec vrais données

#### Jour 4-5: Tests & Debug
- [ ] Créer données test (script populate)
- [ ] Tester CRUD complet équipes
- [ ] Tester CRUD complet départements
- [ ] Vérifier permissions (admin vs manager vs employee)
- [ ] Fix bugs

---

### SEMAINE 3: Analytics Dashboard (13-19 Déc)

#### Package Installation
```yaml
dependencies:
  fl_chart: ^0.68.0
  intl: ^0.19.0  # Déjà installé
```

#### Jour 1-2: Backend Analytics
```javascript
// backend/controllers/analyticsController.js
exports.getDashboardStats = async (req, res) => {
  try {
    // Users stats
    const totalUsers = await User.countDocuments({ active: true });
    const newUsersThisWeek = await User.countDocuments({
      createdAt: { $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) }
    });
    
    // Messages stats
    const totalMessages = await Message.countDocuments();
    const messagesLastWeek = await Message.aggregate([
      {
        $match: {
          createdAt: { $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) }
        }
      },
      {
        $group: {
          _id: { $dateToString: { format: "%Y-%m-%d", date: "$createdAt" } },
          count: { $sum: 1 }
        }
      },
      { $sort: { _id: 1 } }
    ]);
    
    // Notifications stats
    const totalNotifications = await Notification.countDocuments();
    const unreadNotifications = await Notification.countDocuments({
      readBy: { $size: 0 }
    });
    
    // Teams & Departments
    const totalTeams = await Team.countDocuments({ isActive: true });
    const totalDepartments = await Department.countDocuments({ isActive: true });
    
    // Users by role
    const usersByRole = await User.aggregate([
      { $match: { active: true } },
      { $group: { _id: "$role", count: { $sum: 1 } } }
    ]);
    
    // Activity by department
    const activityByDept = await Message.aggregate([
      {
        $lookup: {
          from: 'users',
          localField: 'senderId',
          foreignField: '_id',
          as: 'sender'
        }
      },
      { $unwind: '$sender' },
      {
        $lookup: {
          from: 'teams',
          localField: 'sender._id',
          foreignField: 'members',
          as: 'team'
        }
      },
      { $unwind: { path: '$team', preserveNullAndEmptyArrays: true } },
      {
        $lookup: {
          from: 'departments',
          localField: 'team.department',
          foreignField: '_id',
          as: 'department'
        }
      },
      { $unwind: { path: '$department', preserveNullAndEmptyArrays: true } },
      {
        $group: {
          _id: '$department.name',
          count: { $sum: 1 }
        }
      }
    ]);
    
    res.json({
      status: 'success',
      data: {
        users: {
          total: totalUsers,
          newThisWeek: newUsersThisWeek,
          byRole: usersByRole
        },
        messages: {
          total: totalMessages,
          lastWeek: messagesLastWeek
        },
        notifications: {
          total: totalNotifications,
          unread: unreadNotifications
        },
        teams: totalTeams,
        departments: totalDepartments,
        activityByDepartment: activityByDept
      }
    });
  } catch (error) {
    next(error);
  }
};
```

#### Jour 3-5: Frontend Charts
- [ ] Créer `lib/screens/analytics_dashboard_screen.dart`
- [ ] Line Chart: Messages par jour
- [ ] Bar Chart: Activité par département
- [ ] Pie Chart: Utilisateurs par rôle
- [ ] Cards statistiques (total users, messages, etc.)
- [ ] Filtres temporels (7j, 30j, 90j, année)

---

### SEMAINE 4: Système de Fichiers (20-26 Déc)

#### Backend Setup
```bash
npm install multer sharp
```

```javascript
// backend/config/multer.js
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const fileFilter = (req, file, cb) => {
  // Allowed types
  const allowedTypes = /jpeg|jpg|png|gif|pdf|doc|docx|xls|xlsx|ppt|pptx|zip/;
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = allowedTypes.test(file.mimetype);
  
  if (mimetype && extname) {
    return cb(null, true);
  }
  cb(new Error('Invalid file type. Only images and documents allowed.'));
};

const upload = multer({
  storage,
  limits: { fileSize: 50 * 1024 * 1024 }, // 50MB
  fileFilter
});

module.exports = upload;
```

#### Frontend File Picker
```yaml
dependencies:
  file_picker: ^6.1.1
  dio: ^5.4.0  # Pour upload avec progress
```

**Tâches:**
- [ ] Backend upload endpoint
- [ ] File model & storage
- [ ] Frontend file picker
- [ ] Upload avec progress bar
- [ ] Preview images/PDF
- [ ] Download files
- [ ] Partage dans chats

---

## 🗓️ ROADMAP COMPLÈTE (4 Mois)

### MOIS 1 (Décembre): Fondations Backend & Analytics
- ✅ Semaine 1: Backend Teams API
- ✅ Semaine 2: Intégration Frontend
- ✅ Semaine 3: Analytics Dashboard
- ✅ Semaine 4: File System

### MOIS 2 (Janvier): Chat Avancé & Communication
- Semaine 5-6: Rich Text Editor, Emojis, Mentions
- Semaine 7: Messages vocaux
- Semaine 8: Réactions, Stickers, GIFs

### MOIS 3 (Février): Features Pro & HR
- Semaine 9-10: Système de tâches (Kanban)
- Semaine 11: Documents & Wiki
- Semaine 12: Gestion congés & RH

### MOIS 4 (Mars): Appels Vidéo & Déploiement
- Semaine 13-14: Intégration Agora (appels audio/vidéo)
- Semaine 15: Tests & optimisation
- Semaine 16: Déploiement production

---

## 📊 MÉTRIQUES DE SUCCÈS

### Semaine 1-4 (Phase actuelle)
- [ ] 0 erreurs compilation
- [ ] Backend Teams API fonctionnelle (CRUD complet)
- [ ] Frontend connecté avec vraies données
- [ ] Analytics dashboard avec 4+ graphiques
- [ ] File upload fonctionnel

### Fin Mois 1
- [ ] 100% features Teams/Departments opérationnelles
- [ ] Analytics temps réel
- [ ] File sharing dans chats
- [ ] Performance: < 2s chargement pages
- [ ] Tests: 80%+ coverage backend

---

## 🎯 ACTIONS IMMÉDIATES (Aujourd'hui 28 Nov)

### Priorité 1: Fix Compilation ✅
- [x] Corriger team_management_screen.dart
- [ ] Tester compilation réussie
- [ ] Tester login avec 5 comptes

### Priorité 2: Démarrer Backend Teams
- [ ] Créer branche `feature/teams-backend`
- [ ] Créer models (Team, Department)
- [ ] Créer controllers
- [ ] Créer routes
- [ ] Test Postman

### Priorité 3: Documentation
- [ ] README.md avec setup complet
- [ ] API.md avec tous les endpoints
- [ ] Mettre à jour TODO list

---

## 💪 TU ES PRÊT POUR LE SUCCÈS!

**Prochaine étape**: Une fois l'app compilée sans erreur, on commence immédiatement le backend Teams! 🚀

**Durée estimée Phase 1 (Teams + Analytics)**: 4 semaines  
**Effort**: 2-3h/jour = **60-90h total**  
**Résultat**: Application professionnelle avec gestion complète des équipes et analytics! 📈
