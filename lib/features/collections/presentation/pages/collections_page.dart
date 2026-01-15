import 'package:edubadges/app/colors.dart';
import 'package:edubadges/features/collections/presentation/widgets/create_collection_bottom_sheet.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});

  void _showCreateCollectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateCollectionBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.tabCollections),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            onPressed: () => _showCreateCollectionBottomSheet(context),
            icon: const Icon(Icons.add, color: AppColors.primary, size: 24),
          ),
        ],
      ),
      body: const SizedBox.shrink(),
    );
  }
}
