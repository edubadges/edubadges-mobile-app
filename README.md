# 🎖️ SURF Edubadges

## 📱 Target Platforms
This application is built to run on the following platforms:
*   🍎 iOS
*   🤖 Android

## ⚙️ Installation
1.  **Clone the repository:**
    ```bash
    git clone https://gitlab.com/CoffeeIT/surf/surf-flutter
    cd surf-flutter
    ```
2.  **Set up Environment Variables:**
    *   This project uses `flutter_dotenv` for configuration.
    *   You might need to obtain the necessary keys.
3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

## ▶️ Running the Project

1.  Ensure you have a device (physical or emulator) running.
2.  **Run the app (default flavor, usually dev):**
    ```bash
    flutter run
    ```
3.  **Run a specific flavor:**
    This project uses `flutter_flavorizr` to manage build environments (dev, tst, prod, acc).
    ```bash
    # Example for running the 'dev' flavor
    flutter run --flavor dev

    # Replace 'dev' with 'tst', 'prod', or 'acc' as needed
    flutter run --flavor <flavor_name>
    ```

## 🛠️ Tech Stack
*   **Framework:** Flutter & Dart
*   **Routing:** `go_router`
*   **HTTP Client:** `dio`
*   **Build Flavors:** `flutter_flavorizr`
*   **Environment Variables:** `flutter_dotenv`
*   **Localization:** `flutter_localizations`
*   **Vector Graphics:** `flutter_svg`
