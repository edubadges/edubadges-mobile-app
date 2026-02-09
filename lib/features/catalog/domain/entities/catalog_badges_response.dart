import 'package:edubadges/features/catalog/domain/entities/catalog_badge.dart';
import 'package:equatable/equatable.dart';

class CatalogBadgesResponse extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final List<CatalogBadge> results;

  const CatalogBadgesResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  bool get hasMore => next != null;

  @override
  List<Object?> get props => [count, next, previous, results];
}
