import 'package:edubadges/features/account/domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.entityId,
    required super.marketingOptIn,
    super.institution,
    required super.isSuperuser,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      entityId: json['entity_id'] as String? ?? '',
      marketingOptIn: json['marketing_opt_in'] as bool? ?? false,
      institution: json['institution'] as String?,
      isSuperuser: json['is_superuser'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'entity_id': entityId,
      'marketing_opt_in': marketingOptIn,
      'institution': institution,
      'is_superuser': isSuperuser,
    };
  }
}


