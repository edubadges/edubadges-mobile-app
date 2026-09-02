# Contributing

Thanks for your interest in Edubadges.

## Where development happens

Development happens on GitLab; the GitHub repository is a **read-only mirror**
kept in sync automatically. Pull requests opened against the GitHub mirror
cannot be merged there.

* **Issues and merge requests:** the GitLab project
* **GitHub:** mirror only, for reading and forking

If you cannot access the GitLab project, open an issue on GitHub describing the
change and we will pick it up.

## Getting set up

See the [README](README.md). Short version: Flutter 3.41.3 or newer,
`flutter pub get`, and you can build. There are no credentials to obtain, no
private dependencies and no code-generation step.

## Before you submit

```bash
flutter analyze     # must be clean
flutter test        # must pass
```

Both run in CI on every merge request, alongside a SonarQube quality gate.

## Conventions

* Match the style of the code around you. `analysis_options.yaml` is the
  authority; `flutter analyze` enforces it.
* Commit messages follow the pattern already in the history —
  `feat(web): ...`, `fix: ...`, or a ticket reference such as `SURF-623`.
* Keep generated files committed. `*.g.dart` files are checked in on purpose, so
  a clean clone builds without running `build_runner`.

## Configuration and secrets

The `.env.*` files are committed deliberately: they hold endpoint URLs, a public
OpenID client id and an analytics site id, none of which is secret.

**Never add a client secret, API key or token to them.** They are bundled as
Flutter assets, which means they are downloadable from any web deployment. If
something genuinely needs to be secret, it does not belong in a client
application at all — raise it as an issue instead.

## Platform notes

This is one codebase for iOS, Android and web. When adding a plugin, check
whether it has a web implementation:

* If it does not, put the platform split behind a conditional import, using
  `dart.library.js_interop` as the condition. **Not `dart.library.html`** —
  `dart:html` does not exist under dart2wasm, so a `--wasm` build would silently
  select the wrong implementation. `lib/shared/data/datasources/oidc_auth_datasource.dart`
  and `lib/core/analytics/piwik_pro_tracker.dart` are the patterns to copy.
* `kIsWeb` is fine for behavioural differences that do not need a separate
  implementation file.

Web builds must go through `tool/build_web.sh`, which applies flags that a bare
`flutter build web` does not.
