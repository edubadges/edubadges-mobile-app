import 'package:edubadges/core/network/api_client.dart';
import 'package:edubadges/core/network/errors/error_codes.dart';
import 'package:edubadges/core/network/errors/exceptions.dart';
import 'package:edubadges/core/utils/logger.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';

abstract class BadgesOverviewDataSource {
  Future<List<BadgeInstanceModel>> getBadgeInstances();
  Future<List<BadgeInstanceModel>> getDirectAwards();
  Future<List<BadgeInstanceModel>> getEnrollments();
  Future<void> claimBadge(String entityId);
  Future<void> declineBadge(String entityId);
}

class BadgesOverviewDataSourceImpl implements BadgesOverviewDataSource {
  final ApiClient apiClient;

  BadgesOverviewDataSourceImpl(this.apiClient);

  @override
  Future<List<BadgeInstanceModel>> getBadgeInstances() async {
    final response = await apiClient.get<List<dynamic>>('/badge-instances');
    final data = response.data ?? [];

    try {
      return data.map((json) {
        if (json is! Map<String, dynamic>) {
          throw const FormatException('Invalid badge instance format');
        }
        return BadgeInstanceModel.fromJson(json);
      }).toList();
    } catch (e, stackTrace) {
      throw ParsingException(
        message: 'Failed to parse badge instances: ${e.toString()}',
        code: ErrorCodes.parsingError,
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // THIS IS THE BEST I COULD DO WITH THEIR RESPONSE STRUCTURE, IT WOULD BE BETTER IF THEY RETURNED A LIST OF BADGE INSTANCES
  @override
  Future<List<BadgeInstanceModel>> getDirectAwards() async {
    final response = await apiClient.get<dynamic>('/direct-awards');
    dynamic data = response.data;

    if (data is Map<String, dynamic>) {
      data = data['results'] ?? data['data'] ?? data['badges'] ?? [];
    }

    if (data is! List) {
      logger.w(
        'Direct Awards: Expected List but got ${data.runtimeType}. Using empty list.',
      );
      return [];
    }

    try {
      return data.map((json) {
        if (json is! Map<String, dynamic>) {
          logger.w('Direct Awards: Invalid item format: ${json.runtimeType}');
          throw FormatException(
            'Invalid direct award format: expected Map, got ${json.runtimeType}',
          );
        }

        // Transform direct award response to match BadgeInstanceModel structure
        final transformedJson = Map<String, dynamic>.from(json);

        if (!transformedJson.containsKey('issued_on') &&
            transformedJson.containsKey('created_at')) {
          transformedJson['issued_on'] = transformedJson['created_at'];
        }

        transformedJson['award_type'] ??= 'direct';
        transformedJson['acceptance'] ??= 'Unaccepted';
        transformedJson['public'] ??= false;
        transformedJson['revoked'] ??= false;

        return BadgeInstanceModel.fromJson(transformedJson);
      }).toList();
    } catch (e, stackTrace) {
      logger.e(
        'Failed to parse direct awards',
        error: e,
        stackTrace: stackTrace,
      );
      throw ParsingException(
        message: 'Failed to parse direct awards: ${e.toString()}',
        code: ErrorCodes.parsingError,
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<BadgeInstanceModel>> getEnrollments() async {
    final response = await apiClient.get<dynamic>('/enrollments');
    dynamic data = response.data;

    if (data is Map<String, dynamic>) {
      data =
          data['results'] ??
          data['data'] ??
          data['badges'] ??
          data['enrollments'] ??
          [];
    }

    if (data is! List) {
      logger.w(
        'Enrollments: Expected List but got ${data.runtimeType}. Using empty list.',
      );
      return [];
    }

    try {
      return data.map((json) {
        if (json is! Map<String, dynamic>) {
          logger.w('Enrollments: Invalid item format: ${json.runtimeType}');
          throw FormatException(
            'Invalid enrollment format: expected Map, got ${json.runtimeType}',
          );
        }

        // Transform enrollment response to match BadgeInstanceModel structure
        final transformedJson = <String, dynamic>{
          'id': json['id'],
          'entity_id': json['entity_id'],
        };

        transformedJson['created_at'] = json['created_at'];
        transformedJson['issued_on'] = json['issued_on'];
        transformedJson['award_type'] = 'requested';
        transformedJson['acceptance'] = json['denied'] == true
            ? 'Rejected'
            : 'Unaccepted';
        transformedJson['public'] = false;
        transformedJson['revoked'] = false;
        transformedJson['badgeclass'] = json['badgeclass'];

        return BadgeInstanceModel.fromJson(transformedJson);
      }).toList();
    } catch (e, stackTrace) {
      logger.e('Failed to parse enrollments', error: e, stackTrace: stackTrace);
      throw ParsingException(
        message: 'Failed to parse enrollments: ${e.toString()}',
        code: ErrorCodes.parsingError,
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> claimBadge(String entityId) async {
    await apiClient.post(
      '/direct-awards-accept/$entityId',
      queryParameters: {'accept': 'true'},
      data: {'entity_id': entityId, 'accept': true},
    );
  }

  @override
  Future<void> declineBadge(String entityId) async {
    await apiClient.post(
      '/direct-awards-accept/$entityId',
      queryParameters: {'accept': 'false'},
      data: {'entity_id': entityId, 'accept': false},
    );
  }
}
