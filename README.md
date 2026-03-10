# 🪴 Growbit - Your Local-First Habit Tracker

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
[![Riverpod](https://img.shields.io/badge/Riverpod-State%20Management-blue?style=for-the-badge)](https://riverpod.dev/)
[![Hive](https://img.shields.io/badge/Hive-Local%20Database-yellow?style=for-the-badge)](https://pub.dev/packages/hive)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=for-the-badge)]()

**Growbit** is a beautifully crafted, privacy-centric habit tracker built with Flutter. Designed with a "Modern Journal" aesthetic, it helps users build routines, track streaks, and maintain focus—all without requiring an internet connection or cloud account. **Your data belongs to you.**

---

## ✨ Key Features

* **🔒 Absolute Privacy & Security**
    * 100% Local-First architecture. No cloud servers, no tracking.
    * **App Lock:** Secure your journal with a custom PIN Code or native **Biometrics** (FaceID/Fingerprint).
* **📊 Dynamic Progress Dashboard**
    * Beautiful, interactive charts and streak counters.
    * Intelligent habit leaderboards to visualize your best-performing days.
* **⏳ Integrated Focus Timer**
    * Built-in Pomodoro-style timer with preset and custom durations.
    * Haptic feedback (vibrations) alerts you when deep work sessions end.
* **🗃️ Data Ownership (Backup & Restore)**
    * Generate a `.csv` backup of all your habits, streaks, and settings directly to your device's Downloads folder.
    * Seamlessly restore your entire profile from a `.csv` file upon app reinstall.
* **🎨 Premium UI & Theming**
    * Flawless Dark & Light mode integration.
    * **Drag-and-Drop Reordering:** Curate your day by dragging habits into your preferred sequence.
* **🔔 Reliable Local Notifications**
    * Daily customized reminders powered by native Android/iOS background execution.

---

## 🏗️ App Architecture

Growbit is built using **Clean Architecture** principles to ensure the codebase remains scalable, testable, and highly maintainable. 



The app is divided into three distinct layers:
1.  **Presentation Layer:** Handles UI and state management using **Riverpod**. State is kept highly reactive, ensuring the UI perfectly reflects the database without manual rebuilds.
2.  **Domain Layer:** Contains the core business logic, entities (`HabitEntity`), and Use Cases (e.g., `AddHabitUseCase`, `DeleteHabitUseCase`).
3.  **Data Layer:** Manages local storage using **Hive** (a blazing-fast NoSQL database) and implements the repositories.

### 🛠️ Tech Stack
* **Framework:** Flutter (Dart)
* **State Management:** Riverpod (`flutter_riverpod`)
* **Local Database:** Hive (`hive_flutter`)
* **Security:** `local_auth`, `flutter_secure_storage`
* **Notifications:** `flutter_local_notifications`
* **File Management:** `file_saver`, `file_picker`, `csv`

<!-- ---

## 📸 Screenshots
*(Add your app screenshots here by replacing the placeholder links)*

| Home Dashboard | Focus Timer | Progress Insights | App Lock & Privacy |
| :---: | :---: | :---: | :---: |
| <img src="assets/screenshots/home.png" width="200"/> | <img src="assets/screenshots/timer.png" width="200"/> | <img src="assets/screenshots/progress.png" width="200"/> | <img src="assets/screenshots/lock.png" width="200"/> |

--- -->

## 🚀 Getting Started

Follow these steps to run Growbit on your local machine.

### Prerequisites
* Flutter SDK (v3.22.0 or higher)
* Dart SDK
* Android Studio / VS Code

### Installation

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/yourusername/growbit.git](https://github.com/yourusername/growbit.git)
   cd growbit