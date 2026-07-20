import 'dart:math' as math;

import 'package:edubadges/features/badges_overview/presentation/pages/badge_claim_page.dart';
import 'package:edubadges/features/badges_overview/presentation/pages/badge_claim_success_page.dart';
import 'package:edubadges/features/badges_overview/presentation/pages/badge_privacy_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _ClaimFlowStep { claim, privacy, success }

class DesktopBadgeClaimDialog extends ConsumerStatefulWidget {
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
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DesktopBadgeClaimDialog(
        initialBadgeId: badgeId,
        initialRemainingCount: remainingCount,
      ),
    );
  }

  @override
  ConsumerState<DesktopBadgeClaimDialog> createState() => _DesktopBadgeClaimDialogState();
}

class _DesktopBadgeClaimDialogState extends ConsumerState<DesktopBadgeClaimDialog> {
  late String _badgeId;
  late int _remainingCount;
  String? _badgeClassId;
  late _ClaimFlowStep _step;

  @override
  void initState() {
    super.initState();
    _badgeId = widget.initialBadgeId;
    _remainingCount = widget.initialRemainingCount;
    _step = _ClaimFlowStep.claim;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final colorScheme = Theme.of(context).colorScheme;

    // Constrain the dialog to 9/16 aspect ratio with a max-width of 400
    final double width = math.min(400.0, size.width * 0.85);
    final double height = width * 16 / 9;

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
          _ClaimFlowStep.claim => BadgeClaimPage(
              badgeId: _badgeId,
              remainingCount: _remainingCount,
              onClose: () => Navigator.of(context).pop(),
              onNavigateToPrivacy: (id) {
                setState(() {
                  _badgeId = id;
                  _step = _ClaimFlowStep.privacy;
                });
              },
              onNavigateToSuccess: (classId) {
                setState(() {
                  _badgeClassId = classId;
                  _step = _ClaimFlowStep.success;
                });
              },
            ),
          _ClaimFlowStep.privacy => BadgePrivacyPage(
              badgeId: _badgeId,
              onBack: () {
                setState(() {
                  _step = _ClaimFlowStep.claim;
                });
              },
              onNavigateToSuccess: (classId) {
                setState(() {
                  _badgeClassId = classId;
                  _step = _ClaimFlowStep.success;
                });
              },
              onNavigateToMain: () => Navigator.of(context).pop(),
            ),
          _ClaimFlowStep.success => BadgeClaimSuccessPage(
              badgeClassId: _badgeClassId ?? '',
              onGoToOverview: () => Navigator.of(context).pop(),
              onClaimNextBadge: (nextBadgeId, count) {
                setState(() {
                  _badgeId = nextBadgeId;
                  _remainingCount = count;
                  _step = _ClaimFlowStep.claim;
                });
              },
            ),
        },
      ),
    );
  }
}
