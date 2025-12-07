# Guide de démarrage du projet Dräxlmaier

## ✅ Corrections effectuées

### Backend
1. **Warnings Mongoose corrigés** :
   - ✅ Retiré `useNewUrlParser` et `useUnifiedTopology` (dépréciés)
   - ✅ Supprimé les index dupliqués dans User.js (email déjà unique)
   - ✅ Supprimé les index dupliqués dans Team.js (name déjà unique)
   - ✅ Supprimé les index dupliqués dans Department.js (name déjà unique)
   - ✅ Supprimé les index dupliqués dans BusStop.js (name déjà unique)

2. **MongoDB Connection** :
   - Créé `.env.local` avec MongoDB local
   - L'erreur de connexion MongoDB Atlas est due au réseau

### Frontend
- Les erreurs de fonts et CanvasKit sont dues à des problèmes de connexion Internet
- Ces ressources sont chargées depuis Google CDN

## 🚀 Démarrage du projet

### Option 1: MongoDB Local (Recommandé pour développement)

#### 1. Installer MongoDB localement
```bash
# Télécharger MongoDB Community Server
# https://www.mongodb.com/try/download/community

# Ou avec Chocolatey sur Windows:
choco install mongodb
```

#### 2. Démarrer MongoDB
```powershell
# Dans un terminal PowerShell
mongod
```

#### 3. Utiliser .env.local
```powershell
cd backend
Copy-Item .env.local .env
npm start
```

### Option 2: MongoDB Atlas (avec Internet)

#### 1. Vérifier la connexion Internet
- Assurez-vous d'avoir une connexion Internet stable
- Vérifiez que le pare-feu n'bloque pas MongoDB Atlas

#### 2. Utiliser .env avec MongoDB Atlas
```powershell
cd backend
npm start
```

### Option 3: Docker MongoDB

```powershell
# Démarrer MongoDB dans Docker
docker run -d -p 27017:27017 --name mongodb mongo:latest

# Modifier .env
MONGODB_URI=mongodb://localhost:27017/draxlmaier-app

# Démarrer le backend
cd backend
npm start
```

## 🎯 Lancer l'application

### Backend
```powershell
cd backend
npm start
```

### Frontend
```powershell
cd "c:\Users\azizb\Desktop\Project\projet flutter"
flutter run -d chrome --web-port=8080
```

## ⚠️ Problèmes connus et solutions

### 1. MongoDB Connection Error
**Erreur**: `querySrv ECONNREFUSED`
**Solutions**:
- Vérifier la connexion Internet
- Utiliser MongoDB local
- Vérifier les credentials MongoDB Atlas
- Whitelist votre IP dans MongoDB Atlas

### 2. Flutter Web - Failed to fetch fonts
**Erreur**: `Failed to fetch dynamically imported module`
**Solutions**:
- Vérifier la connexion Internet
- Les fonts Google et CanvasKit nécessitent Internet
- Utiliser `flutter run -d chrome --web-renderer html` pour éviter CanvasKit

### 3. Mongoose Duplicate Index Warning
**Status**: ✅ Corrigé
- Supprimé les déclarations d'index redondantes

## 📝 Variables d'environnement

### .env (MongoDB Atlas)
```env
MONGODB_URI=mongodb+srv://user:password@cluster.mongodb.net/database
```

### .env.local (MongoDB Local)
```env
MONGODB_URI=mongodb://localhost:27017/draxlmaier-app
```

## 🔧 Commandes utiles

### Backend
```powershell
# Installer les dépendances
npm install

# Démarrer en mode développement
npm start

# Tester la connexion
curl http://localhost:3000/health
```

### Frontend
```powershell
# Nettoyer le cache
flutter clean

# Récupérer les dépendances
flutter pub get

# Lancer sur Chrome
flutter run -d chrome --web-port=8080

# Lancer avec HTML renderer (sans CanvasKit)
flutter run -d chrome --web-renderer html --web-port=8080
```

## ✨ Fonctionnalités implémentées

1. ✅ Logo Dräxlmaier sur toutes les pages
2. ✅ Système d'inscription en 4 étapes
3. ✅ Validation des utilisateurs par le manager
4. ✅ Gestion des objectifs
5. ✅ Dashboard role-specific (Employee/Manager)
6. ✅ Thème Dräxlmaier avec couleurs officielles
7. ✅ Backend API complet avec authentification

## 🎨 Logo

Le logo Dräxlmaier est maintenant visible sur :
- Page de connexion (120px)
- Page d'inscription (avec animation)
- App bar personnalisée
- Splash screen

Fichier utilisé : `assets/images/draclmaier_Avec_coleur.jpg`
