import 'package:edubadges/app/colors.dart';
import 'package:edubadges/core/utils/platform_info.dart';
import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ActionableContentLayout extends StatefulWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;
  final bool showBackButton, error;
  final VoidCallback? onBack;

  const ActionableContentLayout({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.showBackButton = true,
    this.error = false,
    this.onBack,
  });

  @override
  State<ActionableContentLayout> createState() => _ActionableContentLayoutState();
}

class _ActionableContentLayoutState extends State<ActionableContentLayout> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // On web the browser's back navigation is used, so hide in-app back buttons.
    final bool showBack =
        widget.showBackButton && PlatformInfo.showInAppBackButton;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: showBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: widget.onBack ?? () => context.pop(),
                tooltip: AppLocalizations.of(context).semanticsBack,
              )
            : null,
        backgroundColor: colorScheme.surface,
        actions: showBack ? [const SizedBox(width: 56)] : null,
      ),
      body: MaxWidthWrapper(
        scrollController: _scrollController,
        child: Column(
          children: [
            Expanded(
              child: widget.error
                  ? Center(child: widget.content)
                  : SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      child: widget.content,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 12,
                children: widget.actions,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
