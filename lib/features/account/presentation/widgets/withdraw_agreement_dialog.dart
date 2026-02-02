import 'package:edubadges/core/widgets/adaptive_dialog.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class WithdrawAgreementDialog {
  static Future<void> show({
    required BuildContext context,
    required String institution,
  }) async {
    final l10n = AppLocalizations.of(context);

    await AdaptiveDialog.show(
      context: context,
      config: AdaptiveDialogConfig(
        title: l10n.withdrawAgreementTitle,
        description: l10n.withdrawAgreementMessage(institution),
        firstButtonText: l10n.cancel,
        secondButtonText: l10n.confirm,
        onFirstButtonPressed: () {},
        onSecondButtonPressed: () {
          // TODO: Implement withdraw agreement functionality https://digitalclub.atlassian.net/browse/SURF-514
        },
      ),
    );
  }
}
