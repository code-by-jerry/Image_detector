import 'package:flutter/material.dart';

import '../l10n/l10n_extensions.dart';
import '../l10n/report_localizer.dart';
import '../services/analysis_history_store.dart';
import '../theme/app_theme.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: AnalysisHistoryStore.instance,
          builder: (context, _) {
            final l10n = context.l10n;
            final latest = AnalysisHistoryStore.instance.latest;
            final count = AnalysisHistoryStore.instance.entries.length;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.insightsTitle,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.insightsSubtitle,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  _StatCard(
                    icon: Icons.analytics_outlined,
                    title: l10n.totalScans,
                    value: '$count',
                  ),
                  const SizedBox(height: 12),
                  if (latest != null) ...[
                    _StatCard(
                      icon: Icons.water_drop_outlined,
                      title: l10n.latestYield,
                      value: l10n.litersPerDayShort(latest.litersPerDay.toStringAsFixed(1)),
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      icon: Icons.verified_outlined,
                      title: l10n.latestConfidence,
                      value: '${(latest.confidence * 100).toStringAsFixed(0)}%',
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      icon: Icons.favorite_outline,
                      title: l10n.healthStatus,
                      value: ReportLocalizer.of(context).text(latest.healthStatus),
                    ),
                  ] else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        l10n.insightsEmpty,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
