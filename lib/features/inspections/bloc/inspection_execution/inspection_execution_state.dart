import 'package:flutter/material.dart';

abstract class InspectionExecutionState {}

class ExecutionLoading extends InspectionExecutionState {}

class ExecutionInProgress extends InspectionExecutionState {
  final int currentStep;
  final Map<String, dynamic> answers;
  final int score;
  final PageController pageController;

  ExecutionInProgress({
    required this.currentStep,
    required this.answers,
    required this.score,
    required this.pageController,
  });

  ExecutionInProgress copyWith({
    int? currentStep,
    Map<String, dynamic>? answers,
    int? score,
  }) {
    return ExecutionInProgress(
      currentStep: currentStep ?? this.currentStep,
      answers: answers ?? this.answers,
      score: score ?? this.score,
      pageController: pageController,
    );
  }
}

class ExecutionFinished extends InspectionExecutionState {
  final Map<String, dynamic> answers;
  final int finalScore;

  ExecutionFinished(this.answers, this.finalScore);
}
