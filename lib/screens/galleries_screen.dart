import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/l10n_extensions.dart';
import '../models/scan_actions.dart';
import '../services/analysis_history_store.dart';
import '../services/sample_gallery_catalog.dart';
import '../theme/app_theme.dart';
import '../widgets/scan/scan_source_sheet.dart';

class GalleriesScreen extends StatefulWidget {
  const GalleriesScreen({
    super.key,
    required this.onStartScan,
  });

  final Future<void> Function(ScanSourceChoice choice) onStartScan;

  @override
  State<GalleriesScreen> createState() => _GalleriesScreenState();
}

class _GalleriesScreenState extends State<GalleriesScreen> {
  bool _loadingSamples = true;
  List<String> _samples = [];

  @override
  void initState() {
    super.initState();
    _loadSamples();
  }

  Future<void> _loadSamples() async {
    await SampleGalleryCatalog.instance.load();
    if (!mounted) return;
    setState(() {
      _samples = SampleGalleryCatalog.instance.paths;
      _loadingSamples = false;
    });
  }

  Future<void> _openScanSheet() async {
    final choice = await ScanSourceSheet.show(context);
    if (choice != null) {
      await widget.onStartScan(choice);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openScanSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: Text(l10n.addPhoto),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: AnalysisHistoryStore.instance,
          builder: (context, _) {
            final entries = AnalysisHistoryStore.instance.entries;
            final sheetL10n = context.l10n;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            sheetL10n.galleriesTitle,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _openScanSheet,
                          icon: const Icon(Icons.document_scanner_outlined, size: 18),
                          label: Text(sheetL10n.navScan),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_loadingSamples)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (_samples.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: Text(
                        sheetL10n.samplePhotos,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final path = _samples[i];
                          return _SampleTile(
                            assetPath: path,
                            label: SampleGalleryCatalog.instance.displayLabel(path),
                            onTap: () => widget.onStartScan(
                              ScanSourceChoice.sample(path),
                            ),
                          );
                        },
                        childCount: _samples.length,
                      ),
                    ),
                  ),
                ] else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          sheetL10n.samplePhotosHint,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      sheetL10n.myScans(entries.length),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                if (entries.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      child: Text(
                        sheetL10n.myScansEmpty,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final e = entries[i];
                          final locale = Localizations.localeOf(context).toString();
                          final date = DateFormat('MMM d, yyyy • hh:mm a', locale)
                              .format(e.capturedAt);
                          final file = e.resolvedImageFile;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Material(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                onTap: () {
                                  final path = file?.path;
                                  if (path != null) {
                                    widget.onStartScan(
                                      ScanSourceChoice.existingFile(path),
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: file != null
                                            ? Image.file(
                                                file,
                                                width: 56,
                                                height: 56,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                width: 56,
                                                height: 56,
                                                color: AppColors.primarySoft,
                                                child: const Icon(
                                                  Icons.pets,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              date,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            Text(
                                              sheetL10n.litersPerDayShort(
                                                e.litersPerDay.toStringAsFixed(1),
                                              ),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: AppColors.textSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: entries.length,
                      ),
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

class _SampleTile extends StatelessWidget {
  const _SampleTile({
    required this.assetPath,
    required this.label,
    required this.onTap,
  });

  final String assetPath;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.primarySoft,
                  child: const Icon(Icons.pets, color: AppColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
