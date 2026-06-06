import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/report_localizer.dart';
import '../../models/dairy_pipeline_report.dart';
import '../../services/milk_production_scale.dart';
import '../../theme/app_theme.dart';
import 'responsive_layout.dart';

/// Results header: tall capture preview on the left, compact stat rail on the right.
class ResultsPreviewStatsRow extends StatelessWidget {
  const ResultsPreviewStatsRow({
    super.key,
    required this.imagePreview,
    required this.report,
  });

  final Widget imagePreview;
  final DairyPipelineReport report;

  static const _tileGap = 8.0;
  static const _rowGap = 10.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalW = constraints.maxWidth;
        final sideBySide = totalW >= 340;
        final aspect = ResponsiveLayout.resultsHeroAspectRatio(context);
        final maxH = ResponsiveLayout.resultsHeroMaxHeight(context);

        if (!sideBySide) {
          final imageH = math.min(totalW / aspect, maxH);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: imageH, child: imagePreview),
              const SizedBox(height: 12),
              _YieldStatsRail(report: report, vertical: false),
            ],
          );
        }

        final statsW = ResponsiveLayout.resultsStatsRailWidth(totalW);
        final imageW = totalW - statsW - _rowGap;
        final imageH = math.min(imageW / aspect, maxH).clamp(240.0, maxH);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: imageW, height: imageH, child: imagePreview),
            const SizedBox(width: _rowGap),
            SizedBox(
              width: statsW,
              height: imageH,
              child: _YieldStatsRail(report: report, vertical: true),
            ),
          ],
        );
      },
    );
  }
}

class _YieldStatsRail extends StatelessWidget {
  const _YieldStatsRail({
    required this.report,
    required this.vertical,
  });

  final DairyPipelineReport report;
  final bool vertical;

  List<_StatTileData> _tiles(AppLocalizations l10n, ReportLocalizer loc) {
    final pct = report.yieldConfidence.clamp(0.0, 1.0);
    return [
      _StatTileData(
        label: l10n.confidence,
        value: '${(pct * 100).round()}%',
        accent: AppColors.primary,
        leading: _MiniConfidenceRing(progress: pct, size: 32),
      ),
      _StatTileData(
        label: l10n.dailyMilkProduction,
        value: MilkProductionScale.formatExact(report.yieldLiters),
        accent: AppColors.success,
        leading: _IconOrb(
          icon: Icons.water_drop_rounded,
          color: AppColors.success,
          size: 32,
        ),
      ),
      _StatTileData(
        label: l10n.estimatedYield,
        value: loc.text(report.yieldRange),
        accent: AppColors.accentGold,
        leading: _IconOrb(
          icon: Icons.straighten_rounded,
          color: AppColors.accentGold,
          size: 32,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loc = ReportLocalizer(l10n);
    final tiles = _tiles(l10n, loc);

    if (!vertical) {
      return SizedBox(
        height: 96,
        child: Row(
          children: [
            for (var i = 0; i < tiles.length; i++) ...[
              if (i > 0) const SizedBox(width: ResultsPreviewStatsRow._tileGap),
              Expanded(child: _StatTile(data: tiles[i])),
            ],
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileH =
            (constraints.maxHeight - ResultsPreviewStatsRow._tileGap * 2) / 3;

        return Column(
          children: [
            for (var i = 0; i < tiles.length; i++) ...[
              if (i > 0) const SizedBox(height: ResultsPreviewStatsRow._tileGap),
              SizedBox(
                height: tileH,
                width: constraints.maxWidth,
                child: _StatTile(data: tiles[i]),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _StatTileData {
  const _StatTileData({
    required this.label,
    required this.value,
    required this.accent,
    required this.leading,
  });

  final String label;
  final String value;
  final Color accent;
  final Widget leading;
}

/// Overflow-safe stat tile — scales content down to fit bounded height.
class _StatTile extends StatelessWidget {
  const _StatTile({required this.data});

  final _StatTileData data;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth,
                  maxHeight: constraints.maxHeight,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    data.leading,
                    const SizedBox(height: 5),
                    Text(
                      data.value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: data.accent,
                        height: 1.05,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.label.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.4,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _IconOrb extends StatelessWidget {
  const _IconOrb({
    required this.icon,
    required this.color,
    required this.size,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: size * 0.55, color: color),
      ),
    );
  }
}

class _MiniConfidenceRing extends StatelessWidget {
  const _MiniConfidenceRing({required this.progress, required this.size});

  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ConfidenceRingPainter(progress),
        child: Center(
          child: Text(
            '${(progress * 100).round()}',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 9,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfidenceRingPainter extends CustomPainter {
  _ConfidenceRingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 2.5;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ConfidenceRingPainter old) =>
      old.progress != progress;
}
