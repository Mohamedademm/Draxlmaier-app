# 🔐 Comptes de Test - Application Dräxlmaier

## 👨‍💼 Compte Administrateur

```
📧 Email: admin@draxlmaier.com
🔑 Mot de passe: admin123
👤 Rôle: Admin
📋 Département: Management
💼 Position: Administrateur Système
```

### Permissions Admin
- ✅ Accès complet à toutes les fonctionnalités
- ✅ Gestion des utilisateurs
- ✅ Gestion des départements et équipes
- ✅ Gestion des objectifs
- ✅ Accès aux statistiques et rapports
- ✅ Configuration système

---

## 👔 Compte Manager

```
📧 Email: manager@draxlmaier.com
🔑 Mot de passe: manager123
👤 Rôle: Manager
📋 Département: Production
💼 Position: Manager Production
```

### Permissions Manager
- ✅ Gestion de son équipe
- ✅ Validation des demandes d'inscription
- ✅ Création d'objectifs pour son équipe
- ✅ Visualisation des statistiques de son département
- ✅ Messagerie avec son équipe

---

## 👷 Compte Employé

```
📧 Email: employee@draxlmaier.com
🔑 Mot de passe: employee123
👤 Rôle: Employee
📋 Département: Production
💼 Position: Technicien
```

### Permissions Employee
- ✅ Messagerie avec collègues et managers
- ✅ Visualisation de ses objectifs
- ✅ Mise à jour de son profil
- ✅ Notifications
- ✅ Localisation (si activée)

---

## 🚀 Comment se Connecter

1. **Ouvrir l'application** : http://localhost:8080/#/login
2. **Entrer l'email** : Choisir un compte ci-dessus
3. **Entrer le mot de passe** : Utiliser le mot de passe correspondant
4. **Cliquer sur "Login"**
5. ✅ **Vous êtes connecté !**

---

## 🆕 Créer un Nouveau Compte

Si vous souhaitez créer votre propre compte :

1. Cliquer sur **"S'inscrire"**
2. Remplir le formulaire en 4 étapes
3. Utiliser un mot de passe simple (ex: `123456`)
4. ✅ Connexion automatique après inscription

---

## ⚙️ Recréer les Comptes de Test

Si vous avez besoin de recréer les comptes :

```powershell
cd backend
node create-admin-quick.js
```

Ce script va :
- Créer/réinitialiser le compte admin
- Créer/réinitialiser le compte manager  
- Créer/réinitialiser le compte employee

---

## 🔧 Dépannage

### "Invalid credentials"
- Vérifiez que vous utilisez exactement : `admin@draxlmaier.com`
- Vérifiez le mot de passe : `admin123` (sensible à la casse)
- Si ça ne marche pas, relancez : `node create-admin-quick.js`

### "Network Error"
- Vérifiez que le backend est démarré : `node server.js`
- Le serveur doit tourner sur port 3000

### Mot de passe oublié
- Relancez simplement : `node create-admin-quick.js`
- Cela réinitialisera les mots de passe

---

## 🎯 Tests Recommandés

### Test 1 : Connexion Admin
1. Se connecter avec `admin@draxlmaier.com` / `admin123`
2. Vérifier l'accès au panneau d'administration
3. Tester la gestion des utilisateurs

### Test 2 : Connexion Manager
1. Se connecter avec `manager@draxlmaier.com` / `manager123`
2. Vérifier la gestion d'équipe
3. Tester la validation des demandes

### Test 3 : Connexion Employee
1. Se connecter avec `employee@draxlmaier.com` / `employee123`
2. Tester la messagerie
3. Vérifier les objectifs

### Test 4 : Nouvelle Inscription
1. Créer un nouveau compte avec mot de passe simple
2. Vérifier la connexion automatique
3. Tester les fonctionnalités de base

---

## 📱 Authentification Google

Le bouton Google est visible mais **temporairement désactivé**.

Pour l'activer, il faut :
1. Créer un projet dans Google Cloud Console
2. Activer Google Sign-In API
3. Configurer les identifiants OAuth 2.0
4. Décommenter le code dans `login_screen.dart`

En attendant, utilisez l'authentification par email/mot de passe.

---

## ✅ Résumé Rapide

**Pour tester rapidement :**
```
Email: admin@draxlmaier.com
Mot de passe: admin123
```

**Ou créez votre propre compte avec n'importe quel mot de passe simple !**

---

**Dernière mise à jour** : 6 décembre 2025  
**Status** : ✅ Comptes actifs et fonctionnels
