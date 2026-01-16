import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/widgets/svg_icon.dart';
import 'package:edubadges/features/account/domain/entities/profile_entity.dart';
import 'package:edubadges/features/account/presentation/providers/account_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  Widget _buildDivider(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      color: colorScheme.surfaceContainer,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
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

  Widget _buildDataSection(BuildContext context, ProfileEntity profile) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final dataItems = [
      {
        'label': l10n.confirmedName,
        'value': profile.fullName,
        'hasBadge': true,
      },
      {'label': l10n.emailAddress, 'value': profile.email, 'hasBadge': false},
      if (profile.institution != null)
        {
          'label': l10n.institution,
          'value': profile.institution!,
          'hasBadge': false,
        },
      {'label': l10n.eduid, 'value': profile.entityId, 'hasBadge': false},
      {
        'label': l10n.memberSince,
        'value': 'dinsdag 20 april 2021 om 16:20',
        'hasBadge': false,
      },
    ];

    return _buildSectionCard(
      context: context,
      title: l10n.accountData,
      children: [
        _buildDivider(colorScheme),
        const SizedBox(height: 16),
        ...dataItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value as Map<String, dynamic>;
          final isLast = index == dataItems.length - 1;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['label'] as String,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                item['value'] as String,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (item['hasBadge'] == true) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        l10n.providedByInstitution,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _buildSectionCard(
      context: context,
      title: l10n.notificationSettings,
      children: [
        _buildDivider(colorScheme),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.generalNotifications,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: profile.marketingOptIn,
              onChanged: (value) {
                // TODO: Implement update notification settings
              },
              activeThumbColor: colorScheme.primary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAgreementsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Mock agreements data - TODO replace with actual API call when available
    final mockAgreements = [
      {
        'institution': 'University Voorbeeld',
        'type': 'agreed',
        'date': DateTime(2025, 11, 15),
        'version': '1',
      },
      {
        'institution': 'University Voorbeeld',
        'type': 'read',
        'date': DateTime(2025, 11, 12),
        'version': '1',
      },
    ];

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
        const SizedBox(height: 8),
        _buildDivider(colorScheme),
        const SizedBox(height: 8),
        ...mockAgreements.asMap().entries.map((entry) {
          final index = entry.key;
          final agreement = entry.value as Map<String, dynamic>;
          final isLast = index == mockAgreements.length - 1;
          final date = agreement['date'] as DateTime;
          final dateStr = DateFormat('MMM d, yyyy').format(date);
          final version = agreement['version'] as String;
          final type = agreement['type'] as String;
          final institution = agreement['institution'] as String;
          final dateText = type == 'agreed'
              ? 'Akkoord op $dateStr, versie $version'
              : 'Gelezen op $dateStr, versie $version';

          return Column(
            children: [
              InkWell(
                onTap: () {
                  // TODO: Navigate to agreement details
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              institution,
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
                        padding: const EdgeInsets.all(8.0),
                        child: SvgIcon(
                          assetPath: Assets.iconChevron,
                          size: 12,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast) _buildDivider(colorScheme),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildDeleteAccountSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _buildSectionCard(
      context: context,
      title: l10n.deleteAccount,
      children: [
        const SizedBox(height: 16),
        Text(
          l10n.deleteAccountDescription,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // TODO: Implement delete account functionality
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
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
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) {
            if (profile == null) {
              return const Center(child: Text('No profile data'));
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                spacing: 0,
                children: [
                  _buildDataSection(context, profile),
                  _buildNotificationSection(context, profile),
                  _buildAgreementsSection(context),
                  _buildDeleteAccountSection(context),
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
