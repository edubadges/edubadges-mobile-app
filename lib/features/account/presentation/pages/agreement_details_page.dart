import 'package:edubadges/app/colors.dart';
import 'package:edubadges/core/widgets/link_text.dart';
import 'package:edubadges/features/account/data/models/agreement_route_model.dart';
import 'package:edubadges/features/account/presentation/widgets/withdraw_agreement_dialog.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          currentTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        backgroundColor: colorScheme.surface,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinkText(
                      text: currentText,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
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
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
