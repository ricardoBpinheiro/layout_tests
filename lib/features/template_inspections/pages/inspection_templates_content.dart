import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:layout_tests/features/template_inspections/models/inspection_template.dart';
import 'package:layout_tests/features/template_inspections/widgets/template_card.dart';

class InspectionTemplatesContent extends StatefulWidget {
  const InspectionTemplatesContent({super.key});

  @override
  State<InspectionTemplatesContent> createState() =>
      _InspectionTemplatesContentState();
}

enum ViewMode { grid, table }

class _InspectionTemplatesContentState
    extends State<InspectionTemplatesContent> {
  ViewMode _viewMode = ViewMode.grid;
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
      folder: 'Qualidade',
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
      folder: 'Engenharia',
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
      folder: 'Almoxarifado',
    ),
  ];

  bool _isLoading = false;
  String _searchQuery = '';
  String _filterSector = 'Todos';
  String _selectedFolder = 'Todas';

  List<String> get folders {
    final set = <String>{};
    for (final t in templates) {
      set.add(t.folder.isEmpty ? 'Geral' : t.folder);
    }
    final list = set.toList()..sort();
    return ['Todas', ...list];
  }

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

      final matchesFolder =
          _selectedFolder == 'Todas' ||
          (template.folder.isEmpty ? 'Geral' : template.folder) ==
              _selectedFolder;

      return matchesSearch && matchesSector && matchesFolder;
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

          const SizedBox(height: 12),

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
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                ),
                child: Row(
                  children: [
                    _buildViewToggleButton(
                      icon: Icons.grid_view_rounded,
                      isSelected: _viewMode == ViewMode.grid,
                      onTap: () => setState(() => _viewMode = ViewMode.grid),
                      isFirst: true,
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: const Color(0xFFD1D5DB),
                    ),
                    _buildViewToggleButton(
                      icon: Icons.table_rows_rounded,
                      isSelected: _viewMode == ViewMode.table,
                      onTap: () => setState(() => _viewMode = ViewMode.table),
                      isLast: true,
                    ),
                  ],
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

          const SizedBox(height: 12),

          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: folders.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final folder = folders[index];
                final selected = folder == _selectedFolder;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _iconForFolder(folder),
                        size: 16,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 6),
                      Text(folder),
                    ],
                  ),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedFolder = folder),
                  selectedColor: const Color(0xFF2563EB),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF374151),
                    fontWeight: FontWeight.w600,
                  ),
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: selected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFD1D5DB),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Grid de Templates
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTemplates.isEmpty
                ? _buildEmptyState()
                : _viewMode == ViewMode.grid
                ? _buildTemplatesGrid()
                : _buildTemplatesTable(),
          ),
        ],
      ),
    );
  }

  IconData _iconForFolder(String folder) {
    final f = folder.toLowerCase();
    if (f.contains('seguran') || f.contains('sst') || f.contains('trabalho')) {
      return Icons.health_and_safety;
    }
    if (f.contains('engenh')) {
      return Icons.build;
    }
    if (f.contains('almox') || f.contains('estoque')) {
      return Icons.inventory_2;
    }
    if (f.contains('qualid')) {
      return Icons.verified_user;
    }
    return Icons.folder;
  }

  Widget _buildViewToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.horizontal(
        left: isFirst ? const Radius.circular(7) : Radius.zero,
        right: isLast ? const Radius.circular(7) : Radius.zero,
      ),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2563EB).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: isFirst ? const Radius.circular(7) : Radius.zero,
            right: isLast ? const Radius.circular(7) : Radius.zero,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF6B7280),
        ),
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

  Widget _buildTemplatesTable() {
    return Container(
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
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 20,
        minWidth: 900,
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
        headingRowHeight: 56,
        dataRowHeight: 72,
        columns: const [
          DataColumn2(
            label: Text(
              'Template',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: Text(
              'Setor',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ),
          DataColumn2(
            label: Text(
              'Status',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ),
          DataColumn2(
            label: Text(
              'Criado em',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ),
          DataColumn2(
            label: Text(
              'Versão',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            size: ColumnSize.S,
          ),
          DataColumn2(
            label: Text(
              'Ações',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            size: ColumnSize.S,
          ),
        ],
        rows: filteredTemplates.map((template) {
          return DataRow2(
            onTap: () => context.go('/templates/${template.id}'),
            cells: [
              DataCell(
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: template.getSectorColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        template.getSectorIcon(),
                        color: template.getSectorColor(),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            template.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            template.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: template.getSectorColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    template.sector,
                    style: TextStyle(
                      color: template.getSectorColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: template.status == 'Ativo'
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    template.status,
                    style: TextStyle(
                      color: template.status == 'Ativo'
                          ? Colors.green[700]
                          : Colors.red[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              DataCell(
                Text(
                  _formatDate(template.createdAt),
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                  ),
                ),
              ),
              DataCell(
                Text(
                  'v${template.version}',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              DataCell(
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Color(0xFF6B7280),
                    size: 20,
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Row(
                        children: [
                          Icon(Icons.content_copy, size: 16),
                          SizedBox(width: 8),
                          Text('Duplicar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle_status',
                      child: Row(
                        children: [
                          Icon(
                            template.status == 'Ativo'
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            template.status == 'Ativo' ? 'Desativar' : 'Ativar',
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Excluir', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'duplicate':
                        _duplicateTemplate(template);
                        break;
                      case 'delete':
                        _deleteTemplate(template);
                        break;
                    }
                  },
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
