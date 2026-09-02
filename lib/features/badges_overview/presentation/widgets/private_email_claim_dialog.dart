import 'package:edubadges/core/widgets/adaptive_dialog.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool> confirmPrivateEmailAwardIfNeeded({
  required BuildContext context,
  required WidgetRef ref,
  required BadgeInstanceEntity badge,
  VoidCallback? onBeforePrompt,
}) async {
  BadgeInstanceEntity resolved = badge;
  if (!badge.hasRecipientDetails) {
    final result = await ref
        .read(badgesOverviewRepositoryProvider)
        .getDirectAward(badge.entityId);
    resolved = result.fold((_) => badge, (detail) => detail);
  }

  if (!resolved.shouldConfirmPrivateEmailName) {
    return true;
  }

  onBeforePrompt?.call();

  if (!context.mounted) {
    return false;
  }

  return showPrivateEmailClaimDialog(context, resolved.recipientFullName!);
}

Future<bool> showPrivateEmailClaimDialog(
  BuildContext context,
  String recipientName,
) async {
  final l10n = AppLocalizations.of(context);
  var confirmed = false;

  await AdaptiveDialog.show(
    context: context,
    config: AdaptiveDialogConfig(
      title: l10n.claimPrivateEmailTitle,
      description: l10n.claimPrivateEmailDescription,
      body: _PrivateEmailNameNote(name: recipientName),
      firstButtonText: l10n.cancel,
      secondButtonText: l10n.confirm,
      onFirstButtonPressed: () {},
      onSecondButtonPressed: () {
        confirmed = true;
      },
    ),
  );

  return confirmed;
}

class _PrivateEmailNameNote extends StatelessWidget {
  final String name;

  const _PrivateEmailNameNote({required this.name});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    final text = AppLocalizations.of(context).claimPrivateEmailNameNote(name);
    final nameIndex = text.indexOf(name);

    if (nameIndex < 0) {
      return Text(text, style: style);
    }

    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, nameIndex)),
          TextSpan(
            text: name,
            style: style?.copyWith(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: text.substring(nameIndex + name.length)),
        ],
      ),
    );
  }
}
