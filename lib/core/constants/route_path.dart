class RoutePath {
  static const String main = '/';
  static const String login = '/login';
  static const String generalTerms = '/general-terms';
  static const String start = '/';
  static const String collections = '/collections';
  static const String collection = '/collection/:id';
  static const String newCollection = '/new-collection';
  static const String newCollectionBadgeSelection = '/new-collection/badges';
  static const String badge = '/badge/:id';
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

  /// List of routes that should redirect logged-in users to their home page.
  static const List<String> redirectRoutesForLoggedInUsers = [login];

  /// Query: optional [id] (existing collection), [name], optional [description].
  static Uri newCollectionBadgeSelectionUri({
    String? id,
    required String name,
    String? description,
  }) {
    return Uri.parse(newCollectionBadgeSelection).replace(
      queryParameters: {
        if (id != null && id.isNotEmpty) 'id': id,
        'name': name,
        if (description != null && description.isNotEmpty) 'description': description,
      },
    );
  }
}
