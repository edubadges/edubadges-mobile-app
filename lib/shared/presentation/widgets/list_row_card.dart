import 'package:edubadges/core/widgets/app_network_image.dart';
import 'package:flutter/material.dart';

class ListRowCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final String? semanticLabel;

  const ListRowCard({
    super.key,
    this.imageUrl,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.semanticLabel,
  });

  Widget _buildImage(ColorScheme colorScheme) {
    final Widget placeholder = Container(
      height: 64,
      width: 64,
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: colorScheme.onSurfaceVariant,
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) {
      return ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: placeholder,
        ),
      );
    }

    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AppNetworkImage(
          imageUrl: imageUrl!,
          height: 64,
          width: 64,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => placeholder,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final cardContent = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
        color: colorScheme.surfaceContainer,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildImage(colorScheme),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return MergeSemantics(
        child: Semantics(
          label: semanticLabel,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: cardContent,
          ),
        ),
      );
    }

    return cardContent;
  }
}
