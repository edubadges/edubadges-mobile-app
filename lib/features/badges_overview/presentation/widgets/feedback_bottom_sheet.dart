import 'package:edubadges/core/widgets/app_text_field.dart';
import 'package:edubadges/core/widgets/base_form_bottom_sheet.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class FeedbackBottomSheet extends StatefulWidget {
  const FeedbackBottomSheet({super.key});

  @override
  State<FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends State<FeedbackBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      // TODO: Send feedback to backend
      Navigator.of(context).pop();
    }
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BaseFormBottomSheet(
      title: l10n.giveFeedback,
      description: l10n.giveFeedbackDescription,
      formKey: _formKey,
      saveButtonText: l10n.confirm,
      cancelButtonText: l10n.cancel,
      onSave: _handleSave,
      onCancel: _handleCancel,
      formFields: [
        AppTextField(
          label: l10n.feedback,
          placeholder: l10n.feedbackPlaceholder,
          controller: _feedbackController,
          maxLines: 6,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.feedbackRequired;
            }
            return null;
          },
        ),
      ],
    );
  }
}
