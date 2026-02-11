import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/constants/branding.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/core/utils/logger.dart';
import 'package:edubadges/core/utils/string.dart';
import 'package:edubadges/core/widgets/adaptive_dialog.dart';
import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:edubadges/core/widgets/svg_icon.dart';
import 'package:edubadges/features/account/data/models/agreement_route_model.dart';
import 'package:edubadges/features/account/domain/entities/profile_entity.dart';
import 'package:edubadges/features/account/presentation/providers/account_providers.dart';
import 'package:edubadges/features/account/presentation/widgets/delete_account_dialog.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  static const double _spacingSmall = 8.0;
  static const double _spacingMedium = 16.0;
  static const double _cardBorderRadius = 20.0;
  static const double _cardPadding = 20.0;
  static const double _badgeBorderRadius = 8.0;
  static const double _chevronSize = 12.0;
  static const double _chevronPadding = 8.0;

  Widget _buildDivider(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _spacingSmall),
      child: Divider(color: colorScheme.outlineVariant, height: 1),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      color: colorScheme.surfaceContainer,
      margin: const EdgeInsets.only(bottom: _spacingMedium),
      child: Padding(
        padding: const EdgeInsets.all(_cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInstitutionBadge(BuildContext context, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _spacingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(_badgeBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, size: 16, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataItem(
    BuildContext context,
    String label,
    String value, {
    bool showBadge = false,
    String? badgeText,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        if (showBadge && badgeText != null) ...[
          const SizedBox(height: 4),
          _buildInstitutionBadge(context, badgeText),
        ],
      ],
    );
  }

  Widget _buildDataSection(BuildContext context, ProfileEntity profile) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final dataItems = [
      (label: l10n.confirmedName, value: profile.fullName, showBadge: true),
      (label: l10n.emailAddress, value: profile.email, showBadge: false),
      if (profile.institution != null)
        (
          label: l10n.institution,
          value: profile.institution!,
          showBadge: false,
        ),
      (label: l10n.eduid, value: profile.entityId, showBadge: false),
      (
        label: l10n.memberSince,
        value: 'dinsdag 20 april 2021 om 16:20',
        showBadge: false,
      ),
    ];

    return _buildSectionCard(
      context: context,
      title: l10n.accountData,
      children: [
        _buildDivider(colorScheme),
        const SizedBox(height: _spacingMedium),
        ...dataItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == dataItems.length - 1;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDataItem(
                context,
                item.label,
                item.value,
                showBadge: item.showBadge,
                badgeText: item.showBadge ? l10n.providedByInstitution : null,
              ),
              if (!isLast) ...[
                const SizedBox(height: 14),
                _buildDivider(colorScheme),
                const SizedBox(height: 14),
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _buildNotificationSection(
    BuildContext context,
    ProfileEntity profile,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _buildSectionCard(
      context: context,
      title: l10n.notificationSettings,
      children: [
        _buildDivider(colorScheme),
        const SizedBox(height: _spacingSmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.generalNotifications,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Switch(
              value:
                  true, // TODO: Replace with real value later https://digitalclub.atlassian.net/browse/SURF-514
              onChanged: (value) {
                // TODO: Implement update notification settings https://digitalclub.atlassian.net/browse/SURF-514
              },
              activeThumbColor: colorScheme.surfaceContainer,
              activeTrackColor: colorScheme.primary,
            ),
          ],
        ),
      ],
    );
  }

  String _formatAgreementDateText(
    BuildContext context,
    bool type,
    DateTime? date,
    String version,
  ) {
    final l10n = AppLocalizations.of(context);
    return type && date != null
        ? l10n.agreedOnDateVersion(date, version)
        : l10n.notYetAgreedVersion(version);
  }

  Widget _buildAgreementItem(
    WidgetRef ref,
    BuildContext context,
    String dateText,
    TermsAgreementEntity agreement,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final langCode = ref.read(appLanguageProvider).code;
    final institution = agreement.terms.institution;
    final institutionName = institution != null
        ? getLocalizedString(
            institution.nameDutch,
            institution.nameEnglish,
            langCode,
          )
        : edubadges;

    return InkWell(
      onTap: () {
        final agreementModel = AgreementRouteModel.create(institutionName, agreement, langCode);
        context.push(agreementModel.buildRouteUrl());
      },
      borderRadius: BorderRadius.circular(_badgeBorderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: _spacingSmall),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    institutionName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    dateText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(_chevronPadding),
              child: SvgIcon(
                assetPath: Assets.iconChevron,
                size: _chevronSize,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgreementsSection(
    WidgetRef ref,
    BuildContext context,
    ProfileEntity profile,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _buildSectionCard(
      context: context,
      title: l10n.givenAgreements,
      children: [
        Text(
          l10n.agreementsDescription,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: _spacingSmall),
        _buildDivider(colorScheme),
        const SizedBox(height: _spacingSmall),
        ...profile.termsagreementSet.asMap().entries.map((entry) {
          final index = entry.key;
          final agreement = entry.value;
          final isLast = index == profile.termsagreementSet.length - 1;
          final dateText = _formatAgreementDateText(
            context,
            entry.value.agreed,
            agreement.agreedAt,
            agreement.agreedVersion.toString(),
          );

          return Column(
            children: [
              _buildAgreementItem(ref, context, dateText, agreement),
              if (!isLast) _buildDivider(colorScheme),
            ],
          );
        }),
      ],
    );
  }

  Future<void> _showDeleteAccountConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => DeleteAccountDialog(
        onDelete: () async {
          final either = await ref
              .read(accountRepositoryProvider)
              .deleteProfile();

          either.fold(
            (failure) {
              logger.e(failure.message);
              // TODO: add a snackbar are something when we know how we are gonna do error handling
            },
            (success) async {
              if (success == true) {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go(RoutePath.login);
                }
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildDeleteAccountSection(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _buildSectionCard(
      context: context,
      title: l10n.deleteAccount,
      children: [
        const SizedBox(height: _spacingMedium),
        Text(
          l10n.deleteAccountDescription,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: _spacingMedium),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _showDeleteAccountConfirmation(context, ref),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error),
              padding: const EdgeInsets.symmetric(vertical: _spacingMedium),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_badgeBorderRadius),
              ),
            ),
            child: Text(
              l10n.deleteMyAccount,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showLogoutConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context);

    await AdaptiveDialog.show(
      context: context,
      config: AdaptiveDialogConfig(
        title: l10n.logoutConfirmationTitle,
        description: l10n.logoutConfirmationMessage,
        firstButtonText: l10n.cancel,
        secondButtonText: l10n.logout,
        isDestructiveAction: true,
        onFirstButtonPressed: () {},
        onSecondButtonPressed: () async {
          await ref.read(authProvider.notifier).logout();
          if (context.mounted) {
            context.go(RoutePath.login);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.tabAccount,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: colorScheme.primary, size: 24),
            onPressed: () => _showLogoutConfirmation(context, ref),
          ),
        ],
      ),
      body: MaxWidthWrapper(
        child: profileAsync.when(
          data: (profile) {
            if (profile == null) {
              return Center(child: Text(l10n.noProfileData));
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                _cardPadding,
                0,
                _cardPadding,
                _cardPadding,
              ),
              child: Column(
                spacing: 0,
                children: [
                  _buildDataSection(context, profile),
                  _buildNotificationSection(context, profile),
                  _buildAgreementsSection(ref, context, profile),
                  _buildDeleteAccountSection(context, ref),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.somethingWentWrong,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(profileProvider.notifier).refresh(),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
