import 'package:flutter/material.dart';
import 'package:layout_tests/features/template_inspections/models/field_types.dart';
import 'package:layout_tests/features/template_inspections/models/inspection_field.dart';

class FieldWidget extends StatelessWidget {
  final InspectionField field;
  final dynamic value;
  final Function(dynamic) onChanged;

  const FieldWidget({
    super.key,
    required this.field,
    this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField(context),
            const SizedBox(height: 12),
            const Divider(),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  /// Renderiza o conteúdo do campo (TextField, Select, Checkbox)
  Widget _buildField(BuildContext context) {
    switch (field.type) {
      case FieldType.text:
        return TextField(
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.hint,
          ),
          controller: TextEditingController(text: value ?? ''),
          onChanged: onChanged,
        );

      case FieldType.select:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              field.label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: field.options!.map((opt) {
                return ChoiceChip(
                  label: Text(opt.label),
                  selected: value == opt.id,
                  onSelected: (_) => onChanged(opt.id),
                );
              }).toList(),
            ),
          ],
        );

      case FieldType.checkbox:
        return CheckboxListTile(
          title: Text(field.label),
          value: value ?? false,
          onChanged: onChanged,
          controlAffinity: ListTileControlAffinity.leading,
        );

      default:
        return Text("Tipo não implementado: ${field.type}");
    }
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
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Adicionar anotação"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Digite sua anotação..."),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              final note = controller.text.trim();
              if (note.isNotEmpty) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Anotação adicionada: $note")),
                );
              }
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
