import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final String? semanticLabel;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.semanticLabel,
    this.errorBuilder,
  });

  int? _cacheDimension(double? logicalSize, BuildContext context) {
    if (logicalSize == null || !logicalSize.isFinite || logicalSize <= 0) {
      return null;
    }
    final double devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    return (logicalSize * devicePixelRatio).round();
  }

  Widget _loadingPlaceholder(BuildContext context, BoxConstraints constraints) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double? resolvedWidth = width ??
        (constraints.maxWidth.isFinite ? constraints.maxWidth : null);
    final double? resolvedHeight = height ??
        (constraints.maxHeight.isFinite ? constraints.maxHeight : null);

    Widget placeholder = ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );

    if (resolvedWidth != null || resolvedHeight != null) {
      placeholder = SizedBox(
        width: resolvedWidth,
        height: resolvedHeight,
        child: placeholder,
      );
    } else {
      placeholder = AspectRatio(aspectRatio: 1, child: placeholder);
    }

    if (semanticLabel != null) {
      placeholder = Semantics(
        label: semanticLabel,
        child: placeholder,
      );
    }
    return placeholder;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final int? cacheWidth = _cacheDimension(width, context);
    final int? cacheHeight = _cacheDimension(height, context);
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: semanticLabel,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      gaplessPlayback: true,
      loadingBuilder:
          (
            BuildContext context,
            Widget child,
            ImageChunkEvent? loadingProgress,
          ) {
            if (loadingProgress == null) {
              return child;
            }
            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return _loadingPlaceholder(context, constraints);
              },
            );
          },
      errorBuilder:
          errorBuilder ??
          (BuildContext context, Object error, StackTrace? stackTrace) {
            return SizedBox(
              width: width,
              height: height,
              child: Icon(
                Icons.image_not_supported_outlined,
                color: colorScheme.onSurfaceVariant,
              ),
            );
          },
    );
  }
}
