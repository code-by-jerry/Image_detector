import 'package:flutter/material.dart';

import '../../services/milk_mirror_measurement_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import 'glass_card.dart';

/// Compact escutcheon A–D metrics (replaces duplicate green analysis card).
class EnterpriseMeasurementCard extends StatelessWidget {
  final MilkMirrorUiMetrics metrics;
  final String engineLabel;

  const EnterpriseMeasurementCard({
    super.key,
    required this.metrics,
    required this.engineLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GlassCard(
      animateDelayMs: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.straighten_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.escutcheonVision,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  engineLabel.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _metric(l10n.metricAbHeight, metrics.heightNorm),
              _metric(l10n.metricCdWidth, metrics.widthNorm),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _metric(l10n.metricArea, metrics.areaNorm),
              _metric(l10n.metricSymmetry, metrics.symmetryPercent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, double value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            Text(
              value.toStringAsFixed(3),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
