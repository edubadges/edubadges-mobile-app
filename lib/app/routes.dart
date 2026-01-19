import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/features/account/presentation/pages/account_page.dart';
import 'package:edubadges/features/badges_overview/presentation/pages/badges_overview_page.dart';
import 'package:edubadges/features/catalog/presentation/pages/catalog_page.dart';
import 'package:edubadges/features/collections/data/models/collection_route_model.dart';
import 'package:edubadges/features/collections/presentation/pages/collection_page.dart';
import 'package:edubadges/features/collections/presentation/pages/collections_page.dart';
import 'package:edubadges/features/general_terms/presentation/pages/general_terms_page.dart';
import 'package:edubadges/features/login/presentation/pages/login_page.dart';
import 'package:edubadges/features/main/main_page.dart';
import 'package:edubadges/shared/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouter = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: RoutePath.login,
    redirect: (context, state) {
      final bool loggedIn = authState.when(
        data: (isLoggedIn) => isLoggedIn,
        loading: () => false,
        // ignore: unnecessary_underscores
        error: (_, __) => false,
      );

      final bool isGoingToLogin = state.uri.path == RoutePath.login;

      if (!loggedIn && !isGoingToLogin) return RoutePath.login;
      if (loggedIn && isGoingToLogin) return RoutePath.main;

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

      GoRoute(path: RoutePath.generalTerms,
          name: 'general-terms',
          builder: (context, state) {
            return const GeneralTermsPage();
          }
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
