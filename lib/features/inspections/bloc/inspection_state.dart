part of 'inspection_bloc.dart';

abstract class InspectionState extends Equatable {
  const InspectionState();

  List<Object?> get props => [];
}

class InspectionInitial extends InspectionState {
  const InspectionInitial();
}

class InspectionLoading extends InspectionState {
  const InspectionLoading();
}

class InspectionLoaded extends InspectionState {
  final List<Inspection> inspections;
  final List<Inspection> filteredInspections;
  final Inspection? selectedInspection;
  final bool showDetailsPanel;
  final String searchQuery;

  const InspectionLoaded({
    required this.inspections,
    required this.filteredInspections,
    this.selectedInspection,
    this.showDetailsPanel = false,
    this.searchQuery = '',
  });

  InspectionLoaded copyWith({
    List<Inspection>? inspections,
    List<Inspection>? filteredInspections,
    Inspection? selectedInspection,
    bool? showDetailsPanel,
    String? searchQuery,
    bool clearSelection = false,
  }) {
    return InspectionLoaded(
      inspections: inspections ?? this.inspections,
      filteredInspections: filteredInspections ?? this.filteredInspections,
      selectedInspection: clearSelection
          ? null
          : (selectedInspection ?? this.selectedInspection),
      showDetailsPanel: showDetailsPanel ?? this.showDetailsPanel,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    inspections,
    filteredInspections,
    selectedInspection,
    showDetailsPanel,
    searchQuery,
  ];
}

class InspectionError extends InspectionState {
  final String message;

  const InspectionError(this.message);

  @override
  List<Object?> get props => [message];
}

class InspectionDeleting extends InspectionState {
  const InspectionDeleting();
}

class InspectionDeleted extends InspectionState {
  const InspectionDeleted();
}

class InspectionDuplicating extends InspectionState {
  const InspectionDuplicating();
}

class InspectionDuplicated extends InspectionState {
  final Inspection duplicatedInspection;

  const InspectionDuplicated(this.duplicatedInspection);

  @override
  List<Object?> get props => [duplicatedInspection];
}
