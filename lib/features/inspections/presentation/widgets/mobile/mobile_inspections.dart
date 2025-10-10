import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:layout_tests/app_injection.dart';
import 'package:layout_tests/features/inspections/bloc/inspection_bloc.dart';
import 'package:layout_tests/features/inspections/bloc/template_bloc.dart';
import 'package:layout_tests/features/inspections/bloc/template_event.dart';
import 'package:layout_tests/features/inspections/bloc/template_state.dart';
import 'package:layout_tests/features/inspections/data/template_repository.dart';
import 'package:layout_tests/features/inspections/models/inspection.dart';
import 'package:layout_tests/features/template_inspections/models/inspection_template.dart';

class MobileInspections extends StatelessWidget {
  final InspectionState state;
  final TextEditingController searchController;
  final void Function(InspectionTemplate template) onStartFromTemplate;
  final VoidCallback onShowTemplatePicker;
  final void Function(BuildContext, Inspection) onShowOptions;

  const MobileInspections({
    super.key,
    required this.state,
    required this.searchController,
    required this.onStartFromTemplate,
    required this.onShowTemplatePicker,
    required this.onShowOptions,
  });

  @override
  Widget build(BuildContext context) {
    // Em mobile, duas abas: Modelos e Em Andamento/Concluídas
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            TabBar(
              isScrollable: false,
              tabs: [
                Tab(text: 'Modelos'),
                Tab(text: 'Em Andamento e Concluídas'),
              ],
            ),
            // Busca
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Pesquisar',
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _MobileTemplatesTab(onStartFromTemplate: onStartFromTemplate),
                  _MobileInspectionsTab(
                    state: state,
                    onShowOptions: onShowOptions,
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: onShowTemplatePicker,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

// Abas

class _MobileTemplatesTab extends StatelessWidget {
  final void Function(InspectionTemplate template) onStartFromTemplate;

  const _MobileTemplatesTab({required this.onStartFromTemplate});

  @override
  Widget build(BuildContext context) {
    // Reutiliza seu TemplateBloc para carregar os templates na aba
    return BlocProvider(
      create: (_) =>
          TemplateBloc(repository: getIt<TemplateRepository>())
            ..add(const LoadTemplates()),
      child: BlocBuilder<TemplateBloc, TemplateState>(
        builder: (context, state) {
          if (state is TemplateLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TemplateLoaded) {
            if (state.filteredTemplates.isEmpty) {
              return const Center(child: Text('Nenhum modelo disponível'));
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: state.filteredTemplates.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final t = state.filteredTemplates[index];
                return _TemplateCard(
                  template: t,
                  onTap: () => onStartFromTemplate(t),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _MobileInspectionsTab extends StatelessWidget {
  final InspectionState state;
  final void Function(BuildContext, Inspection) onShowOptions;

  const _MobileInspectionsTab({
    required this.state,
    required this.onShowOptions,
  });

  @override
  Widget build(BuildContext context) {
    if (state is InspectionLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is! InspectionLoaded) {
      return const SizedBox();
    }

    final inspections = (state as InspectionLoaded).filteredInspections;

    if (inspections.isEmpty) {
      return const Center(child: Text('Nenhuma inspeção encontrada'));
    }

    // 1) Agrupar por dia de início
    final grouped = _groupByDay(inspections);

    // 2) Construir lista com headers por dia + cards
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entry = grouped[index];
        final dayLabel = _formatDayLabel(entry.date);
        final dayInspections = entry.items;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header do dia
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
              child: Text(
                dayLabel,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...dayInspections.map((i) {
              final status = _statusBadge(i.status);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _InspectionCardMobileGrouped(
                  inspection: i,
                  statusLabel: status.label,
                  statusBg: status.bg,
                  statusFg: status.fg,
                  onTap: () {
                    // BottomSheet com ações rápidas
                    showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder: (_) => _InspectionBottomSheet(
                        inspection: i,
                        onShowOptions: () => onShowOptions(context, i),
                      ),
                    );
                  },
                  onMore: () => onShowOptions(context, i),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  // Agrupa por dia (desconsiderando hora/minuto)
  List<_DayGroup> _groupByDay(List<Inspection> list) {
    final map = <DateTime, List<Inspection>>{};
    for (final i in list) {
      final started = _parseDate(
        i.startedAt,
      ); // ajuste se startedAt já for DateTime
      final key = DateTime(started.year, started.month, started.day);
      map.putIfAbsent(key, () => []).add(i);
    }

    final entries = map.entries
        .map(
          (e) => _DayGroup(
            date: e.key,
            items: e.value
              ..sort(
                (a, b) =>
                    _parseDate(b.startedAt).compareTo(_parseDate(a.startedAt)),
              ),
          ),
        )
        .toList();

    // Ordena blocos por dia desc
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  // Converte startedAt (String) -> DateTime
  DateTime _parseDate(String value) {
    // Se já vier em ISO 8601 use DateTime.parse(value)
    // Aqui tentamos parse genérico. Ajuste para seu formato real (ex.: dd/MM/yyyy HH:mm).
    try {
      return DateTime.parse(value);
    } catch (_) {
      // Tente outros formatos se necessário
      // Exemplo rápido: "07/10/2025 14:35"
      final parts = RegExp(r'(\d{2})/(\d{2})/(\d{4})').firstMatch(value);
      if (parts != null) {
        final d = int.parse(parts.group(1)!);
        final m = int.parse(parts.group(2)!);
        final y = int.parse(parts.group(3)!);
        return DateTime(y, m, d);
      }
      // fallback: agora
      return DateTime.now();
    }
  }

  String _formatDayLabel(DateTime date) {
    // “7 de out. de 2025” – use intl se quiser i18n perfeita
    const months = [
      'jan.',
      'fev.',
      'mar.',
      'abr.',
      'mai.',
      'jun.',
      'jul.',
      'ago.',
      'set.',
      'out.',
      'nov.',
      'dez.',
    ];
    final m = months[date.month - 1];
    return '${date.day} de $m de ${date.year}';
  }

  _StatusBadgeColors _statusBadge(String status) {
    final s = status.toLowerCase();
    if (s.contains('conclu')) {
      return _StatusBadgeColors(
        label: 'Concluída',
        bg: const Color(0xFFE9FDF1),
        fg: const Color(0xFF059669),
      );
    }
    return _StatusBadgeColors(
      label: 'Em andamento',
      bg: const Color(0xFFEFF6FF),
      fg: const Color(0xFF2563EB),
    );
  }
}

class _DayGroup {
  final DateTime date;
  final List<Inspection> items;
  _DayGroup({required this.date, required this.items});
}

class _StatusBadgeColors {
  final String label;
  final Color bg;
  final Color fg;
  _StatusBadgeColors({required this.label, required this.bg, required this.fg});
}

class _TemplateCard extends StatelessWidget {
  final InspectionTemplate template;
  final VoidCallback onTap;

  const _TemplateCard({required this.template, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto/ícone do template
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    template.imageUrl != null && template.imageUrl!.isNotEmpty
                    ? Image.network(
                        template.imageUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 48,
                        height: 48,
                        color: const Color(0xFFE5E7EB),
                        child: const Icon(
                          Icons.description,
                          color: Color(0xFF6B7280),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              // Textos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (template.description.isNotEmpty)
                      Text(
                        template.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Versão ${template.version}',
                            style: const TextStyle(
                              color: Color(0xFF2563EB),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (template.sector.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• ${template.sector}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InspectionBottomSheet extends StatelessWidget {
  final Inspection inspection;
  final VoidCallback onShowOptions;

  const _InspectionBottomSheet({
    required this.inspection,
    required this.onShowOptions,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              inspection.templateName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Abrir relatório ou execução
                      // context.push('/inspections/execute', extra: inspection);
                    },
                    child: const Text('Abrir'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onShowOptions,
                  child: const Icon(Icons.more_horiz),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Iniciada: ${inspection.startedAt} • Status: ${inspection.status}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _InspectionCardMobileGrouped extends StatelessWidget {
  final Inspection inspection;
  final String statusLabel;
  final Color statusBg;
  final Color statusFg;
  final VoidCallback onTap;
  final VoidCallback onMore;

  const _InspectionCardMobileGrouped({
    required this.inspection,
    required this.statusLabel,
    required this.statusBg,
    required this.statusFg,
    required this.onTap,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícone circular com fundo suave como no print
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF1FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  color: Color(0xFF5B6DFF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Linha título + badge status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '${inspection.startedAt} / ${inspection.responsibleName}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusFg,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Modelo: ${inspection.templateName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Color(0xFF6B7280)),
                onPressed: onMore,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
