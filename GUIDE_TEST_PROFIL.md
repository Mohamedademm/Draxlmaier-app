# Guide de Test - Gestion du Profil Utilisateur

## 🎯 Fonctionnalités Implémentées

### 1. **Modification du Profil Utilisateur**
   - Modification des informations personnelles
   - Upload d'image de profil
   - Modification des coordonnées professionnelles
   - Modification de l'adresse

### 2. **Corrections des Notifications**
   - Envoi de notifications à tous les utilisateurs
   - Validation corrigée pour accepter un tableau vide de `targetUsers`

---

## 🚀 Comment Tester

### Prérequis
1. **Backend en cours d'exécution** sur `http://localhost:3000`
2. **Frontend Flutter** accessible sur `http://localhost:8080`
3. **Compte de test** : 
   - Email: `admin@gmail.com`
   - Mot de passe: `admin`

---

## 📋 Tests de la Gestion du Profil

### Test 1 : Accéder à l'Écran de Modification du Profil

**Étapes :**
1. Connectez-vous avec `admin@gmail.com` / `admin`
2. Cliquez sur l'onglet **Profil** (dernier onglet en bas)
3. Cliquez sur le bouton **"Modifier le profil"**

**Résultat attendu :**
- ✅ L'écran "Modifier le profil" s'affiche
- ✅ Les champs sont pré-remplis avec les données actuelles de l'utilisateur
- ✅ L'avatar affiche l'initiale ou l'image de profil actuelle

---

### Test 2 : Modifier les Informations Personnelles

**Étapes :**
1. Sur l'écran "Modifier le profil"
2. Modifiez les champs :
   - **Prénom** : Changez pour "Admin"
   - **Nom** : Changez pour "Principal"
   - **Téléphone** : Ajoutez "+33 6 12 34 56 78"
3. Cliquez sur **"Enregistrer les modifications"**

**Résultat attendu :**
- ✅ Message de succès : "Profil mis à jour avec succès"
- ✅ Retour automatique à l'écran Profil
- ✅ Les nouvelles informations sont affichées
- ✅ Le nom dans l'en-tête est mis à jour

---

### Test 3 : Upload d'Image de Profil

**Étapes :**
1. Sur l'écran "Modifier le profil"
2. Cliquez sur **l'icône caméra** (coin inférieur droit de l'avatar)
3. Sélectionnez une image depuis votre ordinateur
   - Format supporté : JPG, PNG, GIF
   - Taille recommandée : < 2 MB
4. L'image apparaît immédiatement dans l'aperçu
5. Cliquez sur **"Enregistrer les modifications"**

**Résultat attendu :**
- ✅ L'image sélectionnée s'affiche dans l'avatar immédiatement
- ✅ Après enregistrement, l'image est sauvegardée
- ✅ L'image s'affiche partout dans l'application (profil, chat, etc.)
- ✅ L'image est stockée en base64 dans la base de données

**Note technique :**
- L'image est convertie en base64 pour la compatibilité web
- Format stocké : `data:image/png;base64,iVBORw0KGgoAAAANS...`

---

### Test 4 : Modifier les Informations Professionnelles

**Étapes :**
1. Sur l'écran "Modifier le profil"
2. Modifiez les champs professionnels :
   - **Département** : "Direction Générale"
   - **Poste** : "Administrateur Système"
3. Cliquez sur **"Enregistrer les modifications"**

**Résultat attendu :**
- ✅ Les informations professionnelles sont mises à jour
- ✅ Visible dans la fiche de profil

---

### Test 5 : Modifier l'Adresse

**Étapes :**
1. Sur l'écran "Modifier le profil"
2. Remplissez les champs d'adresse :
   - **Adresse** : "123 Rue de la République"
   - **Ville** : "Paris"
   - **Code Postal** : "75001"
3. Cliquez sur **"Enregistrer les modifications"**

**Résultat attendu :**
- ✅ L'adresse est sauvegardée
- ✅ Les informations sont disponibles pour la géolocalisation future

---

### Test 6 : Validation des Champs Obligatoires

**Étapes :**
1. Sur l'écran "Modifier le profil"
2. **Videz** le champ **Prénom**
3. Essayez de cliquer sur **"Enregistrer les modifications"**

**Résultat attendu :**
- ✅ Message d'erreur : "Le prénom est requis"
- ✅ Le formulaire ne se soumet pas
- ✅ Le champ en erreur est mis en évidence

**Répétez avec :**
- Nom vide → "Le nom est requis"

---

### Test 7 : Permissions - Utilisateur Normal

**Étapes :**
1. Connectez-vous avec un compte **employé** (ex: `ademuser@gmail.com` / `123456`)
2. Accédez à l'onglet **Profil**
3. Cliquez sur **"Modifier le profil"**
4. Modifiez vos informations personnelles
5. Essayez de modifier les informations d'un autre utilisateur (via API)

**Résultat attendu :**
- ✅ L'utilisateur peut modifier SON propre profil
- ✅ Erreur 403 si tentative de modification d'un autre profil
- ✅ Message : "Vous ne pouvez modifier que votre propre profil"

---

### Test 8 : Permissions - Admin/Manager

**Étapes :**
1. Connectez-vous avec le compte **admin** ou **manager**
2. L'admin/manager peut modifier n'importe quel profil utilisateur

**Résultat attendu :**
- ✅ Admin peut modifier tous les profils
- ✅ Manager peut modifier les profils sous sa responsabilité

---

## 📋 Tests des Notifications (Correction)

### Test 9 : Envoyer une Notification à Tous les Utilisateurs

**Étapes :**
1. Connectez-vous en tant qu'admin
2. Accédez au **Dashboard Admin**
3. Allez dans **Notifications**
4. Créez une nouvelle notification :
   - **Type** : "info"
   - **Titre** : "Test notification globale"
   - **Message** : "Ceci est un test d'envoi à tous"
   - **Destinataires** : Laissez vide ou sélectionnez "Tous les utilisateurs"
5. Envoyez la notification

**Résultat attendu :**
- ✅ La notification est envoyée avec succès
- ✅ **AVANT** : Erreur 400 "At least one target user is required"
- ✅ **APRÈS** : Succès, tous les utilisateurs actifs reçoivent la notification
- ✅ Le backend convertit automatiquement le tableau vide en "tous les utilisateurs actifs"

---

## 🔧 Détails Techniques

### Backend - Endpoint Créé

**Route :** `PUT /api/users/:id/profile`

**Middleware :**
- `authenticate` : Vérifie le token JWT
- Permissions : L'utilisateur peut modifier son propre profil OU être admin/manager

**Corps de la requête :**
```json
{
  "firstname": "string",
  "lastname": "string",
  "phone": "string",
  "department": "string",
  "position": "string",
  "address": "string",
  "city": "string",
  "postalCode": "string",
  "profileImageBase64": "data:image/png;base64,..."
}
```

**Réponse :**
```json
{
  "status": "success",
  "message": "Profil mis à jour avec succès",
  "user": {
    "id": "...",
    "firstname": "Admin",
    "lastname": "Principal",
    "email": "admin@gmail.com",
    "phone": "+33 6 12 34 56 78",
    "profileImage": "data:image/png;base64,...",
    ...
  }
}
```

---

### Frontend - Composants Créés

**Fichier :** `lib/screens/edit_profile_screen.dart`

**Fonctionnalités :**
1. **Upload d'image web** :
   ```dart
   import 'dart:html' as html;
   
   Future<void> _pickImage() async {
     final input = html.FileUploadInputElement()..accept = 'image/*';
     input.click();
     input.onChange.listen((event) async {
       final file = input.files?.first;
       final reader = html.FileReader();
       reader.readAsDataUrl(file);
       reader.onLoadEnd.listen((event) {
         setState(() {
           _profileImageBase64 = reader.result as String;
         });
       });
     });
   }
   ```

2. **Formulaire avec validation** :
   - 9 TextFormController pour tous les champs
   - Validation des champs requis (firstname, lastname)
   - Affichage des erreurs en temps réel

3. **Intégration AuthProvider** :
   - Lecture du user via `context.watch<AuthProvider>()`
   - Appel de `refreshUser()` après mise à jour
   - Mise à jour automatique de l'interface

---

### Modèle User Mis à Jour

**Ajout du champ :**
```dart
final String? profileImage;
```

**Fichier généré :** `user_model.g.dart` (régénéré automatiquement)

---

### Notification - Correction de la Validation

**Fichier :** `backend/middleware/validation.js`

**AVANT :**
```javascript
body('targetUsers')
  .isArray({ min: 1 })
  .withMessage('At least one target user is required')
```

**APRÈS :**
```javascript
body('targetUsers')
  .optional()
  .isArray()
  .custom((users) => {
    // Permet un tableau vide pour "tous les utilisateurs"
    if (!users || users.length === 0) return true;
    // Sinon, vérifie que ce sont des ObjectIds valides
    return users.every(id => mongoose.Types.ObjectId.isValid(id));
  })
```

---

## ✅ Checklist Complète

### Fonctionnalités Profil
- [x] Écran "Modifier le profil" créé
- [x] Upload d'image de profil (base64)
- [x] Modification informations personnelles
- [x] Modification informations professionnelles
- [x] Modification adresse
- [x] Validation des champs requis
- [x] Permissions (utilisateur ne peut modifier que son profil)
- [x] Permissions admin/manager (peuvent modifier tous les profils)
- [x] Refresh automatique du profil après modification
- [x] Endpoint backend `/users/:id/profile` créé
- [x] Route ajoutée dans `userRoutes.js`
- [x] Route ajoutée dans `main.dart`
- [x] Bouton "Modifier le profil" dans HomeScreen
- [x] Modèle User mis à jour avec `profileImage`

### Fonctionnalités Notifications
- [x] Validation corrigée pour accepter tableau vide
- [x] Envoi à tous les utilisateurs fonctionnel
- [x] Backend convertit tableau vide en "tous les utilisateurs actifs"

---

## 🎉 Succès !

Toutes les fonctionnalités ont été implémentées avec succès :

1. ✅ **Gestion complète du profil utilisateur**
2. ✅ **Upload d'images de profil**
3. ✅ **Correction des notifications globales**

L'application est maintenant prête pour que les utilisateurs gèrent leurs profils et reçoivent des notifications !

---

## 🔜 Prochaines Étapes Suggérées

1. **Optimisation des images** :
   - Compression automatique avant upload
   - Limite de taille d'image (actuellement illimitée)
   - Stockage sur AWS S3 ou Azure Blob au lieu de base64

2. **Amélioration UX** :
   - Crop d'image avant upload
   - Prévisualisation de l'image en plein écran
   - Historique des modifications de profil

3. **Sécurité** :
   - Rate limiting sur l'upload d'images
   - Validation du type MIME côté backend
   - Scan antivirus des images uploadées

4. **Debug** :
   - Résoudre le problème de token transmission (401 lors de création d'utilisateurs depuis Flutter)
   - Utiliser le debug screen : `http://localhost:8080/#/debug-user-creation`
