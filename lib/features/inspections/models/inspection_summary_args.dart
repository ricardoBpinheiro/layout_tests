import 'package:layout_tests/features/template_inspections/models/inspection_template.dart';

class InspectionSummaryArgs {
  final InspectionTemplate template;
  final Map<String, dynamic> answers;
  final int finalScore;
  final String inspectorName;
  final DateTime finishedAt;
  final List<MediaItem> media; // fotos/arquivos adicionados

  InspectionSummaryArgs({
    required this.template,
    required this.answers,
    required this.finalScore,
    required this.inspectorName,
    required this.finishedAt,
    required this.media,
  });
}

class MediaItem {
  final String id;
  final String name;
  final String url; // pode ser file path / network
  final String? mimeType; // image/*, application/pdf, etc.
  final DateTime? createdAt;

  MediaItem({
    required this.id,
    required this.name,
    required this.url,
    this.mimeType,
    this.createdAt,
  });
}
