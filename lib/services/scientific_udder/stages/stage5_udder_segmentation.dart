import 'package:image/image.dart' as img;

import '../../../models/scientific_udder_models.dart';
import '../../inference_logger.dart';
import '../../rear_anatomy_detector.dart';
import '../../udder_mask_geometry.dart';
import '../scientific_image_context.dart';

/// Stage 5 — udder mask via TFLite (when bundled) + ROI heuristic fallback.
class Stage5UdderSegmentation {
  const Stage5UdderSegmentation();

  static const String tfliteAsset = 'assets/model/udder_seg.tflite';

  UdderSegmentationResult run(
    ScientificImageContext ctx,
    RearAnatomyLandmarks anatomy,
    AnatomyRoi roi, {
    ({List<int> mask, int width, int height, double score})? tfliteMask,
  }) {
    final sw = Stopwatch()..start();
    final w = ctx.working.width;
    final h = ctx.working.height;

    List<int> udderMask;
    double score;
    bool fromTflite = false;

    if (tfliteMask != null &&
        tfliteMask.width == w &&
        tfliteMask.height == h &&
        tfliteMask.score > 0.008) {
      udderMask = tfliteMask.mask;
      score = tfliteMask.score.clamp(0.0, 1.0);
      fromTflite = true;
      InferenceLogger.log('SCI-S5', 'Using TFLite udder mask score=${score.toStringAsFixed(3)}');
    } else {
      final built = _heuristicMask(ctx.working, anatomy, roi);
      udderMask = built.$1;
      score = built.$2;
      InferenceLogger.log('SCI-S5', 'Heuristic udder mask score=${score.toStringAsFixed(3)}');
    }

    final geometry = UdderMaskGeometry.fromMask(udderMask, w, h);
    final udderPixels = udderMask.where((v) => v > 0).length;
    final minArea = w * h * (fromTflite ? 0.008 : 0.015);
    final geo = geometry;
    final passed = udderPixels >= minArea && geo != null;
    final maskScore = passed
        ? (score * 0.6 + (geo.coverage * 4).clamp(0.0, 0.4)).clamp(0.0, 1.0)
        : score * 0.5;

    InferenceLogger.log(
      'SCI-S5',
      'seg udderPx=$udderPixels passed=$passed tflite=$fromTflite',
    );

    return UdderSegmentationResult(
      stage: ScientificStageMetric(
        stageId: 'segmentation',
        passed: passed,
        score: maskScore,
        durationMs: sw.elapsedMilliseconds,
        issues: passed ? const [] : const ['udder_mask_too_small'],
      ),
      udderMask: udderMask,
      teatMask: _estimateTeatMask(ctx.working, udderMask, anatomy, geometry),
      width: w,
      height: h,
      udderPixelCount: udderPixels,
      geometry: geometry,
      fromTflite: fromTflite,
    );
  }

  (List<int>, double) _heuristicMask(
    img.Image image,
    RearAnatomyLandmarks anatomy,
    AnatomyRoi roi,
  ) {
    final w = image.width;
    final h = image.height;
    final udderMask = List.generate(w * h, (_) => 0);

    final y0 = (anatomy.leftPin.dy * h * 0.82).round().clamp(0, h - 1);
    final y1 = h - 1;
    final x0 = (roi.udder.left * w).round().clamp(0, w - 1);
    final x1 = (roi.udder.right * w).round().clamp(0, w - 1);

    var udderPixels = 0;
    for (var y = y0; y <= y1; y++) {
      for (var x = x0; x <= x1; x++) {
        final p = image.getPixel(x, y);
        final r = p.r.toInt();
        final g = p.g.toInt();
        final b = p.b.toInt();
        final br = (r + g + b) / 3;
        final isPink = r > 95 && g > 70 && b > 80 && r < 200;
        final isUdderTone = br > 32 && br < 168;
        final edgeBoost = _localEdge(image, x, y) > 18;
        if (isPink || isUdderTone || edgeBoost) {
          udderMask[y * w + x] = 1;
          udderPixels++;
        }
      }
    }

    final score = (udderPixels / (w * h * 0.2)).clamp(0.0, 1.0);
    return (udderMask, score);
  }

  double _localEdge(img.Image image, int x, int y) {
    if (x < 1 || y < 1 || x >= image.width - 1 || y >= image.height - 1) {
      return 0;
    }
    final c = image.getPixel(x, y).r;
    final l = image.getPixel(x - 1, y).r;
    final r = image.getPixel(x + 1, y).r;
    final u = image.getPixel(x, y - 1).r;
    final d = image.getPixel(x, y + 1).r;
    return ((c - l).abs() + (c - r).abs() + (c - u).abs() + (c - d).abs()) / 4;
  }

  List<int> _estimateTeatMask(
    img.Image image,
    List<int> udderMask,
    RearAnatomyLandmarks anatomy,
    UdderMaskGeometry? geometry,
  ) {
    final w = image.width;
    final h = image.height;
    final teatMask = List.generate(w * h, (_) => 0);
    final rowY = geometry != null
        ? (geometry.bottom.dy * h).round().clamp(0, h - 1)
        : (anatomy.udder.dy * h).round().clamp(0, h - 1);

    for (var x = 0; x < w; x++) {
      for (var dy = -4; dy <= 10; dy++) {
        final y = (rowY + dy).clamp(0, h - 1);
        final idx = y * w + x;
        if (udderMask[idx] == 0) continue;
        final br = (image.getPixel(x, y).r +
                image.getPixel(x, y).g +
                image.getPixel(x, y).b) /
            3;
        if (br > 45 && br < 145) teatMask[idx] = 1;
      }
    }
    return teatMask;
  }
}

class UdderSegmentationResult {
  const UdderSegmentationResult({
    required this.stage,
    required this.udderMask,
    required this.teatMask,
    required this.width,
    required this.height,
    required this.udderPixelCount,
    this.geometry,
    this.fromTflite = false,
  });

  final ScientificStageMetric stage;
  final List<int> udderMask;
  final List<int> teatMask;
  final int width;
  final int height;
  final int udderPixelCount;
  final UdderMaskGeometry? geometry;
  final bool fromTflite;
}
