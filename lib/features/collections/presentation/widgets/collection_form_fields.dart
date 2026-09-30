import 'package:edubadges/core/widgets/app_text_field.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Name and description fields shared by the create and edit collection forms.
///
/// Must be placed inside a [Form]; the name is required.
class CollectionFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;

  const CollectionFormFields({
    super.key,
    required this.nameController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: l10n.collectionName,
          placeholder: l10n.collectionNamePlaceholder,
          controller: nameController,
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
          controller: descriptionController,
          maxLines: 4,
        ),
      ],
    );
  }
}
