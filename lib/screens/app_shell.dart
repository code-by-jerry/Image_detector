import 'package:flutter/material.dart';

import '../models/scan_actions.dart';
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
  });

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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _tabIndex,
        children: [
          HomeDashboardScreen(
            onScanTap: _launchScan,
            onViewAllGalleries: _goGalleries,
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
              label: 'Home',
              selected: _tabIndex == 0,
              onTap: () => setState(() => _tabIndex = 0),
            ),
            _NavItem(
              icon: Icons.photo_library_rounded,
              label: 'Galleries',
              selected: _tabIndex == 1,
              onTap: () => setState(() => _tabIndex = 1),
            ),
            _ScanNavLabel(
              selected: _tabIndex == 2,
              onTap: _launchScan,
            ),
            _NavItem(
              icon: Icons.insights_rounded,
              label: 'Insights',
              selected: _tabIndex == 3,
              onTap: () => setState(() => _tabIndex = 3),
            ),
            _NavItem(
              icon: Icons.info_outline_rounded,
              label: 'About',
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
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        child: SizedBox(
          width: 56,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 26),
              Text(
                'Scan',
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
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
