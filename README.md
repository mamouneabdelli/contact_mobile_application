# contact_mobile_application
📱 Application de Gestion de Contacts - Flutter + PHP
Une application mobile complète de gestion de contacts avec interface utilisateur moderne et backend PHP/MySQL.

https://img.shields.io/badge/Flutter-3.16-blue
https://img.shields.io/badge/PHP-8.0-purple
https://img.shields.io/badge/MySQL-8.0-orange
https://img.shields.io/badge/License-MIT-green

✨ Fonctionnalités
✅ CRUD Complet des contacts (Créer, Lire, Mettre à jour, Supprimer)

📞 Appel téléphonique simulé depuis l'application

🔍 Recherche avancée par nom, prénom ou téléphone

🎨 Interface utilisateur moderne avec thème sombre

🔄 Synchronisation en temps réel via API REST

📱 Design responsive adapté à tous les écrans

🛡️ Gestion d'erreurs robuste avec messages utilisateur

🔄 Pull-to-refresh pour actualiser la liste

📅 Tri par date d'ajout (plus récents en premier)

📸 Captures d'écran
Liste des contacts	Ajouter contact	Détails contact
https://via.placeholder.com/300x600/2D3748/FFFFFF?text=Liste+Contacts	https://via.placeholder.com/300x600/2D3748/FFFFFF?text=Ajouter+Contact	https://via.placeholder.com/300x600/2D3748/FFFFFF?text=D%C3%A9tails+Contact
🏗️ Architecture du Projet
text
📁 Contact-App/
├── 📁 lib/                          # Code source Flutter
│   ├── 📄 main.dart                 # Point d'entrée principal
│   ├── 📁 models/                   # Modèles de données
│   │   ├── 📄 Contact.dart         # Modèle Contact
│   │   └── 📄 Personne.dart        # Modèle Personne
│   ├── 📁 services/                 # Services et API
│   │   └── 📄 api_service.dart     # Service API REST
│   └── 📁 widgets/                  # Widgets personnalisés
│       └── 📄 contact_widget.dart  # Widget d'affichage contact
├── 📁 backend/                      # Backend PHP
│   ├── 📄 api_contacts.php         # API REST complète
│   └── 📄 config.php               # Configuration DB
├── 📁 database/                     # Scripts SQL
│   └── 📄 schema.sql               # Structure de la base
├── 📄 pubspec.yaml                 # Dépendances Flutter
└── 📄 README.md                    # Ce fichier
🚀 Installation Rapide
Prérequis
Flutter SDK (v3.16+)

XAMPP ou WAMP (PHP 8.0+, MySQL 8.0+)

Android Studio ou VS Code

Git

Installation en 5 étapes
1. Backend (PHP/MySQL)
bash
# 1. Téléchargez et installez XAMPP
# 2. Démarrez Apache et MySQL
# 3. Créez la base de données
mysql -u root -p -e "CREATE DATABASE contact_app;"

# 4. Importez le schéma
mysql -u root -p contact_app < database/schema.sql

# 5. Copiez les fichiers API
cp -r backend/ C:/xampp/htdocs/contacts_api/
2. Frontend (Flutter)
bash
# 1. Clonez le projet
git clone https://github.com/votre-username/contact-app.git
cd contact-app

# 2. Installez les dépendances
flutter pub get

# 3. Configurez l'URL API (modifiez api_service.dart)
# Pour Windows/Mac :
baseUrl = 'http://localhost/contacts_api/api_contacts.php'
# Pour Android Emulator :
baseUrl = 'http://10.0.2.2/contacts_api/api_contacts.php'

# 4. Lancez l'application
flutter run
📖 Guide d'Utilisation
Ajouter un contact
Appuyez sur le bouton + en bas à droite

Remplissez le formulaire (Prénom, Nom, Téléphone)

L'email est généré automatiquement

Appuyez sur "Ajouter"

Modifier un contact
Appuyez sur un contact dans la liste

Cliquez sur "Modifier" dans la fenêtre de détails

Modifiez les informations

Sauvegardez les changements

Supprimer un contact
Ouvrez les détails du contact

Cliquez sur "Supprimer"

Confirmez la suppression

Faire un appel
Cliquez sur l'icône 📞 à côté d'un contact

Confirmez l'appel

(Simulation - affiche un message de confirmation)
