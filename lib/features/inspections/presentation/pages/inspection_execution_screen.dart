import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:layout_tests/features/inspections/bloc/inspection_execution/inspection_execution_bloc.dart';
import 'package:layout_tests/features/inspections/bloc/inspection_execution/inspection_execution_event.dart';
import 'package:layout_tests/features/inspections/bloc/inspection_execution/inspection_execution_state.dart';
import 'package:layout_tests/features/inspections/presentation/widgets/field_widget.dart';
import 'package:layout_tests/features/template_inspections/models/inspection_template.dart';

class InspectionExecutionScreen extends StatelessWidget {
  final InspectionTemplate template;

  const InspectionExecutionScreen({super.key, required this.template});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InspectionExecutionBloc(template: template),
      child: Scaffold(
        appBar: AppBar(title: Text(template.name)),
        body: BlocBuilder<InspectionExecutionBloc, InspectionExecutionState>(
          builder: (context, state) {
            if (state is! ExecutionInProgress) {
              return const Center(child: CircularProgressIndicator());
            }

            final currentStep = state.currentStep;
            final step = template.steps[currentStep];

            return Column(
              children: [
                // Barra de Progresso/Pontuação
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Etapa ${currentStep + 1} de ${template.steps.length}",
                      ),
                      Text(
                        "Pontuação: ${state.score}%",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: state.pageController,
                    onPageChanged: (index) => context
                        .read<InspectionExecutionBloc>()
                        .add(ChangeStep(index)),
                    itemCount: template.steps.length,
                    itemBuilder: (_, index) {
                      final step = template.steps[index];
                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Text(
                            step.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          for (final field in step.fields)
                            FieldWidget(
                              field: field,
                              value: state.answers[field.id],
                              onChanged: (val) {
                                context.read<InspectionExecutionBloc>().add(
                                  AnswerField(field, val),
                                );
                              },
                            ),
                        ],
                      );
                    },
                  ),
                ),

                // Botões de navegação
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (currentStep > 0)
                        ElevatedButton(
                          onPressed: () => context
                              .read<InspectionExecutionBloc>()
                              .add(PreviousStep()),
                          child: const Text("Voltar"),
                        ),
                      if (currentStep < template.steps.length - 1)
                        ElevatedButton(
                          onPressed: () => context
                              .read<InspectionExecutionBloc>()
                              .add(NextStep()),
                          child: const Text("Próxima página"),
                        ),
                      if (currentStep == template.steps.length - 1)
                        ElevatedButton(
                          onPressed: () => context
                              .read<InspectionExecutionBloc>()
                              .add(SubmitInspection()),
                          child: const Text("Finalizar"),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
