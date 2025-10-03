import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:layout_tests/features/template_inspections/models/field_types.dart';
import 'package:layout_tests/features/template_inspections/models/inspection_field.dart';
import 'package:layout_tests/features/template_inspections/models/inspection_step.dart';
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
  String _selectedSector = 'Qualidade';
  List<String> _selectedUsers = [];

  // Dados da Aba 2 - Criação
  List<InspectionStep> _steps = [];

  // Estado geral
  bool _isLoading = false;
  bool get _isEditing => widget.templateId != null;

  // Lista mockada de usuários para o multiselect
  final List<User> _availableUsers = [
    User(
      id: '1',
      name: 'João Silva',
      email: 'joao@example.com',
      phone: '',
      role: '',
      createdAt: DateTime.now(),
    ),
    User(
      id: '2',
      name: 'Maria Santos',
      email: 'maria@example.com',
      phone: '',
      role: '',
      createdAt: DateTime.now(),
    ),
    User(
      id: '3',
      name: 'Pedro Costa',
      email: 'pedro@example.com',
      phone: '',
      role: '',
      createdAt: DateTime.now(),
    ),
    User(
      id: '4',
      name: 'Ana Oliveira',
      email: 'ana@example.com',
      phone: '',
      role: '',
      createdAt: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    if (_isEditing) {
      _loadTemplateData();
    } else {
      // Adicionar uma etapa inicial
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

  void _loadTemplateData() {
    // Simular carregamento de dados
    setState(() {
      _nameController.text = 'Inspeção de Qualidade - Matéria Prima';
      _descriptionController.text =
          'Template para inspeção de matéria prima recebida';
      _selectedSector = 'Qualidade';
      _selectedUsers = ['1', '2'];
    });
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
        // TODO: Handle this case.
        throw UnimplementedError();
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
    return Scaffold(
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
                      style: TextStyle(fontSize: 16, color: Color(0xFF374151)),
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
                            _isEditing ? 'Salvar Alterações' : 'Criar Template',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Usuários com Permissão de Visualização',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                    ),
                    child: InkWell(
                      onTap: () => _showUserSelectionDialog(),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.people, color: Color(0xFF9CA3AF)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _selectedUsers.isEmpty
                                  ? const Text(
                                      'Selecione os usuários...',
                                      style: TextStyle(
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    )
                                  : Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: _selectedUsers.map((userId) {
                                        final user = _availableUsers.firstWhere(
                                          (u) => u.id == userId,
                                        );
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF2563EB,
                                            ).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                user.name,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF2563EB),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedUsers.remove(
                                                      userId,
                                                    );
                                                  });
                                                },
                                                child: const Icon(
                                                  Icons.close,
                                                  size: 12,
                                                  color: Color(0xFF2563EB),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xFF9CA3AF),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
                  _selectedUsers.isEmpty
                      ? 'Nenhum usuário selecionado'
                      : _selectedUsers
                            .map((id) {
                              final user = _availableUsers.firstWhere(
                                (u) => u.id == id,
                              );
                              return user.name;
                            })
                            .join(', '),
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

  void _showUserSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar Usuários'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: _availableUsers.length,
            itemBuilder: (context, index) {
              final user = _availableUsers[index];
              final isSelected = _selectedUsers.contains(user.id);

              return CheckboxListTile(
                value: isSelected,
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedUsers.add(user.id);
                    } else {
                      _selectedUsers.remove(user.id);
                    }
                  });
                },
                title: Text(user.name),
                subtitle: Text(user.email),
                secondary: CircleAvatar(
                  backgroundColor: const Color(
                    0xFF2563EB,
                  ).withValues(alpha: 0.1),
                  child: Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
