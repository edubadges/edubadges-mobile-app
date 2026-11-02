import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/constants/branding.dart';
import 'package:edubadges/core/constants/layout_constants.dart';
import 'package:edubadges/core/utils/color.dart';
import 'package:edubadges/core/utils/links.dart';
import 'package:edubadges/core/utils/url_safety.dart';
import 'package:edubadges/core/widgets/app_snackbar.dart';
import 'package:edubadges/features/badge_details/presentation/providers/badge_details_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:edubadges/shared/presentation/widgets/badge_visibility_dialog.dart';
import 'package:edubadges/shared/presentation/widgets/wide_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BadgeVisibilityCard extends ConsumerStatefulWidget {
  final EdgeInsets margin;
  final BadgeInstanceEntity badge;
  final bool showCopyLink;

  const BadgeVisibilityCard({
    super.key,
    required this.badge,
    this.margin = const EdgeInsets.only(
      left: LayoutConstants.sidebarListLayoutPadding,
      right: LayoutConstants.sidebarListLayoutPadding,
      bottom: 8,
      top: 16,
    ),
    this.showCopyLink = true,
  });

  @override
  ConsumerState<BadgeVisibilityCard> createState() =>
      _BadgeVisibilityCardState();
}

class _BadgeVisibilityCardState extends ConsumerState<BadgeVisibilityCard> {
  late bool isPublic;

  /// Whether the copy link button has copied the link. The button then says
  /// so itself, so the confirmation stays readable after the snackbar is gone.
  bool _linkCopied = false;

  @override
  void initState() {
    super.initState();
    isPublic = widget.badge.public;
  }

  @override
  void didUpdateWidget(BadgeVisibilityCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.badge.public != widget.badge.public) {
      isPublic = widget.badge.public;
      _linkCopied = false;
    }
    if (oldWidget.badge.entityId != widget.badge.entityId) {
      _linkCopied = false;
    }
  }

  /// Badges that come from a list response (catalog, backpack overview, claim
  /// flow) carry no [BadgeInstanceEntity.linkedinUrl], since only the badge
  /// instance detail endpoint returns it. Load the instance details for those,
  /// so the share button shows up wherever the badge is public.
  String? _resolveLinkedinUrl() {
    final String? linkedinUrl = widget.badge.linkedinUrl;
    if (linkedinUrl != null && linkedinUrl.isNotEmpty) {
      return linkedinUrl;
    }

    if (!isPublic || !widget.showCopyLink) {
      return null;
    }

    return ref
        .watch(badgeInstanceProvider(widget.badge.entityId))
        .value
        ?.linkedinUrl;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Widget visibilityToggle = MergeSemantics(
      child: Semantics(
        label: isPublic
            ? l10n.semanticsBadgePublic
            : l10n.semanticsBadgePrivate,
        child: Switch(
          value: isPublic,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: EdgeInsets.zero,
          onChanged: (bool state) async {
            try {
              await BadgeVisibilityDialog.show(
                context: context,
                ref: ref,
                badgeInstance: widget.badge as BadgeInstanceModel,
                isPublic: state,
              );
            } catch (e) {
              if (context.mounted) {
                showAppSnackBar(context, l10n.somethingWentWrong);
              }
            }
          },
        ),
      ),
    );

    final String? linkedinUrl = _resolveLinkedinUrl();
    final bool hasCopyLinkOption = widget.showCopyLink && isPublic;
    final bool hasLinkedInOption =
        widget.showCopyLink && (linkedinUrl?.isNotEmpty ?? false) && isPublic;
    final bool hasShareOptions = hasCopyLinkOption || hasLinkedInOption;

    final Widget? shareButtons = hasShareOptions
        ? Column(
            children: [
              if (hasCopyLinkOption)
                WideButton(
                  text: _linkCopied ? l10n.linkCopied : l10n.copyLink,
                  icon: Icon(
                    _linkCopied ? Icons.check : Icons.copy,
                    size: 20,
                    color: getContrastingTextColor(colorScheme.primary),
                  ),
                  color: colorScheme.primary,
                  onTap: () async {
                    final String entityId = widget.badge.entityId;
                    final String link = createBadgeInstanceLink(entityId, ref);

                    try {
                      await Clipboard.setData(ClipboardData(text: link));
                    } catch (e) {
                      if (context.mounted) {
                        showAppSnackBar(context, l10n.somethingWentWrong);
                      }
                      return;
                    }

                    // The card may show another badge by the time the write
                    // finishes; only this badge's link was copied.
                    if (context.mounted && widget.badge.entityId == entityId) {
                      setState(() => _linkCopied = true);
                      showAppSnackBar(context, l10n.badgeLinkCopied);
                    }
                  },
                ),
              if (hasLinkedInOption) ...[
                const SizedBox(height: 8),
                WideButton(
                  text: linkedinBrand,
                  icon: SvgPicture.asset(
                    Assets.imageLinkedInLogo,
                    height: 18,
                    width: 18,
                  ),
                  color: linkedinBrandColor,
                  secondary: true,
                  onTap: () {
                    launchExternalUrl(linkedinUrl!);
                  },
                ),
              ],
            ],
          )
        : null;

    final Widget content = Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.badgeVisibleAndShareable,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // The explanation only helps while the badge is still
                  // private; once public the share buttons take its place.
                  if (!isPublic) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.badgeVisibleAndShareableDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            visibilityToggle,
          ],
        ),
        ?shareButtons,
      ],
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
        color: colorScheme.surfaceContainer,
      ),
      margin: widget.margin,
      padding: const EdgeInsets.all(16),
      child: content,
    );
  }
}
