import 'dart:async';

import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/widgets/delayed_loader.dart';
import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:edubadges/features/login/domain/web_auto_login.dart';
import 'package:edubadges/features/login/presentation/providers/auto_login_providers.dart';
import 'package:edubadges/features/login/presentation/widgets/login_status_message.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final PageController _pageController = PageController(
    viewportFraction: 0.333,
    initialPage: 0,
  );
  Timer? _timer;
  int _currentPage = 0;

  /// Set once this page has asked for a login, by itself or through the
  /// button, so the automatic login on web fires at most once.
  bool _loginRequested = false;
  late final List<String> _extendedImages;

  final List<String> _badgeImages = [
    Assets.imageBadge0,
    Assets.imageBadge1,
    Assets.imageBadge2,
    Assets.imageBadge3,
    Assets.imageBadge4,
    Assets.imageBadge5,
    Assets.imageBadge6,
    Assets.imageBadge7,
    Assets.imageBadge8,
  ];

  @override
  void initState() {
    super.initState();

    // Enough copies so that when we reset we never see the seam
    _extendedImages = [..._badgeImages, ..._badgeImages, ..._badgeImages];

    _currentPage = 0;

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      // The carousel is not on screen while the page only shows a loader.
      if (!mounted || !_pageController.hasClients) return;

      final nextPage = _currentPage + 1;

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOutCubic,
      );

      _currentPage = nextPage;

      // Reset when we're approaching the end of the first full cycle
      // (do it early so the jump happens during/after animation)
      if (_currentPage >= _badgeImages.length * 2 - 3) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!mounted || !_pageController.hasClients) return;
          _pageController.jumpToPage(_badgeImages.length);
          _currentPage = _badgeImages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _login({bool replaceHistory = false}) async {
    _loginRequested = true;
    ref.read(autoLoginSuppressionProvider.notifier).clear();
    await ref.read(authProvider.notifier).login(replaceHistory: replaceHistory);
  }

  void _startAutoLogin() {
    if (_loginRequested) return;
    _loginRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // This page only shows a loader, so keep it out of the history: Back
      // from eduID should not reload it and redirect straight back.
      unawaited(_login(replaceHistory: true));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final authAsync = ref.watch(authProvider);
    final LoginEntryMode mode = resolveLoginEntryMode(
      autoLoginSupported: ref.watch(autoLoginSupportedProvider),
      auth: authAsync,
      suppression: ref.watch(autoLoginSuppressionProvider),
    );

    switch (mode) {
      case LoginEntryMode.startLogin:
        _startAutoLogin();
        return const _LoginLoadingView();
      case LoginEntryMode.loading:
        return const _LoginLoadingView();
      case LoginEntryMode.landing:
      case LoginEntryMode.landingWithError:
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset(Assets.imageLogo, semanticsLabel: l10n.appName),
        centerTitle: true,
      ),
      body: MaxWidthWrapper(
        enableScrollbar: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    l10n.loginTitle,
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Semantics(
                  child: Text(
                    l10n.loginSubtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 40),

                Card(
                  // Not one merged node: the card's paragraphs are read as
                  // text in their own right, also by the browser's "speak".
                  semanticContainer: false,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: colorScheme.surfaceContainer,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 80,
                          child: PageView.builder(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            padEnds: false,
                            itemCount: _extendedImages.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      _extendedImages[index],
                                      fit: BoxFit.contain,
                                      width: 80,
                                      height: 80,
                                      excludeFromSemantics: true,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          l10n.loginCardText,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),

                        if (mode == LoginEntryMode.landingWithError) ...[
                          SizedBox(
                            width: double.infinity,
                            child: Semantics(
                              liveRegion: true,
                              child: Text(
                                l10n.loginFailedMessage,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: authAsync.isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: authAsync.isLoading
                                ? CircularProgressIndicator(
                                    // The button is disabled, so pale, while
                                    // it loads.
                                    color: colorScheme.primary,
                                    semanticsLabel: AppLocalizations.of(
                                      context,
                                    ).semanticsLoading,
                                  )
                                : Text(
                                    l10n.loginCardButton,
                                    style: textTheme.labelLarge?.copyWith(
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                          ),
                        ),

                        const LoginStatusMessage(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown instead of the landing page while authentication resolves or the
/// browser is on its way to eduID, so the landing page does not flash first.
class _LoginLoadingView extends StatelessWidget {
  const _LoginLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: DelayedLoader()));
  }
}
