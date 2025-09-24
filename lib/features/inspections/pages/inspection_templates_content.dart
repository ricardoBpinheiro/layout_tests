import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:layout_tests/features/inspections/models/inspection_template.dart';
import 'package:layout_tests/features/inspections/widgets/template_card.dart';

class InspectionTemplatesContent extends StatefulWidget {
  const InspectionTemplatesContent({super.key});

  @override
  State<InspectionTemplatesContent> createState() =>
      _InspectionTemplatesContentState();
}

class _InspectionTemplatesContentState
    extends State<InspectionTemplatesContent> {
  List<InspectionTemplate> templates = [
    InspectionTemplate(
      id: '1',
      name: 'Inspeção de Qualidade - Matéria Prima',
      description: 'Template para inspeção de matéria prima recebida',
      sector: 'Qualidade',
      allowedUserIds: ['1', '2'],
      steps: [],
      version: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      createdBy: 'João Silva',
    ),
    InspectionTemplate(
      id: '2',
      name: 'Inspeção de Equipamentos - Linha 1',
      description: 'Checklist para equipamentos da linha de produção 1',
      sector: 'Engenharia',
      allowedUserIds: ['2', '3'],
      steps: [],
      version: 1,
      status: 'Inativo',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      createdBy: 'Maria Santos',
    ),
    InspectionTemplate(
      id: '3',
      name: 'Auditoria de Almoxarifado',
      description: 'Template para auditoria mensal do almoxarifado',
      sector: 'Almoxarifado',
      allowedUserIds: ['1'],
      steps: [],
      version: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      createdBy: 'Pedro Costa',
    ),
  ];

  bool _isLoading = false;
  String _searchQuery = '';
  String _filterSector = 'Todos';

  List<InspectionTemplate> get filteredTemplates {
    var filtered = templates.where((template) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          template.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          template.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      final matchesSector =
          _filterSector == 'Todos' || template.sector == _filterSector;

      return matchesSearch && matchesSector;
    }).toList();

    return filtered;
  }

  void _duplicateTemplate(InspectionTemplate template) {
    final newTemplate = template.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${template.name} (Cópia)',
      version: 1,
      createdAt: DateTime.now(),
      createdBy: 'Usuário Atual',
    );

    setState(() {
      templates.add(newTemplate);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Template "${template.name}" duplicado com sucesso'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _toggleStatus(InspectionTemplate template) {
    setState(() {
      final index = templates.indexWhere((t) => t.id == template.id);
      if (index != -1) {
        templates[index] = template.copyWith(
          status: template.status == 'Ativo' ? 'Inativo' : 'Ativo',
          updatedAt: DateTime.now(),
        );
      }
    });
  }

  void _deleteTemplate(InspectionTemplate template) {
    setState(() {
      templates.removeWhere((t) => t.id == template.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Template "${template.name}" excluído com sucesso'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Templates de Inspeção',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => context.go('/templates/create'),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Novo Template'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Filtros
          Row(
            children: [
              // Busca
              Expanded(
                flex: 2,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: const InputDecoration(
                      hintText: 'Buscar templates...',
                      prefixIcon: Icon(Icons.search, color: Color(0xFF6B7280)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Filtro por setor
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filterSector,
                    items: const [
                      DropdownMenuItem(
                        value: 'Todos',
                        child: Text('Todos os Setores'),
                      ),
                      DropdownMenuItem(
                        value: 'Qualidade',
                        child: Text('Qualidade'),
                      ),
                      DropdownMenuItem(
                        value: 'Engenharia',
                        child: Text('Engenharia'),
                      ),
                      DropdownMenuItem(
                        value: 'Almoxarifado',
                        child: Text('Almoxarifado'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _filterSector = value);
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Botão refresh
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() => _isLoading = true);
                    Future.delayed(const Duration(seconds: 1), () {
                      setState(() => _isLoading = false);
                    });
                  },
                  icon: const Icon(Icons.refresh, color: Color(0xFF6B7280)),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Grid de Templates
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTemplates.isEmpty
                ? _buildEmptyState()
                : _buildTemplatesGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'Nenhum template cadastrado'
                : 'Nenhum template encontrado',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Comece criando seu primeiro template'
                : 'Tente ajustar os filtros de busca',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/templates/create'),
              icon: const Icon(Icons.add),
              label: const Text('Criar Primeiro Template'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTemplatesGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.2,
      ),
      itemCount: filteredTemplates.length,
      itemBuilder: (context, index) {
        final template = filteredTemplates[index];
        return TemplateCard(
          template: template,
          onTap: () => context.go('/templates/edit/${template.id}'),
          onDuplicate: () => _duplicateTemplate(template),
          onToggleStatus: () => _toggleStatus(template),
          onDelete: () => _showDeleteDialog(template),
        );
      },
    );
  }

  void _showDeleteDialog(InspectionTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black),
            children: [
              const TextSpan(
                text: 'Tem certeza que deseja excluir o template ',
              ),
              TextSpan(
                text: '"${template.name}"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '?\n\nEsta ação não pode ser desfeita.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTemplate(template);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
