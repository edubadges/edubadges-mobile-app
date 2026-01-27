import 'package:edubadges/app/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ActionableContentLayout extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;
  final bool showBackButton;

  const ActionableContentLayout({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.showBackButton = true,
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
              )
            : null,
        backgroundColor: colorScheme.surface,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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
