import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/widgets/primary_button.dart';
import 'package:edubadges/features/general_terms/presentation/providers/general_terms_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GeneralTermsPage extends ConsumerStatefulWidget {
  const GeneralTermsPage({super.key});

  @override
  ConsumerState<GeneralTermsPage> createState() => _GeneralTermsPageState();
}

class _GeneralTermsPageState extends ConsumerState<GeneralTermsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isNearBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Check if the scroll position is within 100px of the bottom
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      if (!_isNearBottom) {
        setState(() {
          _isNearBottom = true;
        });
      }
    } else {
      if (_isNearBottom) {
        setState(() {
          _isNearBottom = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _acceptTerms() async {
      context.go(RoutePath.main);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final markdownAsync = ref.watch(markdownContentProvider);
    final buttonText = _isNearBottom ? l10n.generalAgreementButtonRead : l10n.generalAgreementButtonReadMore;
    final buttonOnPressed = _isNearBottom ? _acceptTerms : _scrollToBottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.generalAgreementTitle),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          markdownAsync.when(
            data: (markdownContent) {
              // Show placeholder if content is empty (e.g., while URL is loading)
              if (markdownContent.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                child: Markdown(
                  data: markdownContent,
                  styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                    p: textTheme.bodyMedium!.copyWith(fontSize: 16),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text('Error loading terms: $err'), // TODO: add localisation when we know more about error handling
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: PrimaryButton(
                text: buttonText,
                onPressed: buttonOnPressed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
