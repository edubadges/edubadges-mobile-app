import 'package:edubadges/app/themes.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/utils/string.dart';
import 'package:edubadges/core/widgets/focusable_section.dart';
import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:edubadges/features/badge_details/domain/entities/badge_details_query.dart';
import 'package:edubadges/features/badge_details/domain/enums/badge_details_scope.dart';
import 'package:edubadges/features/badge_details/presentation/providers/badge_details_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/domain/entities/badge_class_entity.dart';
import 'package:edubadges/shared/presentation/widgets/error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

class QualityAssurancePage extends ConsumerStatefulWidget {
  final String badgeId;
  final BadgeDetailsScope scope;

  const QualityAssurancePage({
    super.key,
    required this.badgeId,
    required this.scope,
  });

  @override
  ConsumerState<QualityAssurancePage> createState() =>
      _QualityAssurancePageState();
}

class _QualityAssurancePageState extends ConsumerState<QualityAssurancePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String? _composeQualityAssurance(BadgeClassEntity bc) {
    final name = bc.qualityAssuranceName;
    final desc = bc.qualityAssuranceDescription;

    final parts = <String>[
      if (name != null && name.isNotEmpty) name,
      if (desc != null && desc.isNotEmpty) desc,
    ];
    if (parts.isEmpty) return null;
    return parts.join('\n\n');
  }

  static Future<void> _launchExternalUrl(String url) => launchUrlString(
        url,
        mode: LaunchMode.externalApplication,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final badgeDetailsAsync = ref.watch(
      badgeDetailsModelProvider(
        BadgeDetailsQuery(scope: widget.scope, entityId: widget.badgeId),
      ),
    );
    final qualityAssuranceUrl =
        badgeDetailsAsync.asData?.value?.badgeClass.qualityAssuranceUrl;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RoutePath.catalog);
            }
          },
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(l10n.qualityAssurance),
        backgroundColor: colorScheme.surfaceContainer,
        surfaceTintColor: colorScheme.surfaceContainer,
        actions: [
          if (qualityAssuranceUrl != null && qualityAssuranceUrl.isNotEmpty)
            IconButton(
              onPressed: () => _launchExternalUrl(qualityAssuranceUrl),
              icon: Icon(Icons.launch, color: colorScheme.onSurface),
            ),
        ],
      ),
      backgroundColor: colorScheme.surfaceContainer,
      body: MaxWidthWrapper(
        scrollController: _scrollController,
        child: badgeDetailsAsync.when(
          data: (details) {
            final badgeClass = details?.badgeClass;
            final qualityAssurance = badgeClass != null
                ? _composeQualityAssurance(badgeClass)
                : null;
            final content = qualityAssurance?.trim() ?? '';

            if (content.isEmpty) {
              return const Center(child: ErrorMessageWidget());
            }

            return SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: FocusableSection(
                child: MarkdownBody(
                  data: filterBadMarkdown(content),
                  styleSheet: AppThemes.markdownStyleSheet(context),
                  onTapLink: (text, href, title) {
                    if (href == null) return;
                    _launchExternalUrl(href);
                  },
                ),
              ),
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(
              semanticsLabel: l10n.semanticsLoading,
            ),
          ),
          error: (error, stack) => const Center(child: ErrorMessageWidget()),
        ),
      ),
    );
  }
}
