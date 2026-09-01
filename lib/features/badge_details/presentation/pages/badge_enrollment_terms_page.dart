import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:edubadges/app/colors.dart';
import 'package:edubadges/app/themes.dart';
import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/core/utils/string.dart';
import 'package:edubadges/core/widgets/actionable_content_layout.dart';
import 'package:edubadges/core/widgets/app_snackbar.dart';
import 'package:edubadges/core/widgets/info_state_view.dart';
import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:edubadges/features/account/data/models/agreement_route_model.dart';
import 'package:edubadges/features/account/domain/entities/profile_entity.dart';
import 'package:edubadges/features/account/presentation/providers/account_providers.dart';
import 'package:edubadges/features/badge_details/presentation/providers/badge_details_providers.dart';
import 'package:edubadges/features/badges_overview/utils/badge_terms_agreement_utils.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/presentation/providers/markdown_fetcher.dart';
import 'package:edubadges/shared/presentation/widgets/error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BadgeEnrollmentTermsPage extends ConsumerStatefulWidget {
  final String badgeClassEntityId;

  const BadgeEnrollmentTermsPage({super.key, required this.badgeClassEntityId});

  @override
  ConsumerState<BadgeEnrollmentTermsPage> createState() =>
      _BadgeEnrollmentTermsPageState();
}

class _BadgeEnrollmentTermsPageState
    extends ConsumerState<BadgeEnrollmentTermsPage> {
  bool _isSubmitting = false;
  bool _isShowingLongVersion = false;
  bool _hasInitializedToggle = false;

  String _getErrorMessage(Failure failure, AppLocalizations l10n) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    if (failure is NetworkFailure) {
      return failure.message;
    }
    return l10n.somethingWentWrong;
  }

  Future<void> _handleAccept({
    required BadgeClassModel badgeClass,
    required String termsEntityId,
  }) async {
    if (_isSubmitting) {
      return;
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() {
      _isSubmitting = true;
    });
    try {
      if (!badgeClass.userHasAcceptedTerms) {
        final Either<Failure, void> acceptResult = await ref
            .read(accountRepositoryProvider)
            .acceptTerms(termsEntityId);
        final Failure? acceptFailure = acceptResult.fold(
          (Failure failure) => failure,
          (_) => null,
        );
        if (acceptFailure != null) {
          if (mounted) {
            showAppSnackBar(context, _getErrorMessage(acceptFailure, l10n));
            setState(() {
              _isSubmitting = false;
            });
          }
          return;
        }
        ref.invalidate(badgeDetailsProvider(badgeClass.entityId));
        unawaited(ref.read(profileProvider.notifier).refresh());
      }
      final bool enrolled = await ref.read(enrollBadgeProvider)(
        badgeClass.entityId,
      );
      if (!mounted) {
        return;
      }
      if (!enrolled) {
        showAppSnackBar(context, l10n.somethingWentWrong);
        setState(() {
          _isSubmitting = false;
        });
        return;
      }
      context.pop();
    } catch (error) {
      if (mounted) {
        final String errorMessage = switch (error) {
          Failure(:final message) => message,
          _ => l10n.somethingWentWrong,
        };
        showAppSnackBar(context, errorMessage);
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildTermsContent({
    required BadgeClassModel badgeClass,
    required AgreementRouteModel agreementModel,
    required AppLocalizations l10n,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    if (!_hasInitializedToggle) {
      _hasInitializedToggle = true;
      if (agreementModel.titleShort == null ||
          agreementModel.titleShort!.trim().isEmpty) {
        _isShowingLongVersion = true;
      }
    }
    final String currentTitle = _isShowingLongVersion
        ? agreementModel.titleLong
        : (agreementModel.titleShort?.trim().isEmpty ?? true
              ? agreementModel.titleLong
              : agreementModel.titleShort!);
    final String currentUrlText = _isShowingLongVersion
        ? agreementModel.textUrlLong
        : (agreementModel.textUrlShort?.trim().isEmpty ?? true
              ? agreementModel.textUrlLong
              : agreementModel.textUrlShort!);
    final String toggleButtonText = _isShowingLongVersion
        ? l10n.viewShortText
        : l10n.viewFullText;
    final AsyncValue<String> markdownAsyncValue = ref.watch(
      markdownFetcherProvider(currentUrlText),
    );
    return ActionableContentLayout(
      title: currentTitle,
      error: markdownAsyncValue.hasError,
      content: markdownAsyncValue.when(
        data: (String data) {
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
        error: (Object error, StackTrace stackTrace) {
          return Center(
            child: InfoStateView(
              assetPath: Assets.iconInfo,
              description: l10n.failedToLoadTermsFrom(agreementModel.titleLong),
              error: error,
              stackTrace: stackTrace,
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
            onPressed: _isSubmitting
                ? null
                : () => _handleAccept(
                    badgeClass: badgeClass,
                    termsEntityId: agreementModel.agreementId,
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSubmitting
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      semanticsLabel: AppLocalizations.of(
                        context,
                      ).semanticsLoading,
                    ),
                  )
                : Text(
                    l10n.badgePrivacyReadButton,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        if (agreementModel.textUrlShort?.isEmpty != true)
          TextButton(
            onPressed: () {
              setState(() {
                _isShowingLongVersion = !_isShowingLongVersion;
              });
            },
            child: Text(
              toggleButtonText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final langCode = ref.watch(appLanguageProvider).code;
    final badgeClassAsync = ref.watch(
      badgeDetailsProvider(widget.badgeClassEntityId),
    );
    final profileAsync = ref.watch(profileProvider);

    return MaxWidthWrapper(
      child: badgeClassAsync.when(
        data: (BadgeClassModel badgeClass) {
          final List<TermsAgreementEntity> profileAgreements =
              profileAsync.whenOrNull(
                data: (ProfileEntity? p) => p?.termsagreementSet,
              ) ??
              [];
          final AgreementRouteModel? agreementModel =
              resolveBadgeTermsAgreement(
                requiredTerms: badgeClass.requiredTerms,
                badgeClass: badgeClass,
                profileAgreements: profileAgreements,
                languageCode: langCode,
              );
          if (agreementModel == null) {
            return Scaffold(
              body: Center(
                child: InfoStateView(
                  assetPath: Assets.iconInfo,
                  description: l10n.somethingWentWrong,
                  debugContext: buildBadgeClassTermsDebugContext(
                    routeBadgeId: widget.badgeClassEntityId,
                    badgeClass: badgeClass,
                    requiredTerms: badgeClass.requiredTerms,
                    profileAgreements: profileAgreements,
                  ),
                ),
              ),
            );
          }
          return _buildTermsContent(
            badgeClass: badgeClass,
            agreementModel: agreementModel,
            l10n: l10n,
            theme: theme,
            colorScheme: colorScheme,
          );
        },
        loading: () => Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              semanticsLabel: AppLocalizations.of(context).semanticsLoading,
            ),
          ),
        ),
        error: (Object err, StackTrace stack) => Scaffold(
          body: Center(
            child: ErrorMessageWidget(error: err, stackTrace: stack),
          ),
        ),
      ),
    );
  }
}
