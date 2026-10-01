import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/core/utils/string.dart';
import 'package:edubadges/features/catalog/domain/entities/catalog_institution.dart';
import 'package:edubadges/features/catalog/domain/enums/catalog_institution_type.dart';
import 'package:edubadges/features/catalog/presentation/providers/institution_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CatalogFilters extends ConsumerStatefulWidget {
  final void Function(CatalogInstitutionType?)? onLevelChanged;
  final void Function(String?)? onInstitutionChanged;
  final void Function(String)? onSearchSubmitted;

  const CatalogFilters({
    super.key,
    this.onLevelChanged,
    this.onInstitutionChanged,
    this.onSearchSubmitted,
  });

  @override
  ConsumerState<CatalogFilters> createState() => _CatalogFiltersState();
}

class _CatalogFiltersState extends ConsumerState<CatalogFilters> {
  CatalogInstitutionType? _selectedLevel;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _institutionController = TextEditingController();
  CatalogInstitution? _selectedInstitution;

  static const searchBorderRadius = BorderRadius.all(Radius.circular(8));

  @override
  void dispose() {
    _searchController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.filters,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: l10n.allLevels,
                  level: null,
                  colorScheme: colorScheme,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: l10n.mbo,
                  level: CatalogInstitutionType.MBO,
                  colorScheme: colorScheme,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: l10n.hbo,
                  level: CatalogInstitutionType.HBO,
                  colorScheme: colorScheme,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: l10n.wo,
                  level: CatalogInstitutionType.WO,
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInstitutionAutocomplete(l10n),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.catalogSearchPlaceholder,
              labelText: l10n.search,
              prefixIcon: const ExcludeSemantics(child: Icon(Icons.search)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                        widget.onSearchSubmitted?.call('');
                      },
                      tooltip: l10n.semanticsClearSearch,
                    )
                  : null,
              border: const OutlineInputBorder(
                borderRadius: searchBorderRadius,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              widget.onSearchSubmitted?.call(value);
            },
            onChanged: (value) {
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required CatalogInstitutionType? level,
    required ColorScheme colorScheme,
  }) {
    final textScaler = MediaQuery.textScalerOf(context);
    final isSelected = _selectedLevel == level;

    void onChipTap() {
      setState(() {
        _selectedLevel = level;
      });
      widget.onLevelChanged?.call(level);
    }

    return Semantics(
      selected: isSelected,
      child: MergeSemantics(
        child: InkWell(
          onTap: onChipTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: textScaler.scale(34),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstitutionAutocomplete(AppLocalizations l10n) {
    final institutionsAsync = ref.watch(catalogInstitutionsProvider);
    final String lang = ref.watch(appLanguageProvider).code;

    String institutionName(CatalogInstitution institution) {
      return getLocalizedString(
        institution.nameDutch,
        institution.nameEnglish,
        lang,
      );
    }

    final CatalogInstitution? selectedInstitution = _selectedInstitution;

    return institutionsAsync.when(
      data: (institutions) {
        return Autocomplete<CatalogInstitution>(
          // Recreated when the app language changes, so a selected institution
          // shows its name in the new language. Anything typed is kept.
          key: ValueKey<String>(lang),
          initialValue: TextEditingValue(
            text: selectedInstitution != null
                ? institutionName(selectedInstitution)
                : _institutionController.text,
          ),
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<CatalogInstitution>.empty();
            }
            return institutions.where((institution) {
              return institution.matchesSearch(textEditingValue.text);
            });
          },
          displayStringForOption: institutionName,
          fieldViewBuilder:
              (
                BuildContext context,
                TextEditingController fieldTextEditingController,
                FocusNode fieldFocusNode,
                VoidCallback onFieldSubmitted,
              ) {
                _institutionController.text = fieldTextEditingController.text;

                return TextField(
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                  decoration: InputDecoration(
                    labelText: l10n.institution,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: l10n.allInstitutions,
                    border: const OutlineInputBorder(
                      borderRadius: searchBorderRadius,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: _selectedInstitution != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              fieldTextEditingController.clear();
                              setState(() {
                                _selectedInstitution = null;
                              });
                              widget.onInstitutionChanged?.call(null);
                            },
                            tooltip: l10n.semanticsClearFilter,
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    if (value.isEmpty && _selectedInstitution != null) {
                      setState(() {
                        _selectedInstitution = null;
                      });
                      widget.onInstitutionChanged?.call(null);
                    }
                  },
                );
              },
          onSelected: (CatalogInstitution selection) {
            setState(() {
              _selectedInstitution = selection;
            });
            widget.onInstitutionChanged?.call(selection.entityId);
          },
          optionsViewBuilder:
              (
                BuildContext context,
                AutocompleteOnSelected<CatalogInstitution> onSelected,
                Iterable<CatalogInstitution> options,
              ) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(4),
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 200,
                        maxWidth: 400,
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final CatalogInstitution option = options.elementAt(
                            index,
                          );
                          return InkWell(
                            onTap: () {
                              onSelected(option);
                            },
                            child: ListTile(
                              title: Text(
                                institutionName(option),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
        );
      },
      loading: () => TextField(
        enabled: false,
        decoration: InputDecoration(
          labelText: l10n.allInstitutions,
          hintText: l10n.allInstitutions,
          border: const OutlineInputBorder(borderRadius: searchBorderRadius),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          suffixIcon: SizedBox(
            width: 20,
            height: 20,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                semanticsLabel: AppLocalizations.of(context).semanticsLoading,
              ),
            ),
          ),
        ),
      ),
      error: (error, stack) => TextField(
        enabled: false,
        decoration: InputDecoration(
          labelText: l10n.allInstitutions,
          hintText: l10n.allInstitutions,
          border: const OutlineInputBorder(borderRadius: searchBorderRadius),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          errorText: l10n.catalogFailedToLoadInstitutions,
        ),
      ),
    );
  }
}
