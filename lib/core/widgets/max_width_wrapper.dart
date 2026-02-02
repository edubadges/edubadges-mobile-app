import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MaxWidthWrapper extends StatefulWidget {
  final Widget child;
  final double maxWidth;
  final bool captureOutsideScrolling;

  const MaxWidthWrapper({
    super.key,
    required this.child,
    this.maxWidth = 720.0,
    this.captureOutsideScrolling = true,
  });

  @override
  State<MaxWidthWrapper> createState() => _MaxWidthWrapperState();
}

class _MaxWidthWrapperState extends State<MaxWidthWrapper> {
  Drag? _drag;

  void _handleVerticalDragStart(DragStartDetails details, ScrollController? controller) {
    if (controller != null && controller.hasClients) {
      final position = controller.position;
      _drag = position.drag(details, () {});
    }
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details, ScrollController? controller) {
    if (_drag != null) {
      _drag!.update(details);
    }
  }

  void _handleVerticalDragEnd(DragEndDetails details, ScrollController? controller) {
    if (_drag != null) {
      _drag!.end(details);
      _drag = null;
    }
  }

  void _handleVerticalDragCancel(ScrollController? controller) {
    if (_drag != null) {
      _drag!.cancel();
      _drag = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (layoutContext, constraints) {
        final effectiveWidth = constraints.maxWidth > widget.maxWidth
            ? widget.maxWidth
            : constraints.maxWidth;

        Widget content = Center(
          child: SizedBox(
            width: effectiveWidth,
            child: widget.child,
          ),
        );

        if (widget.captureOutsideScrolling) {
          final scrollController = PrimaryScrollController.maybeOf(layoutContext);
          
          return Listener(
            behavior: HitTestBehavior.translucent,
            // Handle mouse wheel scrolling (desktop/web)
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent) {
                if (scrollController != null && scrollController.hasClients) {
                  final position = scrollController.position;
                  final newOffset = position.pixels + pointerSignal.scrollDelta.dy;
                  scrollController.jumpTo(newOffset.clamp(
                    position.minScrollExtent,
                    position.maxScrollExtent,
                  ));
                }
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              // Handle touch/drag scrolling (mobile/trackpad)
              onVerticalDragStart: (details) => _handleVerticalDragStart(details, scrollController),
              onVerticalDragUpdate: (details) => _handleVerticalDragUpdate(details, scrollController),
              onVerticalDragEnd: (details) => _handleVerticalDragEnd(details, scrollController),
              onVerticalDragCancel: () => _handleVerticalDragCancel(scrollController),
              child: content,
            ),
          );
        }

        return content;
      },
    );
  }
}