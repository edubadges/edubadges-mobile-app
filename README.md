# 🎖️ SURF Edubadges

The Edubadges app: one Flutter codebase for iOS, Android and the web.

*   🍎 iOS
*   🤖 Android
*   🌐 Web

Deploying the web app on your own infrastructure? See
**[docs/hosting/README.md](docs/hosting/README.md)** — this file covers development.

## ⚙️ Getting started

**Requirements:** Flutter **3.41.3 or newer** (`pubspec.lock` will refuse anything
older). CI pins 3.41.3. No other tooling is needed: every dependency comes from
pub.dev, all generated code is committed, and there is no code-generation step
to run before building.

```bash
git clone https://gitlab.com/CoffeeIT/surf/surf-flutter
cd surf-flutter
flutter pub get
```

There are no keys to obtain. Configuration lives in the committed `.env.dev`,
`.env.tst`, `.env.acc` and `.env.prod` files, loaded at startup with
`flutter_dotenv`. They hold endpoint URLs, a public OpenID client id and an
analytics site id — all of it safe to publish, none of it secret. **Never add a
client secret, API key or token to those files:** they are bundled as assets and
are downloadable from any web deployment.

## ▶️ Running

### iOS and Android

Flavors are selected with `--flavor`:

```bash
flutter run --flavor dev
```

Replace `dev` with `tst`, `acc` or `prod`.

### Web

`--flavor` does not exist on web, so the flavor is passed as a compile-time
define instead. It is **required** — a web build with no flavor refuses to start
rather than silently defaulting to `dev`.

```bash
flutter run -d chrome --web-port=8080 --dart-define=APP_FLAVOR=dev
```

Use port **8080**. The SurfConext redirect URI is derived from the browser
origin, and `http://localhost:8080/` is the origin registered for local
development — another port will fail at login.

## 🏗️ Building for the web

Always build through the script. It is the same path CI and the container image
use, so a hand-built copy cannot end up with different flags:

```bash
./tool/build_web.sh acc
```

The output lands in `build/web`. The script:

*   passes `--dart-define=APP_FLAVOR` and compiles with `--wasm` (which also
    emits a JavaScript fallback for browsers that need one);
*   passes `--no-web-resources-cdn`, so the CanvasKit/skwasm renderer is served
    from your own origin instead of being fetched from `www.gstatic.com` on
    every page load;
*   deletes the other three flavors' `.env` files from the output, which would
    otherwise publish every environment's configuration;
*   writes a `robots.txt` that disallows crawling everywhere except production.

To run the result locally:

```bash
cd build/web && python3 -m http.server 8080
```

Or build and run the container, which is what actually gets deployed:

```bash
docker build --build-arg APP_FLAVOR=acc -t edubadges-web:acc .
docker run --rm -p 8080:8080 edubadges-web:acc
```

### One hard constraint

**The web app must be served at the root of its hostname.** The SurfConext
redirect URI is `Uri.base.origin` plus a trailing slash, which ignores
`<base href>`. Deploying under a sub-path such as `/app/` breaks login in a way
that is not obvious from the symptoms.

### What web does not do

Push notifications and crash reporting are mobile-only — Firebase is not
initialised on web and Crashlytics has no browser SDK, so `ENABLE_CRASHLYTICS`
has no effect there. Analytics does run on web, cookielessly, when
`ENABLE_ANALYTICS` is set.

## 🛠️ Tech stack

*   **Framework:** Flutter & Dart
*   **Routing:** `go_router`
*   **HTTP client:** `dio` with `fresh_dio` for token refresh
*   **State:** `flutter_riverpod`
*   **Build flavors:** `flutter_flavorizr` (mobile), `--dart-define` (web)
*   **Environment variables:** `flutter_dotenv`
*   **Login:** SurfConext OpenID Connect — `flutter_appauth` on mobile, a
    PKCE flow built on `package:web` on the web
*   **Localization:** `flutter_localizations`
*   **Vector graphics:** `flutter_svg`

## 📁 Repository layout

| Path | What it is |
|---|---|
| `lib/` | Application code |
| `web/` | Web shell: `index.html`, splash, icons, manifest |
| `deploy/` | nginx template and Compose file for hosting |
| `tool/` | Build and config-rendering scripts |
| `docs/hosting/` | Hosting guide for operators |
| `docs/open-source.md` | Mirroring and open-source release notes |
| `Dockerfile` | Builds the deployable web image |
