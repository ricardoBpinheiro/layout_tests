class TemplateEmailSettings {
  final List<String> to;
  final String subjectTemplate;
  final String bodyTemplate;

  TemplateEmailSettings({
    required this.to,
    required this.subjectTemplate,
    required this.bodyTemplate,
  });

  Map<String, dynamic> toJson() => {
    'to': to,
    'subjectTemplate': subjectTemplate,
    'bodyTemplate': bodyTemplate,
  };

  factory TemplateEmailSettings.fromJson(Map<String, dynamic> json) =>
      TemplateEmailSettings(
        to: List<String>.from(json['to'] ?? []),
        subjectTemplate: json['subjectTemplate'] ?? '',
        bodyTemplate: json['bodyTemplate'] ?? '',
      );
}