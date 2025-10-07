import 'package:flutter/material.dart';

enum FieldType {
  text,
  number,
  email,
  phone,
  select,
  multiSelect,
  checkbox,
  photo,
  signature,
  date,
  time,
  rating,
  predefinedSet,
  instruction,
}

String getFieldTypeDisplayName(FieldType type) {
  switch (type) {
    case FieldType.text:
      return 'Texto';
    case FieldType.number:
      return 'Número';
    case FieldType.email:
      return 'Email';
    case FieldType.phone:
      return 'Telefone';
    case FieldType.select:
      return 'Seleção Única';
    case FieldType.multiSelect:
      return 'Seleção Múltipla';
    case FieldType.checkbox:
      return 'Checkbox';
    case FieldType.photo:
      return 'Foto';
    case FieldType.signature:
      return 'Assinatura';
    case FieldType.date:
      return 'Data';
    case FieldType.time:
      return 'Horário';
    case FieldType.rating:
      return 'Avaliação';
    case FieldType.instruction:
      return 'Instrução';
    case FieldType.predefinedSet:
      return 'Multi Seleção';
  }
}

IconData getFieldTypeIcon(FieldType type) {
  switch (type) {
    case FieldType.text:
      return Icons.text_fields;
    case FieldType.number:
      return Icons.numbers;
    case FieldType.email:
      return Icons.email;
    case FieldType.phone:
      return Icons.phone;
    case FieldType.select:
      return Icons.radio_button_checked;
    case FieldType.multiSelect:
      return Icons.check_box;
    case FieldType.checkbox:
      return Icons.check_box_outlined;
    case FieldType.photo:
      return Icons.camera_alt;
    case FieldType.signature:
      return Icons.draw;
    case FieldType.date:
      return Icons.calendar_today;
    case FieldType.time:
      return Icons.access_time;
    case FieldType.rating:
      return Icons.star;
    case FieldType.predefinedSet:
      return Icons.star;
    case FieldType.instruction:
      return Icons.tungsten_outlined;
  }
}
