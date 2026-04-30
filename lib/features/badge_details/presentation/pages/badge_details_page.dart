import 'package:edubadges/app/constants.dart';
import 'package:edubadges/app/themes.dart';
import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/utils/string.dart';
import 'package:edubadges/core/widgets/focusable_section.dart';
import 'package:edubadges/core/widgets/info_state_view.dart';
import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:edubadges/features/badge_details/data/models/badge_detail_item_model.dart';
import 'package:edubadges/features/badge_details/data/models/badge_details_model.dart';
import 'package:edubadges/features/badge_details/data/models/badge_details_route_model.dart';
import 'package:edubadges/features/badge_details/domain/constants/badge_extensions.dart';
import 'package:edubadges/features/badge_details/domain/entities/badge_details_query.dart';
import 'package:edubadges/features/badge_details/domain/enums/badge_details_scope.dart';
import 'package:edubadges/features/badge_details/presentation/providers/badge_details_providers.dart';
import 'package:edubadges/features/badge_details/presentation/widgets/badge_visibility_card.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/domain/entities/badge_class_entity.dart';
import 'package:edubadges/shared/domain/enums/assessment_type.dart';
import 'package:edubadges/shared/domain/enums/badge_class_type.dart';
import 'package:edubadges/shared/domain/enums/participation_type.dart';
import 'package:edubadges/shared/presentation/widgets/badge_card.dart';
import 'package:edubadges/shared/presentation/widgets/error_widget.dart';
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

  @override
  Widget build(BuildContext context) {
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
          tooltip: AppLocalizations.of(context).semanticsBack,
        ),
      ),
      body: MaxWidthWrapper(
        child: _shouldShowCarousel
            ? _buildCarouselView()
            : _buildSingleBadgeView(),
      ),
    );
  }

  Widget _buildCarouselView() {
    final badgesAsync = ref.watch(badgesListProvider);
    final l10n = AppLocalizations.of(context);

    return ListView(
      children: [
        badgesAsync.when(
          data: (badges) {
            if (!_hasInitializedPage || badges.claimedBadges.isEmpty) {
              return const SizedBox(
                height: _badgeCardHeight,
                child: Center(child: SizedBox()),
              );
            }

            return FlexiPageView.builder(
              controller: _pageController,
              itemCount: badges.claimedBadges.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  child: ExcludeSemantics(
                    excluding: _currentIndex != index,
                    child: BadgeCard(
                      instance: badges.claimedBadges[index],
                      badgeClass:
                          badges.claimedBadges[index].badgeclass
                              as BadgeClassModel,
                      style: BadgeCardStyle.large,
                      onTapDisabled: true,
                    ),
                  ),
                );
              },
            );
          },
          loading: () => SizedBox(
            height: _badgeCardHeight,
            child: Center(
              child: CircularProgressIndicator(
                semanticsLabel: AppLocalizations.of(context).semanticsLoading,
              ),
            ),
          ),
          error: (error, _) => const SizedBox(
            height: _badgeCardHeight,
            child: Center(child: ErrorMessageWidget()),
          ),
        ),

        ...badgesAsync.when(
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

            final currentBadgeId = badges.claimedBadges[_currentIndex].entityId;
            return _buildBadgeDetailsContent(currentBadgeId, null);
          },
          loading: () => [
            Center(
              child: CircularProgressIndicator(
                semanticsLabel: AppLocalizations.of(context).semanticsLoading,
              ),
            ),
          ],
          error: (error, _) => [const Center(child: ErrorMessageWidget())],
        ),
      ],
    );
  }

  Widget _buildSingleBadgeView() {
    final badgeDetailsAsync = ref.watch(
      badgeDetailsModelProvider(
        BadgeDetailsQuery(
          scope: widget.badge.scope,
          entityId: widget.badge.id,
        ),
      ),
    );

    return ListView(
      children: [
        if (badgeDetailsAsync.value?.badgeClass != null)
          FocusableSection(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: BadgeCard(
                  instance: badgeDetailsAsync.value?.badgeInstance,
                  badgeClass: badgeDetailsAsync.value!.badgeClass,
                  style: BadgeCardStyle.large,
                  onTapDisabled: true,
                  badgeRequested: badgeDetailsAsync.value!.requested,
                ),
              ),
            ),
          ),

        ..._buildBadgeDetailsContent(widget.badge.id, badgeDetailsAsync),
      ],
    );
  }

  List<Widget> _buildBadgeDetailsContent(
    String badgeId,
    AsyncValue<BadgeDetailsModel?>? badgeDetailsAsync,
  ) {
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
      data: (details) => [..._buildBadgeDetails(details)],
      loading: () => [
        Center(
          child: CircularProgressIndicator(
            semanticsLabel: AppLocalizations.of(context).semanticsLoading,
          ),
        ),
      ],
      error: (error, _) => [const Center(child: ErrorMessageWidget())],
    );
  }

  List<Widget> _buildBadgeDetails(BadgeDetailsModel? details) {
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

    return [
      if (details?.badgeInstance != null)
        Semantics(
          container: true,
          child: BadgeVisibilityCard(
            badge: details!.badgeInstance!,
            showCopyLink: details.badgeInstance?.public ?? false,
          ),
        ),
      if (details?.badgeClass.description != null)
        FocusableSection(
          child: _buildSectionCard(
            title: l10n.aboutThisEdubadge,
            item: MarkdownBody(
              data: filterBadMarkdown(details!.badgeClass.description!),
              styleSheet: AppThemes.markdownStyleSheet(context),
            ),
          ),
        ),
      if (learningOutcome != null)
        FocusableSection(
          child: _buildSectionCard(
            title: l10n.learningOutcomes,
            item: MarkdownBody(
              data: filterBadMarkdown(learningOutcome),
              styleSheet: AppThemes.markdownStyleSheet(context),
            ),
          ),
        ),
      if (details?.badgeInstance != null)
        FocusableSection(
          child: _buildSectionCard(
            title: l10n.theEdubadge,
            items: [
              if (details!.badgeInstance!.issuedOn != null)
                BadgeDetailItemModel(
                  icon: Assets.iconUnlockedAlternate,
                  title: l10n.issuedOn,
                  subtitle: DateFormat(
                    AppConstants.mediumDateFormat,
                    l10n.localeName,
                  ).format(details.badgeInstance!.issuedOn!),
                ),
              BadgeDetailItemModel(
                icon: Assets.iconBadgeExpireDate,
                title: l10n.expiresOn,
                subtitle: details.badgeInstance!.expiresAt == null
                    ? l10n.never
                    : DateFormat(
                        AppConstants.mediumDateFormat,
                        l10n.localeName,
                      ).format(details.badgeInstance!.expiresAt!),
              ),
            ],
          ),
        ),
      FocusableSection(
        child: _buildSectionCard(
          title: l10n.badgeTheProgram,
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
            if (eQF != null)
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
      ),
      if (assessmentType != null || supervisedStatus != null)
        FocusableSection(
          child: _buildSectionCard(
            title: l10n.badgeTheAssessment,
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
        ),
    ];
  }

  Widget _buildSectionCard({
    required String title,
    List<BadgeDetailItemModel>? items,
    Widget? item,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
        color: colorScheme.surfaceContainer,
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: _sectionCardSpacing / 2,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          if (item != null) item,
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
