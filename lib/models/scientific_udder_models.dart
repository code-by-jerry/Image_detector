import 'dart:ui';

/// NDDB-inspired rear udder traits (cm where calibrated, else normalized).
class ScientificUdderTraits {
  const ScientificUdderTraits({
    required this.ruhCm,
    required this.ruwCm,
    required this.rtdCm,
    required this.frtdCm,
    required this.udderDepthProxyCm,
    required this.symmetryIndex,
    required this.ruhNorm,
    required this.ruwNorm,
    required this.rtdNorm,
    required this.perTraitConfidence,
    required this.scaleCmPerNorm,
  });

  final double ruhCm;
  final double ruwCm;
  final double rtdCm;
  final double frtdCm;
  final double udderDepthProxyCm;
  final double symmetryIndex;
  final double ruhNorm;
  final double ruwNorm;
  final double rtdNorm;
  final Map<String, double> perTraitConfidence;
  final double scaleCmPerNorm;

  Map<String, dynamic> toFirestore() => {
        'ruhCm': ruhCm,
        'ruwCm': ruwCm,
        'rtdCm': rtdCm,
        'frtdCm': frtdCm,
        'udderDepthProxyCm': udderDepthProxyCm,
        'symmetryIndex': symmetryIndex,
        'ruhNorm': ruhNorm,
        'ruwNorm': ruwNorm,
        'rtdNorm': rtdNorm,
        'perTraitConfidence': perTraitConfidence,
        'scaleCmPerNorm': scaleCmPerNorm,
      };

  List<double> toRegressionVector({
    required int lactation,
    required int daysInMilk,
  }) =>
      [
        ruhNorm,
        ruwNorm,
        rtdNorm,
        symmetryIndex,
        udderDepthProxyCm / 20.0,
        lactation.toDouble(),
        daysInMilk.toDouble(),
      ];
}

class PoseEstimate {
  const PoseEstimate({
    required this.yawRad,
    required this.pitchProxy,
    required this.rollRad,
    required this.offCenterX,
    required this.confidence,
  });

  final double yawRad;
  final double pitchProxy;
  final double rollRad;
  final double offCenterX;
  final double confidence;
}

class AnatomyRoi {
  const AnatomyRoi({
    required this.hindquarter,
    required this.udder,
    required this.midlineX,
  });

  final Rect hindquarter;
  final Rect udder;
  final double midlineX;
}

class UdderKeypointSet {
  const UdderKeypointSet({
    required this.leftPin,
    required this.rightPin,
    required this.tailHead,
    required this.vulva,
    required this.udderTop,
    required this.udderBottom,
    required this.udderCenter,
    required this.teatLeft,
    required this.teatRight,
    required this.confidence,
    required this.fromHeuristicFallback,
    this.maskDerived = false,
  });

  final Offset leftPin;
  final Offset rightPin;
  final Offset tailHead;
  final Offset vulva;
  final Offset udderTop;
  final Offset udderBottom;
  final Offset udderCenter;
  final Offset teatLeft;
  final Offset teatRight;
  final double confidence;
  final bool fromHeuristicFallback;
  final bool maskDerived;

  /// Overlay order: L pin, R pin, udder center, tail head.
  List<Offset> get overlayKeypoints =>
      [leftPin, rightPin, udderCenter, tailHead];

  double get pelvicWidthNorm => (rightPin.dx - leftPin.dx).abs().clamp(0.0, 1.0);

  double get udderHeightNorm =>
      (udderCenter.dy - tailHead.dy).abs().clamp(0.0, 1.0);

  double get udderPelvicRatio {
    final pw = pelvicWidthNorm;
    if (pw < 1e-4) return 0;
    return (udderHeightNorm / pw).clamp(0.0, 3.0);
  }
}

class ScientificStageMetric {
  const ScientificStageMetric({
    required this.stageId,
    required this.passed,
    required this.score,
    required this.durationMs,
    this.issues = const [],
    this.detail = '',
  });

  final String stageId;
  final bool passed;
  final double score;
  final int durationMs;
  final List<String> issues;
  final String detail;

  Map<String, dynamic> toJson() => {
        'stageId': stageId,
        'passed': passed,
        'score': score,
        'durationMs': durationMs,
        'issues': issues,
        if (detail.isNotEmpty) 'detail': detail,
      };
}

class ScientificUdderReport {
  const ScientificUdderReport({
    required this.stages,
    required this.scientificallyValid,
    required this.globalConfidence,
    required this.rejectReason,
    this.traits,
    this.predictedLiters,
    this.regressionConfidence,
    this.rectifiedImagePath,
    this.pose,
    this.keypoints,
  });

  final List<ScientificStageMetric> stages;
  final bool scientificallyValid;
  final double globalConfidence;
  final String? rejectReason;
  final ScientificUdderTraits? traits;
  final double? predictedLiters;
  final double? regressionConfidence;
  final String? rectifiedImagePath;
  final PoseEstimate? pose;
  final UdderKeypointSet? keypoints;

  Map<String, dynamic> toFirestore() => {
        'scientificallyValid': scientificallyValid,
        'globalConfidence': globalConfidence,
        if (rejectReason != null) 'rejectReason': rejectReason,
        if (traits != null) 'traits': traits!.toFirestore(),
        if (predictedLiters != null) 'predictedLitersTraits': predictedLiters,
        if (regressionConfidence != null)
          'regressionConfidence': regressionConfidence,
        'stages': stages.map((s) => s.toJson()).toList(),
        if (pose != null)
          'pose': {
            'yawRad': pose!.yawRad,
            'pitchProxy': pose!.pitchProxy,
            'rollRad': pose!.rollRad,
            'offCenterX': pose!.offCenterX,
          },
      };
}
