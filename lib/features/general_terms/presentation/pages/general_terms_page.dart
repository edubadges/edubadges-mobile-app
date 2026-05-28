import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/widgets/focusable_section.dart';
import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:edubadges/core/widgets/primary_button.dart';
import 'package:edubadges/features/general_terms/presentation/providers/general_terms_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/presentation/providers/permission_providers.dart';
import 'package:edubadges/shared/presentation/widgets/error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class GeneralTermsPage extends ConsumerStatefulWidget {
  final String url;

  const GeneralTermsPage({super.key, required this.url});

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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
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
    final dataSource = ref.watch(generalTermsDataSourceProvider);
    await dataSource.acceptTerms();

    final notificationStatus = ref.watch(notificationPermissionStatusProvider);

    if (mounted) {
      if (notificationStatus.value == PermissionStatus.denied) {
        context.go(RoutePath.notificationPermission);
      } else {
        context.go(RoutePath.main);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final markdownAsync = ref.watch(markdownContentProvider(widget.url));

    final buttonText = _isNearBottom
        ? l10n.generalAgreementButtonAgree
        : l10n.generalAgreementButtonReadMore;
    final buttonOnPressed = _isNearBottom ? _acceptTerms : _scrollToBottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.generalAgreementTitle),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: MaxWidthWrapper(
        child: Stack(
          children: [
            markdownAsync.when(
              data: (markdownContent) {
                if (markdownContent.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: AppLocalizations.of(
                        context,
                      ).semanticsLoading,
                    ),
                  );
                }
                return SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                  child: FocusableSection(
                    child: MarkdownBody(
                      data: markdownContent,
                      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                        p: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(
                  semanticsLabel: AppLocalizations.of(context).semanticsLoading,
                ),
              ),
              error: (error, _) => const Center(child: ErrorMessageWidget()),
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
      ),
    );
  }
}
