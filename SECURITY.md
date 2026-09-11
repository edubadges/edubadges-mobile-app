# Security policy

## Reporting a vulnerability

Please report security issues privately to **support@edubadges.nl**, with
"security" in the subject line. Do not open a public issue for a vulnerability.

Include what you found, how to reproduce it, and which environment you saw it on
(`backpack.edubadges.nl` for production; the `-acc`, `-test` and `-demo` hosts
are non-production). We will confirm receipt and keep you updated while we
investigate.

Please give us reasonable time to fix an issue before disclosing it publicly.

## Scope

This repository is the Edubadges client application for iOS, Android and web.
Issues in the Edubadges API or in SurfConext are handled by their own teams,
though reporting them here is fine and we will route them.

## What is not a vulnerability

Some things in this repository look like exposed secrets but are not:

* **The `.env.dev`, `.env.tst`, `.env.acc` and `.env.prod` files are committed
  on purpose.** They contain endpoint URLs, a public OpenID Connect client id
  and an analytics site id. The OpenID client is a public PKCE client and has no
  secret by design. These files are also bundled as app assets and downloadable
  from the web build, which is expected.
* **The Firebase `AIza…` API keys** in `lib/firebase/firebase_options_*.dart`,
  `google-services.json` and `GoogleService-Info.plist` are client identifiers,
  not credentials. Google ships them in every Firebase web app. Access is
  controlled by Firebase security rules and API key restrictions.
* **The SHA-256 fingerprints in `.well-known/assetlinks.json`** are public by
  design — Android app links require them to be served publicly.

Reports that a genuine secret has leaked are very welcome. Reports that one of
the above is "hardcoded" generally are not, unless you have found a way to abuse
it that we have missed.

## Supported versions

Only the current release is supported. Fixes go to the latest version rather
than being backported.
