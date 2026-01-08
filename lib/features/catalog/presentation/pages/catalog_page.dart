import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabCatalog)),
      body: const Center(child: Text('Catalog Page')),
    );
  }
}
