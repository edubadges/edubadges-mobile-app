import 'dart:math' as math;

import 'package:edubadges/features/badges_overview/presentation/pages/badge_claim_page.dart';
import 'package:edubadges/features/badges_overview/presentation/pages/badge_claim_success_page.dart';
import 'package:edubadges/features/badges_overview/presentation/pages/badge_privacy_page.dart';
import 'package:flutter/material.dart';

sealed class _ClaimFlowStep {
  const _ClaimFlowStep();
}

final class _ClaimFlowClaim extends _ClaimFlowStep {
  const _ClaimFlowClaim();
}

final class _ClaimFlowPrivacy extends _ClaimFlowStep {
  const _ClaimFlowPrivacy();
}

final class _ClaimFlowSuccess extends _ClaimFlowStep {
  final String badgeClassId;

  const _ClaimFlowSuccess(this.badgeClassId);
}

class DesktopBadgeClaimDialog extends StatefulWidget {
  final String initialBadgeId;
  final int initialRemainingCount;

  const DesktopBadgeClaimDialog({
    super.key,
    required this.initialBadgeId,
    required this.initialRemainingCount,
  });

  static Future<void> show({
    required BuildContext context,
    required String badgeId,
    required int remainingCount,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DesktopBadgeClaimDialog(
        initialBadgeId: badgeId,
        initialRemainingCount: remainingCount,
      ),
    );
  }

  @override
  State<DesktopBadgeClaimDialog> createState() =>
      _DesktopBadgeClaimDialogState();
}

class _DesktopBadgeClaimDialogState extends State<DesktopBadgeClaimDialog> {
  late String _badgeId;
  late int _remainingCount;
  late _ClaimFlowStep _step;

  @override
  void initState() {
    super.initState();
    _badgeId = widget.initialBadgeId;
    _remainingCount = widget.initialRemainingCount;
    _step = const _ClaimFlowClaim();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final colorScheme = Theme.of(context).colorScheme;

    // Portrait 9:16 (width:height); clamp height so the dialog fits short windows.
    final double width = math.min(400.0, size.width * 0.85);
    final double preferredHeight = width * 16 / 9;
    final double height = math.min(preferredHeight, size.height);

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: width,
        height: height,
        child: switch (_step) {
          _ClaimFlowClaim() => BadgeClaimPage(
              badgeId: _badgeId,
              remainingCount: _remainingCount,
              onClose: () => Navigator.of(context).pop(),
              onNavigateToPrivacy: (id) {
                setState(() {
                  _badgeId = id;
                  _step = const _ClaimFlowPrivacy();
                });
              },
              onNavigateToSuccess: (classId) {
                setState(() {
                  _step = _ClaimFlowSuccess(classId);
                });
              },
            ),
          _ClaimFlowPrivacy() => BadgePrivacyPage(
              badgeId: _badgeId,
              onBack: () {
                setState(() {
                  _step = const _ClaimFlowClaim();
                });
              },
              onNavigateToSuccess: (classId) {
                setState(() {
                  _step = _ClaimFlowSuccess(classId);
                });
              },
              onNavigateToMain: () => Navigator.of(context).pop(),
            ),
          _ClaimFlowSuccess(:final badgeClassId) => BadgeClaimSuccessPage(
              badgeClassId: badgeClassId,
              onGoToOverview: () => Navigator.of(context).pop(),
              onClaimNextBadge: (nextBadgeId, count) {
                setState(() {
                  _badgeId = nextBadgeId;
                  _remainingCount = count;
                  _step = const _ClaimFlowClaim();
                });
              },
            ),
        },
      ),
    );
  }
}
