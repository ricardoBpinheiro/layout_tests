import 'package:flutter/material.dart';

class InspectionCompleteDialog extends StatelessWidget {
  const InspectionCompleteDialog({
    super.key,
    required this.onViewSummary,
    required this.onClose,
    this.title = 'Inspeção concluída',
    this.subtitle = 'Tudo certo! Seus dados foram salvos com sucesso.',
    this.primaryLabel = 'Visualizar resumo',
    this.secondaryLabel = 'Salvar e fechar',
  });

  final VoidCallback onViewSummary;
  final VoidCallback onClose;
  final String title;
  final String subtitle;
  final String primaryLabel;
  final String secondaryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.check_rounded,
                  size: 52,
                  color: theme.colorScheme.primary,
                  semanticLabel: 'Sucesso',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onViewSummary,
                  child: Text(primaryLabel),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onClose,
                  child: Text(secondaryLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
