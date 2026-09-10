/// Sanitizes markdown that reaches the app from outside it — organizer-authored
/// badge descriptions, criteria, quality assurance text and the general terms
/// fetched from a URL the API hands us.
///
/// Note on the threat model: `flutter_markdown_plus` compiles markdown to
/// Flutter widgets (`RichText`/`TextSpan`), never to DOM, so raw HTML in the
/// source is painted as literal text and cannot execute — not even on web.
/// This sanitizer is therefore defense in depth rather than a patch for a live
/// script-execution hole. It buys two concrete things:
///
///  1. Injected markup stays inert if the render path ever changes — a
///     `WebView`, an `HtmlElementView`, `flutter_html`, or a future version of
///     the markdown package that grows raw-HTML support.
///  2. It closes the vector that *is* live on every platform today: link and
///     image destinations carrying an executable scheme, which end up in
///     `onTapLink` and then at the platform's URL handler.
///
/// Content inside fenced code blocks and inline code spans is left untouched.
/// The markdown renderer already treats those as literal text, and mangling
/// them would corrupt legitimate documentation.
library;

import 'package:edubadges/core/utils/url_safety.dart';

/// Elements dropped together with their content: they either execute, load
/// remote code, or restyle the page.
const Set<String> _dangerousElements = <String>{
  'applet',
  'base',
  'embed',
  'frame',
  'frameset',
  'iframe',
  'link',
  'math',
  'meta',
  'noscript',
  'object',
  'portal',
  'script',
  'style',
  'svg',
  'template',
};

/// Attributes that name a URL, and whose value we therefore have to check.
const Set<String> _urlAttributes = <String>{
  'action',
  'background',
  'cite',
  'data',
  'formaction',
  'href',
  'poster',
  'src',
  'xlink:href',
};

/// Attributes stripped unconditionally: they carry code or markup rather than
/// a value we could validate.
const Set<String> _forbiddenAttributes = <String>{
  'srcdoc',
  'style',
};

final RegExp _dangerousElementWithContent = RegExp(
  '<(${_dangerousElements.join('|')})\\b[^>]*>[\\s\\S]*?</\\s*\\1\\s*>',
  caseSensitive: false,
);

final RegExp _dangerousTag = RegExp(
  '</?\\s*(?:${_dangerousElements.join('|')})\\b[^>]*>',
  caseSensitive: false,
);

/// An opening or self-closing HTML tag. Closing tags carry no attributes, so
/// they need no scrubbing. The attribute run must start with whitespace or a
/// slash, which is what keeps an autolink such as `<https://edubadges.nl>` from
/// being mistaken for a tag named `https`.
final RegExp _openingTag = RegExp(
  r'<([a-zA-Z][a-zA-Z0-9-]*)(\s(?:[^>"]|"[^"]*")*|\s*/)?>',
);

final RegExp _attribute = RegExp(
  '([a-zA-Z_:][-a-zA-Z0-9_:.]*)'
  '(?:\\s*=\\s*("[^"]*"|\'[^\']*\'|[^\\s"\'>`]+))?',
);

/// `[label](destination "title")` and its image form. Also accepts the
/// pointy-bracket destination that CommonMark allows.
final RegExp _inlineLink = RegExp(
  r'(!?)\[((?:[^\[\]\\]|\\.)*)\]\('
  // The `markdown` package is looser than CommonMark here: it accepts one
  // level of balanced parentheses (`javascript:alert(1)`) and even embedded
  // whitespace (`java<tab>script:`), which it later percent-encodes. Match
  // what it actually accepts, or the obfuscated form slips past untouched.
  r'\s*(?:<([^<>\n]*)>|((?:[^()\n]|\([^()\n]*\))*))'
  r'(?:\s+(?:"[^"]*"|' "'[^']*'" r'|\([^()]*\)))?\s*\)',
);

/// `[id]: destination "title"` on its own line.
final RegExp _linkDefinition = RegExp(
  r'^[ ]{0,3}\[((?:[^\[\]\\]|\\.)+)\]:[ \t]*(\S+)[^\n]*$',
  multiLine: true,
);

/// `<https://example.com>` — CommonMark's autolink.
final RegExp _autolink = RegExp(r'<([a-zA-Z][a-zA-Z0-9+.\-]*:[^<>\s]*)>');

/// Inline code spans. A greedier-than-strict match is deliberate: over-matching
/// only means we skip sanitizing text that the renderer will show verbatim
/// anyway, so it errs safe.
final RegExp _inlineCode = RegExp(r'(`+)[\s\S]*?\1');

final RegExp _openingFence = RegExp(r'^ {0,3}(`{3,}|~{3,})');
final RegExp _closingFence = RegExp(r'^ {0,3}(`{3,}|~{3,})[ \t]*$');

/// Removes lines that are an empty blockquote marker.
///
/// Purely cosmetic: the CMS emits stray `>` lines that the renderer turns into
/// empty quote blocks. Kept separate from the security scrubbing so the two
/// concerns stay legible.
String filterBadMarkdown(String md) {
  return md.replaceAll(RegExp(r'^>\s*$', multiLine: true), '');
}

/// Strips executable markup and unsafe link targets from untrusted [markdown],
/// and removes the cosmetic artifacts [filterBadMarkdown] handles.
///
/// This is the only function that should feed `MarkdownBody.data` for content
/// the app did not author itself.
String sanitizeMarkdown(String markdown) {
  if (markdown.isEmpty) {
    return markdown;
  }
  return filterBadMarkdown(_sanitizeOutsideCodeBlocks(markdown));
}

/// Splits [markdown] on fenced code blocks and scrubs only the prose between
/// them, so a fence containing `<script>` as an example survives intact.
String _sanitizeOutsideCodeBlocks(String markdown) {
  final List<String> output = <String>[];
  // Consecutive prose lines are buffered so multi-line constructs — an element
  // whose closing tag sits on a later line — are seen as a whole.
  final List<String> prose = <String>[];
  String? openFence;

  void flushProse() {
    if (prose.isEmpty) {
      return;
    }
    output.addAll(_sanitizeProse(prose.join('\n')).split('\n'));
    prose.clear();
  }

  for (final String line in markdown.split('\n')) {
    if (openFence != null) {
      final RegExpMatch? closing = _closingFence.firstMatch(line);
      if (closing != null &&
          closing.group(1)![0] == openFence[0] &&
          closing.group(1)!.length >= openFence.length) {
        openFence = null;
      }
      output.add(line);
      continue;
    }

    final RegExpMatch? opening = _openingFence.firstMatch(line);
    if (opening != null) {
      flushProse();
      openFence = opening.group(1);
      output.add(line);
      continue;
    }

    prose.add(line);
  }

  flushProse();
  return output.join('\n');
}

/// Scrubs one run of prose, leaving inline code spans untouched.
String _sanitizeProse(String text) {
  final StringBuffer buffer = StringBuffer();
  int index = 0;
  for (final RegExpMatch match in _inlineCode.allMatches(text)) {
    buffer.write(_sanitizeMarkup(text.substring(index, match.start)));
    buffer.write(match.group(0));
    index = match.end;
  }
  buffer.write(_sanitizeMarkup(text.substring(index)));
  return buffer.toString();
}

String _sanitizeMarkup(String text) {
  String result = text;

  // Executable elements go entirely, content included, so a dropped `<script>`
  // does not leave its body behind as visible text.
  result = result.replaceAll(_dangerousElementWithContent, '');

  // Then any leftover dangerous tag: unclosed, self-closing, or a stray
  // closing tag whose partner was already removed.
  result = result.replaceAll(_dangerousTag, '');

  // Surviving tags keep their element but lose event handlers, code-bearing
  // attributes, and URL attributes pointing at an unsafe scheme.
  result = result.replaceAllMapped(_openingTag, _scrubTag);

  // Link and image destinations — the vector that is live today.
  result = result.replaceAllMapped(_inlineLink, _scrubInlineLink);
  result = result.replaceAllMapped(
    _linkDefinition,
    (Match match) => isSafeLinkUrl(match.group(2)!) ? match.group(0)! : '',
  );
  result = result.replaceAllMapped(
    _autolink,
    (Match match) => isSafeLinkUrl(match.group(1)!) ? match.group(0)! : '',
  );

  return result;
}

String _scrubTag(Match match) {
  final String tag = match.group(1)!;
  final String rawAttributes = match.group(2) ?? '';
  final bool selfClosing = rawAttributes.trimRight().endsWith('/');

  final List<String> kept = <String>[];
  for (final RegExpMatch attribute in _attribute.allMatches(rawAttributes)) {
    final String name = attribute.group(1)!.toLowerCase();
    final String? rawValue = attribute.group(2);

    if (name.startsWith('on') ||
        _forbiddenAttributes.contains(name) ||
        name.startsWith('xmlns')) {
      continue;
    }
    if (_urlAttributes.contains(name) &&
        !isSafeLinkUrl(_unquote(rawValue ?? ''))) {
      continue;
    }
    kept.add(rawValue == null ? name : '$name=$rawValue');
  }

  final String attributes = kept.isEmpty ? '' : ' ${kept.join(' ')}';
  return '<$tag$attributes${selfClosing ? ' /' : ''}>';
}

/// Rewrites a markdown link or image whose destination is unsafe into plain
/// text, keeping the visible label so the sentence still reads.
String _scrubInlineLink(Match match) {
  final String bang = match.group(1)!;
  final String label = match.group(2)!;
  final String destination = match.group(3) ?? match.group(4) ?? '';

  if (destination.isEmpty || isSafeLinkUrl(destination)) {
    return match.group(0)!;
  }
  // An image loses its rendering entirely; a link keeps its words.
  return bang.isEmpty ? label : '';
}

String _unquote(String value) {
  if (value.length >= 2 &&
      ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'")))) {
    return value.substring(1, value.length - 1);
  }
  return value;
}
