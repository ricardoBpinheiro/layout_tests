import 'package:flutter/material.dart';

class FieldOption {
  final String id;
  final String label;
  final Color color;
  final int score;

  FieldOption({
    required this.id,
    required this.label,
    required this.color,
    required this.score,
  });

  FieldOption copyWith({String? id, String? label, Color? color, int? score}) {
    return FieldOption(
      id: id ?? this.id,
      label: label ?? this.label,
      color: color ?? this.color,
      score: score ?? this.score,
    );
  }
}
