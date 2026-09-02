import 'package:edubadges/shared/data/models/badge_instance_model.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BadgeInstanceModel recipient fields', () {
    test('parses recipient info from a direct award detail payload', () {
      final model = BadgeInstanceModel.fromJson({
        'id': 9596,
        'created_at': '2026-01-16T10:56:44.293475+01:00',
        'entity_id': 'y8uStIzMQ--JY59DIKnvWw',
        'award_type': 'direct',
        'acceptance': 'Unaccepted',
        'public': false,
        'revoked': false,
        'badgeclass': {
          'id': 6,
          'name': 'test direct award',
          'entity_id': 'B3uWEIZSTh6wniHBbzVtbA',
          'badge_class_type': 'regular',
          'image': 'https://example.com/badge.png',
        },
        'eppn': null,
        'recipient_email': 'henk@example.com',
        'recipient_first_name': 'Henk',
        'recipient_surname': 'de Vries',
      });

      expect(model.eppn, isNull);
      expect(model.recipientEmail, 'henk@example.com');
      expect(model.recipientFirstName, 'Henk');
      expect(model.recipientSurname, 'de Vries');
      expect(model.recipientFullName, 'Henk de Vries');
      expect(model.isAwardedToPrivateEmail, isTrue);
      expect(model.acceptance, BadgeAcceptance.unaccepted);
    });

    test(
      'keeps recipient fields optional when the list payload omits them',
      () {
        final model = BadgeInstanceModel.fromJson({
          'id': 9606,
          'created_at': '2026-01-23T16:19:08.699037+01:00',
          'entity_id': 'Lgnh9njyStmGiI_w8396Xg',
          'award_type': 'direct',
          'acceptance': 'Unaccepted',
          'public': false,
          'revoked': false,
          'badgeclass': {
            'id': 113,
            'name': 'unclaimed test',
            'entity_id': 'X4MQyOYPS9yoMyZwZik1Jg',
            'badge_class_type': 'regular',
            'image': 'https://example.com/badge.png',
          },
        });

        expect(model.hasRecipientDetails, isFalse);
        expect(model.isAwardedToPrivateEmail, isFalse);
      },
    );
  });
}
