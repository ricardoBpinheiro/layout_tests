import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:layout_tests/features/inspections/data/inspection_template_repository.dart';
import 'package:layout_tests/features/inspections/models/inspection_template.dart';
import 'package:meta/meta.dart';

part 'template_list_event.dart';
part 'template_list_state.dart';

class TemplatesListBloc extends Bloc<TemplatesListEvent, TemplatesListState> {
  final InspectionTemplateRepository _repo;
  TemplatesListBloc({required InspectionTemplateRepository repository})
    : _repo = repository,
      super(const TemplatesListState()) {
    on<TemplatesListRequested>(_onListRequested);
    on<TemplateDeletedRequested>(_onDeleteRequested);
    on<TemplateDuplicatedRequested>(_onDuplicateRequested);
    on<TemplatePublishedRequested>(_onPublishRequested);
    on<TemplatesQueryChanged>(_onQueryChanged);
  }

  Future<void> _onListRequested(
    TemplatesListRequested event,
    Emitter<TemplatesListState> emit,
  ) async {
    emit(state.copyWith(status: TemplatesListStatus.loading, page: event.page));
    try {
      final result = await _repo.fetchTemplates(
        page: event.page,
        pageSize: 20,
        query: event.query ?? state.query,
      );
      emit(
        state.copyWith(
          status: TemplatesListStatus.success,
          items: result,
          hasMore: result.length == 20,
          query: event.query ?? state.query,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TemplatesListStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteRequested(
    TemplateDeletedRequested event,
    Emitter<TemplatesListState> emit,
  ) async {
    try {
      await _repo.delete(event.id);
      final updated = state.items.where((t) => t.id != event.id).toList();
      emit(state.copyWith(items: updated));
    } catch (e) {
      emit(
        state.copyWith(
          status: TemplatesListStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDuplicateRequested(
    TemplateDuplicatedRequested event,
    Emitter<TemplatesListState> emit,
  ) async {
    try {
      final newTemplate = await _repo.duplicate(event.id);
      final updated = [newTemplate, ...state.items];
      emit(state.copyWith(items: updated));
    } catch (e) {
      emit(
        state.copyWith(
          status: TemplatesListStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onPublishRequested(
    TemplatePublishedRequested event,
    Emitter<TemplatesListState> emit,
  ) async {
    try {
      final published = await _repo.publish(event.id);
      final updated = state.items
          .map((t) => t.id == event.id ? published : t)
          .toList();
      emit(state.copyWith(items: updated));
    } catch (e) {
      emit(
        state.copyWith(
          status: TemplatesListStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onQueryChanged(
    TemplatesQueryChanged event,
    Emitter<TemplatesListState> emit,
  ) async {
    emit(state.copyWith(query: event.query));
    add(TemplatesListRequested(page: 1, query: event.query));
  }
}
