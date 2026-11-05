import 'dart:math' as math;

import 'package:edubadges/app/constants.dart';
import 'package:edubadges/app/themes.dart';
import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/constants/heading_level.dart';
import 'package:edubadges/core/constants/layout_constants.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/utils/markdown_sanitizer.dart';
import 'package:edubadges/core/utils/string.dart';
import 'package:edubadges/core/utils/url_safety.dart';
import 'package:edubadges/core/widgets/app_back_button.dart';
import 'package:edubadges/core/widgets/focus_ring_overlay.dart';
import 'package:edubadges/core/widgets/focusable_section.dart';
import 'package:edubadges/core/widgets/info_state_view.dart';
import 'package:edubadges/core/widgets/loading_spinner.dart';
import 'package:edubadges/core/widgets/page_title.dart';
import 'package:edubadges/features/badge_details/data/models/badge_detail_item_model.dart';
import 'package:edubadges/features/badge_details/data/models/badge_details_model.dart';
import 'package:edubadges/features/badge_details/data/models/badge_details_route_model.dart';
import 'package:edubadges/features/badge_details/domain/constants/badge_extensions.dart';
import 'package:edubadges/features/badge_details/domain/entities/badge_details_query.dart';
import 'package:edubadges/features/badge_details/domain/enums/badge_details_scope.dart';
import 'package:edubadges/features/badge_details/presentation/pages/quality_assurance_page.dart';
import 'package:edubadges/features/badge_details/presentation/providers/badge_details_providers.dart';
import 'package:edubadges/features/badge_details/presentation/widgets/badge_visibility_card.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/domain/entities/badge_class_entity.dart';
import 'package:edubadges/shared/domain/entities/badge_evidence_entity.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:edubadges/shared/domain/enums/assessment_type.dart';
import 'package:edubadges/shared/domain/enums/badge_class_type.dart';
import 'package:edubadges/shared/domain/enums/participation_type.dart';
import 'package:edubadges/shared/presentation/widgets/badge_card.dart';
import 'package:edubadges/shared/presentation/widgets/error_widget.dart';
import 'package:edubadges/shared/presentation/widgets/wide_button.dart';
import 'package:flexi_page_view/flexi_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class BadgeDetailsPage extends ConsumerStatefulWidget {
  final BadgeDetailsRouteModel badge;

  const BadgeDetailsPage({super.key, required this.badge});

  @override
  ConsumerState<BadgeDetailsPage> createState() => _BadgeDetailsPageState();
}

class _BadgeDetailsPageState extends ConsumerState<BadgeDetailsPage> {
  static const int _sectionCardSpacing = 16;
  static const double _badgeCardHeight = 260;
  static const int _qualityAssurancePreviewMaxLines = 5;

  final ScrollController _scrollController = ScrollController();
  late PageController _pageController;
  int _currentIndex = 0;
  bool _hasInitializedPage = false;

  bool get _shouldShowCarousel =>
      widget.badge.scope == BadgeDetailsScope.claimed &&
      widget.badge.showClaimedGallery;

  @override
  void initState() {
    super.initState();

    if (_shouldShowCarousel) {
      ref.listenManual(badgesListProvider, (previous, next) {
        if (!_hasInitializedPage && next is AsyncData) {
          final badges = next.value;
          if (badges?.claimedBadges.isNotEmpty ?? false) {
            final initialIndex = badges!.claimedBadges.indexWhere(
              (b) => b.entityId == widget.badge.id,
            );
            setState(() {
              _currentIndex = initialIndex != -1 ? initialIndex : 0;
              _pageController = PageController(
                initialPage: _currentIndex,
                viewportFraction: 0.93,
              );
              _hasInitializedPage = true;
            });
          }
        }
      }, fireImmediately: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (_shouldShowCarousel && _hasInitializedPage) {
      _pageController.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  String? getAssessmentSupervisedStatus(BadgeClassEntity? badgeclass) {
    if (badgeclass == null) return null;
    final l10n = AppLocalizations.of(context);
    final isIdVerified = badgeclass.assessmentIdVerified == true;
    final isSupervised = badgeclass.assessmentSupervised == true;

    return switch ((isIdVerified, isSupervised)) {
      (true, true) => l10n.assessmentSupervisedWithIdentityVerification,
      (true, false) => l10n.assessmentWithIdentityVerification,
      (false, true) => l10n.supervised,
      _ => null,
    };
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePath.catalog);
    }
  }

  Future<void> _refreshBadgeDetails(String badgeId) async {
    final query = BadgeDetailsQuery(
      scope: _shouldShowCarousel
          ? BadgeDetailsScope.claimed
          : widget.badge.scope,
      entityId: badgeId,
    );
    ref.invalidate(badgeDetailsModelProvider(query));
    try {
      // Keep the refresh indicator up until the details are loaded again.
      await ref.read(badgeDetailsModelProvider(query).future);
    } catch (_) {
      // The watched provider renders the failure state.
    }
  }

  EdgeInsets _sectionMargin(bool useSidebarLayout) {
    if (useSidebarLayout) {
      return const EdgeInsets.only(bottom: 16);
    }
    return const EdgeInsets.symmetric(
      horizontal: LayoutConstants.sidebarListLayoutPadding,
      vertical: 8,
    );
  }

  PreferredSizeWidget _buildBackAppBar() {
    return AppBar(leading: AppBackButton(onPressed: _handleBack));
  }

  Widget _buildDesktopBackHeader({String? title}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          AppBackTextButton(onPressed: _handleBack),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title ?? '',
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedDesktopSidebar({
    required BadgeDetailsModel? details,
    BadgeInstanceEntity? carouselBadge,
    BadgeClassModel? carouselBadgeClass,
    Widget? badgePreview,
  }) {
    final badgeClass = details?.badgeClass ?? carouselBadgeClass;
    if (badgeClass == null) {
      return const SizedBox.shrink();
    }

    final badgeInstance = details?.badgeInstance ?? carouselBadge;
    final visibilitySection = badgeInstance != null
        ? BadgeVisibilityCard(
            badge: badgeInstance,
            showCopyLink: badgeInstance.public,
            margin: EdgeInsets.zero,
          )
        : null;

    return FocusableSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (badgePreview != null)
            badgePreview
          else
            BadgeCard(
              instance: badgeInstance,
              badgeClass: badgeClass,
              style: BadgeCardStyle.large,
              onTapDisabled: true,
              badgeRequested: details?.requested ?? false,
              requestedOn: details?.requestedOn,
            ),
          if (visibilitySection != null) ...[
            const SizedBox(height: 16),
            visibilitySection,
          ],
        ],
      ),
    );
  }

  Widget? _buildVisibilitySection(BadgeDetailsModel? details) {
    if (details?.badgeInstance == null) {
      return null;
    }
    return Semantics(
      container: true,
      child: BadgeVisibilityCard(
        badge: details!.badgeInstance!,
        showCopyLink: details.badgeInstance?.public ?? false,
        margin: const EdgeInsets.only(
          left: LayoutConstants.sidebarListLayoutPadding,
          right: LayoutConstants.sidebarListLayoutPadding,
          bottom: 8,
          top: 16,
        ),
      ),
    );
  }

  Widget _buildBadgeSummaryCard({
    required BadgeDetailsModel? details,
    required bool useSidebarLayout,
  }) {
    if (details?.badgeClass == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: useSidebarLayout
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(
              horizontal: LayoutConstants.sidebarListLayoutPadding,
            ),
      child: FocusRingShape.rounded(
        borderRadius: BorderRadius.circular(20),
        child: FocusableSection(
          child: BadgeCard(
            instance: details?.badgeInstance,
            badgeClass: details!.badgeClass,
            style: BadgeCardStyle.large,
            onTapDisabled: true,
            badgeRequested: details.requested,
            requestedOn: details.requestedOn,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMainContentSlivers({required List<Widget> children}) {
    return [
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    ];
  }

  Widget _buildDetailsLayout({
    required bool useSidebarLayout,
    required String badgeId,
    required Widget sidebar,
    required List<Widget> mainContent,
  }) {
    if (!useSidebarLayout) {
      return ListView(
        controller: _scrollController,
        children: [sidebar, ...mainContent],
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(
        left: LayoutConstants.sidebarListLayoutPadding,
        top: LayoutConstants.sidebarListLayoutPadding,
        right: LayoutConstants.sidebarListLayoutPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: LayoutConstants.badgeDetailsSidebarFlex,
            child: SingleChildScrollView(child: sidebar),
          ),
          const SizedBox(width: LayoutConstants.sidebarListLayoutColumnGap),
          Expanded(
            flex: LayoutConstants.badgeDetailsMainFlex,
            child: RefreshIndicator(
              backgroundColor: colorScheme.surfaceContainer,
              onRefresh: () => _refreshBadgeDetails(badgeId),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  ..._buildMainContentSlivers(children: mainContent),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The name of the badge on screen, once it has loaded.
  String? _visibleBadgeName() {
    if (_shouldShowCarousel) {
      final List<BadgeInstanceEntity>? badges = ref
          .watch(badgesListProvider)
          .value
          ?.claimedBadges;
      if (badges == null || _currentIndex >= badges.length) return null;
      return (badges[_currentIndex].badgeclass as BadgeClassModel).name;
    }
    return ref
        .watch(
          badgeDetailsModelProvider(
            BadgeDetailsQuery(
              scope: widget.badge.scope,
              entityId: widget.badge.id,
            ),
          ),
        )
        .value
        ?.badgeClass
        .name;
  }

  @override
  Widget build(BuildContext context) {
    final String? badgeName = _visibleBadgeName();
    return PageTitle(
      title: (AppLocalizations l10n) => badgeName ?? l10n.pageTitleBadgeDetails,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool useSidebarLayout =
              constraints.maxWidth >= LayoutConstants.sidebarListLayoutMinWidth;

          final Widget body = _shouldShowCarousel
              ? _buildCarouselView(useSidebarLayout: useSidebarLayout)
              : _buildSingleBadgeView(useSidebarLayout: useSidebarLayout);

          return Scaffold(
            appBar: useSidebarLayout ? null : _buildBackAppBar(),
            body: body,
          );
        },
      ),
    );
  }

  Widget _buildCarouselView({required bool useSidebarLayout}) {
    final badgesAsync = ref.watch(badgesListProvider);
    final l10n = AppLocalizations.of(context);

    final Widget carouselWidget = badgesAsync.when(
      data: (badges) {
        if (!_hasInitializedPage || badges.claimedBadges.isEmpty) {
          return const SizedBox(
            height: _badgeCardHeight,
            child: Center(child: SizedBox()),
          );
        }

        if (useSidebarLayout) {
          return BadgeCard(
            instance: badges.claimedBadges[_currentIndex],
            badgeClass:
                badges.claimedBadges[_currentIndex].badgeclass
                    as BadgeClassModel,
            style: BadgeCardStyle.large,
            onTapDisabled: true,
          );
        }

        return FlexiPageView.builder(
          controller: _pageController,
          itemCount: badges.claimedBadges.length,
          onPageChanged: _onPageChanged,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ExcludeSemantics(
                excluding: _currentIndex != index,
                child: BadgeCard(
                  instance: badges.claimedBadges[index],
                  badgeClass:
                      badges.claimedBadges[index].badgeclass as BadgeClassModel,
                  style: BadgeCardStyle.large,
                  onTapDisabled: true,
                ),
              ),
            );
          },
        );
      },
      loading: () => const SizedBox(
        height: _badgeCardHeight,
        child: Center(child: LoadingSpinner()),
      ),
      error: (error, stackTrace) => SizedBox(
        height: _badgeCardHeight,
        child: Center(
          child: ErrorMessageWidget(error: error, stackTrace: stackTrace),
        ),
      ),
    );

    final String currentBadgeId = badgesAsync.maybeWhen(
      data: (badges) {
        if (badges.claimedBadges.isEmpty ||
            _currentIndex >= badges.claimedBadges.length) {
          return widget.badge.id;
        }
        return badges.claimedBadges[_currentIndex].entityId;
      },
      orElse: () => widget.badge.id,
    );
    final BadgeInstanceEntity? currentBadge = badgesAsync.maybeWhen(
      data: (badges) {
        if (badges.claimedBadges.isEmpty ||
            _currentIndex >= badges.claimedBadges.length) {
          return null;
        }
        return badges.claimedBadges[_currentIndex];
      },
      orElse: () => null,
    );
    final AsyncValue<BadgeDetailsModel?> currentDetailsAsync = ref.watch(
      badgeDetailsModelProvider(
        BadgeDetailsQuery(
          scope: BadgeDetailsScope.claimed,
          entityId: currentBadgeId,
        ),
      ),
    );

    final List<Widget> detailsWidgets = badgesAsync.when(
      data: (badges) {
        if (badges.claimedBadges.isEmpty ||
            _currentIndex >= badges.claimedBadges.length) {
          return [
            Center(
              child: InfoStateView(
                assetPath: Assets.iconBackpack,
                description: l10n.noEdubadgesYet,
              ),
            ),
          ];
        }

        return _buildBadgeDetailsContent(
          currentBadgeId,
          currentDetailsAsync,
          useSidebarLayout: useSidebarLayout,
        );
      },
      loading: () => [const Center(child: LoadingSpinner())],
      error: (error, stackTrace) => [
        Center(
          child: ErrorMessageWidget(error: error, stackTrace: stackTrace),
        ),
      ],
    );

    if (useSidebarLayout) {
      final String? badgeTitle = currentBadge == null
          ? null
          : (currentBadge.badgeclass as BadgeClassModel).name;
      final List<Widget> desktopMainContent = _buildBadgeDetailsContent(
        currentBadgeId,
        currentDetailsAsync,
        useSidebarLayout: true,
      );

      return SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDesktopBackHeader(title: badgeTitle),
            Expanded(
              child: _buildDetailsLayout(
                useSidebarLayout: true,
                badgeId: currentBadgeId,
                sidebar: _buildCombinedDesktopSidebar(
                  details: currentDetailsAsync.value,
                  carouselBadge: currentBadge,
                  carouselBadgeClass:
                      currentBadge?.badgeclass as BadgeClassModel?,
                  badgePreview: carouselWidget,
                ),
                mainContent: desktopMainContent,
              ),
            ),
          ],
        ),
      );
    }

    final BadgeInstanceEntity? visibilityBadge =
        currentDetailsAsync.value?.badgeInstance ?? currentBadge;
    final Widget? mobileVisibilityWidget = visibilityBadge == null
        ? null
        : BadgeVisibilityCard(
            badge: visibilityBadge,
            showCopyLink: visibilityBadge.public,
          );

    return ListView(
      controller: _scrollController,
      children: [carouselWidget, ?mobileVisibilityWidget, ...detailsWidgets],
    );
  }

  Widget _buildSingleBadgeView({required bool useSidebarLayout}) {
    final badgeDetailsAsync = ref.watch(
      badgeDetailsModelProvider(
        BadgeDetailsQuery(scope: widget.badge.scope, entityId: widget.badge.id),
      ),
    );

    final List<Widget> mainContent = _buildBadgeDetailsContent(
      widget.badge.id,
      badgeDetailsAsync,
      useSidebarLayout: useSidebarLayout,
    );

    final visibilitySection = _buildVisibilitySection(badgeDetailsAsync.value);
    final Widget sidebar = useSidebarLayout
        ? _buildCombinedDesktopSidebar(details: badgeDetailsAsync.value)
        : Column(
            children: [
              _buildBadgeSummaryCard(
                details: badgeDetailsAsync.value,
                useSidebarLayout: false,
              ),
              ?visibilitySection,
            ],
          );

    if (useSidebarLayout) {
      return SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDesktopBackHeader(
              title: badgeDetailsAsync.value?.badgeClass.name,
            ),
            Expanded(
              child: _buildDetailsLayout(
                useSidebarLayout: true,
                badgeId: widget.badge.id,
                sidebar: sidebar,
                mainContent: mainContent,
              ),
            ),
          ],
        ),
      );
    }

    return _buildDetailsLayout(
      useSidebarLayout: false,
      badgeId: widget.badge.id,
      sidebar: sidebar,
      mainContent: mainContent,
    );
  }

  List<Widget> _buildBadgeDetailsContent(
    String badgeId,
    AsyncValue<BadgeDetailsModel?>? badgeDetailsAsync, {
    required bool useSidebarLayout,
  }) {
    final AsyncValue<BadgeDetailsModel?> badgeDetailsValue =
        badgeDetailsAsync ??
        ref.watch(
          badgeDetailsModelProvider(
            BadgeDetailsQuery(
              scope: BadgeDetailsScope.claimed,
              entityId: badgeId,
            ),
          ),
        );

    return badgeDetailsValue.when(
      data: (details) => [
        ..._buildBadgeDetails(
          details,
          badgeId: badgeId,
          useSidebarLayout: useSidebarLayout,
        ),
      ],
      loading: () => [const Center(child: LoadingSpinner())],
      error: (error, stackTrace) => [
        Center(
          child: ErrorMessageWidget(error: error, stackTrace: stackTrace),
        ),
      ],
    );
  }

  List<Widget> _buildBadgeDetails(
    BadgeDetailsModel? details, {
    required String badgeId,
    required bool useSidebarLayout,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final learningOutcome = details?.badgeClass.getExtensionValue<String?>(
      BadgeExtensionKeys.learningOutcome,
    );
    final eCTS = details?.badgeClass.getExtensionValue<double?>(
      BadgeExtensionKeys.ects,
    );
    final language = languageCodeToString(
      details?.badgeClass.getExtensionValue<String?>(
        BadgeExtensionKeys.language,
      ),
      context,
    );
    final supervisedStatus = getAssessmentSupervisedStatus(details?.badgeClass);
    final assessmentType = details?.badgeClass.assessmentType;
    final participation = details?.badgeClass.participation;
    final stackable = details?.badgeClass.stackable;
    final eQF = details?.badgeClass.getExtensionValue<double?>(
      BadgeExtensionKeys.eQF,
    );
    final isEqfNlqfLevelVerified =
        details?.badgeClass.eqfNlqfLevelVerified == true;
    final criteriaText = details?.badgeClass.criteriaText;
    final badgeClass = details?.badgeClass;
    final qualityAssuranceText = details != null
        ? _composeQualityAssurance(details.badgeClass)
        : null;

    return [
      if (details?.badgeClass.description != null)
        _buildSectionCard(
          title: l10n.aboutThisEdubadge,
          margin: _sectionMargin(useSidebarLayout),
          item: MarkdownBody(
            data: sanitizeMarkdown(details!.badgeClass.description!),
            styleSheet: AppThemes.markdownStyleSheet(context),
          ),
        ),
      if (learningOutcome != null)
        _buildSectionCard(
          title: l10n.learningOutcomes,
          margin: _sectionMargin(useSidebarLayout),
          item: MarkdownBody(
            data: sanitizeMarkdown(learningOutcome),
            styleSheet: AppThemes.markdownStyleSheet(context),
          ),
        ),
      if (criteriaText != null)
        _buildSectionCard(
          title: l10n.badgeCriteria,
          margin: _sectionMargin(useSidebarLayout),
          item: MarkdownBody(
            data: sanitizeMarkdown(criteriaText),
            styleSheet: AppThemes.markdownStyleSheet(context),
          ),
        ),
      if (badgeClass != null && qualityAssuranceText != null)
        _buildSectionCard(
          title: l10n.qualityAssurance,
          margin: _sectionMargin(useSidebarLayout),
          action: badgeClass.qualityAssuranceUrl != null
              ? IconButton(
                  onPressed: () {
                    launchExternalUrl(badgeClass.qualityAssuranceUrl!);
                  },
                  icon: Icon(Icons.launch, color: colorScheme.onSurface),
                  tooltip: l10n.semanticsOpenQualityAssurance,
                )
              : null,
          item: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ClampedMarkdownPreview(
                maxLines: _qualityAssurancePreviewMaxLines,
                child: MarkdownBody(
                  data: sanitizeMarkdown(qualityAssuranceText),
                  styleSheet: AppThemes.markdownStyleSheet(context),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: WideButton(
                  onTap: () {
                    if (useSidebarLayout) {
                      showDialog<void>(
                        context: context,
                        builder: (context) {
                          final size = MediaQuery.sizeOf(context);
                          final double width = math.min(
                            600.0,
                            size.width * 0.85,
                          );
                          final double preferredHeight = width * 16 / 9;
                          final double height = math.min(
                            preferredHeight,
                            size.height,
                          );
                          return Dialog(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: SizedBox(
                              width: width,
                              height: height,
                              child: QualityAssurancePage(
                                badgeId: badgeId,
                                scope: widget.badge.scope,
                                isDialog: true,
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      final path = RoutePath.badgeQualityAssurancePath(
                        scope: widget.badge.scope,
                        id: badgeId,
                      );
                      context.push(path);
                    }
                  },
                  icon: null,
                  text: l10n.readMore,
                  secondary: true,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      if (details?.badgeInstance?.evidences?.isNotEmpty == true)
        _buildSectionCard(
          title: l10n.badgeEvidenceMetadataTitle,
          margin: _sectionMargin(useSidebarLayout),
          item: _buildEvidenceMetadata(
            evidences: details!.badgeInstance!.evidences!,
            textTheme: textTheme,
            colorScheme: colorScheme,
            l10n: l10n,
          ),
        ),
      if (details?.badgeInstance != null)
        _buildSectionCard(
          title: l10n.theEdubadge,
          margin: _sectionMargin(useSidebarLayout),
          // The issue date sits on the badge card next to its visibility
          // lock, so this section only adds the expiry.
          items: [
            BadgeDetailItemModel(
              icon: Assets.iconBadgeExpireDate,
              title: l10n.expiresOn,
              subtitle: details!.badgeInstance!.expiresAt == null
                  ? l10n.never
                  : DateFormat(
                      AppConstants.mediumDateFormat,
                      l10n.localeName,
                    ).format(details.badgeInstance!.expiresAt!),
            ),
          ],
        ),
      _buildSectionCard(
        title: l10n.badgeTheProgram,
        margin: _sectionMargin(useSidebarLayout),
        items: [
          if (details != null)
            BadgeDetailItemModel(
              icon: Assets.iconType,
              title: l10n.type,
              subtitle: details.badgeClass.badgeClassType.getLocalizedName(
                l10n,
              ),
            ),
          if (eCTS != null)
            BadgeDetailItemModel(
              icon: Assets.iconTimeInvestment,
              title: l10n.studyLoad,
              subtitle: '$eCTS ECTS/EC',
            ),
          if (language != null)
            BadgeDetailItemModel(
              icon: Assets.iconLanguage,
              title: l10n.language,
              subtitle: language,
            ),
          if (eQF != null && isEqfNlqfLevelVerified)
            BadgeDetailItemModel(
              icon: Assets.iconIndicatif,
              title: l10n.indicativeLevel,
              subtitle: 'EQF $eQF',
            ),
          if (participation != null && participation.isNotEmpty)
            BadgeDetailItemModel(
              icon: Assets.iconBadgeFormParticipation,
              title: l10n.formOfParticipation,
              subtitle: participation
                  .map((p) => p.getLocalizedName(l10n))
                  .join(', '),
            ),
          if (stackable != null)
            BadgeDetailItemModel(
              icon: Assets.iconDocumentShield,
              title: l10n.stackable,
              subtitle: stackable == true
                  ? l10n.stackableTrue
                  : l10n.stackableFalse,
            ),
        ],
      ),
      if (assessmentType != null || supervisedStatus != null)
        _buildSectionCard(
          title: l10n.badgeTheAssessment,
          margin: _sectionMargin(useSidebarLayout),
          items: [
            if (assessmentType != null && assessmentType.isNotEmpty)
              BadgeDetailItemModel(
                icon: Assets.iconBadgeIndicatief,
                title: l10n.assessmentType,
                subtitle: assessmentType
                    .map((a) => a.getLocalizedName(l10n))
                    .join(', '),
              ),
            if (supervisedStatus != null)
              BadgeDetailItemModel(
                icon: Assets.iconBadgeUnderReview,
                subtitle: supervisedStatus,
              ),
          ],
        ),
      SizedBox(height: useSidebarLayout ? 16 : 70),
    ];
  }

  String? _composeQualityAssurance(BadgeClassEntity bc) {
    final name = bc.qualityAssuranceName;
    final desc = bc.qualityAssuranceDescription;

    final String? header;
    if (name != null && name.isNotEmpty) {
      header = name;
    } else {
      header = null;
    }

    final parts = <String>[?header, if (desc != null && desc.isNotEmpty) desc];
    if (parts.isEmpty) return null;
    return parts.join('\n\n');
  }

  Widget _buildEvidenceMetadata({
    required List<BadgeEvidenceEntity> evidences,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
    required AppLocalizations l10n,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(evidences.length * 2 - 1, (int index) {
        if (index.isOdd) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          );
        }

        return _buildEvidenceItem(
          entity: evidences[index ~/ 2],
          textTheme: textTheme,
          colorScheme: colorScheme,
          l10n: l10n,
        );
      }),
    );
  }

  Widget _buildEvidenceItem({
    required BadgeEvidenceEntity entity,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
    required AppLocalizations l10n,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        if (entity.narrative != null)
          _buildEvidenceTextField(
            label: l10n.badgeEvidencePersonalMessage,
            value: entity.narrative!,
            textTheme: textTheme,
          ),
        if (entity.evidenceUrl != null)
          _buildEvidenceLinkField(
            label: l10n.badgeEvidenceUrl,
            url: entity.evidenceUrl!,
            textTheme: textTheme,
            colorScheme: colorScheme,
          ),
        if (entity.name != null)
          _buildEvidenceTextField(
            label: l10n.badgeEvidenceName,
            value: entity.name!,
            textTheme: textTheme,
          ),
        if (entity.description != null)
          _buildEvidenceTextField(
            label: l10n.badgeEvidenceDescription,
            value: entity.description!,
            textTheme: textTheme,
          ),
      ],
    );
  }

  Widget _buildEvidenceTextField({
    required String label,
    required String value,
    required TextTheme textTheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: textTheme.titleSmall),
        Text(value, style: textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildEvidenceLinkField({
    required String label,
    required String url,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: textTheme.titleSmall),
        InkWell(
          onTap: () {
            launchExternalUrl(url);
          },
          child: Text(
            url,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              decoration: TextDecoration.underline,
              decorationColor: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    List<BadgeDetailItemModel>? items,
    Widget? item,
    Widget? action,
    EdgeInsetsGeometry? margin,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Focusable inside its margin, so the focus ring hugs the card rather
    // than the gap around it.
    return Padding(
      padding:
          margin ??
          const EdgeInsets.symmetric(
            horizontal: LayoutConstants.sidebarListLayoutPadding,
            vertical: _sectionCardSpacing / 2,
          ),
      child: FocusRingShape.rounded(
        borderRadius: BorderRadius.circular(20),
        child: FocusableSection(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.outlineVariant),
              color: colorScheme.surfaceContainer,
            ),
            padding: action != null
                ? const EdgeInsets.only(left: 16, bottom: 16, top: 6, right: 6)
                : const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      // Its own node: inside a FocusableSection a plain header
                      // merges into the section and makes the whole body the heading.
                      child: Semantics(
                        header: true,
                        headingLevel: HeadingLevel.section,
                        container: true,
                        child: Text(
                          title,
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    ?action,
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: action != null
                      ? const EdgeInsets.only(right: 16)
                      : EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ?item,
                      if (items != null && items.isNotEmpty)
                        ...List.generate(items.length * 2 - 1, (int index) {
                          if (index.isOdd) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1),
                            );
                          } else {
                            return _buildSectionItem(item: items[index ~/ 2]);
                          }
                        }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionItem({required BadgeDetailItemModel item}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      spacing: 16,
      children: [
        ExcludeSemantics(
          child: SvgPicture.asset(
            item.icon,
            height: 24,
            width: 24,
            colorFilter: ColorFilter.mode(
              colorScheme.onPrimaryContainer,
              BlendMode.srcIn,
            ),
          ),
        ),
        Expanded(
          child: MergeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.title != null)
                  Text(
                    item.title!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                Text(
                  item.subtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ClampedMarkdownPreview extends StatelessWidget {
  final Widget child;
  final int maxLines;

  const _ClampedMarkdownPreview({required this.child, required this.maxLines});

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;
    final lineHeight = (bodyStyle?.fontSize ?? 14) * (bodyStyle?.height ?? 1.4);
    final maxHeight = lineHeight * maxLines;

    return ClipRect(
      child: SizedBox(
        width: double.infinity,
        height: maxHeight,
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minHeight: 0,
          maxHeight: double.infinity,
          child: child,
        ),
      ),
    );
  }
}
