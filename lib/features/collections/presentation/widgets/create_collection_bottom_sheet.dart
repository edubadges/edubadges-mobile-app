import 'package:edubadges/core/widgets/app_text_field.dart';
import 'package:edubadges/core/widgets/primary_button.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

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
      // TODO: Add backend integration here
      Navigator.of(context).pop();
    }
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 16.0, 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 32),
                    decoration: BoxDecoration(
                      color: colorScheme.outline,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                // Title
                Center(
                  child: Text(
                    l10n.newCollection,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                // Description
                Center(
                  child: Text(
                    l10n.newCollectionDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 22),
                // Name field
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
                // Description field
                AppTextField(
                  label: l10n.collectionDescription,
                  placeholder: l10n.collectionDescriptionPlaceholder,
                  controller: _descriptionController,
                  maxLines: 4,
                ),
                const SizedBox(height: 32),
                // Save button
                PrimaryButton(text: l10n.save, onPressed: _handleSave),
                const SizedBox(height: 8),
                // Cancel button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _handleCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
