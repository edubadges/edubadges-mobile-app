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
import 'package:go_router/go_router.dart';

/// Shared presentation for a single agreement's details.
///
/// On mobile it is hosted in a full page ([ActionableContentLayout]); on web
/// it is hosted inside a centered dialog. The markdown fetching, short/long
/// toggle and withdraw handling are identical in both cases.
class AgreementDetailsView extends ConsumerStatefulWidget {
  final AgreementRouteModel agreement;

  /// When true the view renders itself as a self-contained dialog panel
  /// instead of a full page.
  final bool isDialog;

  const AgreementDetailsView({
    super.key,
    required this.agreement,
    this.isDialog = false,
  });

  @override
  ConsumerState<AgreementDetailsView> createState() =>
      _AgreementDetailsViewState();
}

class _AgreementDetailsViewState extends ConsumerState<AgreementDetailsView> {
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

  void _close() {
    if (widget.isDialog) {
      Navigator.of(context).pop();
    } else {
      context.pop();
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
        if (!context.mounted) return;
        // Show before closing: the messenger lives above the dialog/page so
        // the snackbar persists once this view is dismissed.
        showAppSnackBar(context, l10n.withdrawAgreementSuccess);
        _close();
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

    final Widget content = markdownAsyncValue.when(
      data: (data) {
        return MarkdownBody(
          data: filterBadMarkdown(data),
          styleSheet: AppThemes.markdownStyleSheet(context).copyWith(
            h1: theme.textTheme.bodyMedium?.copyWith(
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
            description: l10n.failedToLoadTermsFrom(widget.agreement.titleLong),
            error: error,
            stackTrace: stackTrace,
          ),
        );
      },
      loading: () {
        return Center(
          child: CircularProgressIndicator(
            semanticsLabel: l10n.semanticsLoading,
          ),
        );
      },
    );

    final List<Widget> actions = [
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
    ];

    if (!widget.isDialog) {
      return ActionableContentLayout(
        title: currentTitle,
        error: markdownAsyncValue.hasError,
        content: content,
        actions: actions,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 12, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    currentTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colorScheme.onSurface),
                  onPressed: _close,
                  tooltip: l10n.semanticsClose,
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: content,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: actions,
            ),
          ),
        ],
      ),
    );
  }
}
