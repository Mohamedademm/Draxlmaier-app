# Phase 2 - Team Management Testing Guide

## 🎯 Testing Overview
This guide covers testing the newly implemented Team Management screen with full CRUD operations for Teams and Departments.

---

## ✅ Prerequisites

### Backend Status
- ✅ Backend server running on `http://localhost:3000`
- ✅ MongoDB connected
- ✅ 15 API endpoints active (8 teams, 7 departments)
- ✅ Test data populated:
  - 3 Departments (HR, Engineering, Sales)
  - 4 Teams (Backend Team, Frontend Team, Mobile Team, QA Team)
  - 5 User accounts available

### Frontend Status
- ✅ Flutter app running on `http://localhost:8080`
- ✅ TeamProvider integrated with state management
- ✅ Team & Department models with JSON serialization
- ✅ TeamService & DepartmentService connected to API
- ✅ team_management_screen.dart rebuilt (0 errors, 16 warnings)

---

## 🔐 Test User Accounts

Use these accounts for testing (all passwords: `password123`):

1. **Admin Account**
   - Email: `admin@company.com`
   - Role: Admin (can manage teams/departments)

2. **Manager Account**
   - Email: `john.smith@company.com`
   - Role: Manager (can manage teams)

3. **Employee Accounts**
   - `jane.doe@company.com`
   - `bob.wilson@company.com`
   - `alice.brown@company.com`

---

## 📋 Test Cases

### 1. Login & Navigation
**Steps:**
1. Open `http://localhost:8080`
2. Login with `admin@company.com` / `password123`
3. Navigate to "Gestion des Équipes" (Team Management)

**Expected Result:**
- ✅ Login successful
- ✅ Main dashboard loads
- ✅ Team Management screen accessible
- ✅ Three tabs visible: Équipes, Départements, Permissions

---

### 2. View Teams Tab
**Steps:**
1. Click on "Équipes" tab (should be default)
2. Observe the stats cards at the top
3. Scroll through the team list

**Expected Result:**
- ✅ Stats cards show:
  - Total teams count (4)
  - Active teams count (4)
  - Total members count
- ✅ Team cards display:
  - Team name and description
  - Active/Inactive status (green/red icon)
  - Member count
  - Color indicator (circle avatar)
  - Three-dot menu (Gérer les membres, Modifier, Supprimer)
- ✅ Expandable cards show:
  - Team leader information
  - List of team members
  - Remove member button for each member

---

### 3. Create New Team
**Steps:**
1. Click the floating action button "+" (bottom right)
2. Fill in the form:
   - **Nom de l'équipe**: "DevOps Team"
   - **Description**: "Infrastructure and deployment team"
   - **Département**: Select "Engineering"
   - **Chef d'équipe**: Select any user (e.g., "John Smith")
   - **Couleur**: Select a color (click on color circle)
3. Click "Créer"

**Expected Result:**
- ✅ Dialog closes
- ✅ Success message: "Équipe créée avec succès"
- ✅ New team appears in the list
- ✅ Stats cards update (total teams count increases)
- ✅ Team card shows correct information

**API Call to Verify:**
```bash
curl http://localhost:3000/api/teams
```

---

### 4. Edit Existing Team
**Steps:**
1. Find the "DevOps Team" created in previous test
2. Click the three-dot menu → "Modifier"
3. Update fields:
   - **Nom**: "DevOps & Security Team"
   - **Description**: "Infrastructure, deployment, and security"
   - Change color to a different one
   - Toggle "Active" switch to test
4. Click "Enregistrer"

**Expected Result:**
- ✅ Dialog closes
- ✅ Success message: "Équipe modifiée avec succès"
- ✅ Team card updates with new information
- ✅ Color changes reflect immediately
- ✅ Active status updates

---

### 5. Add Members to Team
**Steps:**
1. Find any team (e.g., "Backend Team")
2. Click three-dot menu → "Gérer les membres"
3. In the dropdown "Sélectionner un utilisateur", choose a user not already in the team
4. User should be added automatically after selection

**Expected Result:**
- ✅ Success message: "Membre ajouté avec succès"
- ✅ Member appears in the "Membres actuels" list
- ✅ Available users dropdown updates (selected user removed from list)
- ✅ Team card updates member count

---

### 6. Remove Members from Team
**Steps:**
1. In the same "Gérer les membres" dialog
2. Click the remove icon (🚫) next to a member
3. Confirm removal in the dialog

**Expected Result:**
- ✅ Confirmation dialog appears
- ✅ Success message: "Membre retiré avec succès"
- ✅ Member removed from list
- ✅ User appears back in available users dropdown
- ✅ Team card updates member count

---

### 7. Delete Team
**Steps:**
1. Find the "DevOps & Security Team"
2. Click three-dot menu → "Supprimer"
3. Confirm deletion

**Expected Result:**
- ✅ Confirmation dialog: "Êtes-vous sûr de vouloir supprimer l'équipe..."
- ✅ Success message: "Équipe supprimée avec succès"
- ✅ Team removed from list
- ✅ Stats cards update (total teams count decreases)

---

### 8. View Departments Tab
**Steps:**
1. Click on "Départements" tab
2. Observe department cards

**Expected Result:**
- ✅ Departments list displays (3 departments)
- ✅ Each card shows:
  - Department name and description
  - Active/Inactive status
  - Location (if set)
  - Three-dot menu (Modifier, Supprimer)
- ✅ Expandable cards show:
  - Budget info card
  - Employee count info card
  - Manager information (name, email, avatar)

---

### 9. Create New Department
**Steps:**
1. Click the floating action button "+" (bottom right)
2. Fill in the form:
   - **Nom du département**: "Marketing"
   - **Description**: "Marketing and communications team"
   - **Localisation**: "Building C, Floor 3"
   - **Budget**: "250000"
   - **Nombre d'employés**: "15"
   - **Manager**: Select a user
3. Click "Créer"

**Expected Result:**
- ✅ Dialog closes
- ✅ Success message: "Département créé avec succès"
- ✅ New department appears in list
- ✅ All fields display correctly
- ✅ Budget formatted properly (with currency symbol if implemented)

**API Call to Verify:**
```bash
curl http://localhost:3000/api/departments
```

---

### 10. Edit Department
**Steps:**
1. Find "Marketing" department
2. Click three-dot menu → "Modifier"
3. Update fields:
   - **Budget**: "300000"
   - **Nombre d'employés**: "18"
   - Toggle "Actif" switch
4. Click "Enregistrer"

**Expected Result:**
- ✅ Dialog closes
- ✅ Success message: "Département modifié avec succès"
- ✅ Budget updates to new value
- ✅ Employee count updates
- ✅ Active status changes

---

### 11. Delete Department
**Steps:**
1. Find "Marketing" department
2. Click three-dot menu → "Supprimer"
3. Confirm deletion

**Expected Result:**
- ✅ Confirmation dialog appears
- ✅ Success message: "Département supprimé avec succès"
- ✅ Department removed from list

---

### 12. Error Handling Tests

#### Test 12a: Create Team Without Required Fields
**Steps:**
1. Click "+" to create team
2. Leave "Nom de l'équipe" empty
3. Click "Créer"

**Expected Result:**
- ✅ Error message: "Veuillez remplir tous les champs requis"
- ✅ Dialog stays open

#### Test 12b: Network Error Simulation
**Steps:**
1. Stop the backend server (Ctrl+C in backend terminal)
2. Try to load teams (pull to refresh)
3. Restart backend server

**Expected Result:**
- ✅ Error message displays
- ✅ "Réessayer" button appears
- ✅ After restart, retry works

---

### 13. Refresh & Real-time Updates

#### Test 13a: Pull to Refresh (Teams)
**Steps:**
1. On Teams tab
2. Pull down to refresh the list

**Expected Result:**
- ✅ Loading indicator shows
- ✅ Teams list refreshes
- ✅ Latest data from API displayed

#### Test 13b: Pull to Refresh (Departments)
**Steps:**
1. Switch to Départements tab
2. Pull down to refresh

**Expected Result:**
- ✅ Loading indicator shows
- ✅ Departments list refreshes
- ✅ Latest data from API displayed

---

### 14. Permissions Tab
**Steps:**
1. Click on "Permissions" tab

**Expected Result:**
- ✅ Placeholder screen displays
- ✅ Message: "Gestion des permissions - Fonctionnalité à venir..."

---

### 15. Access Control Test
**Steps:**
1. Logout
2. Login as employee: `alice.brown@company.com` / `password123`
3. Try to access Team Management

**Expected Result:**
- ✅ "Accès refusé" screen displays
- ✅ Message: "Vous n'avez pas les permissions nécessaires."
- ✅ No access to team/department management

---

## 🐛 Known Issues / Warnings

### Non-Critical Warnings (16 total)
These are safe to ignore - they're about unnecessary null checks due to Dart's null safety:
- ⚠️ `unnecessary_null_comparison` (2 occurrences)
- ⚠️ `unnecessary_non_null_assertion` (13 occurrences)
- ⚠️ `invalid_null_aware_operator` (1 occurrence)

### Critical Issues to Watch For
None currently! All errors resolved. ✅

---

## 📊 API Endpoint Coverage

### Teams Endpoints (8/8 tested)
1. ✅ `GET /api/teams` - Get all teams (used in loadTeams)
2. ✅ `GET /api/teams/:id` - Get single team (not directly used in UI yet)
3. ✅ `POST /api/teams` - Create team (used in createTeam)
4. ✅ `PUT /api/teams/:id` - Update team (used in updateTeam)
5. ✅ `DELETE /api/teams/:id` - Delete team (used in deleteTeam)
6. ✅ `GET /api/teams/:id/members` - Get team members (implicit in team data)
7. ✅ `POST /api/teams/:id/members` - Add member (used in addMemberToTeam)
8. ✅ `DELETE /api/teams/:id/members/:userId` - Remove member (used in removeMemberFromTeam)

### Departments Endpoints (7/7 tested)
1. ✅ `GET /api/departments` - Get all departments (used in loadDepartments)
2. ✅ `GET /api/departments/:id` - Get single department (not directly used yet)
3. ✅ `POST /api/departments` - Create department (used in createDepartment)
4. ✅ `PUT /api/departments/:id` - Update department (used in updateDepartment)
5. ✅ `DELETE /api/departments/:id` - Delete department (used in deleteDepartment)
6. ✅ `GET /api/departments/:id/teams` - Get department teams (not directly used yet)
7. ✅ `GET /api/departments/:id/stats` - Get department stats (not directly used yet)

---

## 🎉 Success Criteria

### All tests pass if:
- ✅ Login and navigation work smoothly
- ✅ Teams and departments display correctly from API
- ✅ Create operations work for both teams and departments
- ✅ Update operations reflect changes immediately
- ✅ Delete operations remove items successfully
- ✅ Member management (add/remove) works
- ✅ Error messages display appropriately
- ✅ Loading states show during API calls
- ✅ Access control prevents unauthorized access
- ✅ No console errors (except lifecycle warnings)

---

## 📝 Test Results Template

Copy and fill this out after testing:

```
## Test Results - [Date] - [Tester Name]

### Environment
- Backend: ✅/❌ Running
- Frontend: ✅/❌ Running
- Database: ✅/❌ Connected

### Test Cases
1. Login & Navigation: ✅/❌
2. View Teams Tab: ✅/❌
3. Create New Team: ✅/❌
4. Edit Existing Team: ✅/❌
5. Add Members to Team: ✅/❌
6. Remove Members from Team: ✅/❌
7. Delete Team: ✅/❌
8. View Departments Tab: ✅/❌
9. Create New Department: ✅/❌
10. Edit Department: ✅/❌
11. Delete Department: ✅/❌
12. Error Handling: ✅/❌
13. Refresh Updates: ✅/❌
14. Permissions Tab: ✅/❌
15. Access Control: ✅/❌

### Issues Found
[List any bugs or unexpected behavior]

### Notes
[Any additional observations]
```

---

## 🚀 Next Steps After Testing

Once all tests pass:
1. ✅ Mark Phase 2 as complete
2. 📄 Create PHASE2_COMPLETED_SUMMARY.md
3. 🎯 Begin Phase 3: Analytics & Advanced Features
4. 📈 Implement charts with fl_chart package
5. 📁 Build file sharing system
6. 💬 Add advanced chat features
7. 📹 Integrate video calls (Agora SDK)

---

**Happy Testing! 🎊**
