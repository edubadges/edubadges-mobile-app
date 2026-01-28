import 'package:edubadges/core/widgets/lite_rolling_switch.dart';
import 'package:edubadges/features/badge_details/presentation/providers/badge_details_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BadgeVisibilityCard extends ConsumerStatefulWidget {
  final EdgeInsets margin;
  final BadgeInstanceEntity badge;

  const BadgeVisibilityCard({
    super.key,
    required this.badge,
    this.margin = const EdgeInsets.only(left: 20, right: 20, bottom: 8, top: 16),
  });

  @override
  ConsumerState<BadgeVisibilityCard> createState() =>
      _BadgeVisibilityCardState();
}

class _BadgeVisibilityCardState extends ConsumerState<BadgeVisibilityCard> {
  late bool isPublic;

  @override
  void initState() {
    super.initState();
    isPublic = widget.badge.public;
  }

  @override
  void didUpdateWidget(BadgeVisibilityCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.badge.public != widget.badge.public) {
      isPublic = widget.badge.public;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
        color: colorScheme.surfaceContainer,
      ),
      margin: widget.margin,
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.badgeVisibleAndShareable,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.badgeVisibleAndShareableDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedIconSwitch(
                value: isPublic,
                width: 44,
                height: 28,
                activeColor: colorScheme.primary,
                inactiveColor: colorScheme.surfaceContainerHighest,
                activeThumbColor: Colors.white,
                inactiveThumbColor: colorScheme.onSurfaceVariant,
                withIcons: true,
                iconOnThumb: true,
                activeIcon: Icons.check,
                inactiveIcon: Icons.close,
                activeIconColor: colorScheme.primary,
                inactiveIconColor: Colors.white,
                activeIconSize: 16,
                inactiveIconSize: 16,
                borderRadius: 14,
                onChanged: (bool state) async {
                  setState(() {
                    isPublic = state;
                  });

                  //TODO: Add snackbar error if it fails
                  
                  final updateFunction = ref.read(updateBadgeVisibilityProvider);
                  final success = await updateFunction(
                    widget.badge.entityId,
                    state,
                  );
                  
                  if (!success) {
                    setState(() {
                      isPublic = !state;
                    });
                  }
                },
              ),
            ],
          ),
          // TODO: Add copy link and Linkedin link
        ],
      ),
    );
  }
}
