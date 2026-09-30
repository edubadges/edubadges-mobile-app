// Splash-screen bootstrap.
//
// Kept in its own file rather than inline in index.html so the
// Content-Security-Policy can use `script-src 'self'` without `unsafe-inline`.
// That matters here: the SurfConext refresh token lives in localStorage, so an
// injected inline script would be able to read it.

(function () {
  // Same choice as the app makes (AppLanguageNotifier): the language picked on
  // the account page, else the first of Dutch or English the browser prefers,
  // else English.
  var supported = ['nl', 'en'];
  var language = null;
  try {
    // Stored by shared_preferences, which JSON-encodes values.
    var stored = JSON.parse(window.localStorage.getItem('flutter.app_language'));
    if (supported.indexOf(stored) !== -1) {
      language = stored;
    }
  } catch (error) {
    // Storage blocked or unreadable: fall back to the browser languages.
  }
  if (!language) {
    var languages = navigator.languages || [navigator.language || 'en'];
    for (var i = 0; i < languages.length && !language; i++) {
      var code = (languages[i] || '').toLowerCase().split(/[-_]/)[0];
      if (supported.indexOf(code) !== -1) {
        language = code;
      }
    }
  }
  var isDutch = language === 'nl';
  document.documentElement.lang = isDutch ? 'nl' : 'en';
  var element = document.getElementById('loading-splash-text');
  if (element) {
    element.textContent = isDutch ? 'Edubadges laden…' : 'Loading Edubadges…';
  }
})();

window.addEventListener('flutter-first-frame', function () {
  var splash = document.getElementById('loading-splash');
  if (splash) {
    splash.remove();
  }
});
