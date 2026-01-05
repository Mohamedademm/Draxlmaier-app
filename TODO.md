# 📝 TODO List - Améliorations Draexlmaier App

## 🚀 Phase 1 : Fondations UX/UI (Terminé)
- [x] Corriger l'erreur "RenderFlex overflowed" dans `modern_widgets.dart`
- [x] Créer le système d'animations (`animations.dart`)
- [x] Créer les composants Skeleton Loading (`skeleton_loader.dart`)
- [x] Appliquer le Skeleton Loading sur l'écran Détails Objectif
- [x] Créer une page Paramètres dédiée avec Mode Sombre

## 🎨 Phase 2 : Déploiement Global UX (En cours)
- [x] **Dashboard** : Remplacer les loaders par des `SkeletonStatCard` et animer l'apparition des cartes.
- [x] **Liste des Objectifs** : Ajouter `SkeletonList` et l'animation `staggeredList` pour l'apparition des items.
- [x] **Profil** : Utiliser `SkeletonProfile` pour le chargement.
- [x] **Navigation** : Ajouter des transitions de page fluides (Slide/Fade) dans `main.dart`.
- [x] **Pull-to-Refresh** : Ajouter la fonctionnalité "tirer pour rafraîchir" sur les listes (Objectifs, Notifications).

## 📱 Phase 3 : Fonctionnalités Avancées (Terminé)
- [x] **Recherche** : Ajouter une barre de recherche globale ou par écran.
- [x] **Filtres** : Ajouter des filtres avancés (par date, statut, priorité) pour les objectifs.
- [x] **Notifications** : Améliorer l'affichage et la gestion des notifications (marquer comme lu, suppression).
- [x] **Mode Hors Ligne** : Mettre en cache les données essentielles (Partiel via Provider state).

## ⚡ Phase 4 : Optimisation & Nettoyage (Terminé)
- [x] Optimiser les images (Gestion Base64/Network).
- [x] Nettoyer le code mort.
- [x] Vérifier la compatibilité responsive (Mobile/Web).
