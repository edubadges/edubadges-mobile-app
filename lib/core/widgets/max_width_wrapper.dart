import 'package:edubadges/core/utils/platform_info.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MaxWidthWrapper extends StatefulWidget {
  static const double defaultMaxWidth = 720.0;

  final Widget child;
  final double maxWidth;
  final bool captureOutsideScrolling;
  final ScrollController? scrollController;

  /// When non-null, overrides [PlatformInfo.isWeb] for scrollbar rendering.
  final bool? enableWebScrollbar;

  const MaxWidthWrapper({
    super.key,
    required this.child,
    this.maxWidth = defaultMaxWidth,
    this.captureOutsideScrolling = true,
    this.scrollController,
    this.enableWebScrollbar,
  });

  @override
  State<MaxWidthWrapper> createState() => _MaxWidthWrapperState();
}

class _MaxWidthWrapperState extends State<MaxWidthWrapper> {
  ScrollController? _ownedScrollController;
  ScrollController? _discoveredScrollController;
  ScrollPosition? _activeScrollPosition;
  bool _isScrollbarReady = false;
  bool _didInitializeScrollState = false;

  static const Set<TargetPlatform> _scrollInheritPlatforms = <TargetPlatform>{
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.fuchsia,
    TargetPlatform.linux,
    TargetPlatform.macOS,
    TargetPlatform.windows,
  };

  bool get _useWebScrollbar =>
      widget.enableWebScrollbar ?? PlatformInfo.isWeb;

  @override
  void didUpdateWidget(covariant MaxWidthWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      _discoveredScrollController = null;
      _activeScrollPosition = null;
      _isScrollbarReady = false;
      _didInitializeScrollState = false;
    }
  }

  @override
  void dispose() {
    _ownedScrollController?.dispose();
    super.dispose();
  }

  ScrollController _resolveScrollController(BuildContext context) {
    if (widget.scrollController != null) {
      return widget.scrollController!;
    }
    if (_discoveredScrollController != null) {
      return _discoveredScrollController!;
    }
    final ScrollController? inheritedController =
        PrimaryScrollController.maybeOf(context);
    if (inheritedController != null) {
      return inheritedController;
    }
    return _ownedScrollController ??= ScrollController();
  }

  void _linkScrollPosition({
    ScrollPosition? position,
    ScrollController? controller,
  }) {
    final ScrollPosition? resolvedPosition =
        position ?? (controller?.hasClients == true ? controller!.position : null);
    if (resolvedPosition != null && resolvedPosition.hasContentDimensions) {
      _activeScrollPosition = resolvedPosition;
    }
    if (widget.scrollController == null && controller != null) {
      _discoveredScrollController = controller;
    }
    if (!_didInitializeScrollState &&
        _activeScrollPosition != null &&
        _activeScrollPosition!.hasContentDimensions) {
      _didInitializeScrollState = true;
      if (_useWebScrollbar) {
        _isScrollbarReady = true;
      }
      setState(() {});
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) {
      return false;
    }
    final BuildContext? notificationContext = notification.context;
    if (notificationContext == null) {
      return false;
    }
    final ScrollableState? scrollableState =
        notificationContext.findAncestorStateOfType<ScrollableState>();
    _linkScrollPosition(
      position: scrollableState?.position,
      controller: scrollableState?.widget.controller,
    );
    return false;
  }

  bool _handleScrollMetricsNotification(ScrollMetricsNotification notification) {
    final ScrollableState? scrollableState =
        notification.context.findAncestorStateOfType<ScrollableState>();
    _linkScrollPosition(
      position: scrollableState?.position,
      controller: scrollableState?.widget.controller ?? widget.scrollController,
    );
    return false;
  }

  ScrollController? _scrollbarController(ScrollController fallback) {
    if (widget.scrollController != null) {
      return widget.scrollController;
    }
    if (_discoveredScrollController != null) {
      return _discoveredScrollController;
    }
    if (fallback.hasClients) {
      return fallback;
    }
    return null;
  }

  bool _shouldShowWebScrollbar(ScrollController scrollController) {
    final ScrollController? controller = _scrollbarController(scrollController);
    return _useWebScrollbar &&
        _isScrollbarReady &&
        controller != null &&
        controller.hasClients;
  }

  static const double _scrollbarTrackWidth = 18;

  ScrollPosition? _resolveScrollPosition(ScrollController scrollController) {
    final ScrollPosition? cached = _activeScrollPosition;
    if (cached != null) {
      if (cached.hasContentDimensions &&
          scrollController.hasClients &&
          identical(cached, scrollController.position)) {
        return cached;
      }
      _activeScrollPosition = null;
    }
    if (scrollController.hasClients) {
      final ScrollPosition position = scrollController.position;
      if (position.hasContentDimensions) {
        _activeScrollPosition = position;
        return position;
      }
    }
    return null;
  }

  bool _isOutsideContentArea({
    required double localX,
    required double horizontalMargin,
    required double effectiveWidth,
    required double viewportWidth,
  }) {
    if (localX < horizontalMargin ||
        localX > horizontalMargin + effectiveWidth) {
      if (_useWebScrollbar &&
          localX > viewportWidth - _scrollbarTrackWidth) {
        return false;
      }
      return true;
    }
    return false;
  }

  void _applyScrollDelta({
    required ScrollPosition position,
    required double delta,
  }) {
    if (!position.physics.shouldAcceptUserOffset(position)) {
      return;
    }
    if (delta == 0.0) {
      return;
    }
    final double targetPixels = (position.pixels + delta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (targetPixels == position.pixels) {
      return;
    }
    if (position.context.notificationContext == null) {
      return;
    }
    position.pointerScroll(delta);
  }

  void _handleMarginPointerScroll({
    required PointerScrollEvent pointerSignal,
    required ScrollController scrollController,
    required double horizontalMargin,
    required double effectiveWidth,
    required double viewportWidth,
  }) {
    if (!_isOutsideContentArea(
      localX: pointerSignal.localPosition.dx,
      horizontalMargin: horizontalMargin,
      effectiveWidth: effectiveWidth,
      viewportWidth: viewportWidth,
    )) {
      return;
    }
    final ScrollPosition? position = _resolveScrollPosition(scrollController);
    if (position == null) {
      return;
    }
    _applyScrollDelta(
      position: position,
      delta: pointerSignal.scrollDelta.dy,
    );
    pointerSignal.respond(allowPlatformDefault: false);
  }

  void _handleMarginPanZoomUpdate({
    required PointerPanZoomUpdateEvent event,
    required ScrollController scrollController,
    required double horizontalMargin,
    required double effectiveWidth,
    required double viewportWidth,
  }) {
    if (!_isOutsideContentArea(
      localX: event.localPosition.dx,
      horizontalMargin: horizontalMargin,
      effectiveWidth: effectiveWidth,
      viewportWidth: viewportWidth,
    )) {
      return;
    }
    final ScrollPosition? position = _resolveScrollPosition(scrollController);
    if (position == null) {
      return;
    }
    _applyScrollDelta(
      position: position,
      delta: -event.panDelta.dy,
    );
  }

  Widget _buildMarginScrollCapture({
    required ScrollController scrollController,
    required double horizontalMargin,
    required double effectiveWidth,
    required double viewportWidth,
  }) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerSignal: (PointerSignalEvent pointerSignal) {
        if (pointerSignal is! PointerScrollEvent) {
          return;
        }
        _handleMarginPointerScroll(
          pointerSignal: pointerSignal,
          scrollController: scrollController,
          horizontalMargin: horizontalMargin,
          effectiveWidth: effectiveWidth,
          viewportWidth: viewportWidth,
        );
      },
      onPointerPanZoomUpdate: (PointerPanZoomUpdateEvent event) {
        _handleMarginPanZoomUpdate(
          event: event,
          scrollController: scrollController,
          horizontalMargin: horizontalMargin,
          effectiveWidth: effectiveWidth,
          viewportWidth: viewportWidth,
        );
      },
      child: const SizedBox.expand(),
    );
  }

  Widget _wrapCenterChild({
    required BuildContext context,
    required ScrollController scrollController,
    required Widget child,
  }) {
    if (widget.scrollController != null) {
      return child;
    }
    if (PrimaryScrollController.maybeOf(context) != null) {
      return child;
    }
    return PrimaryScrollController(
      controller: scrollController,
      automaticallyInheritForPlatforms: _scrollInheritPlatforms,
      child: child,
    );
  }

  Widget _wrapWithScrollNotifications(Widget child) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: _handleScrollMetricsNotification,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (layoutContext, constraints) {
        final double effectiveWidth = constraints.maxWidth > widget.maxWidth
            ? widget.maxWidth
            : constraints.maxWidth;
        final double horizontalMargin =
            (constraints.maxWidth - effectiveWidth) / 2;
        final ScrollController scrollController = _resolveScrollController(
          layoutContext,
        );
        final ScrollController? scrollbarController =
            _scrollbarController(scrollController);

        final Widget centerChild = _wrapCenterChild(
          context: layoutContext,
          scrollController: scrollController,
          child: widget.child,
        );

        if (!widget.captureOutsideScrolling) {
          return _wrapWithScrollNotifications(
            Center(
              child: SizedBox(
                width: effectiveWidth,
                child: centerChild,
              ),
            ),
          );
        }

        Widget content = horizontalMargin > 0
            ? SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight.isFinite
                    ? constraints.maxHeight
                    : null,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: _buildMarginScrollCapture(
                        scrollController: scrollController,
                        horizontalMargin: horizontalMargin,
                        effectiveWidth: effectiveWidth,
                        viewportWidth: constraints.maxWidth,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(width: horizontalMargin),
                        SizedBox(
                          width: effectiveWidth,
                          child: centerChild,
                        ),
                        SizedBox(width: horizontalMargin),
                      ],
                    ),
                  ],
                ),
              )
            : centerChild;

        content = _wrapWithScrollNotifications(content);

        if (_shouldShowWebScrollbar(scrollController) &&
            scrollbarController != null) {
          content = Scrollbar(
            controller: scrollbarController,
            thumbVisibility: true,
            interactive: true,
            child: ScrollConfiguration(
              behavior: const _NoScrollbarScrollBehavior(),
              child: content,
            ),
          );
        }

        return content;
      },
    );
  }
}

class _NoScrollbarScrollBehavior extends ScrollBehavior {
  const _NoScrollbarScrollBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
