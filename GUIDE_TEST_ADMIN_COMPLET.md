# 🧪 GUIDE DE TEST COMPLET - FONCTIONNALITÉS ADMIN

## 📋 INFORMATIONS DE CONNEXION

### 👨‍💼 Compte Admin Principal
```
Email: admin@gmail.com
Mot de passe: admin
```

### 👔 Compte Manager de Test
```
Email: ademmanager@gmail.com
Mot de passe: 123456
```

### 👤 Compte Employee de Test
```
Email: ademuser@gmail.com
Mot de passe: 123456
```

---

## 🚀 ÉTAPES DE TEST - PARTIE 1 : CONNEXION & NAVIGATION

### ✅ TEST 1 : Connexion Admin
1. **Ouvrez l'application** : http://localhost:8080/#/login
2. **Entrez les identifiants admin** :
   - Email : `admin@gmail.com`
   - Mot de passe : `admin`
3. **Cliquez sur "Login"**
4. **✓ Vérifiez** : Vous êtes redirigé vers le Dashboard

---

### ✅ TEST 2 : Interface Dashboard Admin
1. **Vérifiez les éléments visibles** :
   - ✓ Bienvenue avec le nom "Admin"
   - ✓ Statistiques des objectifs
   - ✓ Menu de navigation en bas
   - ✓ Bouton de profil/menu en haut

2. **Menu de navigation** (4 icônes en bas) :
   - 🏠 Accueil (Dashboard)
   - 📊 Objectifs
   - 💬 Messages
   - 👤 Profil

---

## 🧑‍💼 PARTIE 2 : GESTION DES UTILISATEURS

### ✅ TEST 3 : Créer un Nouvel Admin
1. **Navigation** : Allez dans le menu Profil → Gestion des utilisateurs (ou section Admin)
2. **Cliquez sur** : "Ajouter un utilisateur" ou "+" 
3. **Remplissez le formulaire** :
   ```
   Prénom: TestAdmin
   Nom: System
   Email: testadmin@gmail.com
   Mot de passe: 123456
   Téléphone: +33123456789
   Département: IT
   Rôle: Admin
   ```
4. **Cliquez sur** : "Créer" ou "Enregistrer"
5. **✓ Vérifiez** : Message de succès affiché
6. **✓ Vérifiez** : Le nouvel admin apparaît dans la liste

---

### ✅ TEST 4 : Créer un Manager
1. **Cliquez sur** : "Ajouter un utilisateur"
2. **Remplissez** :
   ```
   Prénom: Manager
   Nom: Test
   Email: manager.test@gmail.com
   Mot de passe: 123456
   Téléphone: +33123456790
   Département: RH
   Rôle: Manager
   ```
3. **Créez l'utilisateur**
4. **✓ Vérifiez** : Manager créé avec succès

---

### ✅ TEST 5 : Créer un Employee
1. **Cliquez sur** : "Ajouter un utilisateur"
2. **Remplissez** :
   ```
   Prénom: Employee
   Nom: Test
   Email: employee.test@gmail.com
   Mot de passe: 123456
   Téléphone: +33123456791
   Département: Production
   Rôle: Employee
   ```
3. **Créez l'utilisateur**
4. **✓ Vérifiez** : Employee créé avec succès

---

### ✅ TEST 6 : Voir la Liste des Utilisateurs
1. **Naviguez vers** : Liste des utilisateurs
2. **✓ Vérifiez que vous voyez** :
   - Admin System (admin@gmail.com) - Admin
   - TestAdmin System (testadmin@gmail.com) - Admin
   - Manager Test (manager.test@gmail.com) - Manager
   - adem adem (ademmanager@gmail.com) - Manager
   - Employee Test (employee.test@gmail.com) - Employee
   - adem adem (ademuser@gmail.com) - Employee

---

### ✅ TEST 7 : Modifier un Utilisateur
1. **Sélectionnez** : Un utilisateur dans la liste (ex: Employee Test)
2. **Cliquez sur** : Icône "Modifier" ou "Edit"
3. **Changez** : Le département en "Quality Control"
4. **Enregistrez**
5. **✓ Vérifiez** : Les modifications sont sauvegardées

---

### ✅ TEST 8 : Supprimer un Utilisateur
1. **Sélectionnez** : Un utilisateur de test
2. **Cliquez sur** : Icône "Supprimer" ou "Delete"
3. **Confirmez** : La suppression
4. **✓ Vérifiez** : L'utilisateur est supprimé de la liste

---

## 🎯 PARTIE 3 : GESTION DES OBJECTIFS

### ✅ TEST 9 : Créer un Objectif
1. **Naviguez vers** : Section Objectifs (icône 📊)
2. **Cliquez sur** : "Créer un objectif" ou "+"
3. **Remplissez** :
   ```
   Titre: Améliorer la productivité
   Description: Augmenter la productivité de 20%
   Date limite: [Date future]
   Priorité: Haute
   Assigné à: [Sélectionner un employee]
   ```
4. **Créez l'objectif**
5. **✓ Vérifiez** : Objectif créé et visible dans la liste

---

### ✅ TEST 10 : Voir les Objectifs de Tous les Utilisateurs
1. **Dans la section Objectifs** :
2. **✓ Vérifiez** : Vous voyez TOUS les objectifs (pas seulement les vôtres)
3. **✓ Vérifiez** : Vous pouvez filtrer par utilisateur
4. **✓ Vérifiez** : Vous pouvez filtrer par statut (En cours, Terminé, En retard)

---

### ✅ TEST 11 : Modifier un Objectif
1. **Cliquez sur** : Un objectif existant
2. **Modifiez** : Le statut ou la description
3. **Enregistrez**
4. **✓ Vérifiez** : Les modifications sont appliquées

---

### ✅ TEST 12 : Supprimer un Objectif
1. **Sélectionnez** : Un objectif
2. **Cliquez sur** : Supprimer
3. **Confirmez**
4. **✓ Vérifiez** : L'objectif est supprimé

---

## 💬 PARTIE 4 : MESSAGERIE

### ✅ TEST 13 : Envoyer un Message Privé
1. **Naviguez vers** : Section Messages (icône 💬)
2. **Sélectionnez** : Un utilisateur (ex: Manager Test)
3. **Tapez un message** : "Bonjour, test de message admin"
4. **Envoyez**
5. **✓ Vérifiez** : Message envoyé et affiché

---

### ✅ TEST 14 : Créer un Groupe de Discussion
1. **Dans Messages** : Cliquez sur "Nouveau groupe" ou "+"
2. **Remplissez** :
   ```
   Nom du groupe: Équipe IT
   Description: Discussions techniques
   Membres: [Sélectionner plusieurs utilisateurs]
   ```
3. **Créez le groupe**
4. **✓ Vérifiez** : Groupe créé et visible

---

### ✅ TEST 15 : Envoyer un Message dans le Groupe
1. **Ouvrez** : Le groupe créé
2. **Envoyez** : "Message de test dans le groupe"
3. **✓ Vérifiez** : Message visible pour tous les membres

---

## 👥 PARTIE 5 : DÉPARTEMENTS & ÉQUIPES

### ✅ TEST 16 : Créer un Département
1. **Naviguez vers** : Gestion des départements
2. **Créez un département** :
   ```
   Nom: Innovation
   Description: Département R&D
   Manager: [Sélectionner un manager]
   ```
3. **✓ Vérifiez** : Département créé

---

### ✅ TEST 17 : Créer une Équipe
1. **Naviguez vers** : Gestion des équipes
2. **Créez une équipe** :
   ```
   Nom: Frontend Team
   Département: IT
   Chef d'équipe: [Manager]
   Membres: [Sélectionner des employees]
   ```
3. **✓ Vérifiez** : Équipe créée avec succès

---

## 🔔 PARTIE 6 : NOTIFICATIONS

### ✅ TEST 18 : Envoyer une Notification Globale
1. **Naviguez vers** : Notifications
2. **Créez une notification** :
   ```
   Type: Annonce importante
   Titre: Réunion générale
   Message: Réunion demain à 10h
   Destinataires: Tous les utilisateurs
   ```
3. **Envoyez**
4. **✓ Vérifiez** : Notification envoyée

---

### ✅ TEST 19 : Voir l'Historique des Notifications
1. **Dans Notifications** :
2. **✓ Vérifiez** : Liste de toutes les notifications envoyées
3. **✓ Vérifiez** : Statut de lecture de chaque notification

---

## 📊 PARTIE 7 : RAPPORTS & STATISTIQUES

### ✅ TEST 20 : Voir les Statistiques Globales
1. **Dashboard Admin** :
2. **✓ Vérifiez les statistiques** :
   - Nombre total d'utilisateurs
   - Nombre d'objectifs actifs
   - Taux de complétion des objectifs
   - Activité récente

---

### ✅ TEST 21 : Exporter des Rapports
1. **Naviguez vers** : Rapports
2. **Sélectionnez** : Type de rapport (Utilisateurs, Objectifs, etc.)
3. **Cliquez sur** : "Exporter" ou "Télécharger"
4. **✓ Vérifiez** : Fichier téléchargé (PDF ou Excel)

---

## 🔐 PARTIE 8 : SÉCURITÉ & PERMISSIONS

### ✅ TEST 22 : Tester les Restrictions Manager
1. **Déconnectez-vous** (Logout)
2. **Connectez-vous avec** : `ademmanager@gmail.com` / `123456`
3. **Essayez de créer un Admin** :
4. **✓ Vérifiez** : Message d'erreur "Les managers ne peuvent pas créer des admins"
5. **Essayez de créer un Manager** :
6. **✓ Vérifiez** : Création réussie
7. **Essayez de créer un Employee** :
8. **✓ Vérifiez** : Création réussie

---

### ✅ TEST 23 : Tester les Restrictions Employee
1. **Déconnectez-vous**
2. **Connectez-vous avec** : `ademuser@gmail.com` / `123456`
3. **Vérifiez** : 
   - ❌ Pas d'accès à la gestion des utilisateurs
   - ❌ Pas d'accès à la création d'équipes
   - ✅ Accès à ses propres objectifs uniquement
   - ✅ Accès à la messagerie

---

## 🔄 PARTIE 9 : VALIDATION DES INSCRIPTIONS

### ✅ TEST 24 : Nouveau Compte en Attente
1. **Créez un nouveau compte** (via page d'inscription)
2. **Connectez-vous comme Admin**
3. **Naviguez vers** : Demandes en attente / Pending Users
4. **✓ Vérifiez** : Nouvelle demande visible
5. **Cliquez sur** : "Approuver" ou "Rejeter"
6. **✓ Vérifiez** : Action appliquée

---

## 🔍 PARTIE 10 : RECHERCHE & FILTRES

### ✅ TEST 25 : Recherche d'Utilisateurs
1. **Dans la liste des utilisateurs** :
2. **Utilisez la barre de recherche** : Tapez "manager"
3. **✓ Vérifiez** : Seuls les managers sont affichés

---

### ✅ TEST 26 : Filtres Avancés
1. **Appliquez des filtres** :
   - Par département
   - Par rôle
   - Par statut (actif/inactif)
2. **✓ Vérifiez** : Résultats filtrés correctement

---

## 📱 PARTIE 11 : RESPONSIVE DESIGN

### ✅ TEST 27 : Test sur Mobile
1. **Ouvrez DevTools** : F12
2. **Activez** : Mode responsive (Ctrl+Shift+M)
3. **Sélectionnez** : iPhone ou Android
4. **✓ Vérifiez** : 
   - Interface adaptée au mobile
   - Navigation fluide
   - Tous les boutons accessibles

---

## 🎨 PARTIE 12 : PERSONNALISATION

### ✅ TEST 28 : Modifier le Profil Admin
1. **Allez dans** : Profil
2. **Cliquez sur** : Modifier le profil
3. **Changez** :
   - Photo de profil
   - Informations personnelles
   - Préférences
4. **Enregistrez**
5. **✓ Vérifiez** : Modifications appliquées

---

## ✅ CHECKLIST FINALE

Cochez après chaque test :

- [ ] TEST 1 : Connexion Admin ✅
- [ ] TEST 2 : Interface Dashboard ✅
- [ ] TEST 3 : Créer un Admin ✅
- [ ] TEST 4 : Créer un Manager ✅
- [ ] TEST 5 : Créer un Employee ✅
- [ ] TEST 6 : Liste des utilisateurs ✅
- [ ] TEST 7 : Modifier un utilisateur ✅
- [ ] TEST 8 : Supprimer un utilisateur ✅
- [ ] TEST 9 : Créer un objectif ✅
- [ ] TEST 10 : Voir tous les objectifs ✅
- [ ] TEST 11 : Modifier un objectif ✅
- [ ] TEST 12 : Supprimer un objectif ✅
- [ ] TEST 13 : Message privé ✅
- [ ] TEST 14 : Créer un groupe ✅
- [ ] TEST 15 : Message groupe ✅
- [ ] TEST 16 : Créer département ✅
- [ ] TEST 17 : Créer équipe ✅
- [ ] TEST 18 : Notification globale ✅
- [ ] TEST 19 : Historique notifications ✅
- [ ] TEST 20 : Statistiques ✅
- [ ] TEST 21 : Export rapports ✅
- [ ] TEST 22 : Restrictions Manager ✅
- [ ] TEST 23 : Restrictions Employee ✅
- [ ] TEST 24 : Validation inscription ✅
- [ ] TEST 25 : Recherche ✅
- [ ] TEST 26 : Filtres ✅
- [ ] TEST 27 : Responsive ✅
- [ ] TEST 28 : Profil admin ✅

---

## 🐛 RAPPORT DE BUGS

Si vous trouvez un problème, notez-le ici :

| Test # | Problème | Gravité | Status |
|--------|----------|---------|--------|
| | | | |

---

## 📝 NOTES IMPORTANTES

1. **Backend doit tourner** : Port 3000
2. **Flutter doit tourner** : Port 8080
3. **Connexion admin** : admin@gmail.com / admin
4. **Base de données** : MongoDB Atlas

---

## 🎯 RÉSUMÉ DES FONCTIONNALITÉS ADMIN

### Ce que l'ADMIN peut faire :
✅ Créer/Modifier/Supprimer : Admins, Managers, Employees
✅ Voir tous les objectifs de tous les utilisateurs
✅ Créer/Gérer : Départements et Équipes
✅ Envoyer des notifications globales
✅ Valider ou rejeter les inscriptions
✅ Accéder à tous les rapports et statistiques
✅ Gérer tous les messages et groupes
✅ Configuration complète du système

### Ce que le MANAGER peut faire :
✅ Créer/Modifier : Managers et Employees (PAS d'admins)
✅ Voir les objectifs de son équipe
✅ Créer des objectifs pour son équipe
✅ Gérer son département
⏸️ Accès limité aux statistiques

### Ce que l'EMPLOYEE peut faire :
✅ Voir ses propres objectifs
✅ Envoyer des messages
✅ Participer aux groupes
❌ Pas de gestion d'utilisateurs
❌ Pas de création d'objectifs pour les autres

---

**🚀 Bon test ! N'hésitez pas si vous trouvez des bugs !**
