import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:edubadges/shared/domain/enums/badge_class_type.dart';
import 'package:flutter_test/flutter_test.dart';

BadgeInstanceEntity _award({
  String? eppn,
  String? recipientEmail,
  String? recipientFirstName,
  String? recipientSurname,
}) {
  return BadgeInstanceEntity(
    id: 1,
    createdAt: DateTime.utc(2026, 8, 25),
    entityId: 'award-1',
    awardType: 'direct',
    revoked: false,
    acceptance: BadgeAcceptance.unaccepted,
    public: false,
    badgeclass: const BadgeClassModel(
      id: 1,
      name: 'Test badge',
      entityId: 'badge-1',
      badgeClassType: BadgeClassType.regular,
      image: 'https://example.com/badge.png',
    ),
    eppn: eppn,
    recipientEmail: recipientEmail,
    recipientFirstName: recipientFirstName,
    recipientSurname: recipientSurname,
  );
}

void main() {
  group('BadgeInstanceEntity recipient details', () {
    test('joins first name and surname', () {
      final award = _award(
        recipientFirstName: 'Henk',
        recipientSurname: 'de Vries',
      );

      expect(award.recipientFullName, 'Henk de Vries');
    });

    test('ignores blank name parts', () {
      expect(_award(recipientFirstName: 'Henk').recipientFullName, 'Henk');
      expect(_award(recipientSurname: '  ').recipientFullName, isNull);
    });

    test('detects a private email award when eppn is missing', () {
      final award = _award(
        recipientEmail: 'henk@example.com',
        recipientFirstName: 'Henk',
        recipientSurname: 'de Vries',
      );

      expect(award.isAwardedToPrivateEmail, isTrue);
      expect(award.shouldConfirmPrivateEmailName, isTrue);
    });

    test('does not treat an EPPN award as a private email award', () {
      final award = _award(
        eppn: 'henk@university-example.org',
        recipientEmail: 'henk@example.com',
        recipientFirstName: 'Henk',
        recipientSurname: 'de Vries',
      );

      expect(award.isAwardedToPrivateEmail, isFalse);
      expect(award.shouldConfirmPrivateEmailName, isFalse);
    });

    test('does not confirm when the recipient name is missing', () {
      final award = _award(recipientEmail: 'henk@example.com');

      expect(award.isAwardedToPrivateEmail, isTrue);
      expect(award.shouldConfirmPrivateEmailName, isFalse);
    });
  });
}
