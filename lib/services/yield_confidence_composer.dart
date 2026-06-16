import 'dart:math' as math;

import '../models/scientific_udder_models.dart';
import 'inference_logger.dart';
import 'tflite_classifier_service.dart';

/// Composes display confidence for the yield ring from fusion + scientific + TFLite.
class YieldConfidenceComposer {
  const YieldConfidenceComposer();

  double compose({
    required double fusionConfidence,
    required double mirrorConfidence,
    required bool mirrorSuccess,
    required double mirrorLiters,
    required bool tfliteTrained,
    required double tfliteValAccuracy,
    TflitePrediction? tflite,
    ScientificUdderReport? scientific,
  }) {
    var conf = fusionConfidence.clamp(0.0, 1.0);

    final tfliteLiters = tflite?.expectedLiters ?? tflite?.litersPerDay;
    final tfliteTrusted = tfliteTrained &&
        tfliteValAccuracy >= 0.55 &&
        tflite != null &&
        !tflite.lowConfidence &&
        tflite.confidence >= 0.38;

    final mirrorTfliteAgreement = mirrorSuccess &&
        tfliteLiters != null &&
        (mirrorLiters - tfliteLiters).abs() <= 1.5;

    final sciValid = scientific?.scientificallyValid == true;
    final sciGlobal = scientific?.globalConfidence ?? 0.0;

    if (sciValid) {
      final sci = scientific!;
      final reg = sci.regressionConfidence ?? sciGlobal;
      conf = conf * 0.4 + sciGlobal * 0.42 + reg * 0.18;

      if (sci.keypoints?.maskDerived == true) conf += 0.04;
      final seg = _stage(sci, 'segmentation');
      final kp = _stage(sci, 'keypoints');
      if (seg != null && seg.passed) conf += seg.score * 0.03;
      if (kp != null && kp.passed) conf += kp.score * 0.03;
    } else if (scientific != null && sciGlobal >= 0.35) {
      // Partial scientific run (e.g. seg weak) — still use stage quality.
      conf = conf * 0.65 + sciGlobal * 0.35;
    }

    if (mirrorSuccess && mirrorConfidence >= 0.68) {
      conf = math.max(conf, mirrorConfidence * 0.92);
    }

    if (tfliteTrusted && mirrorSuccess && mirrorTfliteAgreement) {
      conf = math.max(conf, 0.88);
      conf = math.min(0.96, conf + tflite!.confidence * 0.06);
    } else if (tfliteTrusted && mirrorSuccess) {
      conf = math.min(0.92, math.max(conf, 0.84));
    } else if (sciValid && sciGlobal >= 0.52) {
      conf = math.min(0.90, math.max(conf, 0.80));
    } else if (mirrorSuccess && mirrorConfidence >= 0.65) {
      conf = math.min(0.84, math.max(conf, 0.76));
    } else if (!tfliteTrained ||
        tfliteValAccuracy < 0.55 ||
        (tflite?.lowConfidence ?? true)) {
      conf = math.min(conf, 0.72);
    }

    if (!mirrorSuccess) {
      conf = math.min(conf, 0.55);
    }

    conf = conf.clamp(0.0, 0.96);

    InferenceLogger.log(
      'CONF_COMP',
      'display=${(conf * 100).toStringAsFixed(0)}% '
      'fusion=${(fusionConfidence * 100).toStringAsFixed(0)}% '
      'mirror=${(mirrorConfidence * 100).toStringAsFixed(0)}% '
      'sci=${sciValid ? (sciGlobal * 100).toStringAsFixed(0) : "—"}% '
      'tfliteTrusted=$tfliteTrusted valAcc=${(tfliteValAccuracy * 100).toStringAsFixed(0)}% '
      'tfliteConf=${tflite != null ? (tflite.confidence * 100).toStringAsFixed(0) : "—"}% '
      'agree=$mirrorTfliteAgreement',
    );

    return conf;
  }

  ScientificStageMetric? _stage(ScientificUdderReport report, String id) {
    for (final s in report.stages) {
      if (s.stageId == id) return s;
    }
    return null;
  }
}
