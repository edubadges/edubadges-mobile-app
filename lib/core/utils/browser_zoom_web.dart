import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Lets the browser zoom the page again (WCAG 1.4.4): Ctrl + scroll wheel and
/// trackpad pinch on desktop, two-finger pinch on phones and tablets.
/// Keyboard zoom (Ctrl/Cmd +, - and 0) already works.
///
/// The Flutter engine blocks the rest:
/// - It turns a wheel event with Ctrl held into a scale gesture for the app
///   and cancels the browser default, which is zooming. The app has no
///   pinch-to-zoom of its own, so this listener stops those events in the
///   capture phase, before they reach the engine, and leaves them to the
///   browser.
/// - It sets the viewport to `maximum-scale=1.0, user-scalable=no` and gives
///   the page, and every scrollable area in its semantics tree, `touch-action:
///   none`, so no touch gesture reaches the browser. The viewport now allows
///   500%, as Flutter's own does from 3.50. At normal size `touch-action:
///   pinch-zoom` hands two-finger gestures to the browser while one finger
///   still goes to Flutter, which scrolls the app. Zoomed in, one finger moves
///   the enlarged page around instead (iOS Safari does not pan with two
///   fingers), so lists scroll again once zoomed back out.
/// - iOS zooms in on any text field under 16px that gets focus once zooming
///   is allowed. Flutter's own text fields are hidden elements, 13px by
///   default.
void allowBrowserZoom() {
  web.window.addEventListener(
    'wheel',
    ((web.WheelEvent event) {
      if (event.ctrlKey) {
        event.stopImmediatePropagation();
      }
    }).toJS,
    web.AddEventListenerOptions(capture: true, passive: true),
  );

  // The engine has written its viewport before main() runs.
  web.document
      .querySelector('meta[name="viewport"]')
      ?.setAttribute(
        'content',
        'width=device-width, initial-scale=1.0, maximum-scale=5.0',
      );

  // The semantics tree is built later, so its elements are styled by rule.
  // Tappable ones receive the touches, inside scrollables set to none.
  final web.HTMLStyleElement style =
      web.document.createElement('style') as web.HTMLStyleElement;
  web.document.head?.append(style);

  final web.VisualViewport? visualViewport = web.window.visualViewport;
  void updateTouchAction() {
    final bool zoomedIn = (visualViewport?.scale ?? 1) > 1.01;
    final String touchAction = zoomedIn
        ? 'pan-x pan-y pinch-zoom'
        : 'pinch-zoom';
    web.document.body?.style.setProperty('touch-action', touchAction);
    style.textContent =
        'flt-semantics { touch-action: $touchAction !important; }\n'
        '@supports (-webkit-touch-callout: none) {\n'
        '  flutter-view input, flutter-view textarea {\n'
        '    font-size: 16px !important;\n'
        '  }\n'
        '}\n';
  }

  updateTouchAction();
  visualViewport?.addEventListener(
    'resize',
    ((web.Event _) => updateTouchAction()).toJS,
  );
}
