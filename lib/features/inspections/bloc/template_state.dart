import 'package:equatable/equatable.dart';
import 'package:layout_tests/features/template_inspections/models/inspection_template.dart';

abstract class TemplateState extends Equatable {
  const TemplateState();

  @override
  List<Object?> get props => [];
}

class TemplateInitial extends TemplateState {
  const TemplateInitial();
}

class TemplateLoading extends TemplateState {
  const TemplateLoading();
}

class TemplateLoaded extends TemplateState {
  final List<InspectionTemplate> templates;
  final List<InspectionTemplate> filteredTemplates;
  final InspectionTemplate? selectedTemplate;
  final String searchQuery;

  const TemplateLoaded({
    required this.templates,
    required this.filteredTemplates,
    this.selectedTemplate,
    this.searchQuery = '',
  });

  TemplateLoaded copyWith({
    List<InspectionTemplate>? templates,
    List<InspectionTemplate>? filteredTemplates,
    InspectionTemplate? selectedTemplate,
    String? searchQuery,
    bool clearSelection = false,
  }) {
    return TemplateLoaded(
      templates: templates ?? this.templates,
      filteredTemplates: filteredTemplates ?? this.filteredTemplates,
      selectedTemplate: clearSelection
          ? null
          : (selectedTemplate ?? this.selectedTemplate),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    templates,
    filteredTemplates,
    selectedTemplate,
    searchQuery,
  ];
}

class TemplateError extends TemplateState {
  final String message;

  const TemplateError(this.message);

  @override
  List<Object?> get props => [message];
}
