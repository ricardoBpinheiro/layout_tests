import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:layout_tests/features/template_inspections/models/field_option.dart';
import 'package:layout_tests/features/template_inspections/models/field_types.dart';
import 'package:layout_tests/features/inspections/models/inspection_summary_args.dart';
import 'package:layout_tests/features/template_inspections/models/inspection_field.dart';
import 'package:layout_tests/features/template_inspections/models/inspection_step.dart';
import 'package:layout_tests/features/template_inspections/models/inspection_template.dart';

class InspectionSummaryPage extends StatefulWidget {
  const InspectionSummaryPage({super.key, required this.args});
  final InspectionSummaryArgs args;

  @override
  State<InspectionSummaryPage> createState() => _InspectionSummaryPageState();
}

class _InspectionSummaryPageState extends State<InspectionSummaryPage> {
  bool overviewExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = widget.args.template;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop()
              ? Navigator.of(context).pop()
              : context.go('/inspections'),
          tooltip: 'Voltar à lista',
        ),
        title: const Text('Layout do relatório'),
        actions: [
          // placeholders para layout/pdf/compartilhar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: FilledButton.tonal(
              onPressed: () {
                /* abrir editor de layout */
              },
              child: const Row(
                children: [
                  Icon(Icons.scatter_plot_rounded, size: 18),
                  SizedBox(width: 6),
                  Text('Layout do relatório'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonalIcon(
            onPressed: () {
              /* exportar PDF depois */
            },
            icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
            label: const Text('PDF'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () {
              /* compartilhar depois */
            },
            child: const Text('Compartilhar'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1064),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              // Navegação/âncora lateral do seu print não implementada aqui (pode virar um NavigationRail depois)
              _OverviewSection(
                expanded: overviewExpanded,
                onToggle: () =>
                    setState(() => overviewExpanded = !overviewExpanded),
                args: widget.args,
              ),
              const SizedBox(height: 16),
              ..._buildSteps(t, widget.args.answers, theme),
              const SizedBox(height: 16),
              _MediaSummarySection(media: widget.args.media),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSteps(
    InspectionTemplate template,
    Map<String, dynamic> answers,
    ThemeData theme,
  ) {
    // Cada etapa como ExpansionTile-like card, similar ao print
    return template.steps.map((step) {
      return _StepCard(step: step, answers: answers);
    }).toList();
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({
    required this.expanded,
    required this.onToggle,
    required this.args,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final InspectionSummaryArgs args;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceVar = theme.colorScheme.onSurfaceVariant;

    return Card(
      color: theme.colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            onTap: onToggle,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.06),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    expanded ? Icons.expand_more : Icons.chevron_right,
                    color: surfaceVar,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Visão geral',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  _StatusChip(label: 'Concluída', color: Colors.teal),
                ],
              ),
            ),
          ),
          if (expanded) const Divider(height: 1),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                children: [
                  // Cabeçalho com nome do template e metadados (igual ao print)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _sectionDecoration(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          args.template.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${_fmtDate(args.finishedAt)} / ${args.inspectorName}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: surfaceVar,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, c) {
                            final isWide = c.maxWidth > 560;
                            final items = <Widget>[
                              _KpiTile(
                                title: 'Pontuação da inspeção',
                                value: _formatScore(args),
                              ),
                              _KpiTile(
                                title: 'Itens sinalizados',
                                value: _calcFlagged(args).toString(),
                              ),
                              _KpiTile(
                                title: 'Ações criadas',
                                value: _calcActions(args).toString(),
                              ),
                            ];
                            return isWide
                                ? Row(
                                    children: items
                                        .map((w) => Expanded(child: w))
                                        .toList(),
                                  )
                                : Column(
                                    children: [
                                      items[0],
                                      const SizedBox(height: 12),
                                      items[1],
                                      const SizedBox(height: 12),
                                      items[2],
                                    ],
                                  );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Exemplos de blocos de campo (como no print)
                  _InfoBlock(
                    title: 'Local onde foi conduzido',
                    trailingActionLabel: 'Ação',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [_Tag(label: 'Seguro', color: Colors.teal)],
                    ),
                  ),
                  _InfoBlock(
                    title: 'Realizado em',
                    trailingActionLabel: 'Ação',
                    child: Row(
                      children: [
                        const Icon(Icons.event, size: 18),
                        const SizedBox(width: 8),
                        Text(_fmtDate(args.finishedAt)),
                        const SizedBox(width: 16),
                        const Icon(Icons.access_time_filled_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(_fmtTime(args.finishedAt)),
                      ],
                    ),
                  ),
                  _InfoBlock(
                    title: 'Preparado por',
                    trailingActionLabel: 'Ação',
                    child: Text(args.inspectorName),
                  ),
                  _InfoBlock(
                    title: 'Localização',
                    trailingActionLabel: 'Ação',
                    child: Text(
                      'Sem resposta',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
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

  static BoxDecoration _sectionDecoration(BuildContext context) {
    final theme = Theme.of(context);
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: theme.colorScheme.primary.withOpacity(0.08)),
      color: theme.colorScheme.surface,
    );
  }

  String _formatScore(InspectionSummaryArgs a) {
    // Ajuste para sua regra real: exibe pontos e percentual
    // Aqui usamos finalScore e o total de campos pontuáveis do template
    final totalScore = a.template.steps
        .expand((s) => s.fields)
        .where(
          (f) =>
              f.type == FieldType.select ||
              f.type == FieldType.multiSelect ||
              f.type == FieldType.rating,
        )
        .fold<double>(
          0,
          (acc, f) =>
              acc +
              (f.options
                      ?.map((o) => o.score)
                      .fold<int>(0, (a, b) => a > b ? a : b) ??
                  0.0),
        );
    final pct = totalScore == 0
        ? 0
        : (a.finalScore / totalScore * 100).clamp(0, 100).round();
    return '${a.finalScore} / $totalScore ($pct%)';
  }

  int _calcFlagged(InspectionSummaryArgs a) {
    // Placeholder: conte quantos campos tiveram opção com score negativo, ou regra
    // Ajuste para sua definição de "sinalizado"
    return 0;
  }

  int _calcActions(InspectionSummaryArgs a) {
    // Placeholder: número de ações criadas
    return 0;
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.title,
    required this.child,
    this.trailingActionLabel,
  });
  final String title;
  final Widget child;
  final String? trailingActionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                child,
              ],
            ),
          ),
          if (trailingActionLabel != null) ...[
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: Text(trailingActionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      labelStyle: TextStyle(color: color),
      backgroundColor: color.withOpacity(0.12),
      side: BorderSide(color: color.withOpacity(0.24)),
      visualDensity: VisualDensity.compact,
    );
  }
}

String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
String _fmtTime(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} BRT';

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step, required this.answers});
  final InspectionStep step;
  final Map<String, dynamic> answers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.08)),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          step.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          const SizedBox(height: 4),
          ...step.fields.sortedBy((f) => f.order).map((f) {
            final value = answers[f.id];
            return _QuestionAnswerTile(field: f, value: value);
          }),
        ],
      ),
    );
  }
}

class _QuestionAnswerTile extends StatelessWidget {
  const _QuestionAnswerTile({required this.field, required this.value});
  final InspectionField field;
  final dynamic value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    Widget answerWidget;
    switch (field.type) {
      case FieldType.select:
        answerWidget = _renderSingleSelect(field, value, theme);
        break;
      case FieldType.multiSelect:
        answerWidget = _renderMultiSelect(field, value, theme);
        break;
      case FieldType.photo:
        answerWidget = _renderMedia(value);
        break;
      case FieldType.signature:
        answerWidget = _renderMedia(value);
        break;
      default:
        answerWidget = Text(
          value == null || ('$value').isEmpty ? 'Sem resposta' : '$value',
        );
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field.label, style: labelStyle),
          const SizedBox(height: 6),
          answerWidget,
        ],
      ),
    );
  }

  Widget _renderSingleSelect(
    InspectionField field,
    dynamic value,
    ThemeData theme,
  ) {
    if (value == null) {
      return Text(
        'Sem resposta',
        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      );
    }
    final opt = field.options?.firstWhere((o) => o.id == value);
    if (opt == null) return Text('$value');
    return _OptionChip(opt: opt);
  }

  Widget _renderMultiSelect(
    InspectionField field,
    dynamic value,
    ThemeData theme,
  ) {
    final ids = (value is List) ? value.cast<String>() : <String>[];
    if (ids.isEmpty)
      return Text(
        'Sem resposta',
        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      );
    final opts = field.options?.where((o) => ids.contains(o.id)).toList() ?? [];
    if (opts.isEmpty) return Text(ids.join(', '));
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: opts.map((o) => _OptionChip(opt: o)).toList(),
    );
  }

  Widget _renderMedia(dynamic value) {
    final items = (value is List) ? value.cast<MediaItem>() : <MediaItem>[];
    if (items.isEmpty) return const Text('Sem mídia');
    return _MediaGrid(items: items, maxCrossAxisExtent: 160);
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({required this.opt});
  final FieldOption opt;

  @override
  Widget build(BuildContext context) {
    final border = opt.color.withOpacity(0.30);
    return Chip(
      label: Text(opt.label),
      backgroundColor: opt.color.withOpacity(0.10),
      side: BorderSide(color: border),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _MediaSummarySection extends StatelessWidget {
  const _MediaSummarySection({required this.media});
  final List<MediaItem> media;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.08)),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Text(
              'Resumo de mídia',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${media.length} arquivo${media.length == 1 ? '' : 's'} de mídia',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        children: [
          const SizedBox(height: 8),
          if (media.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Sem mídias adicionadas',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            )
          else
            _MediaGrid(items: media),
        ],
      ),
    );
  }
}

class _MediaGrid extends StatelessWidget {
  const _MediaGrid({required this.items, this.maxCrossAxisExtent = 220});
  final List<MediaItem> items;
  final double maxCrossAxisExtent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 4 / 3,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final m = items[i];
        final isImage = (m.mimeType ?? '').startsWith('image/');
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.12),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(
                child: isImage
                    ? Image.network(
                        m.url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _mediaPlaceholder(m),
                      )
                    : _mediaPlaceholder(m),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  color: Colors.black.withOpacity(0.35),
                  child: Text(
                    m.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _mediaPlaceholder(MediaItem m) {
    return Container(
      color: Colors.blueGrey.withOpacity(0.06),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.insert_drive_file_rounded,
            size: 36,
            color: Colors.blueGrey,
          ),
          const SizedBox(height: 6),
          Text(
            m.mimeType ?? 'arquivo',
            style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
