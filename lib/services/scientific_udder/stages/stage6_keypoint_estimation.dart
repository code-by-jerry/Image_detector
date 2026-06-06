import 'dart:math' as math;
import 'dart:ui';

import '../../../models/scientific_udder_models.dart';
import '../../inference_logger.dart';
import '../../rear_anatomy_detector.dart';
import '../scientific_image_context.dart';
import 'stage5_udder_segmentation.dart';

/// Stage 6 — tail head, pin bones, udder center from anatomy + segmentation mask.
class Stage6KeypointEstimation {
  const Stage6KeypointEstimation();

  UdderKeypointSet estimate(
    ScientificImageContext ctx,
    RearAnatomyLandmarks anatomy, {
    UdderSegmentationResult? segmentation,
  }) {
    final pinMidY = (anatomy.leftPin.dy + anatomy.rightPin.dy) / 2;
    final spineX = (anatomy.leftPin.dx + anatomy.rightPin.dx) / 2;

    // Tail head: well above pin row (body attachment, not tail shaft).
    final tailHead = Offset(
      spineX,
      math.min(anatomy.pointA.dy, pinMidY - 0.10).clamp(0.04, pinMidY - 0.07),
    );

    final geo = segmentation?.geometry;
    final udderCenter = geo != null
        ? Offset(
            geo.center.dx.clamp(anatomy.leftPin.dx + 0.02, anatomy.rightPin.dx - 0.02),
            geo.center.dy.clamp(pinMidY + 0.08, 0.92),
          )
        : anatomy.udder;

    final udderTop = geo != null
        ? Offset(spineX, geo.top.dy.clamp(tailHead.dy + 0.02, udderCenter.dy - 0.02))
        : Offset(
            spineX,
            (tailHead.dy + udderCenter.dy) / 2,
          );

    final udderBottom = geo != null
        ? Offset(udderCenter.dx, geo.bottom.dy.clamp(udderCenter.dy, 0.95))
        : Offset(
            udderCenter.dx,
            (udderCenter.dy + 0.04).clamp(udderCenter.dy, 0.95),
          );

    final vulva = Offset(
      spineX,
      (pinMidY + udderTop.dy) / 2 + 0.02,
    );

    var teatL = Offset(
      geo != null ? geo.left.dx : (anatomy.leftPin.dx + udderCenter.dx) / 2,
      udderBottom.dy,
    );
    var teatR = Offset(
      geo != null ? geo.right.dx : (anatomy.rightPin.dx + udderCenter.dx) / 2,
      udderBottom.dy,
    );

    if (segmentation != null) {
      final refined = _refineTeatsFromMask(segmentation);
      if (refined != null) {
        teatL = refined.$1;
        teatR = refined.$2;
      }
    }

    var conf = anatomy.isTemplateFallback
        ? anatomy.confidence * 0.5
        : anatomy.confidence;
    if (geo != null) {
      conf = (conf + (segmentation!.fromTflite ? 0.85 : 0.65)).clamp(0.0, 1.0) / 2;
      if (geo.coverage < 0.012) conf *= 0.55;
    }

    InferenceLogger.log('SCI-S6', 'keypoints conf=${conf.toStringAsFixed(2)} mask=${geo != null}');

    return UdderKeypointSet(
      leftPin: anatomy.leftPin,
      rightPin: anatomy.rightPin,
      tailHead: tailHead,
      vulva: vulva,
      udderTop: udderTop,
      udderBottom: udderBottom,
      udderCenter: udderCenter,
      teatLeft: teatL,
      teatRight: teatR,
      confidence: conf.clamp(0.0, 1.0),
      fromHeuristicFallback: anatomy.isTemplateFallback && geo == null,
      maskDerived: geo != null,
    );
  }

  (Offset, Offset)? _refineTeatsFromMask(UdderSegmentationResult seg) {
    final w = seg.width;
    final h = seg.height;
    final ys = <int>[];
    for (var y = (h * 0.55).round(); y < h; y++) {
      var row = 0;
      for (var x = 0; x < w; x++) {
        if (seg.teatMask[y * w + x] == 1) row++;
      }
      if (row > w * 0.04) ys.add(y);
    }
    if (ys.isEmpty) return null;
    final y = ys.reduce((a, b) => a + b) ~/ ys.length;
    var leftX = w;
    var rightX = 0;
    for (var x = 0; x < w; x++) {
      if (seg.teatMask[y * w + x] == 1) {
        if (x < leftX) leftX = x;
        if (x > rightX) rightX = x;
      }
    }
    if (rightX <= leftX) return null;
    return (
      Offset(leftX / w, y / h),
      Offset(rightX / w, y / h),
    );
  }

  ScientificStageMetric toStageMetric(UdderKeypointSet kp) {
    final issues = <String>[];
    if (kp.fromHeuristicFallback) issues.add('heuristic_fallback');
    if (!kp.maskDerived) issues.add('no_mask_refinement');
    if (kp.udderBottom.dy <= kp.udderTop.dy) issues.add('invalid_udder_axis');
    if (kp.confidence < 0.3) issues.add('low_keypoint_confidence');

    final passed = kp.udderBottom.dy > kp.udderTop.dy && kp.confidence >= 0.28;
    return ScientificStageMetric(
      stageId: 'keypoints',
      passed: passed,
      score: kp.confidence,
      durationMs: 0,
      issues: issues,
    );
  }
}
