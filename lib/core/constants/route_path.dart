class RoutePath {
  static const String main = '/';
  static const String login = '/login';
  static const String start = '/';
  static const String collections = '/collections';
  static const String collection = '/collection/:id';
  static const String catalog = '/catalog';
  static const String account = '/account';
  static const String agreementDetails = '/agreement/:id';

  /// List of all main navigation routes
  static const List<String> mainRoutes = [main, collections, catalog, account];

  /// List of routes that don't require authentication
  static const List<String> publicRoutes = [login];

  /// List of routes that should redirect logged-in users to their home page.
  static const List<String> redirectRoutesForLoggedInUsers = [login];
}
