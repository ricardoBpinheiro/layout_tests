import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:layout_tests/features/inspections/bloc/template_event.dart';
import 'package:layout_tests/features/inspections/bloc/template_state.dart';
import 'package:layout_tests/features/inspections/data/template_repository.dart';

class TemplateBloc extends Bloc<TemplateEvent, TemplateState> {
  final TemplateRepository repository;

  TemplateBloc({required this.repository}) : super(const TemplateInitial()) {
    on<LoadTemplates>(_onLoadTemplates);
    on<SearchTemplates>(_onSearchTemplates);
    on<SelectTemplate>(_onSelectTemplate);
  }

  Future<void> _onLoadTemplates(
    LoadTemplates event,
    Emitter<TemplateState> emit,
  ) async {
    emit(const TemplateLoading());
    try {
      final templates = await repository.getTemplates();
      emit(TemplateLoaded(templates: templates, filteredTemplates: templates));
    } catch (e) {
      emit(TemplateError('Erro ao carregar templates: ${e.toString()}'));
    }
  }

  Future<void> _onSearchTemplates(
    SearchTemplates event,
    Emitter<TemplateState> emit,
  ) async {
    if (state is TemplateLoaded) {
      final currentState = state as TemplateLoaded;
      final query = event.query.toLowerCase();

      if (query.isEmpty) {
        emit(
          currentState.copyWith(
            filteredTemplates: currentState.templates,
            searchQuery: query,
          ),
        );
      } else {
        final filtered = currentState.templates.where((template) {
          return template.name.toLowerCase().contains(query) ||
              template.description.toLowerCase().contains(query) ||
              template.sector.toLowerCase().contains(query);
        }).toList();

        emit(
          currentState.copyWith(
            filteredTemplates: filtered,
            searchQuery: query,
          ),
        );
      }
    }
  }

  Future<void> _onSelectTemplate(
    SelectTemplate event,
    Emitter<TemplateState> emit,
  ) async {
    if (state is TemplateLoaded) {
      final currentState = state as TemplateLoaded;
      emit(currentState.copyWith(selectedTemplate: event.template));
    }
  }
}
