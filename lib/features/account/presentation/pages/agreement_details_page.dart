import 'package:edubadges/app/themes.dart';
import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/core/utils/string.dart';
import 'package:edubadges/core/widgets/actionable_content_layout.dart';
import 'package:edubadges/core/widgets/app_snackbar.dart';
import 'package:edubadges/core/widgets/info_state_view.dart';
import 'package:edubadges/features/account/data/models/agreement_route_model.dart';
import 'package:edubadges/features/account/presentation/providers/account_providers.dart';
import 'package:edubadges/features/account/presentation/widgets/withdraw_agreement_dialog.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/presentation/providers/markdown_fetcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AgreementDetailsPage extends ConsumerStatefulWidget {
  final AgreementRouteModel agreement;

  const AgreementDetailsPage({super.key, required this.agreement});

  @override
  ConsumerState<AgreementDetailsPage> createState() =>
      _AgreementDetailsPageState();
}

class _AgreementDetailsPageState extends ConsumerState<AgreementDetailsPage> {
  bool _isShowingLongVersion = false;

  @override
  void initState() {
    super.initState();
    // No short version to show (null or empty)
    if (widget.agreement.titleShort == null ||
        widget.agreement.titleShort!.trim().isEmpty) {
      _isShowingLongVersion = true;
    }
  }

  Future<void> _handleWithdrawAgreement(String entityId) async {
    final l10n = AppLocalizations.of(context);
    final repository = ref.read(accountRepositoryProvider);
    final result = await repository.rejectTerms(entityId);
    if (!context.mounted) return;
    result.fold(
      (failure) {
        final message = failure is ServerFailure
            ? failure.message
            : failure is NetworkFailure
            ? failure.message
            : l10n.somethingWentWrong;
        showAppSnackBar(context, message);
      },
      (_) {
        ref.read(profileProvider.notifier).refresh();
        if (context.mounted) {
          Navigator.of(context).pop();
          showAppSnackBar(context, l10n.withdrawAgreementSuccess);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final currentTitle = _isShowingLongVersion
        ? widget.agreement.titleLong
        : (widget.agreement.titleShort?.trim().isEmpty ?? true
              ? widget.agreement.titleLong
              : widget.agreement.titleShort!);
    final currentUrlText = _isShowingLongVersion
        ? widget.agreement.textUrlLong
        : (widget.agreement.textUrlShort?.trim().isEmpty ?? true
              ? widget.agreement.textUrlLong
              : widget.agreement.textUrlShort!);
    final toggleButtonText = _isShowingLongVersion
        ? l10n.viewShortText
        : l10n.viewFullText;

    final markdownAsyncValue = ref.watch(
      markdownFetcherProvider(currentUrlText),
    );

    return ActionableContentLayout(
      title: currentTitle,
      error: markdownAsyncValue.hasError,
      content: markdownAsyncValue.when(
        data: (data) {
          return MarkdownBody(
            data: filterBadMarkdown(data),
            styleSheet: AppThemes.markdownStyleSheet(context).copyWith(
              h1: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: InfoStateView(
              assetPath: Assets.iconInfo,
              description: l10n.failedToLoadTermsFrom(
                widget.agreement.titleLong,
              ),
            ),
          );
        },
        loading: () {
          return Center(
            child: CircularProgressIndicator(
              semanticsLabel: AppLocalizations.of(context).semanticsLoading,
            ),
          );
        },
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => WithdrawAgreementDialog.show(
              context: context,
              institution: widget.agreement.titleLong,
              entityId: widget.agreement.agreementId,
              onWithdraw: _handleWithdrawAgreement,
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
        if (widget.agreement.textUrlShort?.isEmpty == true)
          const SizedBox(height: 12),
        if (widget.agreement.textUrlShort?.isEmpty != true)
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
