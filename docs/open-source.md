# Open-source release and mirroring

Notes for maintainers on how this repository is published, and what has to be
true before it is.

## Repository topology

**GitLab is the source of truth.** `gitlab.com/CoffeeIT/surf/surf-flutter` holds
development, CI/CD and the container registry, and stays a private project. A
**push mirror** publishes the code to a public GitHub repository, which is where
the open-source release lives.

```
GitLab (private)                    GitHub (public)
  development + merge requests  ──▶   read-only mirror
  CI/CD pipelines
  container registry  ──▶ deploy token ──▶ SURF pulls images
```

That split is intentional: the *code* is public, while the pipeline and the
release artifacts stay under our control. It does mean the mirror is where most
people will read the code, so `README.md` and `CONTRIBUTING.md` need to point
issues back to GitLab.

### Setting up the mirror

In the GitLab project: **Settings → Repository → Mirroring repositories**.

* Direction: **Push**
* URL: `https://<github-user>@github.com/<org>/<repo>.git`
* Password: a GitHub personal access token with `repo` scope
* Enable *Keep divergent refs* off, so the mirror always matches

Mirror only the branches you want public. Note that mirroring pushes **all**
history — see the pre-publication checklist below before enabling it.

## Before the mirror goes public

- [x] **Licence.** `LICENSE` is Apache-2.0, copyright SURF.
- [x] **Restrict the Firebase Android and iOS API keys.** The `AIza…` values in
      `lib/firebase/firebase_options_*.dart`, the four `google-services.json`
      and the four `GoogleService-Info.plist` are client identifiers rather than
      secrets, and Google publishes them in every Firebase mobile app. But
      unrestricted, anyone can use the production key to burn quota against
      `edubadges-prod`. In each of the four projects:

      * **Application restrictions.** Android keys → package
        `nl.surf.edubadges` plus the signing-certificate SHA-1; iOS keys →
        bundle ID `nl.surf.edubadges`. All four flavors share one
        `applicationId`, so the package name is the same in every project and
        only the certificate differs by channel (Play app-signing cert for
        prod, upload keystore for the App Distribution builds).
      * **API allowlist** — only the four APIs this app actually uses:
        `firebaseinstallations.googleapis.com`, `fcmregistrations.googleapis.com`,
        `firebase.googleapis.com` and `logging.googleapis.com`. The app pulls in
        only `firebase_core`, `firebase_crashlytics` and `firebase_messaging`,
        so Auth, Firestore, Storage and Remote Config are deliberately absent.
        Never add the Generative Language API to a publicly readable key.
      * **Firebase App Check** (Play Integrity / App Attest). Key restrictions
        are a first layer only — Android application restrictions are not
        enforced uniformly across APIs, so App Check is the real mitigation.

      There is no *browser* key to restrict. Firebase is not initialised on web
      (`main.dart` guards it behind `!kIsWeb`) and the generated options throw
      `UnsupportedError` for web, so the compiled bundle contains no `AIza…`
      value at all — confirmed by grepping `build/web` after a release build.
- [x] **Confirm ownership of `lib/core/network/`.** That code was written to
      replace CoffeeIT's proprietary `aroma_error` and `aroma_networking`
      packages. Confirm it is not derived from them before publishing it under
      an open licence.
- [x] **Review CoffeeIT-internal references.** `sonar-project.properties` names
      an internal SonarQube host; `bitrise.yaml` describes the internal mobile
      pipeline; `developer_configuration.json` is internal scaffolding metadata.
      None of it is secret, but decide whether it should be public.
- [x] **Check `.vscode/launch.json`** (committed) for local paths.
- [x] **Security contact.** `SECURITY.md` points at support@edubadges.nl. If
      SURF would rather route these through their own coordinated vulnerability
      disclosure process, update that file.

## What has already been checked

* **No credentials in the history.** No keystores, service-account JSON,
  `key.properties`, `.p12`/`.p8`/`.pem` files or provisioning profiles have ever
  been committed, across the full history. CI credentials are environment-
  variable references only.
* **No private dependencies.** Every package resolves from pub.dev; the two
  private Aroma git dependencies were removed and replaced with in-repo code.
  A clean clone builds with no access to CoffeeIT infrastructure.
* **The `.env.*` files hold no secrets.** Endpoint URLs, a public PKCE client id
  and an analytics site id. They carry a warning header saying so.
