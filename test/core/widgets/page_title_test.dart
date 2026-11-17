import 'package:edubadges/core/widgets/page_title.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({required Widget home}) => MaterialApp(
  title: 'Edubadges',
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: home,
);

void main() {
  late String? title;

  setUp(() {
    title = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (
          MethodCall call,
        ) async {
          if (call.method == 'SystemChrome.setApplicationSwitcherDescription') {
            title =
                (call.arguments as Map<Object?, Object?>)['label'] as String?;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('names the page on screen, also after going back to it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        home: PageTitle(
          title: (AppLocalizations l10n) => l10n.tabCatalog,
          child: Builder(
            builder: (BuildContext context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => PageTitle(
                    title: (AppLocalizations l10n) => l10n.qualityAssurance,
                    child: const SizedBox(),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    expect(title, 'Catalog – Edubadges');

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(title, 'Quality assurance – Edubadges');

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    expect(title, 'Catalog – Edubadges');
  });

  testWidgets('a page in a hidden tab leaves the title alone', (
    WidgetTester tester,
  ) async {
    final ValueNotifier<int> hiddenRebuilds = ValueNotifier<int>(0);
    addTearDown(hiddenRebuilds.dispose);

    await tester.pumpWidget(
      _app(
        home: IndexedStack(
          index: 1,
          children: [
            TickerMode(
              enabled: false,
              child: ValueListenableBuilder<int>(
                valueListenable: hiddenRebuilds,
                builder: (BuildContext context, int count, Widget? child) =>
                    PageTitle(
                      title: (AppLocalizations l10n) => l10n.tabAccount,
                      child: Text('$count'),
                    ),
              ),
            ),
            PageTitle(
              title: (AppLocalizations l10n) => l10n.tabCatalog,
              child: const SizedBox(),
            ),
          ],
        ),
      ),
    );
    expect(title, 'Catalog – Edubadges');

    // Such as the backpack refreshing its badges in the background.
    hiddenRebuilds.value++;
    await tester.pump();
    expect(title, 'Catalog – Edubadges');
  });

  testWidgets('a title deeper in the page refines the route title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        home: PageTitle(
          title: (AppLocalizations l10n) => l10n.pageTitleBadgeDetails,
          child: PageTitle(
            title: (AppLocalizations l10n) => 'English Grammar B1+',
            child: const SizedBox(),
          ),
        ),
      ),
    );

    expect(title, 'English Grammar B1+ – Edubadges');
  });
}
