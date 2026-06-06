import 'package:flutter/material.dart';

import '../l10n/l10n_extensions.dart';
import '../models/scan_actions.dart';
import '../services/locale_service.dart';
import '../theme/app_theme.dart';
import 'about_screen.dart';
import 'galleries_screen.dart';
import 'home_dashboard_screen.dart';
import 'insights_screen.dart';
import '../widgets/scan/scan_source_sheet.dart';

/// Main app shell with bottom navigation + center Scan action.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.scanPageBuilder,
    required this.localeService,
  });

  final LocaleService localeService;

  final Widget Function(
    VoidCallback goHome,
    void Function(ScanActions actions) registerScan,
  ) scanPageBuilder;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tabIndex = 0;
  ScanActions? _scanActions;

  void _goHome() => setState(() => _tabIndex = 0);

  void _goGalleries() => setState(() => _tabIndex = 1);

  void _registerScan(ScanActions actions) {
    _scanActions = actions;
  }

  Future<void> _runScanChoice(ScanSourceChoice choice) async {
    final actions = _scanActions;
    if (actions == null) return;

    String? imagePath;

    switch (choice.kind) {
      case ScanSourceKind.camera:
        imagePath = await actions.pickFromCamera();
      case ScanSourceKind.gallery:
        imagePath = await actions.pickFromGallery();
      case ScanSourceKind.sampleAsset:
        if (choice.path != null) {
          if (!mounted) return;
          setState(() => _tabIndex = 2);
          await WidgetsBinding.instance.endOfFrame;
          if (!mounted) return;
          await actions.beginWithAssetPath(choice.path!);
          return;
        }
      case ScanSourceKind.existingFile:
        imagePath = choice.path;
    }

    if (imagePath == null || imagePath.isEmpty) return;
    if (!mounted) return;
    setState(() => _tabIndex = 2);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    await actions.beginWithImagePath(imagePath);
  }

  Future<void> _launchScan() async {
    final choice = await ScanSourceSheet.show(context);
    if (choice == null || !mounted) return;
    await _runScanChoice(choice);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _tabIndex,
        children: [
          HomeDashboardScreen(
            onScanTap: _launchScan,
            onViewAllGalleries: _goGalleries,
            localeService: widget.localeService,
          ),
          GalleriesScreen(onStartScan: _runScanChoice),
          widget.scanPageBuilder(_goHome, _registerScan),
          const InsightsScreen(),
          const AboutScreen(),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 72,
        height: 72,
        child: FloatingActionButton(
          onPressed: _launchScan,
          elevation: 4,
          backgroundColor: AppColors.primary,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.document_scanner_outlined,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: AppColors.surface,
        elevation: 8,
        shadowColor: Colors.black26,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: l10n.navHome,
              selected: _tabIndex == 0,
              onTap: () => setState(() => _tabIndex = 0),
            ),
            _NavItem(
              icon: Icons.photo_library_rounded,
              label: l10n.navGalleries,
              selected: _tabIndex == 1,
              onTap: () => setState(() => _tabIndex = 1),
            ),
            _ScanNavLabel(
              label: l10n.navScan,
              selected: _tabIndex == 2,
              onTap: _launchScan,
            ),
            _NavItem(
              icon: Icons.insights_rounded,
              label: l10n.navInsights,
              selected: _tabIndex == 3,
              onTap: () => setState(() => _tabIndex = 3),
            ),
            _NavItem(
              icon: Icons.info_outline_rounded,
              label: l10n.navAbout,
              selected: _tabIndex == 4,
              onTap: () => setState(() => _tabIndex = 4),
            ),
          ],
        ),
      ),
    );
  }
}

/// Scan label aligned with other tabs; FAB sits in the notch above.
class _ScanNavLabel extends StatelessWidget {
  const _ScanNavLabel({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      splashColor: AppColors.primary.withValues(alpha: 0.08),
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: SizedBox(
          width: 56,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 26),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      splashColor: AppColors.primary.withValues(alpha: 0.08),
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
