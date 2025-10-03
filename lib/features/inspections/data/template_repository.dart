import 'package:layout_tests/features/template_inspections/models/inspection_template.dart';

abstract class TemplateRepository {
  Future<List<InspectionTemplate>> getTemplates();
  Future<InspectionTemplate> getTemplateById(String id);
}
