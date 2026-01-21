import 'package:edubadges/core/widgets/app_text_field.dart';
import 'package:edubadges/core/widgets/base_form_bottom_sheet.dart';
import 'package:edubadges/features/collections/data/models/collection_route_model.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateCollectionBottomSheet extends StatefulWidget {
  const CreateCollectionBottomSheet({super.key});

  @override
  State<CreateCollectionBottomSheet> createState() =>
      _CreateCollectionBottomSheetState();
}

class _CreateCollectionBottomSheetState
    extends State<CreateCollectionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final title = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    final id = DateTime.now().millisecondsSinceEpoch.toString();

    Navigator.of(context).pop();

    final collection = CollectionRouteModel(
      id: id,
      title: title,
      description: description.isNotEmpty ? description : null,
    );

    context.push(collection.buildRouteUrl());
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BaseFormBottomSheet(
      title: l10n.newCollection,
      description: l10n.newCollectionDescription,
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
