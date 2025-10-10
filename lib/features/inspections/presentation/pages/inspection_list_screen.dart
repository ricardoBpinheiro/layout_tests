import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:go_router/go_router.dart';
import 'package:layout_tests/app_injection.dart';
import 'package:layout_tests/features/inspections/bloc/inspection_bloc.dart';
import 'package:layout_tests/features/inspections/data/inspection_repository.dart';
import 'package:layout_tests/features/inspections/models/inspection.dart';
import 'package:layout_tests/features/inspections/presentation/widgets/mobile/mobile_inspections.dart';
import 'package:layout_tests/features/inspections/presentation/widgets/template_selection_modal.dart';
import 'package:layout_tests/features/template_inspections/models/inspection_template.dart';

class InspectionListScreen extends StatelessWidget {
  const InspectionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          InspectionBloc(repository: getIt<InspectionRepository>())
            ..add(const LoadInspections()),
      child: const InspectionListView(),
    );
  }
}

class InspectionListView extends StatefulWidget {
  const InspectionListView({super.key});

  @override
  State<InspectionListView> createState() => _InspectionListViewState();
}

class _InspectionListViewState extends State<InspectionListView> {
  final TextEditingController _searchController = TextEditingController();
  bool get _isMobile => MediaQuery.of(context).size.width < 700;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<InspectionBloc>().add(
      SearchInspections(_searchController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InspectionBloc, InspectionState>(
      listener: (context, state) {
        if (state is InspectionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is InspectionDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inspeção excluída com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is InspectionDuplicated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inspeção duplicada com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        if (_isMobile) {
          return MobileInspections(
            state: state,
            searchController: _searchController,
            onStartFromTemplate: _onStartFromTemplate,
            onShowTemplatePicker: () => _showTemplateSelectionModal(context),
            onShowOptions: _showOptionsMenu,
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F7),
          body: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildHeader(context),
                    _buildSearchAndFilters(),
                    Expanded(child: _buildContent(context, state)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, InspectionState state) {
    if (state is InspectionLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
      );
    }

    if (state is InspectionLoaded) {
      if (state.filteredInspections.isEmpty) {
        return _buildEmptyState(context);
      }
      return _buildDataTable(context, state.filteredInspections);
    }

    return const SizedBox();
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Inspeções',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showTemplateSelectionModal(context),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Iniciar inspeção'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF6366F1)),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.assignment_outlined,
              size: 120,
              color: Color(0xFFE5E7EB),
            ),
            const SizedBox(height: 24),
            const Text(
              'Todas as inspeções realizadas pela sua equipe aparecerão aqui',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Ainda não há inspeções. ',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
                InkWell(
                  onTap: () => _showTemplateSelectionModal(context),
                  child: const Text(
                    'Inicie uma inspeção',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Text(
                  ' ou ',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
                InkWell(
                  onTap: () {
                    // Navegar para tela de criação de template
                  },
                  child: const Text(
                    'crie um modelo',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, List<Inspection> inspections) {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 24,
        minWidth: 900,
        headingRowColor: MaterialStateProperty.all(const Color(0xFFF9FAFB)),
        headingRowHeight: 48,
        dataRowHeight: 64,
        columns: const [
          DataColumn2(
            label: Text(
              'Inspeção',
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
            size: ColumnSize.M,
          ),
          DataColumn2(
            label: Text(
              'Nº do documento',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            size: ColumnSize.M,
          ),
          DataColumn2(
            label: Text(
              'Pontuação',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            size: ColumnSize.S,
          ),
          DataColumn2(
            label: Text(
              'Realizadas',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            size: ColumnSize.S,
          ),
          DataColumn2(
            label: Text(
              'Concluídas',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            size: ColumnSize.S,
          ),
          DataColumn2(label: Text(''), size: ColumnSize.S),
        ],
        rows: inspections.map((inspection) {
          return DataRow2(
            onTap: () {
              context.read<InspectionBloc>().add(SelectInspection(inspection));

              _showDetailsPanel(context, inspection);
            },
            cells: [
              DataCell(Text(inspection.templateName)),
              DataCell(Text(inspection.sector)),
              DataCell(Text(inspection.documentNumber)),
              DataCell(Text('${inspection.score}%')),
              DataCell(Text(inspection.startedAt)),
              DataCell(Text(inspection.completedAt ?? '-')),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showOptionsMenu(context, inspection),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDetailsPanel(BuildContext context, Inspection inspection) {
    return Container(
      width: 400,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 24,
            offset: Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailsPanelHeader(context, inspection),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildDetailsPanelContent(inspection),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPanelHeader(BuildContext context, Inspection inspection) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Inspeção',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showOptionsMenu(context, inspection),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  context.read<InspectionBloc>().add(
                    const CloseInspectionDetails(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPanelContent(Inspection inspection) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${inspection.startedAt} / ${inspection.responsibleName}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text('Visualizar o relatório'),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF374151),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Icon(Icons.picture_as_pdf),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF374151),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Icon(Icons.more_horiz),
            ),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.share, size: 18),
          label: const Text('Compartilhar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF6366F1),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: const Size(double.infinity, 0),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Detalhes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Criar uma ação'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6366F1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDetailItem('Modelo', inspection.templateName),
        _buildDetailItem('Status', inspection.status),
        _buildDetailItem('Pontuação', '${inspection.score}%'),
        _buildDetailItem('Itens concluídos', inspection.completedItems),
        _buildDetailItem('Localização', inspection.location ?? '-'),
        _buildDetailItem('Proprietário', inspection.responsibleName),
        _buildDetailItem('Última edição feita por', inspection.lastEditedBy),
        _buildDetailItem('Iniciada', inspection.startedAtFull),
        _buildDetailItem('Atualizada', inspection.updatedAtFull),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, Inspection inspection) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18, color: Color(0xFF374151)),
              SizedBox(width: 12),
              Text('Editar'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'duplicate',
          child: Row(
            children: [
              Icon(Icons.content_copy, size: 18, color: Color(0xFF374151)),
              SizedBox(width: 12),
              Text('Duplicar'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'report',
          child: Row(
            children: [
              Icon(Icons.description, size: 18, color: Color(0xFF374151)),
              SizedBox(width: 12),
              Text('Ver relatório'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 18, color: Color(0xFFEF4444)),
              SizedBox(width: 12),
              Text('Excluir', style: TextStyle(color: Color(0xFFEF4444))),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        _handleMenuAction(context, value, inspection);
      }
    });
  }

  void _handleMenuAction(
    BuildContext context,
    String action,
    Inspection inspection,
  ) {
    switch (action) {
      case 'edit':
        // Implementar edição
        break;
      case 'duplicate':
        context.read<InspectionBloc>().add(DuplicateInspection(inspection.id));
        break;
      case 'report':
        // Implementar visualização de relatório
        break;
      case 'delete':
        _showDeleteConfirmation(context, inspection);
        break;
    }
  }

  void _onStartFromTemplate(InspectionTemplate template) {
    context.push('/inspections/execute', extra: template);
  }

  void _showDeleteConfirmation(BuildContext context, Inspection inspection) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir inspeção'),
        content: const Text('Tem certeza que deseja excluir esta inspeção?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<InspectionBloc>().add(
                DeleteInspection(inspection.id),
              );
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _showTemplateSelectionModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TemplateSelectionModal(),
    );
  }

  void _showDetailsPanel(BuildContext context, Inspection inspection) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Fechar",
      barrierColor: Colors.black54, // fundo escuro
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: FractionallySizedBox(
            widthFactor: 0.45, // largura do painel (45% da tela)
            child: Material(
              color: Colors.white,
              elevation: 8,
              child: _buildDetailsPanel(context, inspection),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(
          begin: const Offset(1, 0), // entra da direita
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOut));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}
