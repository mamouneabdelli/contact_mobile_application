<div align="center">

# 📇 Contact Mobile Application

**A full-stack mobile application for managing contacts and placing phone calls — built with Flutter, PHP, and MySQL.**

<p>
  <img src="https://img.shields.io/badge/Flutter-Mobile-02569B?style=flat-square&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-Language-0175C2?style=flat-square&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/PHP-Backend-777BB4?style=flat-square&logo=php&logoColor=white" />
  <img src="https://img.shields.io/badge/MySQL-Database-4479A1?style=flat-square&logo=mysql&logoColor=white" />
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?style=flat-square&logo=android&logoColor=white" />
</p>

</div>

---

# 📖 Overview

This project is a **full-stack Android mobile application** that allows users to securely manage their personal contacts and place phone calls directly from the application.

The frontend is developed with **Flutter**, while the backend is powered by **PHP** and **MySQL**, communicating through a REST API using JSON.

The application also supports **dual-SIM devices**, allowing users to choose which SIM card to use when making a call.

---

# 📱 Application Preview

<p align="center">
  <img src="https://github.com/mamouneabdelli/contact_mobile_application/blob/e0aed9481e09b0620b1903da06f3e670ddda5f0a/Capture%20d%E2%80%99%C3%A9cran%20(145).png" width="30%">
  <img src="https://github.com/mamouneabdelli/contact_mobile_application/blob/e0aed9481e09b0620b1903da06f3e670ddda5f0a/Capture%20d%E2%80%99%C3%A9cran%20(147).png" width="30%">
  <img src="https://github.com/mamouneabdelli/contact_mobile_application/blob/e0aed9481e09b0620b1903da06f3e670ddda5f0a/Capture%20d%E2%80%99%C3%A9cran%20(150).png" width="30%">
</p>

---

# 📸 Screenshots

## 🔐 Authentication

<p align="center">
  <img src="https://github.com/mamouneabdelli/contact_mobile_application/blob/e0aed9481e09b0620b1903da06f3e670ddda5f0a/Capture%20d%E2%80%99%C3%A9cran%20(143).png" width="48%" alt="Login Screen">
  <img src="https://github.com/mamouneabdelli/contact_mobile_application/blob/e0aed9481e09b0620b1903da06f3e670ddda5f0a/Capture%20d%E2%80%99%C3%A9cran%20(144).png" width="48%" alt="Authentication Screen">
</p>

---

## 📇 Contact Management

<p align="center">
  <img src="https://github.com/mamouneabdelli/contact_mobile_application/blob/e0aed9481e09b0620b1903da06f3e670ddda5f0a/Capture%20d%E2%80%99%C3%A9cran%20(145).png" width="48%" alt="Contacts List">
  <img src="https://github.com/mamouneabdelli/contact_mobile_application/blob/e0aed9481e09b0620b1903da06f3e670ddda5f0a/Capture%20d%E2%80%99%C3%A9cran%20(146).png" width="48%" alt="Contact Details">
</p>

<p align="center">
  <img src="https://github.com/mamouneabdelli/contact_mobile_application/blob/e0aed9481e09b0620b1903da06f3e670ddda5f0a/Capture%20d%E2%80%99%C3%A9cran%20(147).png" width="48%" alt="Create Contact">
  <img src="https://github.com/mamouneabdelli/contact_mobile_application/blob/e0aed9481e09b0620b1903da06f3e670ddda5f0a/Capture%20d%E2%80%99%C3%A9cran%20(148).png" width="48%" alt="Edit Contact">
</p>

---

## 📞 Calling

<p align="center">
  <img src="https://github.com/mamouneabdelli/contact_mobile_application/blob/e0aed9481e09b0620b1903da06f3e670ddda5f0a/Capture%20d%E2%80%99%C3%A9cran%20(149).png" width="48%" alt="Call Screen">
  <img src="https://github.com/mamouneabdelli/contact_mobile_application/blob/e0aed9481e09b0620b1903da06f3e670ddda5f0a/Capture%20d%E2%80%99%C3%A9cran%20(150).png" width="48%" alt="SIM Selection">
</p>

---

# 🛠️ Tech Stack

| Layer | Technology |
| :--- | :--- |
| 📱 Mobile Frontend | Flutter (Dart) |
| ⚙️ Backend API | PHP |
| 🗄️ Database | MySQL |
| 🖥️ Database Management | phpMyAdmin |
| 🌐 Local Server | XAMPP |

---

# ✨ Features

## 🔐 Authentication

- Secure login
- Backend authentication
- Session management

## 📇 Contact Management

- Create contacts
- Edit contacts
- Delete contacts
- Search contacts
- View contact details

## 📞 Calling

- Make calls directly from the app
- Dual-SIM support
- Native phone dialer integration

---

# 🏗️ Architecture

```text
            HTTP / JSON Requests

   Flutter Mobile Application
              │
              ▼
         PHP REST API
              │
              ▼
        MySQL Database

        JSON Responses ▲
```

The Flutter application communicates with the PHP REST API through HTTP requests. The backend performs CRUD operations on the MySQL database and returns JSON responses to the mobile client.

---

# 🚀 Getting Started

## Prerequisites

- Flutter SDK
- Android Studio or VS Code
- XAMPP (Apache + MySQL)
- phpMyAdmin

---

## 1️⃣ Clone the Repository

```bash
git clone https://github.com/mamouneabdelli/contact_mobile_application.git

cd contact_mobile_application
```

---

## 2️⃣ Backend Setup

1. Start **Apache** and **MySQL** from XAMPP.

2. Import the provided SQL database into phpMyAdmin.

3. Configure the database connection:

```php
// config.php

$host = "localhost";
$db   = "contacts_db";
$user = "root";
$pass = "";
```

---

## 3️⃣ Flutter Setup

Install the project dependencies:

```bash
flutter pub get
```

Update the API base URL inside the Flutter project.

Example:

```text
http://192.168.x.x/contact_api/
```

Run the application:

```bash
flutter run
```

---

# 📂 Project Structure

```text
contact_mobile_application/

├── android/
├── ios/
├── lib/
│   ├── screens/
│   ├── widgets/
│   ├── models/
│   └── services/
│
├── php_api/
│   ├── config.php
│   ├── login.php
│   ├── contacts.php
│   └── database.sql
│
├── assets/
└── README.md
```

---

# 🗺️ Roadmap

- [ ] User registration
- [ ] Contact profile pictures
- [ ] Fingerprint authentication
- [ ] Face ID authentication
- [ ] Cloud-hosted backend
- [ ] Contact synchronization
- [ ] Dark mode
- [ ] Material 3 redesign

---

# 👨‍💻 Author

<div align="center">

### Abdelli Abdelmoumen

GitHub: **https://github.com/mamouneabdelli**

Built with ❤️ using **Flutter**, **PHP**, and **MySQL**.

</div>
