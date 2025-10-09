import 'package:flutter/material.dart';
import 'package:layout_tests/features/template_inspections/models/inspection_step.dart';

class InspectionTemplate {
  final String id;
  final String name;
  final String description;
  final String sector;
  final List<String> allowedUserIds;
  final List<InspectionStep> steps;
  final int version;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String createdBy;

  InspectionTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.sector,
    required this.allowedUserIds,
    required this.steps,
    this.version = 1,
    this.status = 'Ativo',
    required this.createdAt,
    this.updatedAt,
    required this.createdBy,
  });

  InspectionTemplate copyWith({
    String? id,
    String? name,
    String? description,
    String? sector,
    List<String>? allowedUserIds,
    List<InspectionStep>? steps,
    int? version,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return InspectionTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sector: sector ?? this.sector,
      allowedUserIds: allowedUserIds ?? this.allowedUserIds,
      steps: steps ?? this.steps,
      version: version ?? this.version,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  factory InspectionTemplate.fromJson(Map<String, dynamic> json) {
    return InspectionTemplate(
      id: json['id'] ?? '',
      name: '',
      description: '',
      sector: '',
      allowedUserIds: [],
      steps: [],
      createdAt: DateTime.now(),
      createdBy: '',
    );
  }

  Color getSectorColor() {
    switch (sector) {
      case 'Qualidade':
        return Colors.blue;
      case 'Engenharia':
        return Colors.orange;
      case 'Almoxarifado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData getSectorIcon() {
    switch (sector) {
      case 'Qualidade':
        return Icons.verified;
      case 'Engenharia':
        return Icons.engineering;
      case 'Almoxarifado':
        return Icons.inventory;
      default:
        return Icons.assignment;
    }
  }
}
