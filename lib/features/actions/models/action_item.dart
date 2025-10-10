// models/action_item.dart
class ActionItem {
  final String id;
  final String code;
  final String title;
  final String description;
  final String status;
  final String priority;
  final DateTime? dueDate;
  final String responsible;
  final DateTime updatedAt;

  ActionItem({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.responsible,
    required this.updatedAt,
  });

  ActionItem copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    String? status,
    String? priority,
    DateTime? dueDate,
    String? responsible,
    DateTime? updatedAt,
  }) {
    return ActionItem(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      responsible: responsible ?? this.responsible,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
