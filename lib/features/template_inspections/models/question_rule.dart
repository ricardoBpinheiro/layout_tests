// Novo model simples para regra
class QuestionRule {
  final String id;
  final String condition;
  final String value;
  final String action;

  QuestionRule({
    String? id,
    required this.condition,
    required this.value,
    required this.action,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  QuestionRule copyWith({
    String? id,
    String? condition,
    String? value,
    String? action,
  }) {
    return QuestionRule(
      id: id ?? this.id,
      condition: condition ?? this.condition,
      value: value ?? this.value,
      action: action ?? this.action,
    );
  }
}
