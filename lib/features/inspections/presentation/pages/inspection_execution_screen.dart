import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:layout_tests/features/inspections/bloc/inspection_execution/inspection_execution_bloc.dart';
import 'package:layout_tests/features/inspections/bloc/inspection_execution/inspection_execution_event.dart';
import 'package:layout_tests/features/inspections/bloc/inspection_execution/inspection_execution_state.dart';
import 'package:layout_tests/features/inspections/models/inspection_summary_args.dart';
import 'package:layout_tests/features/inspections/presentation/widgets/field_widget.dart';
import 'package:layout_tests/features/inspections/presentation/widgets/inspection_complete_dialog.dart';
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
        body: BlocConsumer<InspectionExecutionBloc, InspectionExecutionState>(
          listenWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
          listener: (context, state) {
            if (state is ExecutionFinished) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => InspectionCompleteDialog(
                  onViewSummary: () {
                    Navigator.of(context).pop();
                    context.go(
                      '/inspections/summary',
                      extra: InspectionSummaryArgs(
                        template: template,
                        answers: state.answers,
                        finalScore: state.finalScore,
                        inspectorName: 'USUÁRIO ATUAL',
                        finishedAt: DateTime.now(),
                        media: [], // collectedMedia
                      ),
                    );
                  },
                  onClose: () {
                    Navigator.of(context).pop();
                    context.go('/inspections');
                  },
                  title: 'Inspeção concluída',
                  subtitle: 'Tudo certo! Seus dados foram salvos com sucesso.',
                  primaryLabel: 'Visualizar resumo',
                  secondaryLabel: 'Salvar e fechar',
                ),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Inspeção finalizada.')),
              );
            }
          },
          builder: (context, state) {
            if (state is! ExecutionInProgress) {
              return const Center(child: CircularProgressIndicator());
            }

            final currentStep = state.currentStep;
            final step = template.steps[currentStep];

            return Column(
              children: [
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
                      return CustomScrollView(
                        slivers: [
                          // Cabeçalho fixo
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _StepHeaderDelegate(
                              minExtent: 64,
                              maxExtent: 92,
                              child: Material(
                                color: Theme.of(
                                  context,
                                ).scaffoldBackgroundColor,
                                elevation: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Color(0xFFE5E7EB),
                                      ),
                                    ),
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      step.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Conteúdo da etapa
                          SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 600,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: 12),
                                      for (final field in step.fields) ...[
                                        FieldWidget(
                                          field: field,
                                          value: state.answers[field.id],
                                          note: state.notesByField[field.id],
                                          attachments:
                                              state.attachmentsByField[field
                                                  .id] ??
                                              const [],
                                          onChanged: (val) {
                                            context
                                                .read<InspectionExecutionBloc>()
                                                .add(AnswerField(field, val));
                                          },
                                          onAddAttachments: (newOnes) {
                                            context
                                                .read<InspectionExecutionBloc>()
                                                .add(
                                                  AddFieldAttachments(
                                                    field.id,
                                                    newOnes,
                                                  ),
                                                );
                                          },
                                          onRemoveAttachment: (index) {
                                            context
                                                .read<InspectionExecutionBloc>()
                                                .add(
                                                  RemoveFieldAttachmentAt(
                                                    field.id,
                                                    index,
                                                  ),
                                                );
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
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

class _StepHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minExtent;
  final double maxExtent;
  final Widget child;

  _StepHeaderDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.child,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _StepHeaderDelegate oldDelegate) {
    return oldDelegate.maxExtent != maxExtent ||
        oldDelegate.minExtent != minExtent ||
        oldDelegate.child != child;
  }
}
