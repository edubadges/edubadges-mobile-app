import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/features/account/data/models/agreement_route_model.dart';
import 'package:edubadges/features/account/presentation/pages/account_page.dart';
import 'package:edubadges/features/account/presentation/pages/agreement_details_page.dart';
import 'package:edubadges/features/badges_overview/presentation/pages/badges_overview_page.dart';
import 'package:edubadges/features/catalog/presentation/pages/catalog_page.dart';
import 'package:edubadges/features/collections/data/models/collection_route_model.dart';
import 'package:edubadges/features/collections/presentation/pages/badge_selection_page.dart';
import 'package:edubadges/features/collections/presentation/pages/collection_page.dart';
import 'package:edubadges/features/collections/presentation/pages/collections_page.dart';
import 'package:edubadges/features/collections/presentation/pages/new_collection_page.dart';
import 'package:edubadges/features/general_terms/presentation/pages/general_terms_page.dart';
import 'package:edubadges/features/login/presentation/pages/login_page.dart';
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

      // After login, decide where to go.
      if (loggedIn && isGoingToLogin) {
        // If the permission has not been determined yet, show the permission screen.
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
        path: RoutePath.generalTerms,
        name: 'general-terms',
        builder: (context, state) {
          return const GeneralTermsPage();
        }
      ),

      GoRoute(
        path: RoutePath.notificationPermission,
        name: 'notification-permission',
        builder: (context, state) {
          return const NotificationPermissionPage();
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

      GoRoute(
        path: RoutePath.agreementDetails,
        name: 'agreement-details',
        builder: (context, state) {
          final agreementId = state.pathParameters['id'] ?? '';
          final titleLong = state.uri.queryParameters['titleLong'] ?? '';
          final textLong = state.uri.queryParameters['textLong'] ?? '';
          final titleShort = state.uri.queryParameters['titleShort'] ?? '';
          final textShort = state.uri.queryParameters['textShort'] ?? '';

          final agreement = AgreementRouteModel(
            agreementId: agreementId,
            titleLong: titleLong,
            textLong: textLong,
            titleShort: titleShort,
            textShort: textShort,
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
