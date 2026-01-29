import 'package:edubadges/core/network/api_client.dart';
import 'package:edubadges/core/network/errors/error_codes.dart';
import 'package:edubadges/core/network/errors/exceptions.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';

abstract class BadgeDetailsDataSource {
  Future<BadgeInstanceModel> getBadgeDetails(String entityId);
  Future<void> updateBadgeVisibility(
    String entityId,
    bool isPublic,
    bool includeEvidence,
    bool includeGradeAchieved,
  );
}

class BadgeDetailsDataSourceImpl implements BadgeDetailsDataSource {
  final ApiClient apiClient;

  BadgeDetailsDataSourceImpl(this.apiClient);

  @override
  Future<BadgeInstanceModel> getBadgeDetails(String entityId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/badge-instances/$entityId',
    );

    if (response.data == null) {
      throw ParsingException(
        message: 'No data received for badge details',
        code: ErrorCodes.parsingError,
      );
    }

    try {
      return BadgeInstanceModel.fromJson(response.data!);
    } catch (e, stackTrace) {
      throw ParsingException(
        message: 'Failed to parse badge details: ${e.toString()}',
        code: ErrorCodes.parsingError,
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateBadgeVisibility(
    String entityId,
    bool isPublic,
    bool includeEvidence,
    bool includeGradeAchieved,
  ) async {
    await apiClient.put<void>(
      '/badge-instances/$entityId',
      data: {
        'public': isPublic,
        'include_evidence': includeEvidence,
        'include_grade_achieved': includeGradeAchieved,
      },
    );
  }
}
