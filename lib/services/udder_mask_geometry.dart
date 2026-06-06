import 'dart:ui';

/// Centroid and bounds extracted from a binary udder mask.
class UdderMaskGeometry {
  const UdderMaskGeometry({
    required this.center,
    required this.top,
    required this.bottom,
    required this.left,
    required this.right,
    required this.pixelCount,
    required this.coverage,
  });

  final Offset center;
  final Offset top;
  final Offset bottom;
  final Offset left;
  final Offset right;
  final int pixelCount;
  final double coverage;

  double get widthNorm => (right.dx - left.dx).abs().clamp(0.0, 1.0);
  double get heightNorm => (bottom.dy - top.dy).abs().clamp(0.0, 1.0);

  static UdderMaskGeometry? fromMask(
    List<int> mask,
    int width,
    int height, {
    double threshold = 0.45,
  }) {
    if (mask.length != width * height) return null;

    var count = 0;
    var sumX = 0.0;
    var sumY = 0.0;
    var minX = width;
    var maxX = 0;
    var minY = height;
    var maxY = 0;

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final v = mask[y * width + x];
        if (v <= 0) continue;
        count++;
        sumX += x;
        sumY += y;
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }

    final coverage = count / (width * height);
    if (count < 48 || coverage < 0.001) return null;

    final cx = sumX / count / width;
    final cy = sumY / count / height;
    return UdderMaskGeometry(
      center: Offset(cx, cy),
      top: Offset((minX + maxX) / 2 / width, minY / height),
      bottom: Offset((minX + maxX) / 2 / width, maxY / height),
      left: Offset(minX / width, (minY + maxY) / 2 / height),
      right: Offset(maxX / width, (minY + maxY) / 2 / height),
      pixelCount: count,
      coverage: coverage,
    );
  }
}
