part of 'template_list_bloc.dart';

@immutable
sealed class TemplateState {}

enum TemplatesListStatus { initial, loading, success, failure }

class TemplatesListState {
  final TemplatesListStatus status;
  final List<InspectionTemplate> items;
  final String? errorMessage;
  final int page;
  final bool hasMore;
  final String query;

  const TemplatesListState({
    this.status = TemplatesListStatus.initial,
    this.items = const [],
    this.errorMessage,
    this.page = 1,
    this.hasMore = true,
    this.query = '',
  });

  TemplatesListState copyWith({
    TemplatesListStatus? status,
    List<InspectionTemplate>? items,
    String? errorMessage,
    int? page,
    bool? hasMore,
    String? query,
  }) {
    return TemplatesListState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      query: query ?? this.query,
    );
  }
}
