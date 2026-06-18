import 'package:edubadges/l10n/app_localizations.dart';

enum AssessmentType {
  writtenExam('written_exam'),
  reportPaper('report_paper'),
  behaviouralAssessment('behavioural_assessment'),
  professionalProduct('professional_product'),
  developmentReport('development_report'),
  portfolioAssessment('portfolio_assessment'),
  oramExam('oram_exam'),
  personalizedAssessment('personalized_assessment');

  final String value;

  const AssessmentType(this.value);

  static AssessmentType? fromString(String? value) {
    if (value == null) return null;

    try {
      return AssessmentType.values.firstWhere(
        (type) => type.value == value,
      );
    } catch (_) {
      return null;
    }
  }

  static List<AssessmentType>? fromCommaSeparatedString(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final list = value
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map(fromString)
        .whereType<AssessmentType>()
        .toList();
    return list.isEmpty ? null : list;
  }
}

extension AssessmentTypeLocalization on AssessmentType {
  String getLocalizedName(AppLocalizations l10n) {
    return switch (this) {
      AssessmentType.writtenExam => l10n.assessmentWrittenExam,
      AssessmentType.reportPaper => l10n.assessmentReportPaper,
      AssessmentType.behaviouralAssessment => l10n.assessmentBehaviouralAssessment,
      AssessmentType.professionalProduct => l10n.assessmentProfessionalProduct,
      AssessmentType.developmentReport => l10n.assessmentDevelopmentReport,
      AssessmentType.portfolioAssessment => l10n.assessmentPortfolioAssessment,
      AssessmentType.oramExam => l10n.assessmentOramExam,
      AssessmentType.personalizedAssessment => l10n.assessmentPersonalizedAssessment,
    };
  }
}