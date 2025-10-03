part of 'inspection_bloc.dart';

abstract class InspectionEvent extends Equatable {
  const InspectionEvent();

  @override
  List<Object?> get props => [];
}

class LoadInspections extends InspectionEvent {
  const LoadInspections();
}

class SearchInspections extends InspectionEvent {
  final String query;

  const SearchInspections(this.query);

  @override
  List<Object?> get props => [query];
}

class SelectInspection extends InspectionEvent {
  final Inspection inspection;

  const SelectInspection(this.inspection);

  @override
  List<Object?> get props => [inspection];
}

class CloseInspectionDetails extends InspectionEvent {
  const CloseInspectionDetails();
}

class DeleteInspection extends InspectionEvent {
  final String inspectionId;

  const DeleteInspection(this.inspectionId);

  @override
  List<Object?> get props => [inspectionId];
}

class DuplicateInspection extends InspectionEvent {
  final String inspectionId;

  const DuplicateInspection(this.inspectionId);

  @override
  List<Object?> get props => [inspectionId];
}

class RefreshInspections extends InspectionEvent {
  const RefreshInspections();
}
