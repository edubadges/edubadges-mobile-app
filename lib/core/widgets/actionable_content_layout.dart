import 'package:edubadges/core/constants/heading_level.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/widgets/app_back_button.dart';
import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:flutter/material.dart';

class ActionableContentLayout extends StatefulWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;
  final bool showBackButton, error;
  final VoidCallback? onBack;

  /// Where to navigate when the page was opened directly and has nothing to
  /// pop back to.
  final String backFallbackLocation;

  const ActionableContentLayout({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.showBackButton = true,
    this.error = false,
    this.onBack,
    this.backFallbackLocation = RoutePath.main,
  });

  @override
  State<ActionableContentLayout> createState() =>
      _ActionableContentLayoutState();
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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        // The app bar makes its title a heading; this sets its level.
        title: Semantics(
          headingLevel: HeadingLevel.page,
          child: Text(
            widget.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: widget.showBackButton
            ? AppBackButton(
                onPressed: widget.onBack,
                fallbackLocation: widget.backFallbackLocation,
              )
            : null,
        backgroundColor: colorScheme.surface,
        actions: widget.showBackButton ? [const SizedBox(width: 56)] : null,
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
