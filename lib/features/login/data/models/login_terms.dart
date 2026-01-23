class LoginTerms {
  final String termsType;
  final String? institution;

  LoginTerms({
    required this.termsType,
    this.institution,
  });

  factory LoginTerms.fromJson(Map<String, dynamic> json) {
    final institutionData = json['institution'];
    String? institutionName;
    if (institutionData is Map<String, dynamic>) {
      institutionName = institutionData['name'] as String?;
    } else if (institutionData is String) {
      institutionName = institutionData;
    }

    return LoginTerms(
      termsType: json['terms_type'] as String? ?? '',
      institution: institutionName,
    );
  }

  Map<String, dynamic> toJson() => {
    'terms_type': termsType,
    'institution': institution,
  };
}
