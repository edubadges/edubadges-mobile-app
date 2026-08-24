import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/core/utils/logger.dart';
import 'package:edubadges/core/utils/platform_info.dart';
import 'package:edubadges/core/widgets/app_text_field.dart';
import 'package:edubadges/core/widgets/base_form_bottom_sheet.dart';
import 'package:edubadges/flavors.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackBottomSheet extends ConsumerStatefulWidget {
  const FeedbackBottomSheet({super.key});

  @override
  ConsumerState<FeedbackBottomSheet> createState() =>
      _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends ConsumerState<FeedbackBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final appLanguage = ref.read(appLanguageProvider);
    final navigator = Navigator.of(context);

    final packageInfo = await PackageInfo.fromPlatform();
    final platform = PlatformInfo.platformDisplayName;
    final version = '${packageInfo.version} (${packageInfo.buildNumber})';
    final language = appLanguage.displayName;

    final isProduction = F.appFlavor == Flavor.prod;
    final subject = isProduction
        ? 'Feedback Edubadge app'
        : 'Feedback Edubadge app (${F.name})';

    final body = '''${_feedbackController.text.trim()}

---
App versie: $version
Taal: $language
Platform: $platform''';

    final uri = Uri.parse(
      'mailto:support@edubadges.nl?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    try {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (e) {
      logger.e('Error launching email client: $e');
    }

    navigator.pop();
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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