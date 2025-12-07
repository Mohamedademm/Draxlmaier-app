# Guide de Test - Nouvelles Fonctionnalités

## 🎯 Tests à Effectuer Maintenant

### Test 1 : Inscription avec Mot de Passe Simple ✓
**Objectif** : Vérifier que l'utilisateur peut s'inscrire avec un mot de passe comme "123456"

**Étapes** :
1. Ouvrir l'application Flutter
2. Cliquer sur "S'inscrire"
3. Remplir les 4 étapes du formulaire :
   - **Étape 1** : Informations personnelles (prénom, nom, email, téléphone)
   - **Étape 2** : Position et département
   - **Étape 3** : Adresse (avec localisation GPS)
   - **Étape 4** : Mot de passe = `123456` (ou même plus simple : `123`)
4. Confirmer le mot de passe
5. Cliquer sur "S'inscrire"

**Résultat Attendu** :
- ✅ Message : "Inscription réussie ! Connexion en cours..."
- ✅ Redirection automatique vers l'écran d'accueil
- ✅ Utilisateur connecté (voir son profil)

**Si Erreur** :
- Vérifier que le serveur backend est démarré
- Vérifier les logs dans la console Chrome DevTools
- Relancer l'application Flutter (Hot Restart : `Shift + R`)

---

### Test 2 : Connexion Automatique Après Inscription ✓
**Objectif** : Vérifier que l'utilisateur n'a pas besoin de se reconnecter après inscription

**Étapes** :
1. Après avoir terminé le Test 1
2. Vérifier que vous êtes sur l'écran d'accueil
3. Vérifier votre nom dans le profil

**Résultat Attendu** :
- ✅ Pas de retour à l'écran de connexion
- ✅ Token JWT sauvegardé automatiquement
- ✅ Accès direct à toutes les fonctionnalités

---

### Test 3 : Connexion Google (Configuration requise) 🔧
**Objectif** : Tester la connexion avec un compte Google

**Prérequis** :
Pour que ce test fonctionne, vous devez configurer Google Sign-In. En attendant, le bouton est visible mais peut ne pas fonctionner complètement.

**Étapes** :
1. Aller sur l'écran de connexion
2. Cliquer sur "Continuer avec Google"
3. Sélectionner un compte Google
4. Accepter les permissions

**Résultat Attendu** :
- ✅ Compte créé automatiquement s'il n'existe pas
- ✅ Connexion automatique si le compte existe
- ✅ Redirection vers l'écran d'accueil

**Note** : Ce test nécessite une configuration Google Cloud Console pour fonctionner en production.

---

### Test 4 : Déconnexion et Reconnexion
**Objectif** : Vérifier que l'utilisateur peut se reconnecter avec son mot de passe simple

**Étapes** :
1. Depuis l'écran d'accueil, aller dans Profil
2. Cliquer sur "Déconnexion"
3. Revenir à l'écran de connexion
4. Entrer l'email utilisé lors de l'inscription
5. Entrer le mot de passe simple (ex: `123456`)
6. Cliquer sur "Login"

**Résultat Attendu** :
- ✅ Connexion réussie
- ✅ Redirection vers l'écran d'accueil
- ✅ Toutes les données utilisateur sont présentes

---

## 🐛 Dépannage

### Problème 1 : "Email already registered"
**Cause** : L'email existe déjà dans la base de données

**Solution** :
1. Utiliser un autre email
2. OU supprimer l'utilisateur de MongoDB Atlas
3. OU se connecter avec cet email au lieu de s'inscrire

### Problème 2 : "Network Error" ou "Connection refused"
**Cause** : Le serveur backend n'est pas démarré

**Solution** :
```powershell
cd backend
node server.js
```

### Problème 3 : L'application ne se met pas à jour
**Cause** : Cache Flutter

**Solution** :
```powershell
# Hot Restart
Shift + R dans le terminal Flutter

# OU Redémarrage complet
r (restart)

# OU Rebuild complet
flutter clean
flutter pub get
flutter run
```

### Problème 4 : Erreur de validation du mot de passe
**Cause** : L'application n'a pas été redémarrée

**Solution** :
1. Arrêter l'application Flutter
2. Exécuter `flutter pub get`
3. Relancer avec `flutter run`
4. Ou faire Hot Restart avec `Shift + R`

---

## 📊 Vérifications Backend

### Vérifier que le serveur est démarré
```powershell
# Vous devriez voir :
✅ Server running in development mode on port 3000
✅ MongoDB Atlas connected successfully
```

### Vérifier les routes disponibles
Le backend expose maintenant :
- `POST /api/auth/register` - Inscription avec connexion auto
- `POST /api/auth/login` - Connexion standard
- `POST /api/auth/google` - Connexion Google
- `GET /api/auth/me` - Profil utilisateur

### Tester manuellement l'API

#### Test d'inscription via Postman/cURL
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "firstname": "Test",
    "lastname": "User",
    "email": "test@example.com",
    "password": "123",
    "phone": "0612345678",
    "position": "Technicien",
    "department": "Production",
    "address": "123 Rue Test",
    "city": "Paris",
    "postalCode": "75001"
  }'
```

**Réponse attendue** :
```json
{
  "status": "success",
  "token": "eyJhbGc...",
  "user": {
    "id": "...",
    "email": "test@example.com",
    "firstname": "Test",
    "lastname": "User",
    "role": "employee",
    "status": "active"
  }
}
```

---

## ✅ Checklist de Validation

### Frontend Flutter
- [ ] Package `google_sign_in` installé
- [ ] Service `google_auth_service.dart` créé
- [ ] Bouton Google visible sur l'écran de connexion
- [ ] Validation du mot de passe = 1 caractère minimum
- [ ] Connexion automatique après inscription

### Backend Node.js
- [ ] Serveur démarré sur port 3000
- [ ] MongoDB connecté
- [ ] Route `/api/auth/google` disponible
- [ ] Route `/api/auth/register` retourne un token
- [ ] Validation du mot de passe = 1 caractère minimum

### Base de Données
- [ ] MongoDB Atlas accessible
- [ ] Collection `users` existe
- [ ] Les utilisateurs sont créés avec `status: 'active'`
- [ ] Les mots de passe sont hashés avec bcrypt

---

## 🚀 Prochaines Étapes Recommandées

1. **Tester l'inscription** : Créer un nouveau compte avec mot de passe simple
2. **Vérifier la connexion auto** : Confirmer qu'on arrive sur l'écran d'accueil
3. **Tester la déconnexion** : Se déconnecter et se reconnecter
4. **Configurer Google Sign-In** : Pour tester l'authentification Google (optionnel)
5. **Utiliser l'application** : Tester les autres fonctionnalités (chat, notifications, etc.)

---

## 📝 Notes de Sécurité

⚠️ **Important** : Les mots de passe simples (1 caractère) sont UNIQUEMENT pour le développement !

Pour la production, vous devriez :
1. Réactiver la validation forte des mots de passe
2. Implémenter l'authentification à deux facteurs (2FA)
3. Ajouter un captcha sur l'inscription
4. Logger toutes les tentatives de connexion
5. Bloquer les comptes après X tentatives échouées

---

## 🎉 Félicitations !

Si tous les tests passent, votre application dispose maintenant de :
- ✅ Inscription simplifiée avec mots de passe courts
- ✅ Connexion automatique après inscription
- ✅ Infrastructure pour Google Sign-In
- ✅ Expérience utilisateur fluide
- ✅ Sécurité maintenue (hashage bcrypt, JWT tokens)

---

**Date** : 6 décembre 2025
**Version testée** : 2.0.0
