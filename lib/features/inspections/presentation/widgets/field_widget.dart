import 'dart:typed_data';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:layout_tests/features/inspections/bloc/inspection_execution/inspection_execution_bloc.dart';
import 'package:layout_tests/features/inspections/bloc/inspection_execution/inspection_execution_event.dart';
import 'package:layout_tests/features/template_inspections/models/field_types.dart';
import 'package:layout_tests/features/template_inspections/models/inspection_field.dart';

class FieldWidget extends StatelessWidget {
  final InspectionField field;
  final dynamic value;
  final String? note;
  final Function(dynamic) onChanged;

  const FieldWidget({
    super.key,
    required this.field,
    this.value,
    this.note,
    required this.onChanged,
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
                      onPressed: () {
                        // TODO: implementar ação de anexar mídia
                      },
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Criar ação",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Título da ação"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Descrição"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final title = titleController.text.trim();
                  final desc = descController.text.trim();
                  if (title.isNotEmpty) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Ação criada: $title")),
                    );
                  }
                },
                child: const Text("Salvar"),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
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
