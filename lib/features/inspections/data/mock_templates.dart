import 'package:flutter/material.dart';
import 'package:layout_tests/features/template_inspections/models/field_option.dart';
import 'package:layout_tests/features/template_inspections/models/field_types.dart';
import 'package:layout_tests/features/template_inspections/models/inspection_field.dart';
import 'package:layout_tests/features/template_inspections/models/inspection_step.dart';
import 'package:layout_tests/features/template_inspections/models/inspection_template.dart';
import 'package:layout_tests/features/template_inspections/models/question_rule.dart';

class MockTemplates {
  static List<InspectionTemplate> getTemplates() {
    return [_segurancaTrabalhoTemplate(), _qualidadeAlimentosTemplate()];
  }

  static InspectionTemplate _segurancaTrabalhoTemplate() {
    return InspectionTemplate(
      id: '1',
      name: 'Inspeção de Segurança do Trabalho',
      description:
          'Template para inspeção de segurança e condições de trabalho em ambientes industriais',
      sector: 'Segurança do Trabalho',
      allowedUserIds: ['user1', 'user2', 'user3'],
      version: 1,
      status: 'active',
      createdAt: DateTime(2025, 1, 15),
      updatedAt: DateTime(2025, 2, 1),
      createdBy: 'admin@empresa.com',
      steps: [
        InspectionStep(
          id: 'step1',
          name: 'Equipamentos de Proteção Individual (EPI)',
          description: 'Verificação do uso correto de EPIs',
          order: 1,
          fields: [
            InspectionField(
              id: 'field1',
              label: 'Todos os colaboradores estão usando capacete?',
              type: FieldType.select,
              required: true,
              hint: 'Verifique se todos estão com capacete',
              order: 1,
              options: [
                FieldOption(
                  id: 'opt1',
                  label: 'Conforme',
                  color: const Color(0xFF10B981),
                  score: 100,
                ),
                FieldOption(
                  id: 'opt2',
                  label: 'Não Conforme',
                  color: const Color(0xFFEF4444),
                  score: 0,
                ),
                FieldOption(
                  id: 'opt3',
                  label: 'Não Aplicável',
                  color: const Color(0xFF6B7280),
                  score: 100,
                ),
              ],
            ),
            InspectionField(
              id: 'field2',
              label: 'Os óculos de proteção estão em bom estado?',
              type: FieldType.select,
              required: true,
              order: 2,
              options: [
                FieldOption(
                  id: 'opt1',
                  label: 'Conforme',
                  color: const Color(0xFF10B981),
                  score: 100,
                ),
                FieldOption(
                  id: 'opt2',
                  label: 'Não Conforme',
                  color: const Color(0xFFEF4444),
                  score: 0,
                ),
                FieldOption(
                  id: 'opt3',
                  label: 'Não Aplicável',
                  color: const Color(0xFF6B7280),
                  score: 100,
                ),
              ],
            ),
            InspectionField(
              id: 'field3',
              label: 'Registre foto dos EPIs em uso',
              type: FieldType.photo,
              required: false,
              hint: 'Tire uma foto geral da equipe',
              order: 3,
            ),
            InspectionField(
              id: 'field4',
              label: 'Observações sobre EPIs',
              type: FieldType.text,
              required: false,
              hint: 'Descreva qualquer observação relevante',
              order: 4,
            ),
          ],
        ),
        InspectionStep(
          id: 'step2',
          name: 'Condições do Ambiente',
          description: 'Avaliação das condições gerais do ambiente de trabalho',
          order: 2,
          fields: [
            InspectionField(
              id: 'field5',
              label: 'A iluminação está adequada?',
              type: FieldType.rating,
              required: true,
              hint: 'Avalie de 1 a 5 estrelas',
              order: 1,
            ),
            InspectionField(
              id: 'field6',
              label: 'Temperatura do ambiente (°C)',
              type: FieldType.number,
              required: true,
              hint: 'Informe a temperatura em graus Celsius',
              order: 2,
              validation: 'min:0,max:50',
            ),
            InspectionField(
              id: 'field7',
              label: 'Há sinalização de segurança visível?',
              type: FieldType.checkbox,
              required: true,
              order: 3,
            ),
            InspectionField(
              id: 'field8',
              label: 'As saídas de emergência estão desobstruídas?',
              type: FieldType.select,
              required: true,
              order: 4,
              options: [
                FieldOption(
                  id: 'opt1',
                  label: 'Sim',
                  color: const Color(0xFF10B981),
                  score: 100,
                ),
                FieldOption(
                  id: 'opt2',
                  label: 'Não',
                  color: const Color(0xFFEF4444),
                  score: 0,
                ),
              ],
              rules: [
                QuestionRule(
                  id: 'rule1',
                  condition: 'equals',
                  value: 'opt2',
                  action: 'require_photo',
                ),
              ],
            ),
            InspectionField(
              id: 'field9',
              label: 'Foto das saídas de emergência',
              type: FieldType.photo,
              required: false,
              order: 5,
            ),
          ],
        ),
        InspectionStep(
          id: 'step3',
          name: 'Equipamentos e Máquinas',
          description: 'Verificação de equipamentos e máquinas',
          order: 3,
          fields: [
            InspectionField(
              id: 'field10',
              label: 'Todos os equipamentos possuem proteção adequada?',
              type: FieldType.select,
              required: true,
              order: 1,
              options: [
                FieldOption(
                  id: 'opt1',
                  label: 'Conforme',
                  color: const Color(0xFF10B981),
                  score: 100,
                ),
                FieldOption(
                  id: 'opt2',
                  label: 'Não Conforme',
                  color: const Color(0xFFEF4444),
                  score: 0,
                ),
              ],
            ),
            InspectionField(
              id: 'field11',
              label: 'Data da última manutenção preventiva',
              type: FieldType.date,
              required: true,
              order: 2,
            ),
            InspectionField(
              id: 'field12',
              label: 'Responsável pela manutenção',
              type: FieldType.text,
              required: true,
              hint: 'Nome completo do responsável',
              order: 3,
            ),
            InspectionField(
              id: 'field13',
              label: 'Assinatura do inspetor',
              type: FieldType.signature,
              required: true,
              order: 4,
            ),
          ],
        ),
      ],
    );
  }

  static InspectionTemplate _qualidadeAlimentosTemplate() {
    return InspectionTemplate(
      id: '2',
      name: 'Inspeção de Qualidade de Alimentos',
      description:
          'Template para inspeção de qualidade e higiene em estabelecimentos alimentícios',
      sector: 'Qualidade e Higiene',
      allowedUserIds: ['user1', 'user4', 'user5'],
      version: 2,
      status: 'active',
      createdAt: DateTime(2025, 1, 10),
      updatedAt: DateTime(2025, 2, 5),
      createdBy: 'supervisor@empresa.com',
      steps: [
        InspectionStep(
          id: 'step1',
          name: 'Higiene e Limpeza',
          description:
              'Verificação das condições de higiene do estabelecimento',
          order: 1,
          fields: [
            InspectionField(
              id: 'field1',
              label: 'O piso está limpo e sem resíduos?',
              type: FieldType.select,
              required: true,
              order: 1,
              options: [
                FieldOption(
                  id: 'opt1',
                  label: 'Excelente',
                  color: const Color(0xFF10B981),
                  score: 100,
                ),
                FieldOption(
                  id: 'opt2',
                  label: 'Bom',
                  color: const Color(0xFF3B82F6),
                  score: 75,
                ),
                FieldOption(
                  id: 'opt3',
                  label: 'Regular',
                  color: const Color(0xFFF59E0B),
                  score: 50,
                ),
                FieldOption(
                  id: 'opt4',
                  label: 'Ruim',
                  color: const Color(0xFFEF4444),
                  score: 0,
                ),
              ],
            ),
            InspectionField(
              id: 'field2',
              label: 'As bancadas estão sanitizadas?',
              type: FieldType.select,
              required: true,
              order: 2,
              options: [
                FieldOption(
                  id: 'opt1',
                  label: 'Sim',
                  color: const Color(0xFF10B981),
                  score: 100,
                ),
                FieldOption(
                  id: 'opt2',
                  label: 'Não',
                  color: const Color(0xFFEF4444),
                  score: 0,
                ),
                FieldOption(
                  id: 'opt3',
                  label: 'Parcialmente',
                  color: const Color(0xFFF59E0B),
                  score: 50,
                ),
              ],
            ),
            InspectionField(
              id: 'field3',
              label: 'Foto do ambiente',
              type: FieldType.photo,
              required: true,
              hint: 'Registre foto geral da área de preparo',
              order: 3,
            ),
            InspectionField(
              id: 'field4',
              label: 'Há presença de pragas?',
              type: FieldType.checkbox,
              required: true,
              order: 4,
            ),
          ],
        ),
        InspectionStep(
          id: 'step2',
          name: 'Armazenamento',
          description: 'Verificação das condições de armazenamento',
          order: 2,
          fields: [
            InspectionField(
              id: 'field5',
              label: 'Temperatura da geladeira (°C)',
              type: FieldType.number,
              required: true,
              hint: 'Deve estar entre 0°C e 5°C',
              order: 1,
              validation: 'min:-5,max:10',
            ),
            InspectionField(
              id: 'field6',
              label: 'Temperatura do freezer (°C)',
              type: FieldType.number,
              required: true,
              hint: 'Deve estar abaixo de -18°C',
              order: 2,
              validation: 'min:-30,max:-10',
            ),
            InspectionField(
              id: 'field7',
              label: 'Os alimentos estão identificados com data?',
              type: FieldType.select,
              required: true,
              order: 3,
              options: [
                FieldOption(
                  id: 'opt1',
                  label: 'Todos identificados',
                  color: const Color(0xFF10B981),
                  score: 100,
                ),
                FieldOption(
                  id: 'opt2',
                  label: 'Parcialmente identificados',
                  color: const Color(0xFFF59E0B),
                  score: 50,
                ),
                FieldOption(
                  id: 'opt3',
                  label: 'Não identificados',
                  color: const Color(0xFFEF4444),
                  score: 0,
                ),
              ],
            ),
            InspectionField(
              id: 'field8',
              label: 'Selecione os itens em conformidade',
              type: FieldType.multiSelect,
              required: false,
              order: 4,
              options: [
                FieldOption(
                  id: 'opt1',
                  label: 'Carnes',
                  color: const Color(0xFF10B981),
                  score: 25,
                ),
                FieldOption(
                  id: 'opt2',
                  label: 'Laticínios',
                  color: const Color(0xFF10B981),
                  score: 25,
                ),
                FieldOption(
                  id: 'opt3',
                  label: 'Vegetais',
                  color: const Color(0xFF10B981),
                  score: 25,
                ),
                FieldOption(
                  id: 'opt4',
                  label: 'Congelados',
                  color: const Color(0xFF10B981),
                  score: 25,
                ),
              ],
            ),
            InspectionField(
              id: 'field9',
              label: 'Foto do armazenamento',
              type: FieldType.photo,
              required: false,
              order: 5,
            ),
          ],
        ),
        InspectionStep(
          id: 'step3',
          name: 'Manipuladores',
          description:
              'Verificação das condições dos manipuladores de alimentos',
          order: 3,
          fields: [
            InspectionField(
              id: 'field10',
              label: 'Todos usam uniforme completo?',
              type: FieldType.select,
              required: true,
              order: 1,
              options: [
                FieldOption(
                  id: 'opt1',
                  label: 'Sim',
                  color: const Color(0xFF10B981),
                  score: 100,
                ),
                FieldOption(
                  id: 'opt2',
                  label: 'Não',
                  color: const Color(0xFFEF4444),
                  score: 0,
                ),
              ],
            ),
            InspectionField(
              id: 'field11',
              label: 'As unhas estão curtas e sem esmalte?',
              type: FieldType.checkbox,
              required: true,
              order: 2,
            ),
            InspectionField(
              id: 'field12',
              label: 'Há uso de adornos (anéis, pulseiras, etc)?',
              type: FieldType.checkbox,
              required: true,
              order: 3,
            ),
            InspectionField(
              id: 'field13',
              label: 'Horário da inspeção',
              type: FieldType.time,
              required: true,
              order: 4,
            ),
            InspectionField(
              id: 'field14',
              label: 'E-mail do responsável',
              type: FieldType.email,
              required: true,
              hint: 'exemplo@empresa.com',
              order: 5,
            ),
            InspectionField(
              id: 'field15',
              label: 'Telefone para contato',
              type: FieldType.phone,
              required: true,
              hint: '(00) 00000-0000',
              order: 6,
            ),
          ],
        ),
        InspectionStep(
          id: 'step4',
          name: 'Finalização',
          description: 'Avaliação geral e assinatura',
          order: 4,
          fields: [
            InspectionField(
              id: 'field16',
              label: 'Avaliação geral do estabelecimento',
              type: FieldType.rating,
              required: true,
              hint: 'Avalie de 1 a 5 estrelas',
              order: 1,
            ),
            InspectionField(
              id: 'field17',
              label: 'Observações gerais',
              type: FieldType.text,
              required: false,
              hint: 'Descreva observações importantes',
              order: 2,
            ),
            InspectionField(
              id: 'field18',
              label: 'Recomendações',
              type: FieldType.text,
              required: false,
              hint: 'Liste as recomendações para melhorias',
              order: 3,
            ),
            InspectionField(
              id: 'field19',
              label: 'Assinatura do inspetor',
              type: FieldType.signature,
              required: true,
              order: 4,
            ),
          ],
        ),
      ],
    );
  }
}
