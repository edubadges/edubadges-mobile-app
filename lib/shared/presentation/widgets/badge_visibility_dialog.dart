import 'package:edubadges/core/widgets/adaptive_dialog.dart';
import 'package:edubadges/features/badge_details/presentation/providers/badge_details_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BadgeVisibilityDialog {
  static Future<void> show({
    required BuildContext context,
    required WidgetRef ref,
    required BadgeInstanceModel badgeInstance,
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
            ? StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    spacing: 8,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (badgeInstance.evidences?.isNotEmpty == true)
                        _CustomCheckboxRow(
                          value: includeEvidence,
                          onChanged: (value) {
                            setState(() {
                              includeEvidence = value ?? true;
                            });
                          },
                          label: l10n.makeBadgePublicIncludeEvidence,
                        ),
                      if (badgeInstance.gradeAchieved != null)
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
              )
            : null,
        firstButtonText: l10n.cancel,
        secondButtonText: isPublic ? l10n.makePublic : l10n.actionMakePrivate,
        isDestructiveAction: false,
        onFirstButtonPressed: () {},
        onSecondButtonPressed: () async {
          final updateFunction = ref.read(updateBadgeVisibilityProvider);
          await updateFunction(
            badgeInstance.entityId,
            isPublic: isPublic,
            includeEvidence: includeEvidence,
            includeGradeAchieved: includeGradeAchieved,
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

    return InkWell(
      onTap: () => onChanged?.call(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: Text(label, style: textTheme.bodyMedium),
            ),
            Checkbox(
              value: value,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
