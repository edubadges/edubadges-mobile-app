import 'package:edubadges/core/widgets/adaptive_dialog.dart';
import 'package:edubadges/features/badge_details/presentation/providers/badge_details_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BadgeVisibilityDialog {
  static Future<void> show({
    required BuildContext context,
    required WidgetRef ref,
    required String badgeEntityId,
    required bool isPublic,
  }) async {
    final l10n = AppLocalizations.of(context);

    bool includeEvidence = true;
    bool includeGradeAchieved = true;

    await AdaptiveDialog.show(
      context: context,
      config: AdaptiveDialogConfig(
        title: isPublic ? l10n.toMakePublic : l10n.labelMakePrivate,
        description: isPublic
            ? l10n.badgePublicShareWarning
            : l10n.badgeMakePrivateWarning,
        body: isPublic
            ? Material(
                color: Colors.transparent,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      children: [
                        _CustomCheckboxRow(
                          value: includeEvidence,
                          onChanged: (value) {
                            setState(() {
                              includeEvidence = value ?? true;
                            });
                          },
                          label: l10n.makeBadgePublicIncludeEvidence,
                        ),
                        const SizedBox(height: 8),
                        _CustomCheckboxRow(
                          value: includeGradeAchieved,
                          onChanged: (value) {
                            setState(() {
                              includeGradeAchieved = value ?? true;
                            });
                          },
                          label: l10n.makeBadgePublicIncludeGradeAchieved,
                        ),
                      ],
                    );
                  },
                ),
              )
            : null,
        firstButtonText: l10n.cancel,
        secondButtonText: isPublic ? l10n.makePublic : l10n.actionMakePrivate,
        isDestructiveAction: false,
        onFirstButtonPressed: () {},
        onSecondButtonPressed: () async {
          final updateFunction = ref.read(updateBadgeVisibilityProvider);
          await updateFunction(
            badgeEntityId,
            isPublic,
            includeEvidence,
            includeGradeAchieved,
          );
        },
      ),
    );
  }
}

class _CustomCheckboxRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String label;

  const _CustomCheckboxRow({
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return GestureDetector(
      onTap: () {
        onChanged?.call(!value);
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 8),
          Checkbox(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
