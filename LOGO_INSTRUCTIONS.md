# 📋 Instructions pour ajouter le logo Draexlmaier

## Étapes à suivre :

### 1. Extraire le logo du PDF
- Ouvrir le fichier `yassine_syrine_app[1].pdf`
- Extraire/copier le logo Draexlmaier
- Enregistrer en format PNG avec fond transparent

### 2. Créer les versions du logo

Créer **3 versions** du logo :

#### a) Logo couleur (pour fond blanc)
- Nom : `draexlmaier_logo.png`
- Taille recommandée : 512x512 px
- Fond : Transparent
- Couleurs : Originales du logo

#### b) Logo blanc (pour fond foncé/bleu)
- Nom : `draexlmaier_logo_white.png`
- Taille recommandée : 512x512 px
- Fond : Transparent
- Couleur : Blanc (#FFFFFF)

#### c) Logo splash (haute résolution)
- Nom : `logo_splash.png`
- Taille recommandée : 1024x1024 px
- Fond : Transparent
- Pour l'écran de démarrage

### 3. Placer les fichiers

Copier les 3 fichiers PNG dans le dossier :
```
assets/images/
├── draexlmaier_logo.png
├── draexlmaier_logo_white.png
└── logo_splash.png
```

### 4. Vérifier la configuration

Le fichier `pubspec.yaml` est déjà configuré :
```yaml
flutter:
  assets:
    - assets/images/
```

### 5. Tester l'application

Exécuter les commandes :
```bash
# Obtenir les dépendances
flutter pub get

# Lancer l'application
flutter run
```

## ✅ Résultat attendu

Une fois le logo ajouté, vous verrez :

1. **Splash Screen** : Logo blanc sur fond bleu dégradé
2. **Login Screen** : Logo couleur en haut
3. **Home Screen** : Logo dans l'AppBar
4. **Tous les écrans** : Logo dans la barre de navigation

## 🎨 Alternatives si le logo n'est pas disponible

Le système utilise actuellement un **placeholder** avec le texte "DRAEXLMAIER" qui simule le logo.

Pour personnaliser le placeholder, modifier le fichier :
`lib/widgets/draexlmaier_logo.dart`

## 📝 Notes importantes

- **Format** : PNG recommandé (supporte la transparence)
- **Qualité** : Haute résolution pour éviter le flou
- **Taille** : Ne pas dépasser 2 MB par image
- **Couleurs** : Respecter la charte graphique Draexlmaier

## 🔧 Si le logo ne s'affiche pas

1. Vérifier que les fichiers sont dans `assets/images/`
2. Exécuter `flutter clean`
3. Exécuter `flutter pub get`
4. Relancer l'application

## 📱 Tailles recommandées par plateforme

### Android
- MDPI (1x) : 128x128
- HDPI (1.5x) : 192x192
- XHDPI (2x) : 256x256
- XXHDPI (3x) : 384x384
- XXXHDPI (4x) : 512x512

### iOS
- 1x : 128x128
- 2x : 256x256
- 3x : 384x384

### Web
- Standard : 512x512
- Haute résolution : 1024x1024

---

**Créé le** : 29 novembre 2025
**Projet** : Draexlmaier Employee Management App
