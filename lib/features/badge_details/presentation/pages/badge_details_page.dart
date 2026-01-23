import 'package:edubadges/app/constants.dart';
import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/utils/string.dart';
import 'package:edubadges/features/badge_details/data/models/badge_detail_item_model.dart';
import 'package:edubadges/features/badge_details/data/models/badge_details_route_model.dart';
import 'package:edubadges/features/badge_details/domain/constants/badge_extensions.dart';
import 'package:edubadges/features/badge_details/domain/enums/badge_details_route_from.dart';
import 'package:edubadges/features/badge_details/domain/extensions/badge_instance_extensions.dart';
import 'package:edubadges/features/badge_details/presentation/providers/badge_details_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';
import 'package:edubadges/shared/domain/enums/assessment_type.dart';
import 'package:edubadges/shared/domain/enums/participation_type.dart';
import 'package:edubadges/shared/presentation/widgets/badge_card.dart';
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
  _BadgeDetailsPageState createState() => _BadgeDetailsPageState();
}

class _BadgeDetailsPageState extends ConsumerState<BadgeDetailsPage> {
  static const int _sectionCardSpacing = 16;
  static const double _badgeCardHeight = 260;

  late PageController _pageController;
  int _currentIndex = 0;
  bool _hasInitializedPage = false;

  bool get _shouldShowCarousel =>
      widget.badge.from == BadgeDetailsRouteFrom.overview;

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
    if (_shouldShowCarousel) {
      _pageController.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  String? getAssessmentSupervisedStatus(BadgeInstanceModel? details) {
    final l10n = AppLocalizations.of(context)!;
    final badgeclass = details?.badgeclass;
    final isIdVerified = badgeclass?.assessmentIdVerified == true;
    final isSupervised = badgeclass?.assessmentSupervised == true;

    return switch ((isIdVerified, isSupervised)) {
      (true, true) => l10n.assessmentSupervisedWithIdentityVerification,
      (true, false) => l10n.assessmentWithIdentityVerification,
      (false, true) => l10n.supervised,
      _ => null,
    };
  }

  MarkdownStyleSheet _buildMarkdownStyleSheet() {
    // TODO: Setup markdown styling (https://digitalclub.atlassian.net/browse/SURF-540)
    // final colorScheme = Theme.of(context).colorScheme;
    return MarkdownStyleSheet(
      // TODO: Figure out design with design team what block quotes should look like
      // blockquoteDecoration: BoxDecoration(
      //   color: colorScheme.surfaceContainerLowest,
      //   borderRadius: BorderRadius.circular(12),
      // ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: _shouldShowCarousel
          ? _buildCarouselView()
          : _buildSingleBadgeView(),
    );
  }

  Widget _buildCarouselView() {
    final badgesAsync = ref.watch(badgesListProvider);

    return ListView(
      children: [
        SizedBox(
          height: _badgeCardHeight,
          child: badgesAsync.when(
            data: (badges) {
              if (!_hasInitializedPage || badges.claimedBadges.isEmpty) {
                return const Center(child: SizedBox());
              }

              return PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: badges.claimedBadges.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: BadgeCard(
                      instance: badges.claimedBadges[index],
                      style: BadgeCardStyle.large,
                    ),
                  );
                },
              );
            },
            //TODO: Add loading indicator
            loading: () => const Center(child: SizedBox()),
            //TODO: Add error indicator
            error: (error, _) => Center(child: SizedBox()),
          ),
        ),

        ...badgesAsync.when(
          data: (badges) {
            if (badges.claimedBadges.isEmpty ||
                _currentIndex >= badges.claimedBadges.length) {
              return [const Center(child: Text('No badge'))];
            }

            final currentBadgeId = badges.claimedBadges[_currentIndex].entityId;
            return _buildBadgeDetailsContent(currentBadgeId);
          },
          //TODO: Add loading indicator
          loading: () => [const Center(child: SizedBox())],
          //TODO: Add error indicator
          error: (error, _) => [Center(child: SizedBox())],
        ),
      ],
    );
  }

  Widget _buildSingleBadgeView() {
    final badge = ref.watch(badgeByIdProvider(widget.badge.id));

    return ListView(
      children: [
        // TODO: Add error message
        if (badge != null)
          Container(
            height: _badgeCardHeight,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: BadgeCard(instance: badge, style: BadgeCardStyle.large),
            ),
          ),

        ..._buildBadgeDetailsContent(widget.badge.id),
      ],
    );
  }

  List<Widget> _buildBadgeDetailsContent(String badgeId) {
    final badgeDetailsAsync = ref.watch(badgeDetailsProvider(badgeId));

    return badgeDetailsAsync.when(
      data: (details) => [..._buildBadgeDetails(details)],
      //TODO: Add loading indicator
      loading: () => [const Center(child: SizedBox())],
      //TODO: Add error indicator
      error: (error, _) => [Center(child: SizedBox())],
    );
  }

  List<Widget> _buildBadgeDetails(BadgeInstanceModel? details) {
    final l10n = AppLocalizations.of(context)!;

    final learningOutcome = details?.getExtensionValue<String?>(
      BadgeExtensionKeys.learningOutcome,
    );
    final eCTS = details?.getExtensionValue<double?>(BadgeExtensionKeys.ects);
    final language = languageCodeToString(
      details?.getExtensionValue<String?>(BadgeExtensionKeys.language),
      context,
    );
    final supervisedStatus = getAssessmentSupervisedStatus(details);
    final assessmentType = details?.badgeclass.assessmentType;
    final participation = details?.badgeclass.participation;
    final eQF = details?.getExtensionValue<double?>(BadgeExtensionKeys.eQF);

    return [
      if (details?.badgeclass.description != null)
        _buildSectionCard(
          title: l10n.aboutThisEdubadge,
          item: MarkdownBody(
            data: filterBadMarkdown(details!.badgeclass.description!),
            styleSheet: _buildMarkdownStyleSheet(),
          ),
        ),
      if (learningOutcome != null)
        _buildSectionCard(
          title: l10n.learningOutcomes,
          item: MarkdownBody(
            data: filterBadMarkdown(learningOutcome),
            styleSheet: _buildMarkdownStyleSheet(),
          ),
        ),
      _buildSectionCard(
        title: l10n.theEdubadge,
        items: [
          BadgeDetailItemModel(
            icon: Assets.iconBadgeExpireDate,
            title: l10n.expiresOn,
            subtitle: details?.expiresAt == null
                ? l10n.never
                : DateFormat(
                    AppConstants.mediumDateFormat,
                    l10n.localeName,
                  ).format(details!.expiresAt!),
          ),
          BadgeDetailItemModel(
            icon: Assets.iconCollections,
            title: l10n.type,
            subtitle:
                'Extracurriculair', // TODO: Add real data (https://digitalclub.atlassian.net/browse/SURF-539)
          ),
        ],
      ),
      _buildSectionCard(
        title: l10n.badgeTheProgram,
        items: [
          BadgeDetailItemModel(
            icon: Assets.iconType,
            title: l10n.type,
            subtitle:
                'Microcredential', // TODO: Add real data (https://digitalclub.atlassian.net/browse/SURF-539)
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
          if (participation != null)
            BadgeDetailItemModel(
              icon: Assets.iconBadgeFormParticipation,
              title: l10n.formOfParticipation,
              subtitle: participation.getLocalizedName(l10n),
            ),
        ],
      ),
      if (assessmentType != null || supervisedStatus != null)
        _buildSectionCard(
          title: l10n.badgeTheAssessment,
          items: [
            if (assessmentType != null)
              BadgeDetailItemModel(
                icon: Assets.iconBadgeIndicatief,
                title: l10n.assessmentType,
                subtitle: assessmentType.getLocalizedName(l10n),
              ),
            if (supervisedStatus != null)
              BadgeDetailItemModel(
                icon: Assets.iconBadgeUnderReview,
                subtitle: supervisedStatus,
              ),
          ],
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
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          if (item != null) item,
          if (items != null)
            ...List.generate(items.length * 2 - 1, (int index) {
              if (index.isOdd) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: const Divider(height: 1),
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
        SvgPicture.asset(
          item.icon,
          height: 24,
          width: 24,
          colorFilter: ColorFilter.mode(
            colorScheme.onPrimaryContainer,
            BlendMode.srcIn,
          ),
        ),
        Expanded(
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
      ],
    );
  }
}
