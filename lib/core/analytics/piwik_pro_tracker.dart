/// Selects the Piwik PRO implementation for the current platform.
///
/// Mobile uses the `flutter_piwikpro` plugin. That plugin is Android/iOS only,
/// so web uses Piwik PRO's JavaScript tracking client instead.
///
/// The condition is `dart.library.js_interop` rather than `dart.library.html`
/// because `dart:html` does not exist under dart2wasm, which would silently
/// select the native implementation in a `--wasm` build. See
/// `lib/shared/data/datasources/oidc_auth_datasource.dart` for the same pattern.
library;

export 'piwik_pro_tracker_native.dart'
    if (dart.library.js_interop) 'piwik_pro_tracker_web.dart';
