import 'package:equatable/equatable.dart';

class Inspection extends Equatable {
  final String id;
  final String templateName;
  final String sector;
  final String documentNumber;
  final int score;
  final String startedAt;
  final String? completedAt;
  final String status;
  final String completedItems;
  final String? location;
  final String responsibleName;
  final String lastEditedBy;
  final String startedAtFull;
  final String updatedAtFull;

  const Inspection({
    required this.id,
    required this.templateName,
    required this.sector,
    required this.documentNumber,
    required this.score,
    required this.startedAt,
    this.completedAt,
    required this.status,
    required this.completedItems,
    this.location,
    required this.responsibleName,
    required this.lastEditedBy,
    required this.startedAtFull,
    required this.updatedAtFull,
  });

  @override
  List<Object?> get props => [
    id,
    templateName,
    sector,
    documentNumber,
    score,
    startedAt,
    completedAt,
    status,
    completedItems,
    location,
    responsibleName,
    lastEditedBy,
    startedAtFull,
    updatedAtFull,
  ];

  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      id: json['id'] as String,
      templateName: json['templateName'] as String,
      sector: json['sector'] as String,
      documentNumber: json['documentNumber'] as String,
      score: json['score'] as int,
      startedAt: json['startedAt'] as String,
      completedAt: json['completedAt'] as String?,
      status: json['status'] as String,
      completedItems: json['completedItems'] as String,
      location: json['location'] as String?,
      responsibleName: json['responsibleName'] as String,
      lastEditedBy: json['lastEditedBy'] as String,
      startedAtFull: json['startedAtFull'] as String,
      updatedAtFull: json['updatedAtFull'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'templateName': templateName,
      'sector': sector,
      'documentNumber': documentNumber,
      'score': score,
      'startedAt': startedAt,
      'completedAt': completedAt,
      'status': status,
      'completedItems': completedItems,
      'location': location,
      'responsibleName': responsibleName,
      'lastEditedBy': lastEditedBy,
      'startedAtFull': startedAtFull,
      'updatedAtFull': updatedAtFull,
    };
  }
}
