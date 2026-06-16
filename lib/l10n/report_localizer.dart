import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

/// Translates English UI/report strings for display only.
/// Stored Firestore/model data stays in English — nothing is rewritten.
class ReportLocalizer {
  ReportLocalizer(this.l10n);

  final AppLocalizations l10n;

  factory ReportLocalizer.of(BuildContext context) =>
      ReportLocalizer(AppLocalizations.of(context));

  String text(String value) {
    switch (value) {
      case 'Healthy':
        return l10n.healthy;
      case 'Not healthy':
        return l10n.notHealthy;
      case 'Buffalo':
        return l10n.speciesBuffalo;
      case 'Unknown':
        return l10n.speciesUnknown;
      case 'Uncertain':
        return l10n.speciesUncertain;
      case 'Female':
        return l10n.sexFemale;
      case 'Male':
        return l10n.sexMale;
      case 'Lactating':
        return l10n.lactationLactating;
      case 'Dry / not visible':
        return l10n.lactationDry;
      case 'Normal':
        return l10n.healthNormal;
      case 'Check asymmetry':
        return l10n.healthCheckAsymmetry;
      case 'Poor image quality':
        return l10n.healthPoorImageQuality;
      case 'Early (0–100 DIM)':
        return l10n.stageEarly;
      case 'Mid (100–200 DIM)':
        return l10n.stageMid;
      case 'Late (>200 DIM)':
        return l10n.stageLate;
      case 'Capture image':
        return l10n.stepCaptureImage;
      case 'Rear udder photo':
        return l10n.stepRearPhoto;
      case 'Animal detection':
        return l10n.stepAnimalDetection;
      case 'Animal detected':
        return l10n.stepAnimalDetected;
      case 'Failed':
        return l10n.stepFailed;
      case 'Species':
        return l10n.stepSpecies;
      case 'Sex check':
        return l10n.stepSexCheck;
      case 'Lactation':
        return l10n.stepLactation;
      case 'Health screen':
        return l10n.stepHealthScreen;
      case 'Yield predict':
        return l10n.stepYieldPredict;
      case 'Prediction blocked — fix photo or animal':
        return l10n.alertBlockedDefault;
      case 'Male buffalo detected — milk yield prediction is for lactating females only':
        return l10n.alertMaleBuffalo;
      case 'Use a rear photo of a lactating female with visible udder.':
        return l10n.tipMaleBuffalo;
      case 'Could not measure escutcheon — use rear udder view':
        return l10n.alertEscutcheonFailed;
      case 'Stand 3–5 ft behind, camera at udder height, full udder in frame.':
        return l10n.tipEscutcheon;
      case 'Prediction with caution — train TFLite or retake photo':
        return l10n.alertCaution;
      case 'Use a clear rear udder photo; add more labeled training images for accuracy.':
        return l10n.tipCaution;
      case 'High-confidence పాల Predictor analysis':
        return l10n.alertHighConfidence;
      case 'Maintain nutrition and monitor udder health weekly.':
        return l10n.tipHighConfidence;
      case 'Analysis complete — review measurements below':
        return l10n.alertComplete;
      case 'Log DIM and parity in farmer inputs for better stage accuracy.':
        return l10n.tipComplete;
      case 'No Buffalo Detected':
        return l10n.labelNoBuffaloDetected;
      case 'AI Model Not Loaded':
        return l10n.labelAiModelNotLoaded;
      case 'Detection Error':
        return l10n.labelDetectionError;
      case 'Photo Not Suitable':
        return l10n.labelPhotoNotSuitable;
      default:
        if (value.startsWith('Female — ') || value.startsWith('Male — ')) {
          final parts = value.split(' — ');
          final sex = text(parts.first);
          return parts.length > 1 ? '$sex — ${parts.sublist(1).join(' — ')}' : sex;
        }
        return value;
    }
  }

  String engineSource(String source) {
    switch (source) {
      case 'milk_mirror':
        return l10n.engineMilkMirror;
      case 'milk_mirror+tflite':
        return l10n.engineMilkMirrorTflite;
      case 'tflite':
        return l10n.engineTflite;
      case 'tflite_untrained':
        return l10n.engineTfliteUntrained;
      case 'rules_gate':
        return l10n.engineRulesGate;
      default:
        return source;
    }
  }

  String localizePipelineStepTitle(String title) => text(title);

  String localizePipelineStepSubtitle(String subtitle) {
    if (subtitle.endsWith('%')) {
      final match = RegExp(r'^(.+?) (\d+)%$').firstMatch(subtitle);
      if (match != null) {
        return '${text(match.group(1)!)} ${match.group(2)}%';
      }
    }
    return text(subtitle);
  }
}
