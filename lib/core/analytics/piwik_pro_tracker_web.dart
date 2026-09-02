import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

/// Piwik PRO tracking backed by the JavaScript tracking client.
///
/// `flutter_piwikpro` is Android/iOS only, so on web we load Piwik PRO's
/// `ppms.js` and drive it through the standard `_paq` command queue. The queue
/// buffers commands until the script has loaded, so calls made during startup
/// are not lost.
///
/// Two deliberate choices:
///
///  * **Cookieless.** `disableCookies` is pushed before anything else, so no
///    identifier is written to the browser. This mirrors the native SDK's
///    anonymisation state and is what keeps a consent banner out of scope.
///  * **No real URLs.** Page views are reported with an explicit custom URL
///    built from the normalised screen name, never `document.location`. Real
///    URLs contain badge and collection ids (`/details/:id`), which must not
///    reach the analytics backend.
///
/// The tracker is injected as an external script rather than an inline one, so
/// the Content-Security-Policy needs `https://surfnl.piwik.pro` in `script-src`
/// and `connect-src` but does not need `unsafe-inline`.
class PiwikProTracker {
  const PiwikProTracker();

  static const String _queueName = '_paq';

  Future<void> initialize({
    required String baseUrl,
    required String siteId,
  }) async {
    final String base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    _push(<String>['disableCookies']);
    _push(<String>['setTrackerUrl', '$base/ppms.php']);
    _push(<String>['setSiteId', siteId]);

    final web.HTMLScriptElement script =
        web.document.createElement('script') as web.HTMLScriptElement;
    script.async = true;
    script.src = '$base/ppms.js';
    web.document.head?.appendChild(script);
  }

  Future<void> trackScreen(String screenName) async {
    _push(<String>['setCustomUrl', _customUrlFor(screenName)]);
    _push(<String>['setDocumentTitle', screenName]);
    _push(<String>['trackPageView']);
  }

  /// Builds a stable, id-free URL from the observer's normalised screen name.
  String _customUrlFor(String screenName) {
    final String origin = web.window.location.origin;
    if (screenName.isEmpty || screenName == 'home') {
      return '$origin/';
    }
    return '$origin/$screenName';
  }

  void _push(List<String> command) {
    _queue.callMethod<JSAny?>(
      'push'.toJS,
      command.map((String part) => part.toJS).toList().toJS,
    );
  }

  /// The `window._paq` command queue, created on first use.
  JSArray<JSAny?> get _queue {
    final JSObject window = web.window as JSObject;
    final JSArray<JSAny?>? existing = window.getProperty<JSArray<JSAny?>?>(
      _queueName.toJS,
    );
    if (existing != null) {
      return existing;
    }
    final JSArray<JSAny?> created = JSArray<JSAny?>();
    window.setProperty(_queueName.toJS, created);
    return created;
  }
}
