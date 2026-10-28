import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Lets Ctrl + scroll wheel and trackpad pinch zoom the page again (WCAG 1.4.4).
///
/// The Flutter engine turns a wheel event with Ctrl held into a scale gesture
/// for the app and cancels the browser default, which is zooming. The app has
/// no pinch-to-zoom of its own, so this listener stops those events in the
/// capture phase, before they reach the engine, and leaves them to the
/// browser. Keyboard zoom (Ctrl/Cmd +, - and 0) already works.
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
}
