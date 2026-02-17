import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/features/account/data/models/agreement_route_model.dart';
import 'package:edubadges/features/account/presentation/pages/account_page.dart';
import 'package:edubadges/features/account/presentation/pages/agreement_details_page.dart';
import 'package:edubadges/features/badge_details/data/models/badge_details_route_model.dart';
import 'package:edubadges/features/badge_details/domain/enums/badge_details_route_from.dart';
import 'package:edubadges/features/badge_details/presentation/pages/badge_details_page.dart';
import 'package:edubadges/features/badges_overview/presentation/pages/badge_claim_page.dart';
import 'package:edubadges/features/badges_overview/presentation/pages/badge_claim_success_page.dart';
import 'package:edubadges/features/badges_overview/presentation/pages/badge_privacy_page.dart';
import 'package:edubadges/features/badges_overview/presentation/pages/badges_overview_page.dart';
import 'package:edubadges/features/catalog/presentation/pages/catalog_page.dart';
import 'package:edubadges/features/collections/data/models/collection_route_model.dart';
import 'package:edubadges/features/collections/presentation/pages/badge_selection_page.dart';
import 'package:edubadges/features/collections/presentation/pages/collection_page.dart';
import 'package:edubadges/features/collections/presentation/pages/collections_page.dart';
import 'package:edubadges/features/collections/presentation/pages/new_collection_page.dart';
import 'package:edubadges/features/general_terms/presentation/pages/general_terms_page.dart';
import 'package:edubadges/features/login/data/models/login_terms.dart';
import 'package:edubadges/features/login/data/models/login_user_status.dart';
import 'package:edubadges/features/login/presentation/pages/login_page.dart';
import 'package:edubadges/features/login/presentation/providers/login_providers.dart';
import 'package:edubadges/features/main/main_page.dart';
import 'package:edubadges/features/notification_permission/presentation/pages/notification_permission_page.dart';
import 'package:edubadges/shared/presentation/providers/auth_providers.dart';
import 'package:edubadges/shared/presentation/providers/permission_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

final appRouter = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final notificationStatus = ref.watch(notificationPermissionStatusProvider);

  return GoRouter(
    initialLocation: RoutePath.login,
    redirect: (context, state) {
      final bool loggedIn = authState.asData?.value ?? false;
      final bool isGoingToLogin = state.uri.path == RoutePath.login;

      if (!loggedIn && !isGoingToLogin) return RoutePath.login;

      // After login, decide where to go based on a priority system.
      if (loggedIn && isGoingToLogin) {
        final loginStatus = ref.read(loginStatusProvider).asData?.value;
        final language = ref.read(appLanguageProvider);

        // Check if terms need to be agreed to.
        if (loginStatus is LoginTermsAgreementRequired) {
          final termsAgreement = loginStatus.termsAgreementSet.firstWhere(
                (element) => element.terms.termsType == 'terms_of_service',
          );

          final termsUrl = termsAgreement.terms.termsUrls.urlForLanguage(language.code);
          context.go(RoutePath.generalTerms, extra: termsUrl);
        }

        // Check if notification permissions need to be asked.
        // This packages means user has not decided yet with .denied
        if (notificationStatus.asData?.value == PermissionStatus.denied) {
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
          return const LoginPage();
        },
      ),

      GoRoute(
        path: RoutePath.notificationPermission,
        name: 'notification-permission',
        builder: (context, state) {
          return const NotificationPermissionPage();
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
          return GeneralTermsPage(url: url);
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
            return const CollectionsPage();
          }

          final collection = CollectionRouteModel(
            id: id,
            title: title,
            description: description?.isNotEmpty ?? false ? description : null,
          );

          return CollectionPage(collection: collection);
        },
      ),

      // Deep link from public share → internal catalog page
      GoRoute(
        path: '/public/catalog/:id',
        redirect: (context, state) {
          final id = state.pathParameters['id'];
          if (id == null || id.isEmpty) {
            return RoutePath.catalog; // fallback
          }

          final routeModel = BadgeDetailsRouteModel(
            id: id,
            from: BadgeDetailsRouteFrom.catalog,
          );

          return routeModel.buildRouteUrl();
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

          return AgreementDetailsPage(agreement: agreement);
        },
      ),

      GoRoute(
        path: RoutePath.newCollection,
        builder: (context, state) {
          final name = state.uri.queryParameters['name'] ?? '';
          final description = state.uri.queryParameters['description'];

          return NewCollectionPage(name: name, description: description);
        },
      ),

      GoRoute(
        path: RoutePath.newCollectionBadgeSelection,
        name: 'new-collection-badge-selection',
        builder: (context, state) {
          final name = state.uri.queryParameters['name'] ?? '';
          final description = state.uri.queryParameters['description'];

          return BadgeSelectionPage(name: name, description: description);
        },
      ),

      GoRoute(
        path: RoutePath.badge,
        name: 'badgedetails',
        builder: (context, state) {
          final badge = BadgeDetailsRouteModel(
            id: state.pathParameters['id'] ?? '',
            from: BadgeDetailsRouteFromExtension.fromString(
              state.uri.queryParameters['from'],
            ),
          );

          return BadgeDetailsPage(badge: badge);
        },
      ),

      GoRoute(
        path: RoutePath.badgeClaim,
        name: 'badge-claim',
        builder: (context, state) {
          final badgeId = state.pathParameters['id'] ?? '';
          final remainingCountStr =
              state.uri.queryParameters['remainingCount'] ?? '0';
          final remainingCount = int.tryParse(remainingCountStr) ?? 0;

          return BadgeClaimPage(
            badgeId: badgeId,
            remainingCount: remainingCount,
          );
        },
      ),

      GoRoute(
        path: RoutePath.badgePrivacy,
        name: 'badge-privacy',
        builder: (context, state) {
          final badgeId = state.pathParameters['id'] ?? '';
          return BadgePrivacyPage(badgeId: badgeId);
        },
      ),

      GoRoute(
        path: RoutePath.badgeClaimSuccess,
        name: 'badge-claim-success',
        builder: (context, state) {
          final badgeId = state.uri.queryParameters['id'] ?? '';
          return BadgeClaimSuccessPage(badgeId: badgeId);
        },
      ),

      // Authenticated Shell with 4 Tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainPage(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Badges Overview (default home)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePath.main,
                name: 'badges',
                builder: (context, state) => const BadgesOverviewPage(),
              ),
            ],
          ),

          // Branch 1: Collections
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePath.collections,
                name: 'collections',
                builder: (context, state) => const CollectionsPage(),
              ),
            ],
          ),

          // Branch 2: Catalog
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePath.catalog,
                name: 'catalog',
                builder: (context, state) => const CatalogPage(),
              ),
            ],
          ),

          // Branch 3: Account
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePath.account,
                name: 'account',
                builder: (context, state) => const AccountPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
