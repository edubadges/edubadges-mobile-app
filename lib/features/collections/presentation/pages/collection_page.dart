import 'package:edubadges/app/colors.dart';
import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/widgets/adaptive_dialog.dart';
import 'package:edubadges/core/widgets/svg_icon.dart';
import 'package:edubadges/features/collections/data/models/collection_route_model.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CollectionPage extends StatelessWidget {
  final CollectionRouteModel collection;

  const CollectionPage({super.key, required this.collection});

  Widget _buildEmptyState(BuildContext context, double screenWidth) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: SvgIcon(
            assetPath: Assets.iconCollections,
            size: screenWidth / 3,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          l10n.addEdubadgesToCollection,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.addEdubadgesToCollectionDescription,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement add edubadge functionality
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: colorScheme.onPrimary, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    l10n.addEdubadge,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        centerTitle: false,

        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          collection.title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement edit functionality
            },
            icon: SvgIcon(
              assetPath: Assets.iconEdit,
              size: 24,
              color: AppColors.primary,
            ),
          ),
          IconButton(
            onPressed: () {
              AdaptiveDialog.show(
                context: context,
                title: l10n.areYouSure,
                description: l10n.deleteCollectionConfirmation,
                firstButtonText: l10n.cancel,
                secondButtonText: l10n.delete,
                isDestructiveAction: true,
                onFirstButtonPressed: () {
                  context.pop();
                },
                onSecondButtonPressed: () {
                  // TODO: Implement delete functionality
                },
              );
            },
            icon: SvgIcon(
              assetPath: Assets.iconDelete,
              size: 24,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (collection.description != null &&
                  collection.description!.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    collection.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
              Expanded(child: _buildEmptyState(context, screenWidth)),
            ],
          ),
        ),
      ),
    );
  }
}
