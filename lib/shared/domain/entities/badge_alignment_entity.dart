import 'package:equatable/equatable.dart';

class BadgeAlignmentEntity extends Equatable {
  final String? targetName;
  final String? targetUrl;
  final String? targetDescription;
  final String? targetFramework;
  final String? targetCode;

  const BadgeAlignmentEntity({
    this.targetName,
    this.targetUrl,
    this.targetDescription,
    this.targetFramework,
    this.targetCode,
  });

  @override
  List<Object?> get props => [
        targetName,
        targetUrl,
        targetDescription,
        targetFramework,
        targetCode,
      ];
}
