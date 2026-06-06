import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/l10n_extensions.dart';
import '../l10n/report_localizer.dart';
import '../services/analysis_history_store.dart';
import '../services/locale_service.dart';
import '../theme/app_theme.dart';
import '../widgets/home/home_capture_guidelines.dart';
import '../widgets/home/home_hero_banner.dart';
import '../widgets/language_selector.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({
    super.key,
    required this.onScanTap,
    required this.onViewAllGalleries,
    required this.localeService,
  });

  final VoidCallback onScanTap;
  final VoidCallback onViewAllGalleries;
  final LocaleService localeService;

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AnalysisHistoryStore.instance,
      builder: (context, _) {
        final latest = AnalysisHistoryStore.instance.latest;
        final recent = AnalysisHistoryStore.instance.entries.take(4).toList();

        final l10n = context.l10n;

        return SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              const SliverToBoxAdapter(child: HomeHeroBanner()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _sectionTitle(l10n.latestPrediction, widget.onViewAllGalleries),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: latest != null
                      ? _LatestPredictionCard(entry: latest)
                      : _EmptyPredictionCard(onScan: widget.onScanTap),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Text(
                    l10n.quickInsights,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildQuickInsights(context, latest != null)),
              const SliverToBoxAdapter(child: HomeCaptureGuidelines()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _sectionTitle(l10n.recentAnalyses, widget.onViewAllGalleries),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                sliver: recent.isEmpty
                    ? SliverToBoxAdapter(
                        child: _EmptyRecentCard(onScan: widget.onScanTap),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _RecentRow(entry: recent[i]),
                          ),
                          childCount: recent.length,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title, VoidCallback onViewAll) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accentGold,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.l10n.viewAll, style: const TextStyle(fontWeight: FontWeight.w600)),
              const Icon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/branding/logo/logo-1.png',
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/branding/logo/logo-3-display.png',
                height: 34,
                fit: BoxFit.contain,
              ),
            ),
          ),
          LanguageSelector(
            localeService: widget.localeService,
            compact: true,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInsights(BuildContext context, bool hasData) {
    final l10n = context.l10n;
    final items = [
      _InsightItem(Icons.health_and_safety_outlined, l10n.insightUdderHealth, hasData ? l10n.statusGood : l10n.statusDash),
      _InsightItem(Icons.water_drop_outlined, l10n.insightSymmetry, hasData ? l10n.statusGood : l10n.statusDash),
      _InsightItem(Icons.favorite_border_rounded, l10n.insightBodyCondition, hasData ? l10n.statusGood : l10n.statusDash),
      _InsightItem(Icons.thermostat_outlined, l10n.insightHeatStress, hasData ? l10n.statusLow : l10n.statusDash),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: items
            .map(
              (item) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _QuickInsightCard(item: item),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _InsightItem {
  const _InsightItem(this.icon, this.title, this.status);
  final IconData icon;
  final String title;
  final String status;
}

class _QuickInsightCard extends StatelessWidget {
  const _QuickInsightCard({required this.item});
  final _InsightItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(item.icon, color: AppColors.primary, size: 26),
          const SizedBox(height: 8),
          Text(
            item.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.status,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _LatestPredictionCard extends StatelessWidget {
  const _LatestPredictionCard({required this.entry});
  final AnalysisHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final date = DateFormat('MMM d, yyyy • hh:mm a', locale).format(entry.capturedAt);
    final confPct = (entry.confidence * 100).clamp(0, 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: entry.resolvedImageFile != null
                    ? Image.file(
                        entry.resolvedImageFile!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 72,
                        height: 72,
                        color: AppColors.primarySoft,
                        child: const Icon(Icons.pets, color: AppColors.primary),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.estimatedDailyMilkYield,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      l10n.litersPerDayShort(entry.litersPerDay.toStringAsFixed(1)),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successSoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text(
                            l10n.highYieldPotential,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _ConfidenceRing(percent: confPct),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppColors.border),
          ),
          Row(
            children: [
              Text(
                l10n.healthStatus,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              _HealthBadge(healthy: entry.healthy, label: entry.healthStatus),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConfidenceRing extends StatelessWidget {
  const _ConfidenceRing({required this.percent});
  final String percent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              value: (double.tryParse(percent) ?? 0) / 100,
              strokeWidth: 5,
              backgroundColor: AppColors.primarySoft,
              color: AppColors.success,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                l10n.confidence,
                style: const TextStyle(fontSize: 8, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthBadge extends StatelessWidget {
  const _HealthBadge({required this.healthy, required this.label});
  final bool healthy;
  final String label;

  @override
  Widget build(BuildContext context) {
    final displayLabel = ReportLocalizer.of(context).text(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: healthy ? AppColors.successSoft : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            healthy ? Icons.favorite_rounded : Icons.warning_amber_rounded,
            size: 16,
            color: healthy ? AppColors.success : AppColors.danger,
          ),
          const SizedBox(width: 6),
          Text(
            displayLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: healthy ? AppColors.success : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPredictionCard extends StatelessWidget {
  const _EmptyPredictionCard({required this.onScan});
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.document_scanner_outlined,
              size: 48, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            l10n.noPredictionsYet,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.noPredictionsHint,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onScan,
            child: Text(l10n.startScan),
          ),
        ],
      ),
    );
  }
}

class _EmptyRecentCard extends StatelessWidget {
  const _EmptyRecentCard({required this.onScan});
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        context.l10n.emptyRecentHint,
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.9)),
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.entry});
  final AnalysisHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final date = DateFormat('MMM d, yyyy • hh:mm a', locale).format(entry.capturedAt);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: entry.resolvedImageFile != null
                ? Image.file(
                    entry.resolvedImageFile!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 56,
                    height: 56,
                    color: AppColors.primarySoft,
                    child: const Icon(Icons.pets, color: AppColors.primary),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.litersPerDayShort(entry.litersPerDay.toStringAsFixed(1)),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          _HealthBadge(healthy: entry.healthy, label: entry.healthStatus),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
