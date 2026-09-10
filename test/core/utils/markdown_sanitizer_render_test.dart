import 'package:edubadges/core/utils/markdown_sanitizer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;

/// Renders sanitized markdown through the same parser `flutter_markdown_plus`
/// uses, so we assert on what the widget tree is actually built from rather
/// than on the sanitizer's own output.
String render(String markdown) => md.markdownToHtml(
  sanitizeMarkdown(markdown),
  extensionSet: md.ExtensionSet.gitHubFlavored,
  encodeHtml: false,
);

void main() {
  const payloads = <String>[
    '<script>alert(document.cookie)</script>',
    '<script src="//evil.tld/x.js"></script>',
    '<img src=x onerror=alert(1)>',
    '<svg onload="alert(1)"></svg>',
    '<iframe srcdoc="<script>alert(1)</script>"></iframe>',
    '<body onload=alert(1)>',
    '<a href="javascript:alert(1)">click me</a>',
    '[click me](javascript:alert(1))',
    '[click me](JaVaScRiPt:alert(1))',
    '[click me](java\tscript:alert(1))',
    '[click me](<java\tscript:alert(1)>)',
    '[click me]( javascript:alert(1) )',
    '![x](javascript:alert(1))',
    '<javascript:alert(1)>',
    '[click me][ref]\n\n[ref]: javascript:alert(1)',
    '<style>body{background:url(javascript:alert(1))}</style>',
    '<meta http-equiv="refresh" content="0;url=javascript:alert(1)">',
  ];

  test('no payload survives into an executable position', () {
    for (final payload in payloads) {
      final html = render(payload);
      expect(html, isNot(contains('<script')), reason: payload);
      expect(html, isNot(contains('<iframe')), reason: payload);
      expect(html, isNot(contains('<style')), reason: payload);
      expect(html, isNot(contains('<meta')), reason: payload);
      expect(html.toLowerCase(), isNot(contains('onerror')), reason: payload);
      expect(html.toLowerCase(), isNot(contains('onload')), reason: payload);
      expect(html.toLowerCase(), isNot(contains('srcdoc')), reason: payload);
      // No `javascript:` may remain anywhere a tap or fetch could reach it.
      expect(html.toLowerCase(), isNot(contains('javascript')), reason: payload);
      expect(html.toLowerCase(), isNot(contains('java%09script')), reason: payload);
    }
  });

  test('legitimate content still renders as expected', () {
    expect(
      render('# Title\n\nSee [terms](https://edubadges.nl/terms).'),
      contains('<a href="https://edubadges.nl/terms">terms</a>'),
    );
    expect(render('# Title'), contains('<h1>Title</h1>'));
    expect(
      render('![logo](https://edubadges.nl/l.png)'),
      contains('src="https://edubadges.nl/l.png"'),
    );
  });
}
