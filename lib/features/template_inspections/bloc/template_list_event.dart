part of 'template_list_bloc.dart';

@immutable
sealed class TemplatesListEvent {}

class TemplatesListRequested extends TemplatesListEvent {
  final int page;
  final String? query;
  TemplatesListRequested({this.page = 1, this.query});
}

class TemplateDeletedRequested extends TemplatesListEvent {
  final String id;
  TemplateDeletedRequested(this.id);
}

class TemplateDuplicatedRequested extends TemplatesListEvent {
  final String id;
  TemplateDuplicatedRequested(this.id);
}

class TemplatePublishedRequested extends TemplatesListEvent {
  final String id;
  TemplatePublishedRequested(this.id);
}

class TemplatesQueryChanged extends TemplatesListEvent {
  final String query;
  TemplatesQueryChanged(this.query);
}
