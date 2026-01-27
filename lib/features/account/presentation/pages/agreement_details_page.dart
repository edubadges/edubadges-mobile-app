import 'package:edubadges/core/widgets/actionable_content_layout.dart';
import 'package:edubadges/core/widgets/link_text.dart';
import 'package:edubadges/features/account/data/models/agreement_route_model.dart';
import 'package:edubadges/features/account/presentation/widgets/withdraw_agreement_dialog.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class AgreementDetailsPage extends StatefulWidget {
  final AgreementRouteModel agreement;

  const AgreementDetailsPage({super.key, required this.agreement});

  @override
  State<AgreementDetailsPage> createState() => _AgreementDetailsPageState();
}

class _AgreementDetailsPageState extends State<AgreementDetailsPage> {
  bool _isShowingLongVersion = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final currentTitle = _isShowingLongVersion
        ? widget.agreement.titleLong
        : widget.agreement.titleShort;
    final currentText = _isShowingLongVersion
        ? widget.agreement.textLong
        : widget.agreement.textShort;
    final toggleButtonText = _isShowingLongVersion
        ? l10n.viewShortText
        : l10n.viewFullText;

    return ActionableContentLayout(
      title: currentTitle,
      content: LinkText(text: currentText, style: theme.textTheme.bodyMedium),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => WithdrawAgreementDialog.show(
              context: context,
              institution: widget.agreement.agreementId,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              l10n.withdraw,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _isShowingLongVersion = !_isShowingLongVersion;
            });
          },
          child: Text(
            toggleButtonText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
