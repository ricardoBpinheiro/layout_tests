import 'package:flutter/material.dart';
import 'package:layout_tests/features/inspections/models/field_attachment.dart';

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
  final Map<String, List<FieldAttachment>> attachmentsByField; // NOVO
  final int score;
  final PageController pageController;
  final bool isSaving; // salvando agora
  final DateTime? lastSavedAt;
  final String? saveError; // mensagem de erro da última tentativa

  ExecutionInProgress({
    required this.currentStep,
    required this.answers,
    required this.notesByField,
    required this.attachmentsByField, // NOVO
    required this.score,
    required this.pageController,
    this.isSaving = false,
    this.lastSavedAt,
    this.saveError,
  });

  ExecutionInProgress copyWith({
    int? currentStep,
    Map<String, dynamic>? answers,
    Map<String, String>? notesByField,
    Map<String, List<FieldAttachment>>? attachmentsByField,
    int? score,
    PageController? pageController,
    bool? isSaving,
    DateTime? lastSavedAt,
    String? saveError,
  }) {
    return ExecutionInProgress(
      currentStep: currentStep ?? this.currentStep,
      answers: answers ?? this.answers,
      notesByField: notesByField ?? this.notesByField,
      attachmentsByField: attachmentsByField ?? this.attachmentsByField,
      score: score ?? this.score,
      pageController: pageController ?? this.pageController,
         isSaving: isSaving ?? this.isSaving,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      saveError: saveError,
    );
  }
}