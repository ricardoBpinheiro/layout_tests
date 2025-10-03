import 'package:flutter/material.dart';
import 'package:layout_tests/features/template_inspections/models/field_types.dart';

class FieldTypeSelectorModal extends StatelessWidget {
  final void Function(FieldType, {String? predefinedSet}) onFieldTypeSelected;

  const FieldTypeSelectorModal({
    super.key,
    required this.onFieldTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(40),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Adicionar Campo",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Conteúdo
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ====== CAMPOS NORMAIS ======
                    _buildSection(
                      title: "Respostas em texto",
                      options: [
                        _Option("Texto", Icons.text_fields, FieldType.text),
                        _Option("Número", Icons.numbers, FieldType.number),
                        _Option("E-mail", Icons.email_outlined, FieldType.email),
                        _Option("Telefone", Icons.phone, FieldType.phone),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      title: "Data e Mídia",
                      options: [
                        _Option("Data", Icons.calendar_today, FieldType.date),
                        _Option("Hora", Icons.access_time, FieldType.time),
                        _Option("Foto", Icons.photo_camera, FieldType.photo),
                        _Option("Assinatura", Icons.edit, FieldType.signature),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      title: "Outros",
                      options: [
                        _Option("Sim / Não", Icons.toggle_on, FieldType.checkbox),
                        _Option("Avaliação", Icons.star_rate, FieldType.rating),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ====== CONJUNTOS DE RESPOSTAS (igual print) ======
                    const Text(
                      "Respostas de múltipla escolha",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPredefinedSet(
                      context,
                      "Seguro",
                      ["Seguro", "Em risco", "N/D"],
                      colors: [Colors.teal, Colors.red, Colors.grey],
                    ),
                    _buildPredefinedSet(
                      context,
                      "Qualidade",
                      ["Bom", "Razoável", "Ruim", "N/D"],
                      colors: [Colors.green, Colors.orange, Colors.red, Colors.grey],
                    ),
                    _buildPredefinedSet(
                      context,
                      "Status",
                      ["Aprovado", "Falha", "N/D"],
                      colors: [Colors.green, Colors.red, Colors.grey],
                    ),
                    _buildPredefinedSet(
                      context,
                      "Confirmação",
                      ["Sim", "Não", "N/D"],
                      colors: [Colors.green, Colors.red, Colors.grey],
                    ),
                    _buildPredefinedSet(
                      context,
                      "Conformidade",
                      ["Conforme", "Não conforme", "N/D"],
                      colors: [Colors.teal, Colors.red, Colors.grey],
                    ),

                    const SizedBox(height: 20),
                    // Conjuntos globais
                    const Divider(),
                    const Text(
                      "Nenhum conjunto global de respostas",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Conjuntos globais de respostas podem ser reutilizados em todos os seus modelos e gerenciados em um único local.",
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: const BorderSide(color: Color(0xFF2563EB)),
                      ),
                      child: const Text("Criar Conjunto Global de Respostas"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<_Option> options}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          itemCount: options.length,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 3.5,
          ),
          itemBuilder: (context, index) {
            final option = options[index];
            return _buildOptionCard(context, option);
          },
        ),
      ],
    );
  }

  Widget _buildOptionCard(BuildContext context, _Option option) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onFieldTypeSelected(option.type);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(option.icon, color: const Color(0xFF2563EB)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                option.label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredefinedSet(BuildContext context, String label, List<String> items, {required List<Color> colors}) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onFieldTypeSelected(FieldType.predefinedSet, predefinedSet: label);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (int i = 0; i < items.length; i++)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors[i].withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        items[i],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colors[i],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit, size: 18, color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }
}

class _Option {
  final String label;
  final IconData icon;
  final FieldType type;

  _Option(this.label, this.icon, this.type);
}
