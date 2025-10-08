import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:layout_tests/features/inspections/bloc/inspection_execution/inspection_execution_event.dart';
import 'package:layout_tests/features/inspections/bloc/inspection_execution/inspection_execution_state.dart';
import 'package:layout_tests/features/inspections/models/field_attachment.dart';
import 'package:layout_tests/features/template_inspections/models/field_option.dart';
import 'package:layout_tests/features/template_inspections/models/inspection_template.dart';

class InspectionExecutionBloc
    extends Bloc<InspectionExecutionEvent, InspectionExecutionState> {
  final InspectionTemplate template;
  Timer? _saveDebounce;

  InspectionExecutionBloc({required this.template})
    : super(ExecutionLoading()) {
    on<StartExecution>(_onStartExecution);
    on<AnswerField>(_onAnswerField);
    on<ChangeStep>(_onChangeStep);
    on<NextStep>(_onNextStep);
    on<PreviousStep>(_onPreviousStep);
    on<SubmitInspection>(_onSubmitInspection);
    on<SaveFieldNote>(_onSaveFieldNote);
    on<SaveDraftRequested>(_onSaveDraft);
    on<PerformSaveDraft>(_performSaveDraft); // evita concorrência
    on<AddFieldAttachments>((event, emit) {
      final s = state as ExecutionInProgress;
      final map = Map<String, List<FieldAttachment>>.from(s.attachmentsByField);
      final current = List<FieldAttachment>.from(
        map[event.fieldId] ?? const [],
      );
      current.addAll(event.attachments);
      map[event.fieldId] = current;
      emit(s.copyWith(attachmentsByField: map /* opcional: saveError: null */));
      add(SaveDraftRequested());
    });

    on<RemoveFieldAttachmentAt>((event, emit) {
      final s = state as ExecutionInProgress;
      final map = Map<String, List<FieldAttachment>>.from(s.attachmentsByField);
      final current = List<FieldAttachment>.from(
        map[event.fieldId] ?? const [],
      );
      if (event.index >= 0 && event.index < current.length) {
        current.removeAt(event.index);
        map[event.fieldId] = current;
        emit(s.copyWith(attachmentsByField: map));
        add(SaveDraftRequested());
      }
    });
    // inicia automaticamente
    add(StartExecution());
  }

  void _onSaveDraft(SaveDraftRequested event, Emitter emit) {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), () {
      add(PerformSaveDraft());
    });
  }

  void _onSaveFieldNote(SaveFieldNote event, Emitter emit) {
    final current = state as ExecutionInProgress;
    final newNotes = Map<String, String>.from(current.notesByField);

    if (event.note.trim().isEmpty) {
      newNotes.remove(event.fieldId);
    } else {
      newNotes[event.fieldId] = event.note.trim();
    }

    emit(current.copyWith(notesByField: newNotes));
  }

  void _onStartExecution(StartExecution event, Emitter emit) {
    emit(
      ExecutionInProgress(
        currentStep: 0,
        answers: {},
        notesByField: {},
        attachmentsByField: {},
        score: 0,
        pageController: PageController(),
      ),
    );
  }

  void _onAnswerField(AnswerField event, Emitter emit) {
    final state = this.state;
    if (state is ExecutionInProgress) {
      final updatedAnswers = Map<String, dynamic>.from(state.answers)
        ..[event.field.id] = event.value;

      final score = _calculateScore(template, updatedAnswers);

      emit(state.copyWith(answers: updatedAnswers, score: score));
    }
  }

  void _onChangeStep(ChangeStep event, Emitter emit) {
    final state = this.state;
    if (state is ExecutionInProgress) {
      emit(state.copyWith(currentStep: event.stepIndex));
    }
  }

  void _onNextStep(NextStep event, Emitter emit) {
    final state = this.state;
    if (state is ExecutionInProgress &&
        state.currentStep < template.steps.length - 1) {
      state.pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void _onPreviousStep(PreviousStep event, Emitter emit) {
    final state = this.state;
    if (state is ExecutionInProgress && state.currentStep > 0) {
      state.pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  void _onSubmitInspection(SubmitInspection event, Emitter emit) {
    final state = this.state;
    if (state is ExecutionInProgress) {
      emit(ExecutionFinished(state.answers, state.score));
    }
  }

  Future<void> _performSaveDraft(
    PerformSaveDraft event,
    Emitter<InspectionExecutionState> emit,
  ) async {
    final s = state as ExecutionInProgress;
    emit(s.copyWith(isSaving: true, saveError: null));
    try {
      final payload = {
        "templateId": '',
        "currentStep": s.currentStep,
        "answers": s.answers,
        "notes": s.notesByField,
        "score": s.score,
      };
      // await repo.saveDraft(payload); // chamada Dio
      emit(
        s.copyWith(
          isSaving: false,
          lastSavedAt: DateTime.now(),
          saveError: null,
        ),
      );
    } catch (e) {
      emit(s.copyWith(isSaving: false, saveError: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _saveDebounce?.cancel();
    return super.close();
  }
}

int _calculateScore(InspectionTemplate template, Map<String, dynamic> answers) {
  int totalAchieved = 0;
  int totalPossible = 0;

  for (final step in template.steps) {
    for (final field in step.fields) {
      if (field.options != null && field.options!.isNotEmpty) {
        // soma o maior valor possível desse campo ao total possível
        totalPossible += field.options!
            .map((o) => o.score ?? 0)
            .fold<int>(0, max);

        // se respondeu, soma a pontuação dele
        final answer = answers[field.id];
        final selected = field.options!.firstWhere(
          (opt) => opt.id == answer,
          orElse: () =>
              FieldOption(id: '', label: '', score: 0, color: Colors.red),
        );
        totalAchieved += selected.score ?? 0;
      }
    }
  }

  if (totalPossible == 0) return 0;
  return ((totalAchieved / totalPossible) * 100).round();
}
