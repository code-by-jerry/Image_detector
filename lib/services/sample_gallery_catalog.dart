import 'package:flutter/services.dart';

/// Discovers bundled sample photos under [assets/images/].
class SampleGalleryCatalog {
  SampleGalleryCatalog._();

  static final SampleGalleryCatalog instance = SampleGalleryCatalog._();

  static const _prefix = 'assets/images/';
  static const _extensions = {'.jpg', '.jpeg', '.png', '.webp'};

  List<String> _paths = [];
  bool _loaded = false;

  List<String> get paths => List.unmodifiable(_paths);

  bool get hasSamples => _paths.isNotEmpty;

  Future<void> load() async {
    if (_loaded) return;
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    _paths = manifest
        .listAssets()
        .where((path) {
          if (!path.startsWith(_prefix)) return false;
          final lower = path.toLowerCase();
          return _extensions.any(lower.endsWith);
        })
        .toList()
      ..sort();
    _loaded = true;
  }

  String displayLabel(String assetPath) {
    final parts = assetPath.split('/');
    if (parts.length >= 2) {
      return '${parts[parts.length - 2]} · ${parts.last}';
    }
    return parts.last;
  }
}
