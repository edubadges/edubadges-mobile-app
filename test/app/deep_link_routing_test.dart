import 'package:edubadges/app/routes.dart';
import 'package:edubadges/core/network/network_config.dart';
import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/shared/presentation/providers/auth_providers.dart';
import 'package:edubadges/shared/presentation/providers/permission_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// SURF-675: once Android hands the app a /public/<id> link, a visitor who is
// not logged in must land on the public badge page, not on the login page.

class _LoggedOut extends AuthNotifier {
  @override
  Future<bool> build() async => false;
}

void main() {
  const entityId = 'Kq_WelCoQ62SRMgucb_q4g';

  Future<RouteMatchList> resolve(WidgetTester tester, String location) async {
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(_LoggedOut.new),
        shouldShowNotificationPermissionPromptProvider.overrideWith(
          (ref) async => false,
        ),
        networkConfigProvider.overrideWithValue(
          NetworkConfig(baseUrl: 'https://api.example.test'),
        ),
      ],
    );
    await container.read(authProvider.future);
    final router = container.read(appRouter);

    late BuildContext context;
    await tester.pumpWidget(
      Builder(
        builder: (c) {
          context = c;
          return const SizedBox();
        },
      ),
    );
    final match = await router.routeInformationParser
        .parseRouteInformationWithDependencies(
          RouteInformation(uri: Uri.parse(location)),
          context,
        );
    // Riverpod schedules a zero-length dispose timer; let it run.
    container.dispose();
    await tester.pump(Duration.zero);
    return match;
  }

  String? lastRouteName(RouteMatchList list) =>
      (list.matches.last.route as GoRoute).name;

  testWidgets('/public/<id> opens the public badge page when logged out', (
    tester,
  ) async {
    final match = await resolve(tester, '/public/$entityId');

    expect(match.uri.path, '/public/$entityId');
    expect(lastRouteName(match), 'badge-details-public');
  });

  testWidgets(
    'the older /public/catalog/<id> link still leaves the login page',
    (tester) async {
      final match = await resolve(tester, '/public/catalog/$entityId');

      expect(match.uri.path, isNot('/login'));
    },
  );
}
