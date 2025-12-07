# 🚀 DÉMARRAGE RAPIDE - TEST ADMIN

## ✅ 1. PROJET DÉMARRÉ

### Backend (Port 3000) : ✅ ACTIF
```
✅ Server running on http://localhost:3000
✅ MongoDB Atlas connected
```

### Frontend (Port 8080) : ✅ EN COURS
```
⏳ Flutter app loading on http://localhost:8080
```

---

## 🔐 2. CONNEXION ADMIN

**Ouvrez dans votre navigateur** :
👉 **http://localhost:8080/#/login**

**Identifiants** :
```
📧 Email: admin@gmail.com
🔑 Mot de passe: admin
```

---

## 🧪 3. PREMIERS TESTS (5 MINUTES)

### ✅ Test #1 : Connexion
1. Entrez : `admin@gmail.com` / `admin`
2. Cliquez sur "Login"
3. ✓ Vous voyez le Dashboard

### ✅ Test #2 : Créer un Manager
1. Allez dans : Gestion des utilisateurs
2. Cliquez sur : "Ajouter un utilisateur"
3. Remplissez :
   ```
   Prénom: Manager
   Nom: Test
   Email: manager.new@gmail.com
   Mot de passe: 123456
   Rôle: Manager
   ```
4. Créez
5. ✓ Manager créé avec succès !

### ✅ Test #3 : Créer un Employee
1. Cliquez sur : "Ajouter un utilisateur"
2. Remplissez :
   ```
   Prénom: Employee
   Nom: New
   Email: employee.new@gmail.com
   Mot de passe: 123456
   Rôle: Employee
   ```
3. Créez
4. ✓ Employee créé !

### ✅ Test #4 : Tester Permissions Manager
1. Déconnectez-vous
2. Connectez-vous avec : `ademmanager@gmail.com` / `123456`
3. Essayez de créer un Admin
4. ✓ Vous devez voir : "Les managers ne peuvent pas créer des admins" ❌
5. Essayez de créer un Employee
6. ✓ Ça fonctionne ! ✅

### ✅ Test #5 : Voir les Objectifs
1. Retournez à admin : `admin@gmail.com` / `admin`
2. Allez dans : Section Objectifs
3. ✓ Vous voyez TOUS les objectifs de TOUS les utilisateurs

---

## 📋 4. COMPTES DE TEST DISPONIBLES

```
👨‍💼 ADMIN:
   admin@gmail.com / admin
   
👔 MANAGERS:
   ademmanager@gmail.com / 123456
   manager.new@gmail.com / 123456 (si créé)
   
👤 EMPLOYEES:
   ademuser@gmail.com / 123456
   testemployee@gmail.com / 123456
   employee.new@gmail.com / 123456 (si créé)
```

---

## 🎯 5. CE QUE VOUS DEVEZ TESTER

### Priorité HAUTE (Faites ça en premier) :
- [ ] Connexion Admin ✅
- [ ] Créer un Manager ✅
- [ ] Créer un Employee ✅
- [ ] Vérifier que Manager ne peut pas créer d'Admin ✅
- [ ] Voir la liste des utilisateurs ✅

### Priorité MOYENNE :
- [ ] Créer un objectif
- [ ] Envoyer un message
- [ ] Créer un groupe
- [ ] Modifier un utilisateur
- [ ] Supprimer un utilisateur

### Priorité BASSE (Si vous avez le temps) :
- [ ] Créer un département
- [ ] Créer une équipe
- [ ] Envoyer une notification
- [ ] Exporter des rapports
- [ ] Tester sur mobile

---

## 🐛 6. SI VOUS TROUVEZ UN BUG

**Notez** :
1. Quelle action vous faisiez ?
2. Quel était le résultat attendu ?
3. Quel a été le résultat réel ?
4. Y a-t-il un message d'erreur ?

---

## 📖 7. GUIDE COMPLET

Pour un guide détaillé avec 28 tests complets :
👉 **Voir le fichier : `GUIDE_TEST_ADMIN_COMPLET.md`**

---

## 🔧 8. COMMANDES UTILES

### Redémarrer le Backend :
```powershell
cd backend
node server.js
```

### Redémarrer le Frontend :
```powershell
flutter run -d chrome --web-port 8080
```

### Nettoyer la base de données (garder seulement admin) :
```powershell
cd backend
node cleanup-users.js
```

### Tester l'API directement :
```powershell
cd backend
node test-create-users.js
```

---

## ✅ STATUT ACTUEL

- ✅ Backend : ACTIF (Port 3000)
- ⏳ Frontend : EN CHARGEMENT (Port 8080)
- ✅ Base de données : CONNECTÉE
- ✅ Compte admin : CRÉÉ (admin@gmail.com / admin)

---

**🎉 Tout est prêt ! Commencez vos tests !**

**L'application devrait s'ouvrir automatiquement dans Chrome dans quelques secondes...**
