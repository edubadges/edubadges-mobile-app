import 'package:edubadges/core/widgets/keyboard_activatable.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:edubadges/shared/presentation/widgets/badge_card.dart';
import 'package:flutter/material.dart';

/// Sliver list of edubadges that can be selected for a collection, shared by
/// the create flow and the edit collection screen.
class SelectableBadgeSliverList extends StatelessWidget {
  final List<BadgeInstanceEntity> badges;
  final Set<String> selectedBadgeIds;
  final ValueChanged<String> onToggle;

  const SelectableBadgeSliverList({
    super.key,
    required this.badges,
    required this.selectedBadgeIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return Padding(
          key: ValueKey<String>(badge.entityId),
          padding: const EdgeInsets.only(bottom: 8),
          child: SelectableBadgeTile(
            badge: badge,
            isSelected: selectedBadgeIds.contains(badge.entityId),
            onToggle: () => onToggle(badge.entityId),
          ),
        );
      },
    );
  }
}

/// A badge row with a trailing checkbox; tapping anywhere on the row toggles it.
class SelectableBadgeTile extends StatelessWidget {
  final BadgeInstanceEntity badge;
  final bool isSelected;
  final VoidCallback onToggle;

  const SelectableBadgeTile({
    super.key,
    required this.badge,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // The row is announced as one checkable item; the checkbox is visual only
    // and stays out of the focus order so each row is a single tab stop.
    return MergeSemantics(
      child: Semantics(
        checked: isSelected,
        child: KeyboardActivatable(
          wrapWithSemantics: false,
          includeOuterTapTarget: false,
          onActivate: onToggle,
          child: BadgeCard(
            instance: badge,
            badgeClass: badge.badgeclass as BadgeClassModel,
            style: BadgeCardStyle.small,
            isSelected: isSelected,
            borderColor: Theme.of(context).colorScheme.outline,
            onTap: onToggle,
            trailing: ExcludeSemantics(
              child: ExcludeFocus(
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) => onToggle(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
