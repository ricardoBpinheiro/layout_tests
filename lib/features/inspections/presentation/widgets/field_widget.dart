import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:layout_tests/features/inspections/bloc/inspection_execution/inspection_execution_bloc.dart';
import 'package:layout_tests/features/inspections/bloc/inspection_execution/inspection_execution_event.dart';
import 'package:layout_tests/features/inspections/models/field_attachment.dart';
import 'package:layout_tests/features/template_inspections/models/field_types.dart';
import 'package:layout_tests/features/template_inspections/models/inspection_field.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FieldWidget extends StatelessWidget {
  final InspectionField field;
  final dynamic value;
  final String? note;
  final List<FieldAttachment> attachments; // NOVO
  final Function(dynamic) onChanged;
  final void Function(List<FieldAttachment>) onAddAttachments; // NOVO
  final void Function(int) onRemoveAttachment; // NOVO

  const FieldWidget({
    super.key,
    required this.field,
    this.value,
    this.note,
    this.attachments = const [],
    required this.onChanged,
    required this.onAddAttachments,
    required this.onRemoveAttachment,
  });

  InputDecoration _fieldDeco(String label, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  );

  List<T> _asList<T>(dynamic v) {
    if (v == null) return <T>[];
    if (v is List<T>) return v;
    return <T>[];
  }

  @override
  Widget build(BuildContext context) {
    final hasNote = (note != null && note!.trim().isNotEmpty);
    final attachments = this.attachments;
    ;

    return Stack(
      children: [
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color:
                  field.required == true &&
                      (value == null || (value is String && value.isEmpty))
                  ? const Color(
                      0xFFDC2626,
                    ) // vermelho na borda se quiser indicar obrigatório
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildField(context),

                // Prévia da anotação exatamente abaixo do campo
                if (hasNote) ...[
                  const SizedBox(height: 16),
                  _NotePreview(note: note!),
                ],

                // Miniaturas de anexos
                if (attachments.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _AttachmentsGrid(
                    attachments: attachments,
                    onRemove: (i) => onRemoveAttachment(i),
                  ),
                ],

                const SizedBox(height: 12),
                const Divider(),

                // Ações
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    TextButton.icon(
                      onPressed: () => _addAnnotation(context),
                      icon: const Icon(
                        Icons.note_add,
                        color: Colors.deepPurple,
                      ),
                      label: Text(
                        hasNote ? "Editar anotação" : "Adicionar anotação",
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _pickAndAttachFiles(context),
                      icon: const Icon(
                        Icons.attach_file,
                        color: Colors.deepPurple,
                      ),
                      label: const Text("Anexar mídia"),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _createAction(context),
                      icon: const Icon(
                        Icons.playlist_add_check,
                        color: Colors.deepPurple,
                      ),
                      label: const Text("Criar ação"),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (field.required == true &&
            (value == null || (value is String && value.isEmpty)))
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickAndAttachFiles(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          'png',
          'jpg',
          'jpeg',
          'gif',
          'webp',
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'csv',
          'ppt',
          'pptx',
          'txt',
        ],
        withData: true, // web
      );
      if (result == null || result.files.isEmpty) return;

      final List<FieldAttachment> newOnes = [];
      for (final f in result.files) {
        final name = f.name;
        final mime = (f.extension != null)
            ? _guessMimeFromExtension(f.extension!)
            : null;

        if (f.bytes != null && (kIsWeb || f.path == null)) {
          newOnes.add(
            FieldAttachment(name: name, mimeType: mime, bytes: f.bytes),
          );
        } else if (f.path != null) {
          newOnes.add(
            FieldAttachment(name: name, mimeType: mime, path: f.path),
          );
        }
      }

      if (newOnes.isNotEmpty)
        onAddAttachments(newOnes); // <- não mexe na resposta
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha ao anexar: $e')));
    }
  }

  /// Renderiza o conteúdo do campo (TextField, Select, Checkbox)
  Widget _buildField(BuildContext context) {
    switch (field.type) {
      case FieldType.text:
        return TextField(
          decoration: _fieldDeco(field.label, hint: field.hint),
          controller: TextEditingController(text: value ?? ''),
          onChanged: onChanged,
        );

      case FieldType.select:
        return _buildSelect(context);

      case FieldType.checkbox:
        return CheckboxListTile(
          title: Text(field.label),
          value: value ?? false,
          onChanged: onChanged,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        );

      case FieldType.number:
        return TextField(
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          decoration: _fieldDeco(
            field.label,
            hint: field.hint ?? 'Digite um número',
          ),
          controller: TextEditingController(text: value?.toString() ?? ''),
          onChanged: (txt) {
            final parsed = num.tryParse(txt.replaceAll(',', '.'));
            onChanged(parsed);
          },
        );

      case FieldType.rating:
        return _RatingField(
          label: field.label,
          value: (value is int
              ? value as int
              : (value is double ? (value as double).round() : 0)),
          max: int.parse(field.validation ?? '5'),
          onChanged: (v) => onChanged(v),
        );

      case FieldType.date:
        return _DateField(
          label: field.label,
          value: value is DateTime ? value as DateTime : null,
          onChanged: (dt) => onChanged(dt),
        );

      case FieldType.time:
        return _TimeField(
          label: field.label,
          value: value is TimeOfDay ? value as TimeOfDay : null,
          onChanged: (tod) => onChanged(tod),
        );

      case FieldType.photo:
        return _PhotoField(
          label: field.label,
          files: _asList<String>(value), // pode guardar paths/base64/urls
          onAdd: (path) {
            final list = _asList<String>(value);
            list.add(path);
            onChanged(List<String>.from(list));
          },
          onRemove: (index) {
            final list = _asList<String>(value);
            if (index >= 0 && index < list.length) {
              list.removeAt(index);
              onChanged(List<String>.from(list));
            }
          },
        );

      case FieldType.signature:
        return _SignatureField(
          label: field.label,
          // value pode ser bytes/base64; aqui retorna pngBytes
          onChanged: (bytes) => onChanged(bytes),
        );

      case FieldType.instruction:
        return _InstructionField(
          title: field.label, // ou field.instructionTitle
          text: field.hint,
          // imageUrl: field.instructionImageUrl,
        );
      default:
        return Text("Tipo não implementado: ${field.type}");
    }
  }

  Widget _buildSelect(BuildContext context) {
    final options = field.options ?? [];
    final selectedId = value;

    if (options.length > 6) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedId,
            decoration: _fieldDeco(field.label, hint: 'Selecione'),
            items: options
                .map((o) => DropdownMenuItem(value: o.id, child: Text(o.label)))
                .toList(),
            onChanged: (val) => onChanged(val),
          ),
        ],
      );
    }

    // Até 6 opções: sempre 3 colunas (1–3 linhas conforme qtd)
    const cols = 3;
    const spacing = 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field.label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: 48,
          ),
          itemBuilder: (ctx, i) {
            final opt = options[i];
            final selected = selectedId == opt.id;
            return SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => onChanged(opt.id),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : const Color(0xFFD1D5DB),
                  ),
                  backgroundColor: selected
                      ? Theme.of(context).colorScheme.primary.withOpacity(.08)
                      : Colors.white,
                  foregroundColor: selected
                      ? Theme.of(context).colorScheme.primary
                      : const Color(0xFF374151),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(opt.label, overflow: TextOverflow.ellipsis),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Renderiza os botões de ação
  Widget _buildActionButtons(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        // Adicionar anotação
        TextButton.icon(
          onPressed: () => _addAnnotation(context),
          icon: const Icon(Icons.note_add, color: Colors.deepPurple),
          label: const Text("Adicionar anotação"),
          style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
        ),
        TextButton.icon(
          onPressed: () {
            // TODO: implementar ação de anexar mídia
          },
          icon: const Icon(Icons.attach_file, color: Colors.deepPurple),
          label: const Text("Anexar mídia"),
          style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
        ),
        // Criar ação
        TextButton.icon(
          onPressed: () => _createAction(context),
          icon: const Icon(Icons.playlist_add_check, color: Colors.deepPurple),
          label: const Text("Criar ação"),
          style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
        ),
      ],
    );
  }

  /// Ação para adicionar anotação
  void _addAnnotation(BuildContext context) {
    final controller = TextEditingController(text: note ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          (note?.isNotEmpty ?? false)
              ? "Editar anotação"
              : "Adicionar anotação",
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Digite sua anotação..."),
          maxLines: 3,
        ),
        actions: [
          if ((note?.isNotEmpty ?? false))
            TextButton(
              onPressed: () {
                context.read<InspectionExecutionBloc>().add(
                  SaveFieldNote(field.id, ''),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Anotação removida")),
                );
              },
              child: const Text("Remover"),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              context.read<InspectionExecutionBloc>().add(
                SaveFieldNote(field.id, text),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    text.isEmpty ? "Anotação removida" : "Anotação salva",
                  ),
                ),
              );
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  /// Ação para criar ação
  void _createAction(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Criar ação',
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: _RightSideSheet(
            width: _sideSheetWidth(ctx),
            child: _ActionForm(
              formKey: formKey,
              titleController: titleController,
              descController: descController,
              onCancel: () => Navigator.of(ctx).pop(),
              onCreate: () {
                if (formKey.currentState?.validate() != true) return;
                final title = titleController.text.trim();
                final desc = descController.text.trim();
                // TODO: dispare evento no Bloc para criar ação de fato
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Ação criada: $title')));
              },
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim, secAnim, child) {
        final offset = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));
        final fade = CurvedAnimation(parent: anim, curve: Curves.easeOut);
        return SlideTransition(
          position: offset,
          child: FadeTransition(opacity: fade, child: child),
        );
      },
    );
  }

  double _sideSheetWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1280) return 420; // desktop
    if (w >= 1024) return 380; // laptop
    if (w >= 768) return w * 0.55; // tablet
    return w; // mobile: vira um full-screen para caber
  }
}

class _RightSideSheet extends StatelessWidget {
  final double width;
  final Widget child;

  const _RightSideSheet({required this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      bottomLeft: const Radius.circular(16),
      topRight: MediaQuery.of(context).size.width < width
          ? const Radius.circular(16)
          : Radius.zero,
      bottomRight: MediaQuery.of(context).size.width < width
          ? const Radius.circular(16)
          : Radius.zero,
    );

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          width: width,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).dialogBackgroundColor,
            borderRadius: radius,
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 16)],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ActionForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descController;
  final VoidCallback onCancel;
  final VoidCallback onCreate;

  const _ActionForm({
    required this.formKey,
    required this.titleController,
    required this.descController,
    required this.onCancel,
    required this.onCreate,
  });

  @override
  State<_ActionForm> createState() => _ActionFormState();
}

class _ActionFormState extends State<_ActionForm> {
  String _priority = 'Baixa';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _dueTime = const TimeOfDay(hour: 17, minute: 0);
  String? _assignee = 'Richard Pine'; // mock

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Row(
            children: [
              FilledButton.tonalIcon(
                onPressed: () {},
                icon: const Icon(Icons.bolt),
                label: const Text('Ação'),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onCancel,
                tooltip: 'Fechar',
              ),
            ],
          ),
        ),

        // Body (scroll)
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Form(
              key: widget.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: widget.titleController,
                    decoration: const InputDecoration(
                      hintText: 'Adicionar título...',
                      border: InputBorder.none,
                    ),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Informe um título'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: widget.descController,
                    decoration: const InputDecoration(
                      hintText: 'Adicionar descrição...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),

                  // Prioridade
                  _SectionRow(
                    label: 'Prioridade',
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _priority,
                        items: const [
                          DropdownMenuItem(
                            value: 'Baixa',
                            child: Text('Baixa'),
                          ),
                          DropdownMenuItem(
                            value: 'Média',
                            child: Text('Média'),
                          ),
                          DropdownMenuItem(value: 'Alta', child: Text('Alta')),
                        ],
                        onChanged: (v) =>
                            setState(() => _priority = v ?? _priority),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Prazo (data e hora)
                  _SectionRow(
                    label: 'Prazo',
                    child: Row(
                      children: [
                        _IconLabel(
                          icon: Icons.calendar_today,
                          text: _fmtDate(_dueDate),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _dueDate,
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 1),
                              ),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365 * 3),
                              ),
                            );
                            if (picked != null)
                              setState(() => _dueDate = picked);
                          },
                          child: const Text('Alterar'),
                        ),
                        const SizedBox(width: 16),
                        _IconLabel(
                          icon: Icons.access_time,
                          text: _dueTime.format(context),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: _dueTime,
                            );
                            if (picked != null)
                              setState(() => _dueTime = picked);
                          },
                          child: const Text('Alterar'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Responsáveis
                  _SectionRow(
                    label: 'Responsáveis',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 18,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_assignee ?? 'Selecionar')),
                        TextButton(
                          onPressed: () async {
                            // TODO: abrir seletor de usuários
                          },
                          child: const Text('Alterar'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Local / Recurso / Rótulos (placeholders como no print)
                  _SectionRow(
                    label: 'Local',
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add_location_alt_outlined),
                      label: const Text('Adicionar local'),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _SectionRow(
                    label: 'Recurso',
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.link_outlined),
                      label: const Text('Adicionar recurso'),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _SectionRow(
                    label: 'Rótulos',
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.sell_outlined),
                      label: const Text('Adicionar rótulos'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: const [
                      Icon(
                        Icons.visibility,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Visível para qualquer pessoa que tenha acesso à inspeção relevante.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Footer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: widget.onCancel,
                child: const Text('Cancelar'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: widget.onCreate,
                child: const Text('Criar'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _SectionRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _SectionRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: const TextStyle(color: Color(0xFF6B7280))),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _IconLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  const _IconLabel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}

class _RatingField extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  const _RatingField({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: List.generate(max, (i) {
            final idx = i + 1;
            final filled = idx <= value;
            return IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () => onChanged(idx),
              icon: Icon(
                filled ? Icons.star : Icons.star_border,
                color: filled ? Colors.amber[700] : Colors.grey[500],
                size: 28,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final text = value != null
        ? '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}'
        : 'Selecionar data';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.calendar_today),
          label: Text(text),
          onPressed: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? now,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            onChanged(picked);
          },
        ),
      ],
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay?> onChanged;

  const _TimeField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final text = value != null ? value!.format(context) : 'Selecionar hora';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.schedule),
          label: Text(text),
          onPressed: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: value ?? TimeOfDay.now(),
            );
            onChanged(picked);
          },
        ),
      ],
    );
  }
}

int _gridCrossAxisCountForWidth(double width) {
  if (width >= 600) return 3;
  if (width >= 400) return 2;
  return 1;
}

class _PhotoField extends StatelessWidget {
  final String label;
  final List<String> files;
  final ValueChanged<String> onAdd;
  final ValueChanged<int> onRemove;

  const _PhotoField({
    required this.label,
    required this.files,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      ...files.map((p) => _PhotoTile(path: p)),
      _AddPhotoTile(
        onTap: () async {
          // TODO: integrar image_picker/file_picker. Aqui só mock:
          onAdd('mock_${DateTime.now().millisecondsSinceEpoch}.png');
        },
      ),
    ];

    final crossAxisCount = _gridCrossAxisCountForWidth(
      MediaQuery.of(context).size.width.clamp(320, 600),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
          ),
          itemBuilder: (_, i) {
            if (i < files.length) {
              return Stack(
                children: [
                  items[i],
                  Positioned(
                    right: 6,
                    top: 6,
                    child: InkWell(
                      onTap: () => onRemove(i),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return items[i];
          },
        ),
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final String path;
  const _PhotoTile({required this.path});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Center(child: Icon(Icons.image, color: Colors.grey)),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddPhotoTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: DottedBorder(
        // color: const Color(0xFF9CA3AF),
        // strokeWidth: 1,
        // dashPattern: const [6, 4],
        // borderType: BorderType.RRect,
        // radius: const Radius.circular(10),
        child: Container(
          alignment: Alignment.center,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo, color: Color(0xFF6B7280)),
              SizedBox(height: 6),
              Text(
                'Adicionar foto',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignatureField extends StatefulWidget {
  final String label;
  final ValueChanged<Uint8List> onChanged;

  const _SignatureField({required this.label, required this.onChanged});

  @override
  State<_SignatureField> createState() => _SignatureFieldState();
}

class _SignatureFieldState extends State<_SignatureField> {
  final _points = <Offset>[];
  final _paths = <List<Offset>>[];

  void _addPoint(Offset p) {
    setState(() {
      _points.add(p);
    });
  }

  void _endStroke() {
    if (_points.isNotEmpty) {
      _paths.add(List<Offset>.from(_points));
      _points.clear();
    }
  }

  Future<void> _exportAsImage(GlobalKey key) async {
    final boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final img = await boundary.toImage(pixelRatio: 3);
    final bytes = await img.toByteData(format: ImageByteFormat.png);
    widget.onChanged(bytes!.buffer.asUint8List());
  }

  final _repaintKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        RepaintBoundary(
          key: _repaintKey,
          child: GestureDetector(
            onPanStart: (d) => _addPoint(d.localPosition),
            onPanUpdate: (d) => _addPoint(d.localPosition),
            onPanEnd: (_) => _endStroke(),
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD1D5DB)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: _SignaturePainter(_paths, _points),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Limpar'),
              onPressed: () => setState(() {
                _points.clear();
                _paths.clear();
              }),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Salvar assinatura'),
              onPressed: () => _exportAsImage(_repaintKey),
            ),
          ],
        ),
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> paths;
  final List<Offset> current;
  _SignaturePainter(this.paths, this.current);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final path in paths) {
      final p = Path();
      for (int i = 0; i < path.length; i++) {
        if (i == 0) {
          p.moveTo(path[i].dx, path[i].dy);
        } else {
          p.lineTo(path[i].dx, path[i].dy);
        }
      }
      canvas.drawPath(p, paint);
    }

    if (current.isNotEmpty) {
      final p = Path();
      p.moveTo(current.first.dx, current.first.dy);
      for (int i = 1; i < current.length; i++) {
        p.lineTo(current[i].dx, current[i].dy);
      }
      canvas.drawPath(p, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return oldDelegate.paths != paths || oldDelegate.current != current;
  }
}

class _InstructionField extends StatelessWidget {
  final String? title;
  final String? text;
  final String? imageUrl;

  const _InstructionField({this.title, this.text, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null && title!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              title!,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        if (text != null && text!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              text!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF374151)),
            ),
          ),
        if (hasImage)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFF3F4F6),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.broken_image,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _NotePreview extends StatelessWidget {
  final String note;
  const _NotePreview({required this.note});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.sticky_note_2, color: Colors.deepPurple, size: 18),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            note,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF374151)),
          ),
        ),
      ],
    );
  }
}

class _AttachmentsGrid extends StatelessWidget {
  final List<FieldAttachment> attachments;
  final ValueChanged<int> onRemove;

  const _AttachmentsGrid({required this.attachments, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(attachments.length, (i) {
        final a = attachments[i];
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                color: const Color(0xFFF9FAFB),
              ),
              child: a.isImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildImageThumb(a),
                    )
                  : _FileIconPlaceholder(name: a.name),
            ),
            Positioned(
              right: -6,
              top: -6,
              child: InkWell(
                onTap: () => onRemove(i),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildImageThumb(FieldAttachment a) {
    // Prioridade: bytes (web) > url (após upload) > path (mobile/desktop)
    if (a.bytes != null) {
      return Image.memory(
        a.bytes!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _FileIconPlaceholder(name: a.name),
      );
    }
    if (a.url != null && a.url!.isNotEmpty) {
      return Image.network(
        a.url!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _FileIconPlaceholder(name: a.name),
      );
    }
    if (a.path != null && a.path!.isNotEmpty && !kIsWeb) {
      // Evite usar File no web
      return Image(
        image: FileImage(File(a.path!)),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _FileIconPlaceholder(name: a.name),
      );
    }
    return _FileIconPlaceholder(name: a.name);
  }
}

String _guessMimeFromExtension(String ext) {
  final e = ext.toLowerCase();
  switch (e) {
    case 'png':
      return 'image/png';
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'gif':
      return 'image/gif';
    case 'webp':
      return 'image/webp';
    case 'pdf':
      return 'application/pdf';
    case 'doc':
      return 'application/msword';
    case 'docx':
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    case 'xls':
      return 'application/vnd.ms-excel';
    case 'xlsx':
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    case 'csv':
      return 'text/csv';
    case 'ppt':
      return 'application/vnd.ms-powerpoint';
    case 'pptx':
      return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
    case 'txt':
      return 'text/plain';
    default:
      return 'application/octet-stream';
  }
}

class _FileIconPlaceholder extends StatelessWidget {
  final String name;
  const _FileIconPlaceholder({required this.name});

  @override
  Widget build(BuildContext context) {
    final ext = name.split('.').last.toLowerCase();
    IconData icon;
    Color color;

    if (['pdf'].contains(ext)) {
      icon = Icons.picture_as_pdf;
      color = const Color(0xFFE11D48);
    } else if (['doc', 'docx', 'txt'].contains(ext)) {
      icon = Icons.description;
      color = const Color(0xFF2563EB);
    } else if (['xls', 'xlsx', 'csv'].contains(ext)) {
      icon = Icons.table_chart;
      color = const Color(0xFF059669);
    } else if (['ppt', 'pptx'].contains(ext)) {
      icon = Icons.slideshow;
      color = const Color(0xFFF59E0B);
    } else {
      icon = Icons.insert_drive_file;
      color = const Color(0xFF6B7280);
    }

    return Center(child: Icon(icon, color: color, size: 28));
  }
}

List<FieldAttachment> _attachmentsFromValue(dynamic v) {
  if (v is List<FieldAttachment>) return v;
  if (v is List) {
    // tenta converter se vier de json
    try {
      return v
          .map((e) {
            if (e is FieldAttachment) return e;
            if (e is Map<String, dynamic>) return FieldAttachment.fromJson(e);
            return null;
          })
          .whereType<FieldAttachment>()
          .toList();
    } catch (_) {}
  }
  return <FieldAttachment>[];
}

bool _isImage(String? mimeOrName) {
  if (mimeOrName == null) return false;
  final lower = mimeOrName.toLowerCase();
  return lower.startsWith('image/') ||
      lower.endsWith('.png') ||
      lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.gif') ||
      lower.endsWith('.webp');
}
