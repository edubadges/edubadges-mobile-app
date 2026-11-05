/// Levels for [Semantics.headingLevel], so the headings in the code have the
/// hierarchy the page shows (WCAG 1.3.1). A heading without a level is an h2
/// on the web, which makes the page title a sibling of its own sections.
///
/// Dialog titles keep the default: a dialog is not part of the page outline.
class HeadingLevel {
  HeadingLevel._();

  /// The page title, once per page.
  static const int page = 1;

  /// A section of the page, such as a card under the page title.
  static const int section = 2;

  /// A group within a section.
  static const int subsection = 3;
}
