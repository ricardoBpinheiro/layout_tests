import 'package:layout_tests/features/inspections/models/inspection.dart';

abstract class InspectionRepository {
  Future<List<Inspection>> getInspections();
  Future<void> deleteInspection(String id);
  Future<Inspection> duplicateInspection(String id);
  Future<Inspection> getInspectionById(String id);
}
