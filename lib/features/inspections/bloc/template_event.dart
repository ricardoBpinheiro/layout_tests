import 'package:equatable/equatable.dart';
import 'package:layout_tests/features/template_inspections/models/inspection_template.dart';

abstract class TemplateEvent extends Equatable {
  const TemplateEvent();

  @override
  List<Object?> get props => [];
}

class LoadTemplates extends TemplateEvent {
  const LoadTemplates();
}

class SearchTemplates extends TemplateEvent {
  final String query;

  const SearchTemplates(this.query);

  @override
  List<Object?> get props => [query];
}

class SelectTemplate extends TemplateEvent {
  final InspectionTemplate template;

  const SelectTemplate(this.template);

  @override
  List<Object?> get props => [template];
}
