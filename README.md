<div align="center">

<h1>📇 Contact Mobile Application</h1>
<p><strong>A full-stack mobile app for managing contacts and placing calls — built with Flutter, PHP, and MySQL</strong></p>

<p>
  <img src="https://img.shields.io/badge/Flutter-Mobile-02569B?style=flat-square&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-Language-0175C2?style=flat-square&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/PHP-Backend-777BB4?style=flat-square&logo=php&logoColor=white" />
  <img src="https://img.shields.io/badge/MySQL-Database-4479A1?style=flat-square&logo=mysql&logoColor=white" />
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?style=flat-square&logo=android&logoColor=white" />
</p>

</div>

---

## Overview

A full-stack mobile application that lets users securely manage their personal contacts and place calls directly from the app — with SIM card selection support for dual-SIM devices. The Flutter frontend communicates with a PHP REST API backed by a MySQL database.

---

## Screenshots

<p align="center">
  <img src="https://github.com/mamouneabdelli/contact_mobile_application/blob/e0aed9481e09b0620b1903da06f3e670ddda5f0a/Capture%20d%E2%80%99%C3%A9cran%20(143).png" width="23%" />
  <img src="https://github.com/mamouneabdelli/contact_mobile_application/blob/e0aed9481e09b0620b1903da06f3e670ddda5f0a/Capture%20d%E2%80%99%C3%A9cran%20(144).png" width="23%" />
  <img src="https://github.com/mamouneabdelli/contact_mobile_application/blob/e0aed9481e09b0620b1903da06f3e670ddda5f0a/Capture%20d%E2%80%99%C3%A9cran%20(145).png" width="23%" />
  <img src="https://github.com/mamouneabdelli/contact_mobile_application/blob/e0aed9481e09b0620b1903da06f3e670ddda5f0a/Capture%20d%E2%80%99%C3%A9cran%20(146).png" width="23%" />
</p>
<p align="center">
  <img src="https://github.com/mamouneabdelli/contact_mobile_application/blob/e0aed9481e09b0620b1903da06f3e670ddda5f0a/Capture%20d%E2%80%99%C3%A9cran%20(147).png" width="23%" />
  <img src="https://github.com/mamouneabdelli/contact_mobile_application/blob/e0aed9481e09b0620b1903da06f3e670ddda5f0a/Capture%20d%E2%80%99%C3%A9cran%20(148).png" width="23%" />
  <img src="https://github.com/mamouneabdelli/contact_mobile_application/blob/e0aed9481e09b0620b1903da06f3e670ddda5f0a/Capture%20d%E2%80%99%C3%A9cran%20(149).png" width="23%" />
  <img src="https://github.com/mamouneabdelli/contact_mobile_application/blob/e0aed9481e09b0620b1903da06f3e670ddda5f0a/Capture%20d%E2%80%99%C3%A9cran%20(150).png" width="23%" />
</p>

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile Frontend | Flutter (Dart) |
| Backend API | PHP |
| Database | MySQL |
| DB Management | phpMyAdmin |
| Local Server | XAMPP |

---

## Features

### 🔐 Authentication
- Secure login with backend validation
- Session-based user access control

### 📇 Contact Management (CRUD)
- Add contacts with name, phone number, and details
- Edit and update existing contact information
- Delete contacts
- Browse and search the full contact list

### 📞 Calling
- Place calls directly from a contact's profile
- SIM card selection prompt for dual-SIM devices

---

## Architecture

```
Flutter App  ──(HTTP / JSON)──►  PHP REST API  ──►  MySQL Database
     ▲                                │
     └────────── JSON Response ───────┘
```

The Flutter client sends HTTP requests to the PHP backend, which performs CRUD operations on the MySQL database and returns JSON responses.

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [XAMPP](https://www.apachefriends.org/) (or any PHP + MySQL server)
- phpMyAdmin

### 1 — Backend Setup

1. Start Apache and MySQL in XAMPP.
2. Open **phpMyAdmin** and import the provided `.sql` database file.
3. Update the database credentials in the PHP config file:
   ```php
   // config.php
   $host = "localhost";
   $db   = "contacts_db";
   $user = "root";
   $pass = "";
   ```

### 2 — Flutter Setup

```bash
# Clone the repository
git clone https://github.com/mamouneabdelli/contact_mobile_application.git
cd contact_mobile_application

# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run
```

> **Note:** Update the base API URL in the Flutter project to match your local server address (e.g., `http://192.168.x.x/contact_api/`).

---

## Roadmap

- [ ] User registration and account management
- [ ] Contact profile pictures
- [ ] Biometric authentication (fingerprint / face ID)
- [ ] Contact backup and restore
- [ ] Cloud API deployment (replace XAMPP)
- [ ] Dark mode UI

---

<div align="center">
  <sub>Built with Flutter & PHP · Developed by <a href="https://github.com/mamouneabdelli">Abdelli Abdelmoumen</a></sub>
</div>
