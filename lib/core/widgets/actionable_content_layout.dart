import 'package:edubadges/app/colors.dart';
import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ActionableContentLayout extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;
  final bool showBackButton, error;

  const ActionableContentLayout({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.showBackButton = true,
    this.error = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
        centerTitle: true,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () => context.pop(),
                tooltip: AppLocalizations.of(context).semanticsBack,
              )
            : null,
        backgroundColor: colorScheme.surface,
        actions: showBackButton ? [const SizedBox(width: 56)] : null,
      ),
      body: MaxWidthWrapper(
        child: Column(
          children: [
            Expanded(
              child: error
                  ? Center(child: content)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: content,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 12,
                children: actions,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
