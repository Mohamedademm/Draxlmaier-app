# 🧪 Guide de Test - Personnalisation du Thème

## ✅ Checklist de Test

### 1. **Test de la Personnalisation du Thème (Admin)**

#### Accès à l'Écran
- [ ] Connectez-vous avec un compte admin:
  - Email: `admin@draexlmaier.com`
  - Password: `Test123!`
- [ ] Allez dans le "Admin Dashboard"
- [ ] Vérifiez que le bouton "🎨 Theme Customization" est visible
- [ ] Cliquez sur "Theme Customization"

#### Test du Color Picker - Couleur Primaire
- [ ] Section "Couleur Primaire" visible avec carré bleu (#0F4C81)
- [ ] Cliquez sur "Modifier"
- [ ] Dialog du color picker s'ouvre avec 24 couleurs
- [ ] Sélectionnez une couleur différente (ex: violet #9C27B0)
- [ ] L'aperçu en haut se met à jour instantanément
- [ ] Fermez le dialog
- [ ] L'AppBar de l'écran change de couleur
- [ ] Retournez au dashboard - l'AppBar a la nouvelle couleur

#### Test du Color Picker - Couleur d'Accent
- [ ] Retournez à "Theme Customization"
- [ ] Section "Couleur d'Accent" visible avec carré rouge (#E63946)
- [ ] Cliquez sur "Modifier"
- [ ] Sélectionnez une couleur différente (ex: orange #F59E0B)
- [ ] Vérifiez que l'aperçu se met à jour

#### Test du Color Picker - Couleur de Fond
- [ ] Section "Couleur de Fond" visible avec carré gris clair (#F8F9FA)
- [ ] Cliquez sur "Modifier"
- [ ] Sélectionnez une couleur différente (ex: blanc #FFFFFF)
- [ ] L'arrière-plan de l'écran change

#### Test de Persistance
- [ ] Modifiez les 3 couleurs (primaire, accent, fond)
- [ ] Retournez au dashboard
- [ ] Fermez complètement l'application (Ctrl+C dans le terminal)
- [ ] Relancez l'application: `flutter run -d chrome --web-port 8081`
- [ ] Connectez-vous à nouveau
- [ ] Vérifiez que les couleurs personnalisées sont conservées

#### Test de Réinitialisation
- [ ] Allez dans "Theme Customization"
- [ ] Cliquez sur l'icône ↻ (refresh) en haut à droite
- [ ] Message de confirmation "✅ Thème réinitialisé aux valeurs par défaut"
- [ ] Vérifiez que les couleurs reviennent aux valeurs d'origine:
  - Primaire: Bleu #0F4C81
  - Accent: Rouge #E63946
  - Fond: Gris clair #F8F9FA

---

### 2. **Test des Notifications**

#### Envoi de Notification
- [ ] Connecté en tant qu'admin
- [ ] Dashboard > "Send Notification"
- [ ] Remplissez le titre: "Test de notification"
- [ ] Remplissez le message: "Ceci est un test"
- [ ] Cliquez sur "Send"
- [ ] Message de succès s'affiche: "✅ Notification envoyée à tous les utilisateurs avec succès!"
- [ ] La liste des notifications se recharge automatiquement
- [ ] La nouvelle notification apparaît dans la liste

#### Badge de Compteur
- [ ] Vérifiez l'icône 🔔 dans la barre de navigation en bas
- [ ] Un badge rouge avec un chiffre doit être visible (si notifications non lues)
- [ ] Le badge affiche le nombre de notifications non lues
- [ ] Si plus de 99 notifications, affiche "99+"
- [ ] Le badge a une bordure blanche
- [ ] Marquez une notification comme lue
- [ ] Le compteur diminue de 1

---

### 3. **Test des Images de Profil**

#### Upload d'Image
- [ ] Connecté en tant qu'utilisateur (ou admin)
- [ ] Allez dans l'onglet "Profile" (👤)
- [ ] Cliquez sur "Edit Profile"
- [ ] Cliquez sur "Choose Profile Image"
- [ ] Sélectionnez une image (JPG, PNG)
- [ ] L'aperçu de l'image s'affiche
- [ ] Cliquez sur "Save Changes"
- [ ] Message de succès

#### Affichage de l'Image
- [ ] Retournez à l'écran "Profile"
- [ ] Vérifiez que l'image uploadée est affichée dans le CircleAvatar
- [ ] L'image est ronde et bien cadrée
- [ ] Pas d'initiale affichée (car image présente)

#### Affichage dans HomeScreen
- [ ] Allez dans l'onglet "Home"
- [ ] Vérifiez que l'image de profil est visible en haut
- [ ] L'image est affichée dans un CircleAvatar
- [ ] Si aucune image, l'initiale du prénom est affichée

#### Test Base64 vs URL
- [ ] Image en base64 (data:image/...) fonctionne
- [ ] Image en URL (https://...) fonctionne aussi
- [ ] Pas d'erreur dans la console

---

### 4. **Test du Design Moderne**

#### Écran de Connexion
- [ ] Ouvrez l'application
- [ ] Écran de connexion avec dégradé bleu
- [ ] Animation de fade-in (apparition progressive)
- [ ] Animation de slide-up (montée du formulaire)
- [ ] Logo Draexlmaier centré
- [ ] Texte "Welcome Back" élégant
- [ ] Carte blanche avec ombres
- [ ] Champs avec icônes 📧 et 🔒
- [ ] Toggle de visibilité du mot de passe (👁️)
- [ ] Bouton "Sign In" avec dégradé
- [ ] Hints des comptes de test en bas

#### Widgets Modernes
- [ ] Les cartes (ModernCard) ont des ombres et coins arrondis
- [ ] Effet hover sur les cartes (survol souris)
- [ ] Les boutons ont des dégradés
- [ ] Les badges de statut sont colorés
- [ ] Les AppBars ont des dégradés

---

### 5. **Test de Sécurité**

#### Accès Réservé Admin
- [ ] Connectez-vous avec un compte utilisateur normal:
  - Email: `mike.davis@draexlmaier.com`
  - Password: `Test123!`
- [ ] Tentez d'accéder à `/theme-customization` manuellement
- [ ] Vérifiez que l'accès est bloqué
- [ ] Message "Accès réservé aux administrateurs" affiché
- [ ] Icône 🔒 visible
- [ ] Pas d'accès aux color pickers

---

## 🐛 Erreurs Connues à Vérifier

### Erreurs Possibles
- [ ] Erreur "Cannot invoke a non-'const' constructor" → **CORRIGÉE**
- [ ] Badge de notification ne s'affiche pas → Vérifier `unreadCount > 0`
- [ ] Image base64 ne charge pas → Vérifier `split(',').last`
- [ ] Color picker ne s'ouvre pas → Vérifier import `flutter_colorpicker`
- [ ] Couleurs ne persistent pas → Vérifier SharedPreferences

### Console Navigateur
- [ ] Ouvrez la console (F12)
- [ ] Aucune erreur rouge
- [ ] Pas de warning critiques
- [ ] Les requêtes API réussissent (200 OK)

---

## 📊 Résultats Attendus

### ✅ Fonctionnalités qui doivent fonctionner:
1. **Personnalisation du thème** - Admin peut changer les couleurs et les sauvegarder
2. **Persistance** - Les couleurs sont conservées après redémarrage
3. **Réinitialisation** - Bouton pour revenir aux couleurs par défaut
4. **Notifications** - Message de confirmation + rechargement automatique
5. **Badge de compteur** - Affichage du nombre de notifications non lues
6. **Images de profil** - Upload et affichage dans CircleAvatar
7. **Design moderne** - Écran de connexion avec animations
8. **Sécurité** - Accès theme customization réservé aux admins

---

## 🚀 Commandes de Test

### Lancer l'Application
```bash
cd "c:\Users\azizb\Desktop\Project\projet flutter"
flutter run -d chrome --web-port 8081
```

### Lancer le Backend (si non lancé)
```bash
cd "c:\Users\azizb\Desktop\Project\projet flutter\backend"
node server.js
```

### Vérifier les Processus Node
```powershell
Get-Process | Where-Object {$_.ProcessName -eq "node"}
```

---

## 📝 Comptes de Test

### Administrateur
- **Email:** `admin@draexlmaier.com`
- **Password:** `Test123!`
- **Accès:** Tous les écrans, theme customization

### Utilisateur Normal
- **Email:** `mike.davis@draexlmaier.com`
- **Password:** `Test123!`
- **Accès:** Écrans utilisateur uniquement

### Manager
- **Email:** `manager@draexlmaier.com`
- **Password:** `Test123!`
- **Accès:** Écrans manager + objectives

---

## 🎯 Critères de Succès

L'implémentation est réussie si:
1. ✅ Admin peut ouvrir l'écran de personnalisation
2. ✅ Les 3 color pickers fonctionnent
3. ✅ Les modifications s'appliquent en temps réel
4. ✅ Les couleurs sont sauvegardées après fermeture
5. ✅ Le bouton reset fonctionne
6. ✅ Les utilisateurs normaux n'ont pas accès
7. ✅ Notifications affichent le message de succès
8. ✅ Badge de compteur fonctionne
9. ✅ Images de profil s'affichent correctement
10. ✅ Aucune erreur dans la console

---

## 📞 Support

Si vous rencontrez des problèmes:
1. Vérifiez que le backend est lancé (port 3000)
2. Vérifiez que l'application Flutter est sur le port 8081
3. Consultez la console du navigateur (F12)
4. Vérifiez les logs du terminal Flutter
5. Consultez `THEME_CUSTOMIZATION_GUIDE.md` pour plus de détails

**Bonne chance pour les tests ! 🚀**
