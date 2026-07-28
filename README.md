# 🎖️ SURF Edubadges

## 📱 Target Platforms
This application is built to run on the following platforms:
*   🍎 iOS
*   🤖 Android
*   🌐 Web

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

4.  **Run on web:**
    Flavors use `--dart-define` instead of `--flavor` on web:
    ```bash
    flutter run -d chrome --dart-define=APP_FLAVOR=dev
    ```

    **Local dev for web** (
    ```bash
   flutter run -d chrome --web-port=8080 --dart-define=APP_FLAVOR=dev
    ```
  

5.  **Build for web:**
    ```bash
    flutter build web \
      --release \
      --dart-define=APP_FLAVOR=tst \
      --wasm
    ```
    Use `--source-maps` for staging builds when debugging. Omit it for production.

    Deploy the `build/web` output to static hosting with SPA path fallback (see `firebase.json` and `web/nginx.conf`).

## 🛠️ Tech Stack
*   **Framework:** Flutter & Dart
*   **Routing:** `go_router`
*   **HTTP Client:** `dio`
*   **Build Flavors:** `flutter_flavorizr`
*   **Environment Variables:** `flutter_dotenv`
*   **Localization:** `flutter_localizations`
*   **Vector Graphics:** `flutter_svg`


star