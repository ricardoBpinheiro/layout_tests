import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:layout_tests/features/inspections/data/inspection_repository.dart';
import 'package:layout_tests/features/inspections/models/inspection.dart';

part 'inspection_event.dart';
part 'inspection_state.dart';

class InspectionBloc extends Bloc<InspectionEvent, InspectionState> {
  final InspectionRepository repository;

  InspectionBloc({required this.repository})
    : super(const InspectionInitial()) {
    on<LoadInspections>(_onLoadInspections);
    on<SearchInspections>(_onSearchInspections);
    on<SelectInspection>(_onSelectInspection);
    on<CloseInspectionDetails>(_onCloseInspectionDetails);
    on<DeleteInspection>(_onDeleteInspection);
    on<DuplicateInspection>(_onDuplicateInspection);
    on<RefreshInspections>(_onRefreshInspections);
  }

  Future<void> _onLoadInspections(
    LoadInspections event,
    Emitter<InspectionState> emit,
  ) async {
    emit(const InspectionLoading());
    try {
      final inspections = await repository.getInspections();
      emit(
        InspectionLoaded(
          inspections: inspections,
          filteredInspections: inspections,
        ),
      );
    } catch (e) {
      emit(InspectionError('Erro ao carregar inspeções: ${e.toString()}'));
    }
  }

  Future<void> _onSearchInspections(
    SearchInspections event,
    Emitter<InspectionState> emit,
  ) async {
    if (state is InspectionLoaded) {
      final currentState = state as InspectionLoaded;
      final query = event.query.toLowerCase();

      if (query.isEmpty) {
        emit(
          currentState.copyWith(
            filteredInspections: currentState.inspections,
            searchQuery: query,
          ),
        );
      } else {
        final filtered = currentState.inspections.where((inspection) {
          return inspection.templateName.toLowerCase().contains(query) ||
              inspection.sector.toLowerCase().contains(query) ||
              inspection.documentNumber.toLowerCase().contains(query) ||
              inspection.responsibleName.toLowerCase().contains(query);
        }).toList();

        emit(
          currentState.copyWith(
            filteredInspections: filtered,
            searchQuery: query,
          ),
        );
      }
    }
  }

  Future<void> _onSelectInspection(
    SelectInspection event,
    Emitter<InspectionState> emit,
  ) async {
    if (state is InspectionLoaded) {
      final currentState = state as InspectionLoaded;
      emit(
        currentState.copyWith(
          selectedInspection: event.inspection,
          showDetailsPanel: true,
        ),
      );
    }
  }

  Future<void> _onCloseInspectionDetails(
    CloseInspectionDetails event,
    Emitter<InspectionState> emit,
  ) async {
    if (state is InspectionLoaded) {
      final currentState = state as InspectionLoaded;
      emit(
        currentState.copyWith(showDetailsPanel: false, clearSelection: true),
      );
    }
  }

  Future<void> _onDeleteInspection(
    DeleteInspection event,
    Emitter<InspectionState> emit,
  ) async {
    if (state is InspectionLoaded) {
      final currentState = state as InspectionLoaded;
      emit(const InspectionDeleting());

      try {
        await repository.deleteInspection(event.inspectionId);

        final updatedInspections = currentState.inspections
            .where((inspection) => inspection.id != event.inspectionId)
            .toList();

        final updatedFiltered = currentState.filteredInspections
            .where((inspection) => inspection.id != event.inspectionId)
            .toList();

        emit(const InspectionDeleted());

        emit(
          InspectionLoaded(
            inspections: updatedInspections,
            filteredInspections: updatedFiltered,
            searchQuery: currentState.searchQuery,
          ),
        );
      } catch (e) {
        emit(InspectionError('Erro ao excluir inspeção: ${e.toString()}'));
        emit(currentState);
      }
    }
  }

  Future<void> _onDuplicateInspection(
    DuplicateInspection event,
    Emitter<InspectionState> emit,
  ) async {
    if (state is InspectionLoaded) {
      final currentState = state as InspectionLoaded;
      emit(const InspectionDuplicating());

      try {
        final duplicated = await repository.duplicateInspection(
          event.inspectionId,
        );

        final updatedInspections = [...currentState.inspections, duplicated];
        final updatedFiltered = [
          ...currentState.filteredInspections,
          duplicated,
        ];

        emit(InspectionDuplicated(duplicated));

        emit(
          InspectionLoaded(
            inspections: updatedInspections,
            filteredInspections: updatedFiltered,
            searchQuery: currentState.searchQuery,
          ),
        );
      } catch (e) {
        emit(InspectionError('Erro ao duplicar inspeção: ${e.toString()}'));
        emit(currentState);
      }
    }
  }

  Future<void> _onRefreshInspections(
    RefreshInspections event,
    Emitter<InspectionState> emit,
  ) async {
    if (state is InspectionLoaded) {
      final currentState = state as InspectionLoaded;
      try {
        final inspections = await repository.getInspections();
        emit(
          currentState.copyWith(
            inspections: inspections,
            filteredInspections: inspections,
            searchQuery: '',
          ),
        );
      } catch (e) {
        emit(InspectionError('Erro ao atualizar inspeções: ${e.toString()}'));
      }
    }
  }
}
