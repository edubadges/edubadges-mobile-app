import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/widgets/base_form_bottom_sheet.dart';
import 'package:edubadges/features/collections/presentation/widgets/collection_form_fields.dart';
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
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();

      Navigator.of(context).pop();

      context.push(
        RoutePath.newCollectionBadgeSelectionPath(
          name: name,
          description: description,
        ),
      );
    }
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BaseFormBottomSheet(
      title: l10n.newCollection,
      description: l10n.newCollectionDescription,
      formKey: _formKey,
      saveButtonText: l10n.save,
      cancelButtonText: l10n.cancel,
      onSave: _handleSave,
      onCancel: _handleCancel,
      formFields: [
        CollectionFormFields(
          nameController: _nameController,
          descriptionController: _descriptionController,
        ),
      ],
    );
  }
}
