import 'package:edubadges/core/utils/markdown_sanitizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sanitizeMarkdown leaves legitimate content alone', () {
    test('keeps headings, emphasis, lists and tables', () {
      const markdown = '''
# Algemene voorwaarden

Deze **voorwaarden** zijn van _toepassing_ op alle badges.

- Eerste punt
- Tweede punt

| Rol | Recht |
|-----|-------|
| Student | Lezen |
''';
      expect(sanitizeMarkdown(markdown), markdown);
    });

    test('keeps safe links, images and autolinks', () {
      const markdown = 'See [the terms](https://edubadges.nl/terms "Terms"), '
          '![logo](https://edubadges.nl/logo.png), '
          '<https://edubadges.nl>, [mail](mailto:a@b.nl) and [rel](/terms).';
      expect(sanitizeMarkdown(markdown), markdown);
    });

    test('keeps harmless inline HTML', () {
      const markdown = 'Line one<br>Line two and <b>bold</b>.';
      expect(sanitizeMarkdown(markdown), markdown);
    });

    test('leaves fenced code blocks untouched', () {
      const markdown = '''
Example:

```html
<script>alert(1)</script>
<a href="javascript:alert(1)">x</a>
```

Done.
''';
      expect(sanitizeMarkdown(markdown), markdown);
    });

    test('leaves inline code spans untouched', () {
      const markdown = 'Never write `<script>alert(1)</script>` in a badge.';
      expect(sanitizeMarkdown(markdown), markdown);
    });

    test('still strips empty blockquote markers', () {
      expect(sanitizeMarkdown('a\n>\nb'), 'a\n\nb');
    });

    test('is a no-op on empty input', () {
      expect(sanitizeMarkdown(''), '');
    });
  });

  group('sanitizeMarkdown removes executable markup', () {
    test('drops a script element and its body', () {
      final result = sanitizeMarkdown(
        'Hello <script>alert(document.cookie)</script> world',
      );
      expect(result, 'Hello  world');
      expect(result, isNot(contains('alert')));
    });

    test('drops a script element spanning multiple lines', () {
      final result = sanitizeMarkdown('Intro\n<script>\nalert(1)\n</script>\nOutro');
      expect(result, isNot(contains('alert')));
      expect(result, contains('Intro'));
      expect(result, contains('Outro'));
    });

    test('drops an unclosed script tag', () {
      expect(sanitizeMarkdown('<script src="//evil.tld/x.js">'), '');
    });

    test('drops iframe, object, svg, style, meta and base', () {
      for (final markup in <String>[
        '<iframe src="//evil.tld"></iframe>',
        '<object data="//evil.tld/x.swf"></object>',
        '<svg onload="alert(1)"></svg>',
        '<style>body{display:none}</style>',
        '<meta http-equiv="refresh" content="0;url=//evil.tld">',
        '<base href="//evil.tld/">',
      ]) {
        expect(sanitizeMarkdown(markup), '', reason: markup);
      }
    });

    test('strips event handler attributes but keeps the element', () {
      expect(
        sanitizeMarkdown('<img src="https://edubadges.nl/a.png" onerror="alert(1)">'),
        '<img src="https://edubadges.nl/a.png">',
      );
      expect(
        sanitizeMarkdown('<div onmouseover="alert(1)" class="x">hi</div>'),
        '<div class="x">hi</div>',
      );
    });

    test('strips srcdoc and style attributes', () {
      expect(
        sanitizeMarkdown('<iframe srcdoc="<script>alert(1)</script>"></iframe>'),
        '',
      );
      expect(sanitizeMarkdown('<p style="position:fixed">x</p>'), '<p>x</p>');
    });

    test('strips a URL attribute pointing at an unsafe scheme', () {
      expect(
        sanitizeMarkdown('<a href="javascript:alert(1)">click</a>'),
        '<a>click</a>',
      );
      expect(
        sanitizeMarkdown('<a href="https://edubadges.nl">click</a>'),
        '<a href="https://edubadges.nl">click</a>',
      );
    });
  });

  group('sanitizeMarkdown removes unsafe link targets', () {
    test('unwraps a link with an executable scheme, keeping its words', () {
      expect(
        sanitizeMarkdown('Please [accept the terms](javascript:steal()) now'),
        'Please accept the terms now',
      );
    });

    test('handles obfuscated schemes', () {
      for (final destination in <String>[
        'JavaScript:alert(1)',
        'java\tscript:alert(1)',
        ' javascript:alert(1)',
        'vbscript:msgbox(1)',
        'data:text/html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg==',
      ]) {
        expect(
          sanitizeMarkdown('[label]($destination)'),
          'label',
          reason: destination,
        );
      }
    });

    test('drops an image with an unsafe source entirely', () {
      expect(sanitizeMarkdown('![alt](javascript:alert(1))'), '');
    });

    test('drops a pointy-bracket destination with an unsafe scheme', () {
      expect(sanitizeMarkdown('[label](<javascript:alert(1)>)'), 'label');
    });

    test('drops a reference-style link definition with an unsafe scheme', () {
      final result = sanitizeMarkdown('Read [the terms][t].\n\n[t]: javascript:alert(1)');
      expect(result, isNot(contains('javascript')));
      expect(result, contains('the terms'));
    });

    test('keeps a reference-style definition with a safe scheme', () {
      const markdown = 'Read [the terms][t].\n\n[t]: https://edubadges.nl/terms';
      expect(sanitizeMarkdown(markdown), markdown);
    });

    test('drops an autolink with an unsafe scheme', () {
      expect(sanitizeMarkdown('Click <javascript:alert(1)> here'), 'Click  here');
    });
  });
}
