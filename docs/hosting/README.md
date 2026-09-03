# Edubadges web app — hosting guide

This describes how to run the Edubadges web app on your own servers: what it is,
what you need to provide, and how releases reach your environments.

It replaces the earlier guide written for AWS. Nothing here assumes a cloud
provider.

---

## 1. What you are hosting

A **static website** — HTML, JavaScript, WebAssembly, CSS and assets. It has:

* no application server of its own
* no database
* no secrets in the build
* no background workers
* nothing written to disk at runtime

Your infrastructure only has to serve those files over HTTPS. After that the
user's browser talks directly to:

```
User's browser
  ├── HTTPS  →  your host (the web app)
  ├── API    →  api.edubadges.nl  or  api-demo.edubadges.nl
  └── Login  →  SurfConext
```

## 2. Environments

| Hostname | Flavor | API | SurfConext |
|---|---|---|---|
| `backpack.edubadges.nl` | `prod` | `https://api.edubadges.nl` | `https://connect.surfconext.nl` |
| `backpack-acc.edubadges.nl` | `acc` | `https://api-demo.edubadges.nl` | `https://connect.test.surfconext.nl` |
| `backpack-test.edubadges.nl` | `tst` | `https://api-demo.edubadges.nl` | `https://connect.test.surfconext.nl` |
| `backpack-demo.edubadges.nl` | `dev` | `https://api-demo.edubadges.nl` | `https://connect.test.surfconext.nl` |

Each environment is a separate build; the flavor is compiled in, not configured
at runtime.

> **Worth deciding before you build all four.** `dev`, `tst` and `acc` point at
> the same backend and the same SurfConext test issuer. On web they differ only
> in whether analytics is sent (`acc` yes, `dev`/`tst` no). If you want a
> genuinely separate acceptance environment, `acc` needs its own backend — tell
> us and we will point it there.

**The app must be served at the root of each hostname.** The SurfConext redirect
URI is derived from the browser's origin, so hosting it under a path such as
`/app/` breaks login. Use a hostname dedicated to this app: login tokens are
stored in the browser against that origin.

## 3. Getting a release

Three options. They produce the same files — pick whichever fits how you already
deploy.

### Option A — pull the container image (recommended)

A small image: nginx plus the compiled app, listening on **8080** as a non-root
user. TLS terminates on your proxy, not inside the container.

```bash
docker login registry.gitlab.com          # read-only deploy token, supplied separately
docker pull registry.gitlab.com/coffeeit/surf/surf-flutter/web:acc-1.0.1-a1b2c3d
docker run -d --restart unless-stopped -p 127.0.0.1:8080:8080 \
  registry.gitlab.com/coffeeit/surf/surf-flutter/web:acc-1.0.1-a1b2c3d
```

Tags are `<flavor>-<version>-<commit>`, plus a moving `<flavor>-latest`. **Pin
the full tag in production** so a restart cannot quietly change which build runs.

There is a ready-made Compose file at [`deploy/docker-compose.yml`](../../deploy/docker-compose.yml).

The deploy token is read-only and scoped to the container registry of this one
project. It has an expiry date — please diarise it, because deployment stops
working the day it lapses.

### Option B — unpack the tarball onto your existing nginx

Every release also publishes `edubadges-web-<flavor>-<version>-<commit>.tar.gz`
as a pipeline artifact. It contains:

```
web/          the files to serve
nginx.conf    a matching server block, already filled in for that flavor
```

Unpack `web/` into your document root and use `nginx.conf` as the server block.
No container runtime needed.

### Option C — build it yourself from source

The repository is open source and builds with no private dependencies, no
credentials and no code-generation step — a clean clone plus Flutter 3.41.3 or
newer is enough. If you already build your website on the server, this fits the
same pattern:

```bash
git clone <repository>
cd surf-flutter
flutter pub get
./tool/build_web.sh acc                       # output in build/web
./tool/render_nginx_conf.sh acc > default.conf
```

Always build through `tool/build_web.sh` rather than calling `flutter build web`
directly. It applies flags that matter (see §7) and removes the other
environments' configuration from the output.

## 4. What the supplied nginx config already does

Whether you use the image or the tarball, the config that ships with it:

* serves the site on port 8080
* falls unknown paths back to `index.html`, which in-app routes require
* sets short cache headers — Flutter's filenames are not content-hashed, so
  nothing may be cached immutably — and marks `index.html`,
  `flutter_bootstrap.js` and `version.json` `no-cache`
* serves `.wasm` and `.mjs` with the correct content types (a wrong type on the
  wasm module silently disables streaming compilation)
* exposes `GET /health` returning 200, for your load balancer
* sets `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`,
  `Permissions-Policy`, HSTS and a Content-Security-Policy naming your API,
  SurfConext and analytics hosts
* serves a `robots.txt` that disallows crawling on every non-production host
* runs as a non-root user and does not advertise the nginx version

If you serve the files some other way, those rules still apply.

Every item above was verified on 3 September 2026 against a local run of the
`acc` build under this exact configuration: routing and deep links, `/health`,
`.wasm` and `.mjs` content types, cache headers, the rendered CSP, `robots.txt`,
and the pruning of the other flavors' `.env` files. The app booted, made no
third-party requests, and reached the eduID login screen.

**What you still need to provide:** TLS with a valid certificate, an HTTP→HTTPS
redirect, and the `/health` check wired into your load balancer.

## 5. What we need from you

* **DNS and TLS.** Checked 3 September 2026 — further along than it looks:
  * `backpack-acc`, `backpack-test` and `backpack-demo` all resolve, and a
    GEANT-issued certificate valid until **14 March 2027 already covers all
    three** (it is the `test.edubadges.nl` certificate; they are listed as
    SANs). No new certificate is needed for these three.
  * `backpack-demo` already answers on 443 — but with a placeholder, not this
    app. Every path returns the same 773-byte document, `/health` and
    `/flutter_bootstrap.js` included. That vhost needs repointing at the app.
  * `backpack-acc` and `backpack-test` resolve but refuse connections on 443;
    nothing is listening there yet.
  * `backpack.edubadges.nl` (production) **does not exist** — no DNS record,
    and it is not on that certificate. This is the only hostname that needs
    both DNS and a certificate.
* **SurfConext registration** — see §6. This is historically the item that
  blocks go-live, so please start it first.
* **API CORS** — see §6.
* Whether you will run the container or unpack the tarball.
* Who may approve a production deploy, and who is contacted if an environment
  is down.

## 6. SurfConext and API CORS

### SurfConext

Login uses the authorization-code flow with PKCE, in the browser. We are reusing
the existing mobile clients rather than registering new ones, so these settings
need to be **added** to them:

| Client | Environments |
|---|---|
| `edubadges.mobile` | production |
| `edubadges.mobile.test` | acceptance, test, demo |

| Setting | Value |
|---|---|
| Grant type | `authorization_code` |
| PKCE | Required, method `S256` |
| Redirect URI | `https://<hostname>/` — **exactly**, including the trailing slash |
| Scopes | `openid`, `eduid.nl/links`, `offline_access` |
| Token-endpoint CORS | Allow origin `https://<hostname>` |

Add one redirect URI per hostname, so `edubadges.mobile.test` ends up with
`backpack-acc`, `backpack-test` and `backpack-demo`.

`http://localhost:8080/` is **already registered** on `edubadges.mobile.test`, so
development logins work today — a local build completes the flow as far as the
eduID login screen. None of the three backpack hostnames is registered yet, so
those are what remain.

While you have that client open, one piece of housekeeping:
`https://dev.edubadges.preprod.aws.coffeeit.nl/` is still a registered redirect
URI on it. It points at the AWS deployment this setup replaces, and a registered
redirect URI on infrastructure that is being decommissioned is worth removing.

The redirect URI is read from the address bar. A different value will not work
without a code change. `offline_access` is required for users to stay signed in.
Token-endpoint CORS is required because the code-for-token exchange happens in
the browser; without it, login returns to the site and then fails.

> Because the refresh token is held in browser storage, a shorter refresh-token
> lifetime for these clients is worth considering.

### API CORS

The Edubadges API must allow each app origin:

```
Access-Control-Allow-Origin:  https://<hostname>
Access-Control-Allow-Headers: Authorization, Content-Type
Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS
```

`Access-Control-Allow-Credentials` is not required — the app sends a bearer
token. The web app does not send `x-platform`, `x-app-version` or `x-language`,
but it does send `x-requested-with`.

## 7. Notes on the build

Two flags in `tool/build_web.sh` are worth knowing about, because they change
what your infrastructure has to allow:

* **`--no-web-resources-cdn`.** Without it, Flutter fetches its CanvasKit
  renderer from `www.gstatic.com` on every page load. With it, the renderer is
  served from your own host — which is what makes a strict CSP possible, works
  on egress-restricted networks, and keeps visitor traffic off a Google CDN.
* **`--wasm`.** The app is compiled to WebAssembly, with a JavaScript fallback
  emitted automatically for browsers that need one.

## 8. Rollback

Re-run the previous image tag, or re-unpack the previous tarball. There is no
database and no migration, so rollback is just serving the older files again.
Please rehearse it once before go-live.

## 9. What the web app does not do

* **No push notifications and no crash reporting.** Firebase is not initialised
  on web and Crashlytics has no browser SDK.
* **Analytics is cookieless.** Page views are reported to Piwik PRO with
  anonymous tracking and no cookies, and URLs are normalised so badge and
  collection ids are never sent. Disabled entirely on `dev` and `tst`.
* **Account linking prompts are not yet reachable on web.** A user who needs to
  link an eduID account or revalidate their name cannot complete that flow in
  the browser today. Known issue, fix pending.

## 10. Security notes

* The image contains no secrets.
* Refresh tokens are stored in the browser against the app's origin. Use a
  hostname dedicated to this app and keep refresh-token lifetime short.
* A Content-Security-Policy is set by the supplied config. If you replace it,
  keep `'wasm-unsafe-eval'` in `script-src` — WebAssembly will not start without
  it — and avoid adding `'unsafe-inline'` to `script-src`.
* **No third-party requests at runtime.** The renderer and all fonts the app
  uses are served from your own host. One consequence is visible: the Flutter
  engine attempts to fetch fallback fonts from `fonts.gstatic.com` at startup
  and the CSP blocks it, which logs an error in the browser console. This is
  expected and the app renders correctly — the fonts it actually uses are
  bundled. The only effect is that a badge title written in a script those
  fonts do not cover may show placeholder glyphs. If you would rather allow the
  Google CDN, add `https://fonts.gstatic.com` to `connect-src` and `font-src`
  in the CSP; see the comment in `deploy/nginx.conf.template`.
* The container runs as a non-root user, is safe to run read-only, and needs no
  extra capabilities.

## 11. Checklist

**Your side**

- [ ] `backpack.edubadges.nl` created in DNS
- [ ] TLS certificate covering `backpack.edubadges.nl` (the other three
      hostnames are already covered — see §5)
- [ ] HTTP redirects to HTTPS
- [ ] Reverse proxy forwards to the app on port 8080
- [ ] `backpack-demo` repointed from its placeholder page to the app
- [ ] `/health` wired into the load balancer
- [ ] SurfConext redirect URIs and token-endpoint CORS added to both clients
- [ ] API CORS live for all four origins
- [ ] Deploy token stored, and its expiry date diarised
- [ ] Decided who approves a production deploy
- [ ] Decided who is contacted if an environment is down

**Before go-live, per environment**

- [ ] `https://<hostname>/` loads
- [ ] A deep link such as `https://<hostname>/collections` returns 200 on a hard
      reload, not 404
- [ ] `https://<hostname>/health` returns 200 **with the body `ok`** — check the
      body, not just the status. The placeholder currently on `backpack-demo`
      returns 200 for every path, so a status-only check passes with no app
      deployed at all
- [ ] A full login completes
- [ ] A page that loads data works after login
- [ ] Rollback has been rehearsed once
