class LoginTermsUrl {
  final String url;
  final String language;
  final bool excerpt;

  LoginTermsUrl({
    required this.url,
    required this.language,
    required this.excerpt,
  });

  factory LoginTermsUrl.fromJson(Map<String, dynamic> json) {
    return LoginTermsUrl(
      url: json['url'] as String? ?? '',
      language: json['language'] as String? ?? '',
      excerpt: json['excerpt'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'language': language,
    'excerpt': excerpt,
  };
}
