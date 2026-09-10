import 'package:edubadges/core/utils/logger.dart';
import 'package:url_launcher/url_launcher.dart';

/// Schemes we are willing to render as a tappable link or hand to the
/// platform. Everything else (`javascript:`, `data:`, `vbscript:`, `file:`,
/// arbitrary app deep links) is treated as hostile.
const Set<String> kSafeUrlSchemes = <String>{
  'http',
  'https',
  'mailto',
  'tel',
  'sms',
};

/// Characters a browser strips before it resolves a scheme, and which are
/// therefore used to smuggle one past a naive `startsWith` check
/// (`java<tab>script:`, `<newline>javascript:`, ...).
final RegExp _ignorableSchemeChars = RegExp(
  r'[\u0000-\u0020\u00a0\u200b-\u200d\u2028\u2029\ufeff]',
);

/// A scheme may only contain these characters. Anything else means the colon
/// belongs to a path or query, not to a scheme.
final RegExp _schemeChars = RegExp(r'^[a-z][a-z0-9+.\-]*$');

/// The scheme of [url] as a browser would resolve it, or `null` when [url]
/// carries no scheme at all (a relative, root-relative or fragment target).
String? urlScheme(String url) {
  final String trimmed = url.trim();
  final int colon = trimmed.indexOf(':');
  if (colon <= 0) {
    return null;
  }

  // A `/`, `?` or `#` before the colon means the colon is part of the path,
  // e.g. `./notes/12:30.md`.
  for (final String terminator in const <String>['/', '?', '#']) {
    final int index = trimmed.indexOf(terminator);
    if (index >= 0 && index < colon) {
      return null;
    }
  }

  final String scheme = trimmed
      .substring(0, colon)
      .replaceAll(_ignorableSchemeChars, '')
      .toLowerCase();

  // Not a syntactically valid scheme (`%6aavascript:`, `foo bar:`), so a
  // browser reads the whole thing as a relative reference.
  return _schemeChars.hasMatch(scheme) ? scheme : null;
}

/// Whether [url] is safe to present to the user as a link.
///
/// Scheme-less targets pass: they resolve against our own origin and cannot
/// execute. A target that does carry a scheme must use one of
/// [kSafeUrlSchemes].
bool isSafeLinkUrl(String url) {
  if (url.trim().isEmpty) {
    return false;
  }
  final String? scheme = urlScheme(url);
  return scheme == null || kSafeUrlSchemes.contains(scheme);
}

/// Whether [url] can be handed to the platform to open.
///
/// Stricter than [isSafeLinkUrl]: an external launch needs an explicit,
/// allow-listed scheme, so scheme-less targets are rejected here.
bool isLaunchableUrl(String url) {
  final String trimmed = url.trim();
  final String? scheme = urlScheme(trimmed);
  return scheme != null &&
      kSafeUrlSchemes.contains(scheme) &&
      Uri.tryParse(trimmed) != null;
}

/// Opens [url] externally, but only when it uses an allow-listed scheme.
///
/// Returns whether the launch was attempted. Use this instead of calling
/// `launchUrl`/`launchUrlString` directly with a URL that came from the API,
/// from markdown content, or from any other party outside the app.
Future<bool> launchExternalUrl(
  String url, {
  LaunchMode mode = LaunchMode.externalApplication,
}) async {
  if (!isLaunchableUrl(url)) {
    logger.w('Blocked launch of unsafe URL: $url');
    return false;
  }

  final Uri uri = Uri.parse(url.trim());
  try {
    // `mailto:`, `tel:` and `sms:` have no in-app equivalent; let the OS pick.
    final LaunchMode effectiveMode =
        uri.scheme == 'http' || uri.scheme == 'https'
        ? mode
        : LaunchMode.platformDefault;
    return await launchUrl(uri, mode: effectiveMode);
  } catch (e) {
    logger.e('Error launching URL: $e');
    return false;
  }
}
