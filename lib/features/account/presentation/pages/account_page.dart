import 'package:app_settings/app_settings.dart';
import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/constants/branding.dart';
import 'package:edubadges/core/constants/layout_constants.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/core/utils/logger.dart';
import 'package:edubadges/core/utils/platform_info.dart';
import 'package:edubadges/core/utils/string.dart';
import 'package:edubadges/core/widgets/adaptive_dialog.dart';
import 'package:edubadges/core/widgets/app_modal.dart';
import 'package:edubadges/core/widgets/app_snackbar.dart';
import 'package:edubadges/core/widgets/focusable_section.dart';
import 'package:edubadges/core/widgets/page_header.dart';
import 'package:edubadges/core/widgets/sidebar_list_layout.dart';
import 'package:edubadges/core/widgets/svg_icon.dart';
import 'package:edubadges/features/account/data/models/agreement_route_model.dart';
import 'package:edubadges/features/account/domain/entities/profile_entity.dart';
import 'package:edubadges/features/account/presentation/providers/account_providers.dart';
import 'package:edubadges/features/account/presentation/widgets/agreement_details_view.dart';
import 'package:edubadges/features/account/presentation/widgets/delete_account_dialog.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  final ScrollController _scrollController = ScrollController();

  static const double _spacingSmall = 8.0;
  static const double _spacingMedium = 16.0;
  static const double _cardBorderRadius = 20.0;
  static const double _cardPadding = 20.0;
  static const double _badgeBorderRadius = 8.0;
  static const double _chevronSize = 12.0;
  static const double _chevronPadding = 8.0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
    String? semanticsIdentifier,
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
            Semantics(
              header: true,
              identifier: semanticsIdentifier,
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
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
          ExcludeSemantics(
            child: Icon(Icons.check, size: 16, color: colorScheme.primary),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
              ),
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

    return MergeSemantics(
      child: Column(
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
      ),
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
        value: l10n.memberSinceDateValue(profile.dateJoined),
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
    WidgetRef ref,
    ProfileEntity profile,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final notificationAsync = ref.watch(notificationEnabledProvider);

    return _buildSectionCard(
      context: context,
      title: l10n.notificationSettings,
      children: [
        _buildDivider(colorScheme),
        const SizedBox(height: _spacingSmall),
        MergeSemantics(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  l10n.generalNotifications,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              notificationAsync.when(
                data: (enabled) => Switch(
                  value: enabled,
                  onChanged: (value) =>
                      _handleNotificationToggle(context, ref, value),
                  activeThumbColor: colorScheme.surfaceContainer,
                  activeTrackColor: colorScheme.primary,
                ),
                loading: () => Switch(
                  value: true,
                  onChanged: null,
                  activeThumbColor: colorScheme.surfaceContainer,
                  activeTrackColor: colorScheme.primary,
                ),
                error: (_, _) => Switch(
                  value: false,
                  onChanged: (value) =>
                      _handleNotificationToggle(context, ref, value),
                  activeThumbColor: colorScheme.surfaceContainer,
                  activeTrackColor: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleNotificationToggle(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    try {
      await ref.read(notificationEnabledProvider.notifier).setEnabled(value);
    } on NotificationPermissionDeniedException catch (_) {
      if (context.mounted) {
        await _showNotificationPermissionDeniedDialog(context, ref);
      }
    } catch (error) {
      if (!context.mounted) return;
      final message = switch (error) {
        Failure(:final message) => message,
        _ => error.toString(),
      };
      showAppSnackBar(context, message);
    }
  }

  String _formatAgreementDateText(
    BuildContext context,
    bool type,
    DateTime? date,
    String version,
  ) {
    final l10n = AppLocalizations.of(context);
    return type
        ? date != null
              ? l10n.agreedOnDateVersion(date, version)
              : l10n.agreedOnUnknownVersion(version)
        : l10n.notYetAgreedVersion(version);
  }

  Widget _buildAgreementItem(
    WidgetRef ref,
    BuildContext context,
    String dateText,
    TermsAgreementEntity agreement,
  ) {
    final l10n = AppLocalizations.of(context);
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

    void onOpenAgreement() {
      final agreementModel = AgreementRouteModel.create(
        institutionName,
        agreement,
        langCode,
      );

      // On web, open the agreement in a dialog instead of a full page.
      if (PlatformInfo.isWeb) {
        showAppFormModal<void>(
          context,
          useRootNavigator: true,
          builder: (dialogContext) => AgreementDetailsView(
            agreement: agreementModel,
            isDialog: true,
          ),
        );
        return;
      }

      context.push(
        RoutePath.agreementDetailsPath(
          agreementId: agreementModel.agreementId,
          titleLong: agreementModel.titleLong,
          textUrlLong: agreementModel.textUrlLong,
          titleShort: agreementModel.titleShort,
          textUrlShort: agreementModel.textUrlShort,
        ),
      );
    }

    final agreementTitle = agreement.getAgreementTypeName(l10n);

    return MergeSemantics(
      child: InkWell(
        onTap: onOpenAgreement,
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
                      agreementTitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.primary,
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
                  excludeFromSemantics: true,
                ),
              ),
            ],
          ),
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
        ...() {
          // Group agreements by terms.institution (identifier as key)
          final grouped = <String, List<TermsAgreementEntity>>{};
          for (final agreement in profile.termsagreementSet) {
            final key = agreement.terms.institution?.identifier ?? '';
            grouped.putIfAbsent(key, () => []).add(agreement);
          }

          final langCode = ref.read(appLanguageProvider).code;
          final groupEntries = grouped.entries.toList();

          return groupEntries.expand((groupEntry) {
            final institution = groupEntry.value.first.terms.institution;
            final institutionName = institution != null
                ? getLocalizedString(
                    institution.nameDutch,
                    institution.nameEnglish,
                    langCode,
                  )
                : edubadges;

            return [
              _buildDivider(colorScheme),
              Padding(
                padding: EdgeInsets.only(
                  top: groupEntry == groupEntries.first ? 0 : _spacingMedium,
                ),
                child: Semantics(
                  header: true,
                  child: Text(
                    institutionName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: _spacingSmall),
              ...groupEntry.value.asMap().entries.map((entry) {
                final agreement = entry.value;
                final dateText = _formatAgreementDateText(
                  context,
                  agreement.agreed,
                  agreement.agreedAt,
                  agreement.agreedVersion.toString(),
                );
                return _buildAgreementItem(ref, context, dateText, agreement);
              }),
            ];
          });
        }(),
      ],
    );
  }

  Future<void> _showDeleteAccountConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context2) => DeleteAccountDialog(
        onDelete: () async {
          final either = await ref
              .read(accountRepositoryProvider)
              .deleteProfile();

          await either.fold(
            (failure) {
              logger.e(failure.message);
              showAppSnackBar(
                context,
                AppLocalizations.of(context).deleteAccountError,
                duration: const Duration(seconds: 7),
              );
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

  Future<void> _showNotificationPermissionDeniedDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context);

    await AdaptiveDialog.show(
      context: context,
      config: AdaptiveDialogConfig(
        title: l10n.notificationPermissionDeniedTitle,
        description: l10n.notificationPermissionDeniedMessage,
        firstButtonText: l10n.cancel,
        secondButtonText: l10n.openSettings,
        isFirstButtonDefaultAction: false,
        onFirstButtonPressed: () {},
        onSecondButtonPressed: () async {
          await AppSettings.openAppSettings(type: AppSettingsType.notification);
        },
      ),
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

  Widget _buildLogoutButton({
    required BuildContext context,
    required WidgetRef ref,
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
  }) {
    return IconButton(
      icon: Icon(Icons.logout, color: colorScheme.primary, size: 24),
      onPressed: () => _showLogoutConfirmation(context, ref),
      tooltip: l10n.semanticsLogout,
    );
  }

  Widget _buildSidebarContent({
    required BuildContext context,
    required WidgetRef ref,
    required ProfileEntity profile,
  }) {
    return Column(
      children: [
        FocusableSection(
          autofocus: true,
          child: _buildDataSection(context, profile),
        ),
        if (!PlatformInfo.isWeb) _buildNotificationSection(context, ref, profile),
      ],
    );
  }

  List<Widget> _buildMainContentSlivers({
    required BuildContext context,
    required WidgetRef ref,
    required ProfileEntity profile,
    required bool useSidebarLayout,
  }) {
    final horizontalPadding = useSidebarLayout
        ? 0.0
        : LayoutConstants.sidebarListLayoutPadding;

    return [
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        sliver: SliverToBoxAdapter(
          child: Column(
            children: [
              _buildAgreementsSection(ref, context, profile),
              _buildDeleteAccountSection(context, ref),
            ],
          ),
        ),
      ),
    ];
  }

  Future<void> _refreshAccountData(WidgetRef ref) async {
    final refreshTasks = <Future<void>>[
      ref.read(profileProvider.notifier).refresh(),
    ];
    if (!PlatformInfo.isWeb) {
      refreshTasks.add(
        ref.read(notificationEnabledProvider.notifier).refresh(),
      );
    }
    await Future.wait(refreshTasks);
  }

  Widget _buildAccountContent({
    required BuildContext context,
    required WidgetRef ref,
    required ProfileEntity profile,
    required bool useSidebarLayout,
  }) {
    return SidebarListLayout(
      sidebar: _buildSidebarContent(
        context: context,
        ref: ref,
        profile: profile,
      ),
      scrollController: _scrollController,
      onRefresh: () => _refreshAccountData(ref),
      useSidebarLayout: useSidebarLayout,
      slivers: _buildMainContentSlivers(
        context: context,
        ref: ref,
        profile: profile,
        useSidebarLayout: useSidebarLayout,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final profileAsync = ref.watch(profileProvider);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool useSidebarLayout =
            constraints.maxWidth >= LayoutConstants.sidebarListLayoutMinWidth;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: useSidebarLayout
              ? null
              : AppBar(
                  title: Text(
                    l10n.tabAccount,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  backgroundColor: colorScheme.surface,
                  actions: [
                    _buildLogoutButton(
                      context: context,
                      ref: ref,
                      l10n: l10n,
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (useSidebarLayout)
                PageHeader(
                  title: l10n.tabAccount,
                  subtitle: l10n.accountSubtitle,
                  actions: [
                    _buildLogoutButton(
                      context: context,
                      ref: ref,
                      l10n: l10n,
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              Expanded(
                child: profileAsync.when(
                  data: (profile) {
                    if (profile == null) {
                      return Center(child: Text(l10n.noProfileData));
                    }

                    return _buildAccountContent(
                      context: context,
                      ref: ref,
                      profile: profile,
                      useSidebarLayout: useSidebarLayout,
                    );
                  },
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: l10n.semanticsLoading,
                    ),
                  ),
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
                          onPressed: () =>
                              ref.read(profileProvider.notifier).refresh(),
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
