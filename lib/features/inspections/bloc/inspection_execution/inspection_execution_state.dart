import 'package:flutter/material.dart';

abstract class InspectionExecutionState {}

class ExecutionLoading extends InspectionExecutionState {}

class ExecutionFinished extends InspectionExecutionState {
  final Map<String, dynamic> answers;
  final int finalScore;

  ExecutionFinished(this.answers, this.finalScore);
}
class ExecutionInProgress extends InspectionExecutionState {
  final int currentStep;
  final Map<String, dynamic> answers;
  final Map<String, String> notesByField;
  final int score;
  final PageController pageController;

  ExecutionInProgress({
    required this.currentStep,
    required this.answers,
    required this.notesByField,
    required this.score,
    required this.pageController,
  });

  ExecutionInProgress copyWith({
    int? currentStep,
    Map<String, dynamic>? answers,
    Map<String, String>? notesByField,
    int? score,
    PageController? pageController,
  }) {
    return ExecutionInProgress(
      currentStep: currentStep ?? this.currentStep,
      answers: answers ?? this.answers,
      notesByField: notesByField ?? this.notesByField,
      score: score ?? this.score,
      pageController: pageController ?? this.pageController,
    );
  }
}
