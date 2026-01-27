import 'package:edubadges/core/widgets/app_snackbar.dart';
import 'package:edubadges/core/widgets/app_text_field.dart';
import 'package:edubadges/core/widgets/base_form_bottom_sheet.dart';
import 'package:edubadges/features/collections/domain/entities/collections_entity.dart';
import 'package:edubadges/features/collections/presentation/providers/collections_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditCollectionBottomSheet extends ConsumerStatefulWidget {
  final CollectionsEntity collection;

  const EditCollectionBottomSheet({super.key, required this.collection});

  @override
  ConsumerState<EditCollectionBottomSheet> createState() =>
      _EditCollectionBottomSheetState();
}

class _EditCollectionBottomSheetState
    extends ConsumerState<EditCollectionBottomSheet> {
  late final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.collection.name,
  );
  late final _descriptionController = TextEditingController(
    text: widget.collection.description ?? '',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    final success = await ref
        .read(collectionsProvider.notifier)
        .updateCollection(
          widget.collection.entityId,
          name,
          description.isNotEmpty ? description : null,
          widget.collection.public,
          widget.collection.badgeInstanceIds
              .map((id) => int.tryParse(id) ?? -1)
              .where((id) => id != -1)
              .toList(),
        );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen<AsyncValue<List<CollectionsEntity>>>(collectionsProvider, (
      previous,
      next,
    ) {
      next.whenOrNull(
        error: (error, stackTrace) {
          if (mounted) {
            showAppSnackBar(
              context,
              AppLocalizations.of(context)!.somethingWentWrong,
            );
          }
        },
      );
    });

    return BaseFormBottomSheet(
      title: l10n.editCollection,
      description: l10n.editCollectionDescription,
      formKey: _formKey,
      saveButtonText: l10n.save,
      cancelButtonText: l10n.cancel,
      onSave: _handleSave,
      onCancel: _handleCancel,
      formFields: [
        AppTextField(
          label: l10n.collectionName,
          placeholder: l10n.collectionNamePlaceholder,
          controller: _nameController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.collectionNameRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        AppTextField(
          label: l10n.collectionDescription,
          placeholder: l10n.collectionDescriptionPlaceholder,
          controller: _descriptionController,
          maxLines: 4,
        ),
      ],
    );
  }
}
