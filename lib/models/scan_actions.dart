/// Callbacks registered by [DetectorHomePage] for shell-level scan launch.
class ScanActions {
  const ScanActions({
    required this.pickFromCamera,
    required this.pickFromGallery,
    required this.beginWithImagePath,
    required this.beginWithAssetPath,
  });

  final Future<String?> Function() pickFromCamera;
  final Future<String?> Function() pickFromGallery;
  final Future<void> Function(String imagePath) beginWithImagePath;
  final Future<void> Function(String assetPath) beginWithAssetPath;
}

enum ScanSourceKind { camera, gallery, sampleAsset, existingFile }

class ScanSourceChoice {
  const ScanSourceChoice.camera()
      : kind = ScanSourceKind.camera,
        path = null;
  const ScanSourceChoice.gallery()
      : kind = ScanSourceKind.gallery,
        path = null;
  const ScanSourceChoice.sample(String assetPath)
      : kind = ScanSourceKind.sampleAsset,
        path = assetPath;
  const ScanSourceChoice.existingFile(String filePath)
      : kind = ScanSourceKind.existingFile,
        path = filePath;

  final ScanSourceKind kind;
  final String? path;
}
