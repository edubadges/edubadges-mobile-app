enum BadgeDetailsRouteFrom { overview, catalog, collection, other }

extension BadgeDetailsRouteFromExtension on BadgeDetailsRouteFrom {
  String toValue() {
    switch (this) {
      case BadgeDetailsRouteFrom.overview:
        return 'overview';
      case BadgeDetailsRouteFrom.catalog:
        return 'catalog';
      case BadgeDetailsRouteFrom.collection:
        return 'collection';
      case BadgeDetailsRouteFrom.other:
        return 'other';
    }
  }

  static BadgeDetailsRouteFrom fromString(String? value) {
    switch (value) {
      case 'overview':
        return BadgeDetailsRouteFrom.overview;
      case 'catalog':
        return BadgeDetailsRouteFrom.catalog;
      case 'collection':
        return BadgeDetailsRouteFrom.collection;
      case 'other':
      default:
        return BadgeDetailsRouteFrom.other;
    }
  }
}