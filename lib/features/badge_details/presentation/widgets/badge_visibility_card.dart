import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/constants/branding.dart';
import 'package:edubadges/core/utils/color.dart';
import 'package:edubadges/core/utils/links.dart';
import 'package:edubadges/core/widgets/app_snackbar.dart';
import 'package:edubadges/core/widgets/lite_rolling_switch.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:edubadges/shared/presentation/widgets/badge_visibility_dialog.dart';
import 'package:edubadges/shared/presentation/widgets/wide_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BadgeVisibilityCard extends ConsumerStatefulWidget {
  final EdgeInsets margin;
  final BadgeInstanceEntity badge;
  final bool showCopyLink;

  const BadgeVisibilityCard({
    super.key,
    required this.badge,
    this.margin = const EdgeInsets.only(
      left: 20,
      right: 20,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
        color: colorScheme.surfaceContainer,
      ),
      margin: widget.margin,
      padding: const EdgeInsets.all(16),
      child: Column(
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
                    Text(
                      l10n.badgeVisibleAndShareable,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.badgeVisibleAndShareableDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedIconSwitch(
                value: isPublic,
                width: 44,
                height: 28,
                activeColor: colorScheme.primary,
                inactiveColor: colorScheme.surfaceContainerHighest,
                activeThumbColor: Colors.white,
                inactiveThumbColor: colorScheme.onSurfaceVariant,
                withIcons: true,
                iconOnThumb: true,
                activeIcon: Icons.check,
                inactiveIcon: Icons.close,
                activeIconColor: colorScheme.primary,
                inactiveIconColor: Colors.white,
                activeIconSize: 16,
                inactiveIconSize: 16,
                borderRadius: 14,
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
            ],
          ),
          Column(
            children: [
              if (widget.showCopyLink)
                WideButton(
                  text: l10n.copyLink,
                  icon: Icon(
                    Icons.copy,
                    size: 20,
                    color: getContrastingTextColor(colorScheme.primary),
                  ),
                  color: colorScheme.primary,
                  onTap: () async {
                    final String link = createBadgeInstanceLink(
                      widget.badge.entityId,
                      ref,
                    );

                    await Clipboard.setData(ClipboardData(text: link));

                    if (context.mounted) {
                      showAppSnackBar(context, l10n.badgeLinkCopied);
                    }
                  },
                ),
              if (widget.showCopyLink && widget.badge.linkedinUrl != null) ...[
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
                    launchUrlString(
                      widget.badge.linkedinUrl!,
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
