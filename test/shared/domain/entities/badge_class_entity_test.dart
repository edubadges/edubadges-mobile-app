import 'package:edubadges/features/badge_details/domain/constants/badge_extensions.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/domain/entities/badge_class_entity.dart';
import 'package:edubadges/shared/domain/entities/badge_class_extension_entity.dart';
import 'package:edubadges/shared/domain/enums/badge_class_type.dart';
import 'package:flutter_test/flutter_test.dart';

BadgeClassModel _badgeClass(Object? ects) {
  return BadgeClassModel(
    id: 1,
    name: 'Test badge',
    entityId: 'badge-1',
    badgeClassType: BadgeClassType.regular,
    image: 'https://example.com/badge.png',
    badgeclassextensionSet: [
      BadgeClassExtensionEntity(name: BadgeExtensionKeys.ects, value: ects),
      const BadgeClassExtensionEntity(
        name: BadgeExtensionKeys.language,
        value: 'nl_NL',
      ),
    ],
  );
}

void main() {
  group('BadgeClassEntity.getExtensionValue', () {
    // SURF-676: the release Wasm build minifies type names, so the conversion
    // cannot depend on T.toString(); a failed cast blanked the details page.
    test('reads a whole number as a double', () {
      final double? ects = _badgeClass(
        5,
      ).getExtensionValue<double?>(BadgeExtensionKeys.ects);

      expect(ects, 5.0);
      expect(ects, isA<double>());
    });

    test('keeps a fractional value', () {
      expect(
        _badgeClass(2.5).getExtensionValue<double?>(BadgeExtensionKeys.ects),
        2.5,
      );
    });

    test('leaves an int as int when an int is asked for', () {
      expect(
        _badgeClass(5).getExtensionValue<int?>(BadgeExtensionKeys.ects),
        5,
      );
    });

    test('returns null for a missing extension', () {
      expect(
        _badgeClass(null).getExtensionValue<double?>(BadgeExtensionKeys.ects),
        isNull,
      );
      expect(
        _badgeClass(5).getExtensionValue<String?>(BadgeExtensionKeys.eQF),
        isNull,
      );
    });

    test('reads a string value', () {
      expect(
        _badgeClass(5).getExtensionValue<String?>(BadgeExtensionKeys.language),
        'nl_NL',
      );
    });
  });
}
