import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Draws a visible ring around whichever widget has keyboard focus.
///
/// Material marks focus only with a translucent fill, which is too faint on
/// the white cards and purple buttons of this app for WCAG 2.4.7 (Focus
/// visible) and 1.4.11 (Non-text contrast). This paints a 2px ring in the
/// primary colour with a 2px light gap around the focused widget instead, on
/// top of the whole app, so every control, dialog and route gets the same
/// indicator without each widget drawing its own.
///
/// The ring follows the shape of an [InkResponse] or [FocusRingShape] that
/// wraps exactly the focused widget. It stays inside the scroll views the
/// widget sits in, so it never floats over an app bar, and moves inwards
/// where the widget runs past them so it is always fully visible.
///
/// Like the browser's `:focus-visible`, the ring only shows after a key press
/// and hides again on the next pointer press, so a mouse or touch user does
/// not see it after a click. Text fields are skipped: they draw their own
/// focused border.
class FocusRingOverlay extends StatefulWidget {
  final Widget child;

  const FocusRingOverlay({super.key, required this.child});

  /// Width of the ring, and of the light gap between it and the widget.
  static const double ringWidth = 2;

  @override
  State<FocusRingOverlay> createState() => _FocusRingOverlayState();
}

/// Declares the shape [FocusRingOverlay] draws its ring in, for a focusable
/// widget that is not an [InkResponse], such as a [FocusableActionDetector]
/// around a rounded card.
///
/// Only applies when [child] takes up exactly the area of the focused widget.
class FocusRingShape extends StatelessWidget {
  final ShapeBorder shape;
  final Widget child;

  const FocusRingShape({super.key, required this.shape, required this.child});

  FocusRingShape.rounded({
    super.key,
    required BorderRadius borderRadius,
    required this.child,
  }) : shape = RoundedRectangleBorder(borderRadius: borderRadius);

  @override
  Widget build(BuildContext context) => child;
}

class _FocusRingOverlayState extends State<FocusRingOverlay> {
  /// Ancestors searched for an [InkResponse] or [FocusRingShape]; an
  /// [InkWell] sits five elements above the [Focus] it builds.
  static const int _shapeSearchDepth = 12;

  static const ShapeBorder _defaultShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(4)),
  );

  static final Set<LogicalKeyboardKey> _modifierKeys = <LogicalKeyboardKey>{
    LogicalKeyboardKey.shiftLeft,
    LogicalKeyboardKey.shiftRight,
    LogicalKeyboardKey.controlLeft,
    LogicalKeyboardKey.controlRight,
    LogicalKeyboardKey.altLeft,
    LogicalKeyboardKey.altRight,
    LogicalKeyboardKey.metaLeft,
    LogicalKeyboardKey.metaRight,
    LogicalKeyboardKey.capsLock,
    LogicalKeyboardKey.fn,
  };

  final GlobalKey _paintKey = GlobalKey();

  bool _keyboardInUse = false;
  bool _measureScheduled = false;
  _FocusRing? _ring;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_scheduleMeasure);
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    GestureBinding.instance.pointerRouter.addGlobalRoute(_handlePointerEvent);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_scheduleMeasure);
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    GestureBinding.instance.pointerRouter.removeGlobalRoute(
      _handlePointerEvent,
    );
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent && !_modifierKeys.contains(event.logicalKey)) {
      _keyboardInUse = true;
      _scheduleMeasure();
    }
    // Only observing: the key still goes to the focused widget.
    return false;
  }

  void _handlePointerEvent(PointerEvent event) {
    if (event is PointerDownEvent && _keyboardInUse) {
      _keyboardInUse = false;
      _scheduleMeasure();
    }
  }

  /// Measures after the next frame, once the focused widget has its final
  /// layout. While a ring shows, it measures again after every frame, so the
  /// ring follows scrolling and layout changes.
  void _scheduleMeasure() {
    if (_measureScheduled || !mounted) return;
    _measureScheduled = true;
    SchedulerBinding.instance
      ..addPostFrameCallback(_measure)
      ..ensureVisualUpdate();
  }

  void _measure(Duration _) {
    _measureScheduled = false;
    if (!mounted) return;
    final _FocusRing? ring = _keyboardInUse ? _measureFocusedWidget() : null;
    if (ring != _ring) {
      setState(() => _ring = ring);
    }
    // Keeps checking while the keyboard is in use, also when the focused
    // widget is scrolled out of view and may scroll back in. This only runs
    // after frames that happen anyway; it never asks for one.
    if (_keyboardInUse) {
      _measureScheduled = true;
      SchedulerBinding.instance.addPostFrameCallback(_measure);
    }
  }

  _FocusRing? _measureFocusedWidget() {
    final FocusNode? node = FocusManager.instance.primaryFocus;
    final BuildContext? target = node?.context;
    final RenderObject? overlay = _paintKey.currentContext?.findRenderObject();
    if (node == null ||
        target == null ||
        node is FocusScopeNode ||
        node.skipTraversal ||
        overlay is! RenderBox ||
        !overlay.hasSize) {
      return null;
    }
    if (target.findAncestorWidgetOfExactType<EditableText>() != null) {
      return null;
    }
    final Rect? rect = _rectIn(overlay, target.findRenderObject());
    if (rect == null) return null;

    // The part of the screen the widget can show in: inside every scroll view
    // around it, so the ring never covers an app bar or a navigation bar.
    Rect clip = Offset.zero & overlay.size;
    ScrollableState? scrollable = target
        .findAncestorStateOfType<ScrollableState>();
    while (scrollable != null) {
      final Rect? viewport = _rectIn(
        overlay,
        scrollable.context.findRenderObject(),
      );
      if (viewport != null) {
        clip = clip.intersect(viewport);
      }
      scrollable = scrollable.context
          .findAncestorStateOfType<ScrollableState>();
    }

    // Where the widget runs past that area, such as a section taller than the
    // screen or a card against the screen edge, the ring moves inwards so all
    // four sides stay visible.
    final Rect ringRect = rect.intersect(
      clip.deflate(FocusRingOverlay.ringWidth * 2),
    );
    if (ringRect.width <= 0 || ringRect.height <= 0) return null;

    return _FocusRing(
      rect: ringRect,
      clip: clip,
      shape: _shapeOf(target, overlay, rect),
    );
  }

  Rect? _rectIn(RenderBox overlay, RenderObject? object) {
    if (object is! RenderBox || !object.attached || !object.hasSize) {
      return null;
    }
    return MatrixUtils.transformRect(
      object.getTransformTo(overlay),
      Offset.zero & object.size,
    );
  }

  static bool _sameRect(Rect a, Rect b) =>
      (a.topLeft - b.topLeft).distance < 0.5 &&
      (a.bottomRight - b.bottomRight).distance < 0.5;

  ShapeBorder _shapeOf(BuildContext target, RenderBox overlay, Rect rect) {
    ShapeBorder shape = _defaultShape;
    int depth = 0;
    target.visitAncestorElements((Element element) {
      final Widget widget = element.widget;
      final ShapeBorder? declared = switch (widget) {
        FocusRingShape(:final ShapeBorder shape) => shape,
        InkResponse(:final ShapeBorder customBorder) => customBorder,
        InkResponse(:final BorderRadius borderRadius) => RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
        InkResponse(highlightShape: BoxShape.circle) => const CircleBorder(),
        InkResponse() => _defaultShape,
        _ => null,
      };
      if (declared == null) {
        return ++depth < _shapeSearchDepth;
      }
      // An ink response further out belongs to a larger widget, such as the
      // row a checkbox sits in; only one around exactly this widget counts.
      final Rect? declaredRect = _rectIn(overlay, element.findRenderObject());
      if (declaredRect != null && _sameRect(declaredRect, rect)) {
        shape = declared;
      }
      return false;
    });
    return shape;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                key: _paintKey,
                painter: _FocusRingPainter(
                  ring: _ring,
                  ringColor: colorScheme.primary,
                  gapColor: colorScheme.surfaceContainer,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

@immutable
class _FocusRing {
  final Rect rect;
  final Rect clip;
  final ShapeBorder shape;

  const _FocusRing({
    required this.rect,
    required this.clip,
    required this.shape,
  });

  /// The outline of the focused widget grown by [outset], keeping rounded
  /// corners concentric.
  Path outline(double outset) {
    final ShapeBorder shape = this.shape;
    if (shape is RoundedRectangleBorder) {
      final RRect rrect = shape.borderRadius
          .resolve(TextDirection.ltr)
          .toRRect(rect);
      return Path()..addRRect(rrect.inflate(outset));
    }
    return shape.getOuterPath(rect.inflate(outset));
  }

  @override
  bool operator ==(Object other) =>
      other is _FocusRing &&
      other.rect == rect &&
      other.clip == clip &&
      other.shape == shape;

  @override
  int get hashCode => Object.hash(rect, clip, shape);
}

class _FocusRingPainter extends CustomPainter {
  final _FocusRing? ring;
  final Color ringColor;
  final Color gapColor;

  const _FocusRingPainter({
    required this.ring,
    required this.ringColor,
    required this.gapColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final _FocusRing? ring = this.ring;
    if (ring == null) return;
    const double width = FocusRingOverlay.ringWidth;
    final Paint stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    canvas
      ..save()
      ..clipRect(ring.clip)
      // The light gap keeps the ring readable against a purple widget or
      // background, where a purple ring alone would disappear.
      ..drawPath(ring.outline(width / 2), stroke..color = gapColor)
      ..drawPath(ring.outline(width * 1.5), stroke..color = ringColor)
      ..restore();
  }

  @override
  bool shouldRepaint(_FocusRingPainter oldDelegate) =>
      oldDelegate.ring != ring ||
      oldDelegate.ringColor != ringColor ||
      oldDelegate.gapColor != gapColor;
}
