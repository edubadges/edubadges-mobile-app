import 'package:edubadges/core/utils/platform_info.dart';
import 'package:edubadges/core/widgets/app_modal.dart';
import 'package:edubadges/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class BaseFormBottomSheet extends StatelessWidget {
  final String title;
  final String description;
  final GlobalKey<FormState> formKey;
  final List<Widget> formFields;
  final VoidCallback onSave;
  final VoidCallback? onCancel;
  final String saveButtonText;
  final String cancelButtonText;
  final bool handleKeyboardPadding;

  /// When null, uses [AppFormModalPresentation] from [showAppFormModal], then
  /// falls back to [PlatformInfo.isWeb] to preserve historical behavior.
  final bool? isDialog;

  const BaseFormBottomSheet({
    super.key,
    required this.title,
    required this.description,
    required this.formKey,
    required this.formFields,
    required this.onSave,
    required this.saveButtonText,
    required this.cancelButtonText,
    this.onCancel,
    this.handleKeyboardPadding = true,
    this.isDialog,
  });

  void _handleSave() {
    if (formKey.currentState!.validate()) {
      onSave();
    }
  }

  void _handleCancel() {
    onCancel?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool isDialog = this.isDialog ??
        AppFormModalPresentation.maybeOf(context) ??
        PlatformInfo.isWeb;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: isDialog
            ? BorderRadius.circular(28)
            : const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20.0,
            20.0,
            16.0,
            handleKeyboardPadding
                ? MediaQuery.of(context).viewInsets.bottom + 20
                : 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isDialog)
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
                  Center(
                    // Names the dialog for screen readers, and is its heading.
                    child: Semantics(
                      header: true,
                      namesRoute: true,
                      child: Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 22),
                  ...formFields,
                  const SizedBox(height: 32),
                  PrimaryButton(text: saveButtonText, onPressed: _handleSave),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _handleCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: colorScheme.primary),
                      ),
                      child: Text(
                        cancelButtonText,
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
      ),
    );
  }
}
