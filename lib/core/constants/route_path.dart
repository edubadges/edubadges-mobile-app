import 'package:edubadges/features/badge_details/domain/enums/badge_details_scope.dart';

class RoutePath {
  static const String main = '/';
  static const String login = '/login';
  static const String generalTerms = '/general-terms';
  static const String start = '/';
  static const String collections = '/collections';
  static const String collection = '/collection/:id';
  static const String newCollection = '/new-collection';
  static const String newCollectionBadgeSelection = '/new-collection/badges';
  /// Claimed badge (instance id). Carousel on by default; use `?gallery=false` for single-badge layout.
  static const String badgeDetailsClaimed = '/details/:id';

  /// Requested / enrollment (badge class id).
  static const String badgeEnrollment = '/enrollment/:id';

  /// Catalog / shared class (badge class id).
  static const String badgePublic = '/public/:id';

  /// Quality assurance details nested under badge detail routes.
  static const String badgeQualityAssuranceClaimed =
      '/details/:id/quality-assurance';
  static const String badgeQualityAssuranceEnrollment =
      '/enrollment/:id/quality-assurance';
  static const String badgeQualityAssurancePublic =
      '/public/:id/quality-assurance';
  static const String catalog = '/catalog';
  static const String account = '/account';
  static const String notificationPermission = '/notification-permission';
  static const String agreementDetails = '/agreement/:id';
  static const String badgeClaim = '/badge-claim/:id';
  static const String badgePrivacy = '/badge-privacy/:id';
  static const String badgeClaimSuccess = '/badge-claim-success';

  /// List of all main navigation routes
  static const List<String> mainRoutes = [main, collections, catalog, account];

  /// List of routes that don't require authentication
  static const List<String> publicRoutes = [login];

  /// Returns true when [path] can be accessed without logging in.
  static bool isPublicPath(String path) {
    if (publicRoutes.contains(path)) {
      return true;
    }
    if (path.startsWith('/public/')) {
      return true;
    }
    if (path.startsWith('/enrollment/')) {
      return true;
    }
    return false;
  }

  /// List of routes that should redirect logged-in users to their home page.
  static const List<String> redirectRoutesForLoggedInUsers = [login];

  /// Builds a location for [BadgeDetailsPage] matching website routes.
  ///
  /// For [BadgeDetailsScope.claimed], [gallery] defaults to true (carousel). Pass false for `?gallery=false`.
  static String badgeDetailsLocation({
    required BadgeDetailsScope scope,
    required String id,
    bool gallery = true,
  }) {
    final encoded = Uri.encodeComponent(id);
    switch (scope) {
      case BadgeDetailsScope.claimed:
        if (!gallery) {
          return Uri(
            path: '/details/$encoded',
            queryParameters: {'gallery': 'false'},
          ).toString();
        }
        return '/details/$encoded';
      case BadgeDetailsScope.enrollment:
        return '/enrollment/$encoded';
      case BadgeDetailsScope.public:
        return '/public/$encoded';
    }
  }

  static String badgeQualityAssurancePath({
    required BadgeDetailsScope scope,
    required String id,
  }) {
    final encoded = Uri.encodeComponent(id);
    switch (scope) {
      case BadgeDetailsScope.claimed:
        return '/details/$encoded/quality-assurance';
      case BadgeDetailsScope.enrollment:
        return '/enrollment/$encoded/quality-assurance';
      case BadgeDetailsScope.public:
        return '/public/$encoded/quality-assurance';
    }
  }

  static String collectionPath({
    required String id,
    required String title,
    String? description,
  }) {
    return Uri(
      path: '/collection/${Uri.encodeComponent(id)}',
      queryParameters: {
        'title': title,
        if (description != null && description.isNotEmpty) 'description': description,
      },
    ).toString();
  }

  static String agreementDetailsPath({
    required String agreementId,
    required String titleLong,
    required String textUrlLong,
    String? titleShort,
    String? textUrlShort,
  }) {
    return Uri(
      path: '/agreement/${Uri.encodeComponent(agreementId)}',
      queryParameters: {
        'titleLong': titleLong,
        'textUrlLong': textUrlLong,
        if (titleShort != null) 'titleShort': titleShort,
        if (textUrlShort != null) 'textUrlShort': textUrlShort,
      },
    ).toString();
  }

  static String badgeClaimPath({
    required String id,
    required int remainingCount,
  }) {
    return Uri(
      path: '/badge-claim/${Uri.encodeComponent(id)}',
      queryParameters: {'remainingCount': remainingCount.toString()},
    ).toString();
  }

  static String badgePrivacyPath({required String id}) {
    return Uri(
      path: '/badge-privacy/${Uri.encodeComponent(id)}',
    ).toString();
  }

  static String badgeClaimSuccessPath({required String id}) {
    return Uri(
      path: badgeClaimSuccess,
      queryParameters: {'id': id},
    ).toString();
  }

  static String newCollectionPath({
    required String name,
    String? description,
  }) {
    return Uri(
      path: newCollection,
      queryParameters: {
        'name': name,
        if (description != null && description.isNotEmpty) 'description': description,
      },
    ).toString();
  }

  /// Query: optional [id] (existing collection), [name], optional [description].
  static String newCollectionBadgeSelectionPath({
    String? id,
    required String name,
    String? description,
  }) {
    return Uri(
      path: newCollectionBadgeSelection,
      queryParameters: {
        if (id != null && id.isNotEmpty) 'id': id,
        'name': name,
        if (description != null && description.isNotEmpty) 'description': description,
      },
    ).toString();
  }
}
