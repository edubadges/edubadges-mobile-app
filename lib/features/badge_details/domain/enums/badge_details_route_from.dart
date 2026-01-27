enum BadgeDetailsRouteFrom { overview, other }

extension BadgeDetailsRouteFromExtension on BadgeDetailsRouteFrom {
  String toValue() {
    switch (this) {
      case BadgeDetailsRouteFrom.overview:
        return 'overview';
      case BadgeDetailsRouteFrom.other:
        return 'other';
    }
  }

  static BadgeDetailsRouteFrom fromString(String? value) {
    switch (value) {
      case 'overview':
        return BadgeDetailsRouteFrom.overview;
      case 'other':
      default:
        return BadgeDetailsRouteFrom.other;
    }
  }
}