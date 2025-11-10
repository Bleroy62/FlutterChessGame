# 🦫 CapyChess - Jeu d'Échecs Flutter

Un jeu d'échecs élégant développé avec Flutter, mettant en scène des capybaras comme pièces d'échecs.

## ✨ Fonctionnalités

- **🎯 Interface intuitive** : Plateau d'échecs 8x8 avec design moderne
- **🦫 Pièces thématiques** : Capybaras mignons comme pièces d'échecs
- **♟️ Mouvements complets** : Toutes les règles d'échecs implémentées
- **⚡ Détection d'échec et mat** : Système intelligent de vérification
- **🏆 Écran de victoire stylisé** : Animation et design élégant
- **📱 Responsive** : Compatible mobile et tablette
- **🎨 Design moderne** : Interface utilisateur fluide et attrayante

## 🚀 Installation

### Prérequis
- Flutter SDK (version 3.0 ou supérieure)
- Android Studio / VS Code
- Émulateur Android/iOS ou appareil physique

### Étapes d'installation

1. **Cloner le repository**
   ```bash
   git clone https://github.com/votre-username/capychess.git
   cd capychess

2. Installer les dépendances
   flutter pub get

3. Lancer l'application
   flutter run

🎮 Comment jouer
Sélectionnez une pièce : Appuyez sur une pièce pour la sélectionner

Voir les mouvements valides : Les cases vertes indiquent les déplacements possibles

Déplacer la pièce : Appuyez sur une case verte pour déplacer la pièce

Capturer : Déplacez votre pièce sur une case occupée par une pièce adverse

Échec et mat : Le jeu se termine lorsqu'un roi est en échec et mat

lib/
├── components/
│   ├── piece.dart          # Widget des pièces d'échecs
│   ├── square.dart         # Widget des cases du plateau
│   └── dead_piece.dart     # Widget des pièces capturées
├── helper/
│   └── helper_methods.dart # Méthodes utilitaires
├── values/
│   └── colors.dart         # Palette de couleurs
└── main.dart               # Point d'entrée de l'app

🎯 Règles implémentées
✅ Déplacement de toutes les pièces (Pion, Tour, Cavalier, Fou, Reine, Roi)

✅ Prise des pièces adverses

✅ Détection d'échec

✅ Détection d'échec et mat

✅ Tour de jeu alterné

✅ Affichage des pièces capturées

✅ Validation des mouvements (empêche les coups illégaux)

🛠️ Développement
Architecture
L'application utilise une architecture Stateful Widget avec :

Gestion d'état via setState

Plateau représenté par une matrice 8x8

Logique de jeu séparée en méthodes spécialisées
