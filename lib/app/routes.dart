import 'package:edubadges/app/router_refresh_listenable.dart';
import 'package:edubadges/core/analytics/piwik_pro_analytics.dart';
import 'package:edubadges/core/analytics/piwik_pro_route_observer.dart';
import 'package:edubadges/core/app_container.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/core/utils/route_exit_guard.dart';
import 'package:edubadges/core/widgets/deferred_widget.dart';
import 'package:edubadges/core/widgets/page_title.dart';
import 'package:edubadges/features/account/data/models/agreement_route_model.dart';
import 'package:edubadges/features/account/presentation/pages/account_page.dart';
import 'package:edubadges/features/account/presentation/pages/agreement_details_page.dart';
import 'package:edubadges/features/badge_details/data/models/badge_details_route_model.dart';
import 'package:edubadges/features/badge_details/domain/enums/badge_details_scope.dart';
import 'package:edubadges/features/badge_details/presentation/pages/badge_details_page.dart'
    deferred as badge_details;
import 'package:edubadges/features/badge_details/presentation/pages/badge_enrollment_terms_page.dart';
import 'package:edubadges/features/badge_details/presentation/pages/quality_assurance_page.dart'
    deferred as quality_assurance;
import 'package:edubadges/features/badges_overview/presentation/pages/badge_claim_page.dart'
    deferred as badge_claim;
import 'package:edubadges/features/badges_overview/presentation/pages/badge_claim_success_page.dart'
    deferred as badge_claim_success;
import 'package:edubadges/features/badges_overview/presentation/pages/badge_privacy_page.dart';
import 'package:edubadges/features/badges_overview/presentation/pages/badges_overview_page.dart';
import 'package:edubadges/features/catalog/presentation/pages/catalog_page.dart';
import 'package:edubadges/features/collections/data/models/collection_route_model.dart';
import 'package:edubadges/features/collections/presentation/pages/collection_form_page.dart';
import 'package:edubadges/features/collections/presentation/pages/collection_page.dart';
import 'package:edubadges/features/collections/presentation/pages/collections_page.dart';
import 'package:edubadges/features/general_terms/domain/general_terms_url_resolver.dart';
import 'package:edubadges/features/general_terms/presentation/pages/general_terms_page.dart'
    deferred as general_terms;
import 'package:edubadges/features/general_terms/presentation/providers/general_terms_providers.dart';
import 'package:edubadges/features/login/data/models/login_user_status.dart';
import 'package:edubadges/features/login/presentation/pages/login_page.dart';
import 'package:edubadges/features/login/presentation/providers/login_providers.dart';
import 'package:edubadges/features/main/main_page.dart';
import 'package:edubadges/features/notification_permission/presentation/pages/notification_permission_page.dart';
import 'package:edubadges/shared/presentation/providers/auth_providers.dart';
import 'package:edubadges/shared/presentation/providers/permission_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouter = Provider<GoRouter>((ref) {
  final refreshListenable = RouterRefreshListenable(ref);
  ref.onDispose(refreshListenable.dispose);

  // Lets the edit collection page ask about unsaved changes however the route
  // is left, including browser back/forward on web.
  final editCollectionExitGuard = RouteExitGuard();

  final router = GoRouter(
    initialLocation: RoutePath.login,
    refreshListenable: refreshListenable,
    observers: <NavigatorObserver>[
      PiwikProRouteObserver(PiwikProAnalytics.instance),
    ],
    redirect: (context, state) {
      final bool loggedIn = ref.read(authProvider).asData?.value ?? false;
      final bool isGoingToLogin = state.uri.path == RoutePath.login;

      if (!loggedIn) {
        return RoutePath.redirectForAnonymousVisitor(state.uri.path);
      }

      // After login, decide where to go based on a priority system.
      if (loggedIn && isGoingToLogin) {
        final loginStatus = ref.read(loginStatusProvider).asData?.value;
        final language = ref.read(appLanguageProvider);

        // Check if terms need to be agreed to.
        if (loginStatus is LoginTermsAgreementRequired) {
          final termsUrl = resolveGeneralTermsUrlFromLoginStatus(
            loginStatus,
            language.code,
          );
          cacheGeneralTermsMarkdownUrl(ref, termsUrl);
          context.go(RoutePath.generalTerms, extra: termsUrl);
          return null;
        }

        // Check if notification permissions need to be asked.
        if (!kIsWeb &&
            ref
                    .read(shouldShowNotificationPermissionPromptProvider)
                    .asData
                    ?.value ==
                true) {
          return RoutePath.notificationPermission;
        }

        // Otherwise, go directly to the main page.
        return RoutePath.main;
      }

      return null;
    },
    routes: [
      // Login Route
      GoRoute(
        path: RoutePath.login,
        name: 'login',
        builder: (context, state) {
          return PageTitle(
            title: (l10n) => l10n.pageTitleLogin,
            child: const LoginPage(),
          );
        },
      ),

      GoRoute(
        path: RoutePath.notificationPermission,
        name: 'notification-permission',
        builder: (context, state) {
          return PageTitle(
            title: (l10n) => l10n.notificationPermissionsTitle,
            child: const NotificationPermissionPage(),
          );
        },
      ),

      GoRoute(
        path: RoutePath.generalTerms,
        name: 'general-terms',
        redirect: (context, state) {
          final extra = state.extra;
          if (extra == null || extra is! String || extra.isEmpty) {
            return null;
          }
          return null;
        },
        builder: (context, state) {
          final url = state.extra as String;
          return PageTitle(
            title: (l10n) => l10n.generalAgreementTitle,
            child: DeferredWidget(
              loadLibrary: general_terms.loadLibrary,
              createWidget: () => general_terms.GeneralTermsPage(url: url),
            ),
          );
        },
      ),

      GoRoute(
        path: RoutePath.collection,
        name: 'collection',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          final title = state.uri.queryParameters['title'] ?? '';
          final description = state.uri.queryParameters['description'];

          if (id == null || id.isEmpty) {
            return PageTitle(
              title: (l10n) => l10n.tabCollections,
              child: const CollectionsPage(),
            );
          }

          final collection = CollectionRouteModel(
            id: id,
            title: title,
            description: description?.isNotEmpty ?? false ? description : null,
          );

          return PageTitle(
            title: (l10n) => title.isNotEmpty ? title : l10n.tabCollections,
            child: CollectionPage(collection: collection),
          );
        },
      ),

      GoRoute(
        path: RoutePath.editCollection,
        name: 'edit-collection',
        onExit: (context, state) => editCollectionExitGuard.canExit(),
        // Presented as a full-screen dialog (close button, no iOS back swipe).
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          name: state.name ?? state.path,
          arguments: <String, String>{
            ...state.pathParameters,
            ...state.uri.queryParameters,
          },
          restorationId: state.pageKey.value,
          fullscreenDialog: true,
          child: PageTitle(
            title: (l10n) => l10n.editCollection,
            child: CollectionFormPage.edit(
              collectionId: state.pathParameters['id'] ?? '',
              exitGuard: editCollectionExitGuard,
            ),
          ),
        ),
      ),

      // Deep link from public share → badge class details (must be before `/public/:id`)
      GoRoute(
        path: '/public/catalog/:id',
        redirect: (context, state) {
          final id = state.pathParameters['id'];
          if (id == null || id.isEmpty) {
            return RoutePath.catalog;
          }
          return '/public/${Uri.encodeComponent(id)}';
        },
      ),

      GoRoute(
        path: RoutePath.badgeQualityAssuranceLegacy,
        name: 'badge-quality-assurance-legacy',
        redirect: (context, state) {
          final scopeName = state.pathParameters['scope'];
          final id = state.pathParameters['id'];
          if (scopeName == null || id == null || id.isEmpty) {
            return RoutePath.main;
          }
          final BadgeDetailsScope? scope = BadgeDetailsScope.values
              .where((value) => value.name == scopeName)
              .firstOrNull;
          if (scope == null) {
            return RoutePath.main;
          }
          return RoutePath.badgeQualityAssurancePath(scope: scope, id: id);
        },
      ),

      GoRoute(
        path: RoutePath.badgeQualityAssuranceClaimed,
        name: 'badge-quality-assurance-claimed',
        builder: (context, state) {
          final badgeId = state.pathParameters['id'] ?? '';
          return PageTitle(
            title: (l10n) => l10n.qualityAssurance,
            child: DeferredWidget(
              loadLibrary: quality_assurance.loadLibrary,
              createWidget: () => quality_assurance.QualityAssurancePage(
                badgeId: badgeId,
                scope: BadgeDetailsScope.claimed,
              ),
            ),
          );
        },
      ),

      GoRoute(
        path: RoutePath.badgeQualityAssuranceEnrollment,
        name: 'badge-quality-assurance-enrollment',
        builder: (context, state) {
          final badgeId = state.pathParameters['id'] ?? '';
          return PageTitle(
            title: (l10n) => l10n.qualityAssurance,
            child: DeferredWidget(
              loadLibrary: quality_assurance.loadLibrary,
              createWidget: () => quality_assurance.QualityAssurancePage(
                badgeId: badgeId,
                scope: BadgeDetailsScope.enrollment,
              ),
            ),
          );
        },
      ),

      GoRoute(
        path: RoutePath.badgeQualityAssurancePublic,
        name: 'badge-quality-assurance-public',
        builder: (context, state) {
          final badgeId = state.pathParameters['id'] ?? '';
          return PageTitle(
            title: (l10n) => l10n.qualityAssurance,
            child: DeferredWidget(
              loadLibrary: quality_assurance.loadLibrary,
              createWidget: () => quality_assurance.QualityAssurancePage(
                badgeId: badgeId,
                scope: BadgeDetailsScope.public,
              ),
            ),
          );
        },
      ),

      GoRoute(
        path: RoutePath.badgeDetailsClaimed,
        name: 'badge-details-claimed',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final showClaimedGallery =
              state.uri.queryParameters['gallery'] != 'false';
          return DeferredWidget(
            loadLibrary: badge_details.loadLibrary,
            createWidget: () => badge_details.BadgeDetailsPage(
              badge: BadgeDetailsRouteModel(
                id: id,
                scope: BadgeDetailsScope.claimed,
                showClaimedGallery: showClaimedGallery,
              ),
            ),
          );
        },
      ),

      GoRoute(
        path: RoutePath.badgeEnrollment,
        name: 'badge-details-enrollment',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return DeferredWidget(
            loadLibrary: badge_details.loadLibrary,
            createWidget: () => badge_details.BadgeDetailsPage(
              badge: BadgeDetailsRouteModel(
                id: id,
                scope: BadgeDetailsScope.enrollment,
              ),
            ),
          );
        },
      ),

      GoRoute(
        path: RoutePath.badgePublic,
        name: 'badge-details-public',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return DeferredWidget(
            loadLibrary: badge_details.loadLibrary,
            createWidget: () => badge_details.BadgeDetailsPage(
              badge: BadgeDetailsRouteModel(
                id: id,
                scope: BadgeDetailsScope.public,
              ),
            ),
          );
        },
      ),

      GoRoute(
        path: RoutePath.agreementDetails,
        name: 'agreement-details',
        builder: (context, state) {
          final agreementId = state.pathParameters['id'] ?? '';
          final titleLong = state.uri.queryParameters['titleLong'] ?? '';
          final textUrlLong = state.uri.queryParameters['textUrlLong'] ?? '';
          final titleShort = state.uri.queryParameters['titleShort'] ?? '';
          final textUrlShort = state.uri.queryParameters['textUrlShort'] ?? '';

          final agreement = AgreementRouteModel(
            agreementId: agreementId,
            titleLong: titleLong,
            textUrlLong: textUrlLong,
            titleShort: titleShort,
            textUrlShort: textUrlShort,
          );

          return PageTitle(
            title: (l10n) => titleLong.isNotEmpty ? titleLong : titleShort,
            child: AgreementDetailsPage(agreement: agreement),
          );
        },
      ),

      GoRoute(
        path: RoutePath.newCollection,
        name: 'new-collection',
        builder: (context, state) => PageTitle(
          title: (l10n) => l10n.newCollection,
          child: const CollectionFormPage.create(),
        ),
      ),

      GoRoute(
        path: RoutePath.badgeClaim,
        name: 'badge-claim',
        builder: (context, state) {
          final badgeId = state.pathParameters['id'] ?? '';
          final remainingCountStr =
              state.uri.queryParameters['remainingCount'] ?? '0';
          final remainingCount = int.tryParse(remainingCountStr) ?? 0;

          return PageTitle(
            title: (l10n) => l10n.claimEdubadge,
            child: DeferredWidget(
              loadLibrary: badge_claim.loadLibrary,
              createWidget: () => badge_claim.BadgeClaimPage(
                badgeId: badgeId,
                remainingCount: remainingCount,
              ),
            ),
          );
        },
      ),

      GoRoute(
        path: RoutePath.badgePrivacy,
        name: 'badge-privacy',
        builder: (context, state) {
          final badgeId = state.pathParameters['id'] ?? '';
          return PageTitle(
            title: (l10n) => l10n.badgePrivacyTitle,
            child: BadgePrivacyPage(badgeId: badgeId),
          );
        },
      ),

      GoRoute(
        path: RoutePath.badgeEnrollmentTerms,
        name: 'badge-enrollment-terms',
        builder: (context, state) {
          final badgeClassEntityId = state.pathParameters['id'] ?? '';
          return PageTitle(
            title: (l10n) => l10n.pageTitleEnrollmentTerms,
            child: BadgeEnrollmentTermsPage(
              badgeClassEntityId: badgeClassEntityId,
            ),
          );
        },
      ),

      GoRoute(
        path: RoutePath.badgeClaimSuccess,
        name: 'badge-claim-success',
        builder: (context, state) {
          final badgeClassId = state.uri.queryParameters['id'] ?? '';
          return PageTitle(
            title: (l10n) => l10n.badgeClaimSuccessSubtitle,
            child: DeferredWidget(
              loadLibrary: badge_claim_success.loadLibrary,
              createWidget: () => badge_claim_success.BadgeClaimSuccessPage(
                badgeClassId: badgeClassId,
              ),
            ),
          );
        },
      ),

      // Authenticated Shell with 4 Tabs
      StatefulShellRoute(
        builder: (context, state, navigationShell) {
          return MainPage(navigationShell: navigationShell);
        },
        navigatorContainerBuilder:
            (
              BuildContext context,
              StatefulNavigationShell navigationShell,
              List<Widget> children,
            ) {
              return IndexedStack(
                index: navigationShell.currentIndex,
                children: [
                  // Hidden tabs stay built but without tickers, as in
                  // go_router's own container: nothing animates out of
                  // sight, and their pages know not to set the page title.
                  for (int i = 0; i < children.length; i++)
                    TickerMode(
                      enabled: i == navigationShell.currentIndex,
                      child: children[i],
                    ),
                ],
              );
            },
        branches: [
          // Branch 0: Badges Overview (default home)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePath.main,
                name: 'badges',
                builder: (context, state) => PageTitle(
                  title: (l10n) => l10n.badgesOverviewTitle,
                  child: const BadgesOverviewPage(),
                ),
              ),
            ],
          ),

          // Branch 1: Collections
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePath.collections,
                name: 'collections',
                builder: (context, state) => PageTitle(
                  title: (l10n) => l10n.tabCollections,
                  child: const CollectionsPage(),
                ),
              ),
            ],
          ),

          // Branch 2: Catalog
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePath.catalog,
                name: 'catalog',
                builder: (context, state) => PageTitle(
                  title: (l10n) => l10n.tabCatalog,
                  child: const CatalogPage(),
                ),
              ),
            ],
          ),

          // Branch 3: Account
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePath.account,
                name: 'account',
                builder: (context, state) => PageTitle(
                  title: (l10n) => l10n.tabAccount,
                  child: const AccountPage(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    if (appGoRouter == router) {
      appGoRouter = null;
    }
  });
  appGoRouter = router;
  return router;
});
