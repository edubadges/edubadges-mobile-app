import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MaxWidthWrapper extends StatefulWidget {
  static const double defaultMaxWidth = 720.0;

  final Widget child;
  final double maxWidth;
  final bool captureOutsideScrolling;
  final ScrollController? scrollController;

  /// When false, skips the outer [Scrollbar] (for static, non-scrolling pages).
  final bool enableScrollbar;

  const MaxWidthWrapper({
    super.key,
    required this.child,
    this.maxWidth = defaultMaxWidth,
    this.captureOutsideScrolling = true,
    this.scrollController,
    this.enableScrollbar = true,
  });

  @override
  State<MaxWidthWrapper> createState() => _MaxWidthWrapperState();
}

class _MaxWidthWrapperState extends State<MaxWidthWrapper> {
  late ScrollController _scrollController;
  late bool _ownsController;
  bool _scrollbarVisible = false;

  static const Set<TargetPlatform> _scrollInheritPlatforms = <TargetPlatform>{
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.fuchsia,
    TargetPlatform.linux,
    TargetPlatform.macOS,
    TargetPlatform.windows,
  };

  static const double _scrollbarTrackWidth = 18;

  @override
  void initState() {
    super.initState();
    _attachController(widget.scrollController);
  }

  @override
  void didUpdateWidget(covariant MaxWidthWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      if (_ownsController) {
        _scrollController.dispose();
      }
      _attachController(widget.scrollController);
      _scrollbarVisible = false;
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _attachController(ScrollController? external) {
    if (external != null) {
      _scrollController = external;
      _ownsController = false;
    } else {
      _scrollController = ScrollController();
      _ownsController = true;
    }
  }

  void _syncScrollbarVisibility() {
    final bool shouldShow =
        widget.enableScrollbar && _scrollController.hasClients;
    if (shouldShow == _scrollbarVisible) {
      return;
    }
    setState(() {
      _scrollbarVisible = shouldShow;
    });
  }

  bool _handleScrollMetricsNotification(ScrollMetricsNotification notification) {
    _syncScrollbarVisibility();
    return false;
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      _syncScrollbarVisibility();
    }
    return false;
  }

  bool _isOutsideContentArea({
    required double localX,
    required double horizontalMargin,
    required double effectiveWidth,
    required double viewportWidth,
  }) {
    if (localX < horizontalMargin ||
        localX > horizontalMargin + effectiveWidth) {
      if (widget.enableScrollbar &&
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

  ScrollPosition? _resolveScrollPosition() {
    if (!_scrollController.hasClients) {
      return null;
    }
    final ScrollPosition position = _scrollController.position;
    if (!position.hasContentDimensions) {
      return null;
    }
    return position;
  }

  void _handleMarginPointerScroll({
    required PointerScrollEvent pointerSignal,
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
    final ScrollPosition? position = _resolveScrollPosition();
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
    final ScrollPosition? position = _resolveScrollPosition();
    if (position == null) {
      return;
    }
    _applyScrollDelta(
      position: position,
      delta: -event.panDelta.dy,
    );
  }

  Widget _buildMarginScrollCapture({
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
          horizontalMargin: horizontalMargin,
          effectiveWidth: effectiveWidth,
          viewportWidth: viewportWidth,
        );
      },
      onPointerPanZoomUpdate: (PointerPanZoomUpdateEvent event) {
        _handleMarginPanZoomUpdate(
          event: event,
          horizontalMargin: horizontalMargin,
          effectiveWidth: effectiveWidth,
          viewportWidth: viewportWidth,
        );
      },
      child: const SizedBox.expand(),
    );
  }

  Widget _buildConstrainedContent({
    required double effectiveWidth,
  }) {
    return PrimaryScrollController(
      controller: _scrollController,
      automaticallyInheritForPlatforms: _scrollInheritPlatforms,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: Center(
          child: SizedBox(
            width: effectiveWidth,
            child: widget.child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = LayoutBuilder(
      builder: (BuildContext layoutContext, BoxConstraints constraints) {
        final double effectiveWidth = constraints.maxWidth > widget.maxWidth
            ? widget.maxWidth
            : constraints.maxWidth;
        final double horizontalMargin =
            (constraints.maxWidth - effectiveWidth) / 2;

        final Widget constrained = !widget.captureOutsideScrolling ||
                horizontalMargin <= 0
            ? _buildConstrainedContent(effectiveWidth: effectiveWidth)
            : SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight.isFinite
                    ? constraints.maxHeight
                    : null,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: _buildMarginScrollCapture(
                        horizontalMargin: horizontalMargin,
                        effectiveWidth: effectiveWidth,
                        viewportWidth: constraints.maxWidth,
                      ),
                    ),
                    _buildConstrainedContent(effectiveWidth: effectiveWidth),
                  ],
                ),
              );

        return NotificationListener<ScrollMetricsNotification>(
          onNotification: _handleScrollMetricsNotification,
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: constrained,
          ),
        );
      },
    );

    if (!widget.enableScrollbar ||
        !_scrollbarVisible ||
        !_scrollController.hasClients) {
      return content;
    }

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      interactive: true,
      child: content,
    );
  }
}
