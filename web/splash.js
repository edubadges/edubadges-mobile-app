// Splash-screen bootstrap.
//
// Kept in its own file rather than inline in index.html so the
// Content-Security-Policy can use `script-src 'self'` without `unsafe-inline`.
// That matters here: the SurfConext refresh token lives in localStorage, so an
// injected inline script would be able to read it.

(function () {
  var languages = navigator.languages || [navigator.language || 'en'];
  var isDutch = languages.some(function (language) {
    return language && language.toLowerCase().startsWith('nl');
  });
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
