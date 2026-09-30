import 'package:collection/collection.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/utils/error_message.dart';
import 'package:edubadges/core/utils/route_exit_guard.dart';
import 'package:edubadges/core/widgets/adaptive_dialog.dart';
import 'package:edubadges/core/widgets/app_back_button.dart';
import 'package:edubadges/core/widgets/app_snackbar.dart';
import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:edubadges/core/widgets/outlined_button.dart';
import 'package:edubadges/core/widgets/primary_button.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/features/collections/domain/entities/collections_entity.dart';
import 'package:edubadges/features/collections/presentation/providers/collections_providers.dart';
import 'package:edubadges/features/collections/presentation/widgets/collection_action_bar.dart';
import 'package:edubadges/features/collections/presentation/widgets/collection_form_fields.dart';
import 'package:edubadges/features/collections/presentation/widgets/selectable_badge_list.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:edubadges/shared/presentation/widgets/error_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _UnsavedChangesChoice { discard, save }

/// The values the edit form started from, to tell whether anything changed.
class _CollectionSnapshot {
  final String name;
  final String description;
  final Set<String> badgeInstanceIds;

  _CollectionSnapshot(CollectionsEntity collection)
    : name = collection.name.trim(),
      description = (collection.description ?? '').trim(),
      badgeInstanceIds = Set.of(collection.badgeInstanceIds);
}

/// "Nieuwe collectie" and "Collectie wijzigen": the name, description and
/// edubadges of a collection on one screen.
///
/// Creating needs a name and at least one edubadge; "Annuleren" leaves without
/// saving.
///
/// Editing starts with the collection's edubadges selected. Deselecting all of
/// them is allowed (the collection then shows its empty state); only the name
/// is required. Removing an edubadge from a collection never deletes the badge.
/// Leaving with unsaved changes asks whether to save them first. That covers
/// the close button and pops (via [PopScope]) and, when [exitGuard] is wired to
/// the route's `onExit`, also `go()` and browser back/forward on web.
class CollectionFormPage extends ConsumerStatefulWidget {
  /// The collection being edited; null when creating one.
  final String? collectionId;
  final RouteExitGuard? exitGuard;

  const CollectionFormPage.create({super.key})
    : collectionId = null,
      exitGuard = null;

  const CollectionFormPage.edit({
    super.key,
    required String this.collectionId,
    this.exitGuard,
  });

  @override
  ConsumerState<CollectionFormPage> createState() => _CollectionFormPageState();
}

class _CollectionFormPageState extends ConsumerState<CollectionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  /// Insertion ordered, so edubadges that stay keep their position in the
  /// collection and newly selected ones are appended.
  final Set<String> _selectedBadgeIds = <String>{};

  _CollectionSnapshot? _initial;

  /// Edubadges that were in the collection when the form opened, so they can
  /// be deselected even when they are not in the claimed list.
  List<BadgeInstanceEntity> _initialBadges = const [];

  bool _isSaving = false;
  bool _isConfirmingExit = false;

  /// Set when saving a new collection without any edubadge selected.
  bool _showBadgeError = false;

  /// Set once the user saved or chose to discard; leaving is then allowed
  /// without asking again.
  bool _exitAllowed = false;

  bool get _isCreating => widget.collectionId == null;

  @override
  void initState() {
    super.initState();
    if (_isCreating) {
      return;
    }
    widget.exitGuard?.attach(_confirmExit);

    final collection = _findCollection(ref.read(collectionsProvider));
    if (collection != null) {
      _initialize(collection);
    } else {
      // Opened directly (deep link / reload): fill the form once loaded.
      ref.listenManual<AsyncValue<List<CollectionsEntity>>>(
        collectionsProvider,
        (previous, next) {
          if (_initial != null) {
            return;
          }
          final loaded = _findCollection(next);
          if (loaded != null) {
            setState(() => _initialize(loaded));
          }
        },
      );
    }
  }

  @override
  void didUpdateWidget(covariant CollectionFormPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exitGuard != widget.exitGuard) {
      oldWidget.exitGuard?.detach(_confirmExit);
      widget.exitGuard?.attach(_confirmExit);
    }
  }

  @override
  void dispose() {
    widget.exitGuard?.detach(_confirmExit);
    _scrollController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  CollectionsEntity? _findCollection(
    AsyncValue<List<CollectionsEntity>> collections,
  ) {
    return collections.value?.firstWhereOrNull(
      (c) => c.entityId == widget.collectionId,
    );
  }

  void _initialize(CollectionsEntity collection) {
    _initial = _CollectionSnapshot(collection);
    _initialBadges = collection.badgeInstances ?? const [];
    _nameController.text = collection.name;
    _descriptionController.text = collection.description ?? '';
    _selectedBadgeIds
      ..clear()
      ..addAll(collection.badgeInstanceIds);
  }

  bool get _hasChanges {
    final initial = _initial;
    if (initial == null) {
      return false;
    }
    return _nameController.text.trim() != initial.name ||
        _descriptionController.text.trim() != initial.description ||
        !setEquals(_selectedBadgeIds, initial.badgeInstanceIds);
  }

  void _toggleBadge(String badgeEntityId) {
    setState(() {
      if (!_selectedBadgeIds.remove(badgeEntityId)) {
        _selectedBadgeIds.add(badgeEntityId);
      }
      if (_selectedBadgeIds.isNotEmpty) {
        _showBadgeError = false;
      }
    });
  }

  /// Claimed edubadges, followed by any edubadge in the collection that is not
  /// claimed (e.g. not accepted yet) so everything shown on the collection can
  /// be removed from it.
  List<BadgeInstanceEntity> _selectableBadges(
    List<BadgeInstanceEntity> claimedBadges,
  ) {
    final claimedIds = {for (final badge in claimedBadges) badge.entityId};
    return [
      ...claimedBadges,
      ..._initialBadges.where((badge) => !claimedIds.contains(badge.entityId)),
    ];
  }

  Future<void> _handleSave() async {
    if (!_isCreating && !_hasChanges) {
      _close();
      return;
    }
    if (await _save() && mounted) {
      _close();
    }
  }

  /// Validates and saves; returns whether the collection was saved.
  Future<bool> _save() async {
    if (_isSaving) {
      return false;
    }
    final bool fieldsValid = _formKey.currentState?.validate() ?? false;
    final bool badgesValid = !_isCreating || _selectedBadgeIds.isNotEmpty;
    if (!fieldsValid || !badgesValid) {
      setState(() => _showBadgeError = !badgesValid);
      _scrollToTop();
      return false;
    }

    setState(() => _isSaving = true);
    final notifier = ref.read(collectionsProvider.notifier);
    final String name = _nameController.text.trim();
    final String description = _descriptionController.text.trim();
    final result = _isCreating
        ? await notifier.createCollection(
            name: name,
            description: description,
            public: false,
            badgeInstanceIds: _selectedBadgeIds.toList(),
          )
        : await notifier.patchCollection(
            entityId: widget.collectionId!,
            name: name,
            description: description,
            badgeInstanceIds: _selectedBadgeIds.toList(),
          );
    if (!mounted) {
      return result.isRight();
    }
    setState(() => _isSaving = false);

    return result.fold(
      (failure) {
        showAppSnackBar(
          context,
          messageFromFailure(context, failure),
          duration: const Duration(seconds: 5),
        );
        return false;
      },
      (_) {
        _exitAllowed = true;
        return true;
      },
    );
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  /// Whether the screen may be left. Asks about unsaved changes first; the
  /// caller does the navigation.
  Future<bool> _confirmExit() async {
    if (_isCreating || _exitAllowed || !_hasChanges) {
      return true;
    }
    if (_isSaving || _isConfirmingExit || !mounted) {
      return false;
    }

    _isConfirmingExit = true;
    try {
      switch (await _showUnsavedChangesDialog()) {
        case _UnsavedChangesChoice.discard:
          _exitAllowed = true;
          return true;
        case _UnsavedChangesChoice.save:
          return _save();
        case null:
          return false;
      }
    } finally {
      _isConfirmingExit = false;
    }
  }

  Future<_UnsavedChangesChoice?> _showUnsavedChangesDialog() async {
    final l10n = AppLocalizations.of(context);
    _UnsavedChangesChoice? choice;
    await AdaptiveDialog.show(
      context: context,
      config: AdaptiveDialogConfig(
        title: l10n.saveChangesTitle,
        description: l10n.unsavedCollectionChangesDescription,
        firstButtonText: l10n.dontSave,
        secondButtonText: l10n.save,
        isFirstButtonDestructive: true,
        onFirstButtonPressed: () => choice = _UnsavedChangesChoice.discard,
        onSecondButtonPressed: () => choice = _UnsavedChangesChoice.save,
      ),
    );
    return choice;
  }

  Future<void> _handleCloseRequest() async {
    if (await _confirmExit() && mounted) {
      _close();
    }
  }

  void _close() {
    _exitAllowed = true;
    if (_isCreating) {
      navigateBack(context, fallbackLocation: RoutePath.collections);
      return;
    }
    final name =
        _findCollection(ref.read(collectionsProvider))?.name ??
        _nameController.text.trim();
    navigateBack(
      context,
      fallbackLocation: RoutePath.collectionPath(
        id: widget.collectionId!,
        title: name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final collectionsAsync = ref.watch(collectionsProvider);

    final scaffold = Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainer,
        automaticallyImplyLeading: false,
        leading: _isCreating
            ? const AppBackButton(fallbackLocation: RoutePath.collections)
            : null,
        title: Text(
          _isCreating ? l10n.newCollection : l10n.editCollection,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (!_isCreating)
            IconButton(
              onPressed: _handleCloseRequest,
              icon: Icon(Icons.close, color: colorScheme.onSurface),
              tooltip: l10n.semanticsClose,
            ),
        ],
      ),
      body: _buildBody(context, collectionsAsync),
    );

    if (_isCreating) {
      return scaffold;
    }
    return ListenableBuilder(
      listenable: Listenable.merge([_nameController, _descriptionController]),
      builder: (context, child) => PopScope<Object?>(
        canPop: _exitAllowed || !_hasChanges,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            _handleCloseRequest();
          }
        },
        child: child!,
      ),
      child: scaffold,
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncValue<List<CollectionsEntity>> collectionsAsync,
  ) {
    if (_isCreating || _initial != null) {
      return _buildForm(context);
    }
    if (collectionsAsync.hasError && !collectionsAsync.hasValue) {
      return Center(
        child: ErrorMessageWidget(
          error: collectionsAsync.error,
          stackTrace: collectionsAsync.stackTrace,
        ),
      );
    }
    if (collectionsAsync.hasValue) {
      // Loaded, but this collection no longer exists.
      return const Center(child: ErrorMessageWidget());
    }
    return Center(
      child: CircularProgressIndicator(
        semanticsLabel: AppLocalizations.of(context).semanticsLoading,
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final Color? badgeSectionColor = _showBadgeError ? colorScheme.error : null;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: MaxWidthWrapper(
              scrollController: _scrollController,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CollectionFormFields(
                            nameController: _nameController,
                            descriptionController: _descriptionController,
                          ),
                          const SizedBox(height: 32),
                          Semantics(
                            header: true,
                            child: Text(
                              l10n.badgesInCollection,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color:
                                    badgeSectionColor ?? colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Semantics(
                            liveRegion: _showBadgeError,
                            child: Text(
                              l10n.badgesInCollectionHelper,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color:
                                    badgeSectionColor ??
                                    colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    sliver: _buildBadgeList(context),
                  ),
                ],
              ),
            ),
          ),
          CollectionActionBar(
            children: [
              PrimaryButton(
                text: l10n.save,
                onPressed: _handleSave,
                isLoading: _isSaving,
              ),
              if (_isCreating)
                CustomOutlinedButton(
                  text: l10n.cancel,
                  onPressed: _isSaving ? null : _close,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeList(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ref
        .watch(badgesOverviewProvider)
        .when(
          data: (badgesState) {
            final badges = _selectableBadges(badgesState.claimedBadges);
            if (badges.isEmpty) {
              return SliverToBoxAdapter(
                child: Text(
                  l10n.noBadgesAvailable,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            return SelectableBadgeSliverList(
              badges: badges,
              selectedBadgeIds: _selectedBadgeIds,
              onToggle: _toggleBadge,
            );
          },
          loading: () => SliverToBoxAdapter(
            child: Center(
              child: CircularProgressIndicator(
                semanticsLabel: l10n.semanticsLoading,
              ),
            ),
          ),
          error: (error, stackTrace) => SliverToBoxAdapter(
            child: ErrorMessageWidget(error: error, stackTrace: stackTrace),
          ),
        );
  }
}
