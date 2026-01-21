import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabCatalog)),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the GeneralTermsPage
            // TODO: remove this later, for now it was needed to test the general terms because could not get the user in a state that it needs to be accepted.
            context.go('/general-terms');
          },
          child: const Text('Open General Terms'),
        ),
      ),
    );
  }
}
