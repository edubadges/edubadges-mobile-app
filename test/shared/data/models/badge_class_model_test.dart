import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _minimalBadgeClassJson({
  Map<String, dynamic>? enrollmentFields,
}) {
  return {
    'id': 1,
    'name': 'Test badge',
    'entity_id': 'badge-entity-id',
    'badge_class_type': 'regular',
    'image': 'https://example.com/badge.png',
    ...?enrollmentFields,
  };
}

void main() {
  group('BadgeClassModel enrollment mapping', () {
    test('reads self_enrollment_enabled from the confirmed backend field', () {
      final model = BadgeClassModel.fromJson(
        _minimalBadgeClassJson(
          enrollmentFields: {
            'self_enrollment_enabled': true,
            'user_may_enroll': true,
          },
        ),
      );

      expect(model.selfEnrollmentEnabled, isTrue);
      expect(model.userMayEnroll, isTrue);
    });

    test('falls back to enrollment_enabled when the confirmed key is absent', () {
      final model = BadgeClassModel.fromJson(
        _minimalBadgeClassJson(
          enrollmentFields: {
            'enrollment_enabled': true,
            'user_may_enroll': true,
          },
        ),
      );

      expect(model.selfEnrollmentEnabled, isTrue);
      expect(model.userMayEnroll, isTrue);
    });

    test('prefers self_enrollment_enabled when both enrollment keys are present', () {
      final model = BadgeClassModel.fromJson(
        _minimalBadgeClassJson(
          enrollmentFields: {
            'self_enrollment_enabled': false,
            'enrollment_enabled': true,
            'user_may_enroll': false,
          },
        ),
      );

      expect(model.selfEnrollmentEnabled, isFalse);
      expect(model.userMayEnroll, isFalse);
    });

    test('defaults enrollment flags to false when neither key is present', () {
      final model = BadgeClassModel.fromJson(_minimalBadgeClassJson());

      expect(model.selfEnrollmentEnabled, isFalse);
      expect(model.userMayEnroll, isFalse);
    });

    test('parses string booleans for enrollment flags', () {
      final model = BadgeClassModel.fromJson(
        _minimalBadgeClassJson(
          enrollmentFields: {
            'self_enrollment_enabled': 'true',
            'user_may_enroll': 'true',
          },
        ),
      );

      expect(model.selfEnrollmentEnabled, isTrue);
      expect(model.userMayEnroll, isTrue);
    });
  });
}
