import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabCollections)),
      body: const Center(child: Text('Collections Page')),
    );
  }
}
