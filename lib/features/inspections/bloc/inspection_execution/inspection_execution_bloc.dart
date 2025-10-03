import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:layout_tests/features/inspections/bloc/inspection_execution/inspection_execution_event.dart';
import 'package:layout_tests/features/inspections/bloc/inspection_execution/inspection_execution_state.dart';
import 'package:layout_tests/features/template_inspections/models/field_option.dart';
import 'package:layout_tests/features/template_inspections/models/inspection_template.dart';

class InspectionExecutionBloc
    extends Bloc<InspectionExecutionEvent, InspectionExecutionState> {
  final InspectionTemplate template;

  InspectionExecutionBloc({required this.template})
    : super(ExecutionLoading()) {
    on<StartExecution>(_onStartExecution);
    on<AnswerField>(_onAnswerField);
    on<ChangeStep>(_onChangeStep);
    on<NextStep>(_onNextStep);
    on<PreviousStep>(_onPreviousStep);
    on<SubmitInspection>(_onSubmitInspection);

    // inicia automaticamente
    add(StartExecution());
  }

  void _onStartExecution(StartExecution event, Emitter emit) {
    emit(
      ExecutionInProgress(
        currentStep: 0,
        answers: {},
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

  int _calculateScore(
    InspectionTemplate template,
    Map<String, dynamic> answers,
  ) {
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
}
