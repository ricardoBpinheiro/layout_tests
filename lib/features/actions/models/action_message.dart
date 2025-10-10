class ActionMessage {
  final String id;
  final String actionId;
  final String author;
  final String text;
  final String? imageUrl;
  final DateTime createdAt;

  ActionMessage({
    required this.id,
    required this.actionId,
    required this.author,
    required this.text,
    this.imageUrl,
    required this.createdAt,
  });
}
