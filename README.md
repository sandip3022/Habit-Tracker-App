# 🪴 GroBit - Your Local-First Habit Tracker

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
[![Riverpod](https://img.shields.io/badge/Riverpod-State%20Management-blue?style=for-the-badge)](https://riverpod.dev/)
[![Hive](https://img.shields.io/badge/Hive-Local%20Database-yellow?style=for-the-badge)](https://pub.dev/packages/hive)
[![Platform](https://img.shields.io/badge/Platform-Android-lightgrey?style=for-the-badge)]()

**GroBit** is a beautifully crafted, privacy-centric habit tracker built from the ground up with Flutter. Designed with a "Modern Journal" aesthetic, it helps users build routines, track streaks, and execute deep work—all without requiring an internet connection or cloud account. **Your data belongs to you.**

---

## ✨ Key Features

* **🔒 Absolute Privacy & Security**
    * 100% Local-First architecture. No cloud servers, no telemetry, no tracking.
    * **App Vault:** Secure your journal with an encrypted 4-digit PIN Code and automatic session timeouts.
* **🌍 Native Localization**
    * Fully translated and optimized for both **English**, **Hindi** and **Marathi**.
    * Instant, runtime language hot-swapping without requiring an app restart.
* **🎯 Custom Habit Engine**
    * Build the exact habits you want with a custom Material Icon registry, hex-color pickers, and flexible tracking frequencies. 
* **📊 Dynamic Progress Dashboard**
    * Beautiful, interactive charts and streak counters.
    * Intelligent habit leaderboards to visualize your best-performing days.
* **⏳ Built-In Execution Tools**
    * Integrated Stopwatch and Pomodoro-style Focus Timer.
    * Reliable local push notification reminders powered by native background execution.
* **🗃️ Data Ownership (High-Performance I/O)**
    * Generate `.csv` backups of all habits, streaks, and settings directly to your device.
    * **Zero-Jank Imports:** Heavy CSV parsing is offloaded to background **Isolates**, ensuring the UI never freezes even when restoring massive backup files.
* **🎨 Premium UI & Theming**
    * Flawless, system-aware Dark & Light mode integration.
    * Highly optimized asset and font rendering, resulting in a lightweight ~20MB release APK.

---

## 🏗️ App Architecture

GroBit is built using strict **Clean Architecture** principles to ensure the codebase remains scalable, testable, and highly maintainable. 

The app is divided into three distinct layers:
1.  **Presentation Layer:** Handles UI and state management using **Riverpod**. State is kept highly reactive, ensuring the UI perfectly reflects the database without manual rebuilds or prop drilling.
2.  **Domain Layer:** Contains the core business logic, entities (`HabitEntity`), and Use Cases (e.g., `AddHabitUseCase`, `ImportCSVUseCase`).
3.  **Data Layer:** Manages local storage using **Hive** (a blazing-fast NoSQL database) and implements the repositories. Highly sensitive data (like the PIN) is routed through a secure keystore.

### 🛠️ Tech Stack
* **Framework:** Flutter (Dart)
* **State Management:** Riverpod (`flutter_riverpod`)
* **Local Database:** Hive (`hive_flutter`)
* **Security:** `flutter_secure_storage`
* **Localization:** `easy_localization`
* **Notifications:** `flutter_local_notifications`
* **Data & Processing:** `csv`, Dart `Isolate` API, `file_saver`, `file_picker`

## 🚀 Getting Started

Follow these steps to run GroBit on your local machine.

### Prerequisites
* Flutter SDK (v3.22.0 or higher)
* Dart SDK
* Android Studio / VS Code

### Installation

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/sandip3022/Habit-Tracker-App.git](https://github.com/sandip3022/Habit-Tracker-App.git)