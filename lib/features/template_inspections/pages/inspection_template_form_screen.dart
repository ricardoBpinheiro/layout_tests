import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:layout_tests/app_injection.dart';
import 'package:layout_tests/core/widgets/user_selection/bloc/user_selection_bloc.dart';
import 'package:layout_tests/core/widgets/user_selection/domain/repositories/user_repository.dart';
import 'package:layout_tests/core/widgets/user_selection/presentation/selected_users_field.dart';
import 'package:layout_tests/core/widgets/user_selection/presentation/user_selection_modal.dart';
import 'package:layout_tests/features/template_inspections/models/field_types.dart';
import 'package:layout_tests/features/template_inspections/models/inspection_field.dart';
import 'package:layout_tests/features/template_inspections/models/inspection_step.dart';
import 'package:layout_tests/features/template_inspections/models/report_preview_data.dart';
import 'package:layout_tests/features/template_inspections/widgets/field_type_selector_modal.dart';
import 'package:layout_tests/features/template_inspections/widgets/step_builder.dart';
import 'package:layout_tests/features/user/models/user_model.dart';

class InspectionTemplateFormScreen extends StatefulWidget {
  final String? templateId;

  const InspectionTemplateFormScreen({super.key, this.templateId});

  @override
  State<InspectionTemplateFormScreen> createState() =>
      _InspectionTemplateFormScreenState();
}

class _InspectionTemplateFormScreenState
    extends State<InspectionTemplateFormScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Controladores da Aba 1 - Capa
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailToController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  String _selectedSector = 'Qualidade';

  // Dados da Aba 2 - Criação
  List<InspectionStep> _steps = [];

  // Estado geral
  bool _isLoading = false;
  bool get _isEditing => widget.templateId != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    if (_isEditing) {
    } else {
      _addNewStep();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addNewStep() {
    setState(() {
      _steps.add(
        InspectionStep(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Etapa ${_steps.length + 1}',
          description: '',
          order: _steps.length,
          fields: [],
        ),
      );
    });
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
      // Reordenar as etapas
      for (int i = 0; i < _steps.length; i++) {
        _steps[i] = _steps[i].copyWith(order: i);
      }
    });
  }

  void _addFieldToStep(int stepIndex, FieldType fieldType) {
    setState(() {
      _steps[stepIndex] = _steps[stepIndex].copyWith(
        fields: [
          ..._steps[stepIndex].fields,
          InspectionField(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            label: _getDefaultFieldLabel(fieldType),
            type: fieldType,
            order: _steps[stepIndex].fields.length,
          ),
        ],
      );
    });
  }

  /// Adiciona um conjunto pré-definido de respostas a um step
  void _addPredefinedSetFieldToStep(int stepIndex, String predefinedSetKey) {
    final predefinedSets = <String, List<String>>{
      'Seguro': ['Seguro', 'Em risco', 'N/D'],
      'Qualidade': ['Bom', 'Razoável', 'Ruim', 'N/D'],
      'Status': ['Aprovado', 'Falha', 'N/D'],
      'Confirmação': ['Sim', 'Não', 'N/D'],
      'Conforme': ['Conforme', 'Não conforme', 'N/D'],
    };

    final options = predefinedSets[predefinedSetKey];

    if (options == null) {
      debugPrint('Conjunto não encontrado: $predefinedSetKey');
      return;
    }

    // setState(() {
    //   _steps[stepIndex] = _steps[stepIndex].copyWith(
    //     fields: [
    //       ..._steps[stepIndex].fields,
    //       InspectionField(
    //         id: DateTime.now().millisecondsSinceEpoch.toString(),
    //         label: predefinedSetKey,
    //         type: FieldType.select,
    //         order: _steps[stepIndex].fields.length,
    //         options: options,
    //       ),
    //     ],
    //   );
    // });
  }

  String _getDefaultFieldLabel(FieldType type) {
    switch (type) {
      case FieldType.text:
        return 'Pergunta de texto';
      case FieldType.number:
        return 'Pergunta numérica';
      case FieldType.email:
        return 'Email';
      case FieldType.phone:
        return 'Telefone';
      case FieldType.select:
        return 'Múltipla escolha';
      case FieldType.multiSelect:
        return 'Caixa de seleção';
      case FieldType.checkbox:
        return 'Pergunta sim/não';
      case FieldType.photo:
        return 'Upload de arquivo';
      case FieldType.signature:
        return 'Assinatura';
      case FieldType.date:
        return 'Data';
      case FieldType.time:
        return 'Horário';
      case FieldType.rating:
        return 'Escala de avaliação';
      case FieldType.predefinedSet:
        return 'Seleção';
      case FieldType.instruction:
        return 'Instrução';
    }
  }

  void _showFieldTypeSelector(int stepIndex) {
    showDialog(
      context: context,
      builder: (context) => FieldTypeSelectorModal(
        onFieldTypeSelected: (FieldType fieldType, {String? predefinedSet}) {
          if (predefinedSet != null) {
            _addPredefinedSetFieldToStep(stepIndex, predefinedSet);
          } else {
            _addFieldToStep(stepIndex, fieldType);
          }
        },
      ),
    );
  }

  void _removeFieldFromStep(int stepIndex, int fieldIndex) {
    setState(() {
      final fields = List<InspectionField>.from(_steps[stepIndex].fields);
      fields.removeAt(fieldIndex);

      // Reordenar os campos
      for (int i = 0; i < fields.length; i++) {
        fields[i] = fields[i].copyWith(order: i);
      }

      _steps[stepIndex] = _steps[stepIndex].copyWith(fields: fields);
    });
  }

  void _saveTemplate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos uma etapa'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simular salvamento
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing
              ? 'Template atualizado com sucesso!'
              : 'Template criado com sucesso!',
        ),
        backgroundColor: Colors.green,
      ),
    );

    context.go('/templates');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          UserSelectionBloc(getIt<UserRepository>())..add(LoadUsers()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: Text(_isEditing ? 'Editar Template' : 'Novo Template'),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: const Color(0xFF1F2937),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/templates'),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF2563EB),
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: const Color(0xFF2563EB),
            tabs: const [
              Tab(text: 'Capa'),
              Tab(text: 'Criação'),
              Tab(text: 'Revisão'),
              Tab(text: 'Relatório'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCoverTab(),
                  _buildCreationTab(),
                  _buildReviewTab(),
                  _buildReportTab(),
                ],
              ),
            ),

            // Botões de ação fixos
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/templates'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveTemplate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              _isEditing
                                  ? 'Salvar Alterações'
                                  : 'Criar Template',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Aba 1 - Capa do Template
  Widget _buildCoverTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(32),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informações Básicas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 24),

              // Nome do Template
              _buildTextField(
                label: 'Nome do Template',
                controller: _nameController,
                hint: 'Digite o nome do template',
                icon: Icons.assignment,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Descrição
              _buildTextField(
                label: 'Descrição',
                controller: _descriptionController,
                hint: 'Descreva o propósito e objetivo deste template',
                icon: Icons.description,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Descrição é obrigatória';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Setor Responsável
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Setor Responsável',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSector,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: 'Qualidade',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.verified,
                                  size: 18,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 12),
                                Text('Qualidade'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Engenharia',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.engineering,
                                  size: 18,
                                  color: Colors.orange,
                                ),
                                SizedBox(width: 12),
                                Text('Engenharia'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Almoxarifado',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.inventory,
                                  size: 18,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 12),
                                Text('Almoxarifado'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedSector = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Usuários com Permissão de Visualização (MultiSelect)
              SelectedUsersField(),
            ],
          ),
        ),
      ),
    );
  }

  // Aba 2 - Criação das Etapas
  Widget _buildCreationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lista de Etapas
          if (_steps.isEmpty)
            Container(
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
                children: [
                  Icon(Icons.assignment, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma etapa criada',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Clique no botão abaixo para começar',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          else
            ...List.generate(_steps.length, (index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: StepBuilder(
                  step: _steps[index],
                  stepIndex: index,
                  onStepUpdated: (updatedStep) {
                    setState(() {
                      _steps[index] = updatedStep;
                    });
                  },
                  onStepDeleted: () => _removeStep(index),
                  onAddField: () => _showFieldTypeSelector(index),
                  onRemoveField: (fieldIndex) =>
                      _removeFieldFromStep(index, fieldIndex),
                ),
              );
            }),

          // Botão para adicionar nova etapa
          const SizedBox(height: 20),
          Center(
            child: OutlinedButton.icon(
              onPressed: _addNewStep,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Adicionar Etapa'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                side: const BorderSide(color: Color(0xFF2563EB)),
                foregroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Aba 3 - Revisão
  Widget _buildReviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(32),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revisão do Template',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 24),

            // Resumo das informações básicas
            _buildReviewSection(
              title: 'Informações Básicas',
              children: [
                _buildReviewItem('Nome', _nameController.text),
                _buildReviewItem('Descrição', _descriptionController.text),
                _buildReviewItem('Setor Responsável', _selectedSector),
                _buildReviewItem(
                  'Usuários com Permissão',
                  'Nenhum usuário selecionado',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Resumo das etapas
            _buildReviewSection(
              title: 'Etapas Criadas',
              children: [
                if (_steps.isEmpty)
                  Text(
                    'Nenhuma etapa foi criada ainda.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  ...List.generate(_steps.length, (index) {
                    final step = _steps[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${index + 1}. ${step.name}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          if (step.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              step.description,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            'Campos: ${step.fields.length}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          if (step.fields.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: step.fields.map((field) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF2563EB,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    field.label,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Aba 4 - Relatorio
  Widget _buildReportTab() {
    final theme = Theme.of(context);
    final sampleData = ReportPreviewData(
      tituloTemplate: 'Modelo sem título',
      tituloInspecao: '06/10/2025 / Nome Usuário',
      dataInspecao: DateTime.now(),
      pontuacao: 0.80, // 80%
    );

    final subjectPreview = _applyVars(_subjectController.text, sampleData);
    final bodyPreview = _applyVars(_bodyController.text, sampleData);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 1000;

        // Use SingleChildScrollView no eixo principal e evite Expanded dentro dele.
        final content = Padding(
          padding: const EdgeInsets.all(16),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Coluna esquerda
                    Flexible(
                      flex: 4,
                      fit: FlexFit.loose,
                      child: _LeftEmailConfigCard(
                        subjectPreview: subjectPreview,
                        bodyPreview: bodyPreview,
                        isLoading: _isLoading,
                        saveTemplate: _saveTemplate,
                        emailToController: _emailToController,
                        subjectController: _subjectController,
                        bodyController: _bodyController,
                        insertVarInSubject: _insertVarInSubject,
                        insertVarInBody: _insertVarInBody,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Coluna direita
                    Flexible(
                      flex: 6,
                      fit: FlexFit.loose,
                      child: _RightPreviewCard(
                        subjectPreview: subjectPreview,
                        bodyPreview: bodyPreview,
                        data: sampleData,
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // importante
                  children: [
                    _LeftEmailConfigCard(
                      subjectPreview: subjectPreview,
                      bodyPreview: bodyPreview,
                      isLoading: _isLoading,
                      saveTemplate: _saveTemplate,
                      emailToController: _emailToController,
                      subjectController: _subjectController,
                      bodyController: _bodyController,
                      insertVarInSubject: _insertVarInSubject,
                      insertVarInBody: _insertVarInBody,
                    ),
                    const SizedBox(height: 16),
                    _RightPreviewCard(
                      subjectPreview: subjectPreview,
                      bodyPreview: bodyPreview,
                      data: sampleData,
                    ),
                  ],
                ),
        );

        return SingleChildScrollView(child: content);
      },
    );
  }

  String _applyVars(String input, ReportPreviewData data) {
    return input
        .replaceAll('{TituloTemplate}', data.tituloTemplate)
        .replaceAll('{TituloInspecao}', data.tituloInspecao)
        .replaceAll('{DataInspecao}', _formatDateTime(data.dataInspecao))
        .replaceAll(
          '{Pontuação}',
          '${(data.pontuacao * 100).toStringAsFixed(0)}%',
        );
  }

  void _insertAtCursor(TextEditingController c, String token) {
    final sel = c.selection;
    final base = c.text;
    if (!sel.isValid) {
      c.text = base + token;
      c.selection = TextSelection.collapsed(offset: c.text.length);
      return;
    }
    final newText = base.replaceRange(sel.start, sel.end, token);
    c.text = newText;
    c.selection = TextSelection.collapsed(offset: sel.start + token.length);
  }

  void _insertVarInSubject(String token) {
    setState(() => _insertAtCursor(_subjectController, token));
  }

  void _insertVarInBody(String token) {
    setState(() => _insertAtCursor(_bodyController, token));
  }

  String _formatDateTime(DateTime dt) {
    // 06/10/2025 21:30
    final two = (int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }

  Widget _buildReviewSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Não informado' : value,
              style: TextStyle(
                color: value.isEmpty
                    ? Colors.grey[500]
                    : const Color(0xFF1F2937),
                fontStyle: value.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _VarsMenu extends StatelessWidget {
  final void Function(String token) onInsert;
  const _VarsMenu({required this.onInsert});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Inserir variável',
      onSelected: onInsert,
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: '{TituloTemplate}',
          child: Text('{TituloTemplate}'),
        ),
        PopupMenuItem(
          value: '{TituloInspecao}',
          child: Text('{TituloInspecao}'),
        ),
        PopupMenuItem(value: '{DataInspecao}', child: Text('{DataInspecao}')),
        PopupMenuItem(value: '{Pontuação}', child: Text('{Pontuação}')),
      ],
      child: OutlinedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Variáveis'),
        onPressed: null,
      ),
    );
  }
}

class _VarsLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final styleK = const TextStyle(
      fontWeight: FontWeight.w600,
      color: Color(0xFF374151),
    );
    final styleV = const TextStyle(color: Color(0xFF6B7280));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Variáveis disponíveis',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: const [
            _KV('{TituloTemplate}', 'Título do modelo, ex: Modelo sem título'),
            _KV(
              '{TituloInspecao}',
              'Título da inspeção, ex: 06/10/2025 / Nome Usuário',
            ),
            _KV('{DataInspecao}', 'Data de conclusão, ex: 06/10/2025 21:30'),
            _KV('{Pontuação}', 'Pontuação total, ex: 80%'),
          ],
        ),
      ],
    );
  }
}

class _KV extends StatelessWidget {
  final String k;
  final String v;
  const _KV(this.k, this.v);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(k, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text('— $v', style: const TextStyle(color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}

class _EmailPreviewCard extends StatelessWidget {
  final String to;
  final String subject;
  final String body;
  const _EmailPreviewCard({
    required this.to,
    required this.subject,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prévia do e-mail',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _row('Para', to.isEmpty ? '—' : to),
          _row('Assunto', subject.isEmpty ? '—' : subject),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text(body.isEmpty ? '—' : body),
          ),
        ],
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(k, style: const TextStyle(color: Color(0xFF6B7280))),
          ),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }
}

class _PdfPreviewCard extends StatelessWidget {
  final ReportPreviewData data;
  const _PdfPreviewCard({required this.data});

  @override
  Widget build(BuildContext context) {
    // Apenas um mock visual. Na inspeção você usará seu gerador real de PDF.
    return AspectRatio(
      aspectRatio: 210 / 297, // A4
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0ECFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.insert_drive_file,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.tituloTemplate,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          data.tituloInspecao,
                          style: const TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Pontuação ${(data.pontuacao * 100).toStringAsFixed(0)}%',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              // Body placeholders
              _line('Local onde foi conduzido'),
              _line('Realizado em'),
              _line('Preparado por'),
              _line('Localização'),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Itens sinalizados e ações',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      border: Border.all(color: Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              title,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          Expanded(
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RightPreviewCard extends StatelessWidget {
  final String subjectPreview;
  final String bodyPreview;
  final ReportPreviewData data;

  const _RightPreviewCard({
    required this.subjectPreview,
    required this.bodyPreview,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min, // evita conflito em altura "solta"
        children: [
          Row(
            children: [
              Text(
                'Pré-visualização do Relatório',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'web', label: Text('Web')),
                  ButtonSegment(value: 'pdf', label: Text('PDF')),
                ],
                selected: const {'pdf'},
                onSelectionChanged: (_) {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _EmailPreviewCard(
            to: '', // opcional: passe _emailToController.text
            subject: subjectPreview,
            body: bodyPreview,
          ),
          const SizedBox(height: 16),

          // Em vez de Expanded, defina um AspectRatio ou altura máxima.
          AspectRatio(
            aspectRatio: 210 / 297, // A4
            child: _PdfPreviewSurface(data: data),
          ),
        ],
      ),
    );
  }
}

class _PdfPreviewSurface extends StatelessWidget {
  final ReportPreviewData data;
  const _PdfPreviewSurface({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header...
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0ECFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.insert_drive_file,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.tituloTemplate,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      data.tituloInspecao,
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Pontuação ${(data.pontuacao * 100).toStringAsFixed(0)}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          _line('Local onde foi conduzido'),
          _line('Realizado em'),
          _line('Preparado por'),
          _line('Localização'),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'Itens sinalizados e ações',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),

          // Lista não-scrollável com altura conhecida
          // Use Expanded somente se a altura do pai for limitada. Aqui usamos SizedBox + ListView(shrinkWrap).
          SizedBox(
            height: 3 * 40, // 3 linhas x 40px
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => Container(
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              title,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          Expanded(
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeftEmailConfigCard extends StatelessWidget {
  final String subjectPreview;
  final String bodyPreview;
  final bool isLoading;
  final VoidCallback saveTemplate;
  final TextEditingController emailToController;
  final TextEditingController subjectController;
  final TextEditingController bodyController;
  final void Function(String) insertVarInSubject;
  final void Function(String) insertVarInBody;

  const _LeftEmailConfigCard({
    required this.subjectPreview,
    required this.bodyPreview,
    required this.isLoading,
    required this.saveTemplate,
    required this.emailToController,
    required this.subjectController,
    required this.bodyController,
    required this.insertVarInSubject,
    required this.insertVarInBody,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Configurações do e-mail',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Text('E-mail para', style: _labelStyle()),
          const SizedBox(height: 8),
          TextField(
            controller: emailToController,
            decoration: _inputDecoration('ex: pessoa@empresa.com'),
          ),
          const SizedBox(height: 16),
          Text('Assunto', style: _labelStyle()),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: subjectController,
                  onChanged: (_) => (context as Element).markNeedsBuild(),
                  decoration: _inputDecoration('Assunto do e-mail'),
                ),
              ),
              const SizedBox(width: 8),
              _VarsMenu(onInsert: insertVarInSubject),
            ],
          ),
          const SizedBox(height: 16),
          Text('Corpo', style: _labelStyle()),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: bodyController,
                  onChanged: (_) => (context as Element).markNeedsBuild(),
                  maxLines: 10,
                  decoration: _inputDecoration(
                    'Escreva o corpo do e-mail...\nUse as variáveis.',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _VarsMenu(onInsert: insertVarInBody),
            ],
          ),
          const SizedBox(height: 16),
          _VarsLegend(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : saveTemplate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Salvar'),
            ),
          ),
        ],
      ),
    );
  }
}

TextStyle _labelStyle() => const TextStyle(
  fontSize: 12,
  color: Color(0xFF6B7280),
  fontWeight: FontWeight.w600,
);

InputDecoration _inputDecoration(String hint) => InputDecoration(
  hintText: hint,
  filled: true,
  fillColor: const Color(0xFFFAFAFA),
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Color(0xFF2563EB)),
  ),
);
