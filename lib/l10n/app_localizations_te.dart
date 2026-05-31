// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appTitle => 'మిల్క్ మిర్రర్';

  @override
  String get languageLabel => 'భాష';

  @override
  String get languageEnglish => 'ఇంగ్లీష్';

  @override
  String get languageHindi => 'హిందీ';

  @override
  String get languageTelugu => 'తెలుగు';

  @override
  String get headerSubtitleReady =>
      'AI డైరీ విశ్లేషణ · వెనుక క్షీర గ్రంథి ఫోటో';

  @override
  String get headerSubtitleBooting => 'అంచనా ఇంజిన్ ప్రారంభమవుతోంది…';

  @override
  String get statusAiOnline => 'AI ఆన్‌లైన్';

  @override
  String get statusBooting => 'ప్రారంభం';

  @override
  String get flowCapture => 'క్యాప్చర్';

  @override
  String get flowReview => 'సమీక్ష';

  @override
  String get flowResults => 'ఫలితాలు';

  @override
  String get captureHintReady => 'AI సిద్ధం · కెమెరా / గ్యాలరీ';

  @override
  String get captureHintLoading => 'AI లోడ్ అవుతోంది…';

  @override
  String get camera => 'కెమెరా';

  @override
  String get gallery => 'గ్యాలరీ';

  @override
  String get uploadedPhoto => 'అప్‌లోడ్ చేసిన ఫోటో';

  @override
  String get reviewInstructions =>
      'పశువు ఆరోగ్యం నిర్ధారించండి, తర్వాత AI విశ్లేషణకు ముందుకు సాగండి.';

  @override
  String get animalHealth => 'పశువు ఆరోగ్యం';

  @override
  String get healthy => 'ఆరోగ్యంగా';

  @override
  String get healthySubtitle => 'సాధారణ స్థితి, పాలు అంచనా కోసం అనుకూలం';

  @override
  String get notHealthy => 'ఆరోగ్యం లేదు';

  @override
  String get notHealthySubtitle =>
      'అనారోగ్యం, గాయం లేదా చెడు స్థితి కనిపిస్తుంది';

  @override
  String get changePhoto => 'ఫోటో మార్చండి';

  @override
  String get proceed => 'ముందుకు';

  @override
  String get analyzing => 'విశ్లేషిస్తోంది…';

  @override
  String get editHealthRetry => 'ఆరోగ్యం సవరించి మళ్లీ ప్రయత్నించండి';

  @override
  String get newPhoto => 'కొత్త ఫోటో';

  @override
  String get emptyStateHint =>
      'గుర్తింపు ప్రారంభించడానికి ఫోటో క్యాప్చర్ లేదా అప్‌లోడ్ చేయండి';

  @override
  String get errorCameraWindows =>
      'Windows డెస్క్‌టాప్‌లో కెమెరా మద్దతు లేదు. గేదె ఫోటో అప్‌లోడ్ చేయడానికి \"గ్యాలరీ\" ఉపయోగించండి.';

  @override
  String errorPickImage(String source) {
    return '$source తెరవడం విఫలమైంది. దయచేసి యాప్ అనుమతులు తనిఖీ చేయండి.';
  }

  @override
  String savedCapture(String id) {
    return 'క్యాప్చర్ $id సేవ్ చేయబడింది (Firestore)';
  }

  @override
  String firestoreSaveFailed(String error) {
    return 'Firestore సేవ్ విఫలం: $error';
  }

  @override
  String get analysisFailed =>
      'విశ్లేషణ విఫలమైంది. దయచేసి మరో ఫోటో ప్రయత్నించండి.';

  @override
  String get engineMilkMirror => 'పిన్ బోన్ + ఎస్కుచeon (A–B, C–D)';

  @override
  String get engineMilkMirrorTflite => 'మిల్క్ మిర్రర్ + AI';

  @override
  String get engineTflite => 'TFLite AI';

  @override
  String get engineTfliteUntrained => 'TFLite (శిక్షణ అవసరం)';

  @override
  String get engineRulesGate => 'నియమాల గేట్ మాత్రమే';

  @override
  String get overlayAiAnalysisTitle => 'AI విశ్లేషణ జరుగుతోంది';

  @override
  String get overlayAiAnalysisSubtitle =>
      'కంప్యూటర్ విజన్ · కొలత · అంచనా ఇంజిన్';

  @override
  String get overlayStepCapture => 'క్యాప్చర్';

  @override
  String get overlayStepCaptureSub => 'ఫోటో లోడ్';

  @override
  String get overlayStepDetect => 'గుర్తించు';

  @override
  String get overlayStepDetectSub => 'పశువు స్కాన్';

  @override
  String get overlayStepMeasure => 'కొలత';

  @override
  String get overlayStepMeasureSub => 'ఎస్కుచeon';

  @override
  String get overlayStepPredict => 'అంచనా';

  @override
  String get overlayStepPredictSub => 'TFLite';

  @override
  String get showcaseBootingAi => 'AI ప్రారంభం';

  @override
  String get showcaseMilkMirror => 'మిల్క్ మిర్రర్';

  @override
  String get showcaseBuffaloRearTitle => 'గేదె వెనుక';

  @override
  String get showcaseBuffaloRearSub => 'పిన్ బోన్ ఎస్కుచeon';

  @override
  String get showcaseCowRearTitle => 'ఆవు వెనుక';

  @override
  String get showcaseCowRearSub => 'మంద పోలిక';

  @override
  String get showcaseMilkingTitle => 'పాలు పార్చడం';

  @override
  String get showcaseMilkingSub => 'దిగుబడి సందర్భం';

  @override
  String get showcaseAiScanTitle => 'AI స్కానింగ్';

  @override
  String get showcaseAiScanSub => 'న్యూరల్ విశ్లేషణ';

  @override
  String get showcaseHealthTitle => 'ఆరోగ్యం';

  @override
  String get showcaseHealthSub => 'స్థితి తనిఖీ';

  @override
  String get showcaseLactationTitle => 'పాలిచ్చే దశ';

  @override
  String get showcaseLactationSub => 'దశ & DIM';

  @override
  String get showcaseMilkYieldTitle => 'పాలు దిగుబడి';

  @override
  String get showcaseMilkYieldSub => 'రోజుకు లీటర్లు';

  @override
  String get alertAnalysisSuccessful => 'విశ్లేషణ విజయవంతం';

  @override
  String get alertReviewRecommended => 'సమీక్ష సిఫారసు';

  @override
  String get alertPredictionBlocked => 'అంచనా నిలిపివేయబడింది';

  @override
  String get alertAiInsight => 'AI అంతర్దృష్టి';

  @override
  String get dailyMilkProduction => 'రోజువారీ పాలు ఉత్పత్తి';

  @override
  String yieldRangeLabel(String min, String max, String band) {
    return 'పరిధి $min–$max L · $band';
  }

  @override
  String get metricSpecies => 'జాతి';

  @override
  String get metricLactation => 'పాలిచ్చే దశ';

  @override
  String get metricHealth => 'ఆరోగ్యం';

  @override
  String get aiPipeline => 'AI పైప్‌లైన్';

  @override
  String get detectionPanel => 'గుర్తింపు ప్యానెల్';

  @override
  String get detectSexClassification => 'లింగ వర్గీకరణ';

  @override
  String get detectLactationStage => 'పాలిచ్చే దశ';

  @override
  String get detectSpeciesConfidence => 'జాతి నమ్మకం';

  @override
  String get dimBadge => 'DIM';

  @override
  String get productionEstimate => 'ఉత్పత్తి అంచనా';

  @override
  String get litersPerDay => 'L / రోజు';

  @override
  String confidencePercent(int percent) {
    return '$percent% నమ్మకం';
  }

  @override
  String productionEstimateFootnote(String min, String max) {
    return 'ఎస్కుచeon కొలత మరియు పరికర AI నుండి గుర్తించబడింది ($min–$max L స్కేల్).';
  }

  @override
  String sessionId(String id) {
    return 'సెషన్ $id';
  }

  @override
  String get escutcheonVision => 'ఎస్కుచeon విజన్';

  @override
  String get metricAbHeight => 'A–B ఎత్తు';

  @override
  String get metricCdWidth => 'C–D వెడల్పు';

  @override
  String get metricArea => 'విస్తీర్ణం';

  @override
  String get metricSymmetry => 'సమరూపత %';

  @override
  String get milkMirrorAnalysis => 'మిల్క్ మిర్రర్ విశ్లేషణ';

  @override
  String get measured => 'కొలవబడింది';

  @override
  String centerEstimate(String liters) {
    return 'కేంద్ర అంచనా: $liters L/రోజు';
  }

  @override
  String confidenceLabel(String percent) {
    return 'నమ్మకం: $percent%';
  }

  @override
  String get escutcheonMeasurements => 'ఎస్కుచeon కొలతలు';

  @override
  String get heightAb => 'ఎత్తు (A → B)';

  @override
  String get widthCd => 'వెడల్పు (C → D)';

  @override
  String get areaHw => 'విస్తీర్ణం (H × W)';

  @override
  String get symmetryIndex => 'సమరూపత సూచిక';

  @override
  String percentOfFrame(String percent) {
    return 'ఫ్రేమ్ $percent%';
  }

  @override
  String percentBalanced(String percent) {
    return '$percent% సమతుల్యం';
  }

  @override
  String get keyFeaturesExtracted => 'ముఖ్య లక్షణాలు వెలికితీయబడ్డాయి';

  @override
  String get featureArea => 'విస్తీర్ణం';

  @override
  String get featureSymmetry => 'సమరూపత';

  @override
  String get featureFullness => 'పూర్తిగా';

  @override
  String get featureTexture => 'టెక్స్చర్';

  @override
  String aiCrossCheck(String liters, String match) {
    return 'AI క్రాస్-చెక్: $liters L/రోజు ($match% సరిపోలింపు)';
  }

  @override
  String get dailyRevenue => 'రోజువారీ ఆదాయం';

  @override
  String get monthlyRevenue => 'నెలవారీ ఆదాయం';

  @override
  String get milkMirrorFootnote =>
      '* ఫోటోలో పిన్ బోన్లు (C/D) మరియు క్షీర గ్రంథి (B) — ఓవర్లే చూడండి. ఎస్కుచeon + పరికర AI నుండి 1–30 L/రోజు స్కేల్.';

  @override
  String get proofRulesGate => 'నియమాల గేట్';

  @override
  String get proofPinBones => 'పిన్ బోన్లు గుర్తించబడ్డాయి';

  @override
  String get proofEscutcheon => 'ఎస్కుచeon కొలవబడింది';

  @override
  String get proofTfliteRan => 'TFLite నడిచింది';

  @override
  String get inferenceProof => 'అనుమాన ప్రమాణం';

  @override
  String get inferenceProofConsole => 'అనుమాన ప్రమాణం (డీబగ్ కన్సోల్ చూడండి)';

  @override
  String get proofSession => 'సెషన్';

  @override
  String get proofPredictedBy => 'ద్వారా అంచనా';

  @override
  String get proofTfliteLoaded => 'TFLite లోడ్';

  @override
  String get proofInterpreter => 'ఇంటర్‌ప్రెటర్';

  @override
  String get proofInterpreterRun => 'interpreter.run()';

  @override
  String get proofPass => 'పాస్';

  @override
  String get proofFail => 'ఫెయిల్';

  @override
  String get proofMilkMirrorUi => 'మిల్క్ మిర్రర్ (UI):';

  @override
  String get proofHeightAb => 'ఎత్తు A→B';

  @override
  String get proofWidthCd => 'వెడల్పు C→D';

  @override
  String get proofLitersMeasured => 'లీటర్లు (కొలవబడింది)';

  @override
  String get proofTfliteClass => 'TFLite తరగతి';

  @override
  String get proofAllClassScores => 'అన్ని తరగతి స్కోర్లు:';

  @override
  String get badgeMilkMirrorMeasurement => 'మిల్క్ మిర్రర్ కొలత';

  @override
  String get badgeAiModelTflite => 'AI మోడల్ (TFLite)';

  @override
  String get estimatedYield => 'అంచనా దిగుబడి';

  @override
  String get dailyRevenueRow => 'రోజువారీ ఆదాయం';

  @override
  String get monthlyRevenueRow => 'నెలవారీ ఆదాయం';

  @override
  String engineLabel(String engine) {
    return 'ఇంజిన్: $engine';
  }

  @override
  String litersPerMonth(String liters) {
    return '${liters}L / నెల';
  }

  @override
  String get tfliteUntrainedWarning =>
      'ఈ TFLite ఫైల్ మీ గేదె ఫోటోలపై ఇంకా శిక్షణ పొందలేదు. యాప్ ఎల్లప్పుడూ తరగతిని ఎంచుకుంటుంది, కానీ 0% స్కోర్లు అంటే మోడల్ 6–10 L బ్యాండ్లను వేరు చేయలేదు. training/train_model.py తో శిక్షణ ఇవ్వండి.';

  @override
  String get couldNotIdentifyBuffalo => '* ఈ ఫోటో నుండి గేదె గుర్తించబడలేదు';

  @override
  String get localBuffaloDebug =>
      '* స్థానిక గేదె — పైన డీబగ్ ఇన్‌పుట్‌లతో హైబ్రిడ్ మోడల్';

  @override
  String get localBuffaloPhoto => '* స్థానిక గేదె — ఫోటో నుండి మాత్రమే అంచనా';

  @override
  String get badgeImageBasedModel => 'చిత్ర-ఆధారిత మోడల్';

  @override
  String get visualAnalysisComplete => 'దృశ్య విశ్లేషణ పూర్తి';

  @override
  String get basedOnImageFeatures => 'చిత్ర లక్షణాల ఆధారంగా';

  @override
  String get visualPrediction => 'దృశ్య అంచనా';

  @override
  String get visualScore => 'దృశ్య స్కోర్';

  @override
  String get udderSize => 'క్షీర గ్రంథి పరిమాణం';

  @override
  String get bodyCondition => 'శరీర స్థితి';

  @override
  String get frameSize => 'ఫ్రేమ్ పరిమాణం';

  @override
  String get buildScoreDebug => 'బిల్డ్ స్కోర్ (డీబగ్)';

  @override
  String get imageBasedFootnote => '* దృశ్య AI మోడల్ ఆధారంగా (చిత్ర విశ్లేషణ)';

  @override
  String get debugHybridInputs => 'డీబగ్ — హైబ్రిడ్ మోడల్ ఇన్‌పుట్‌లు';

  @override
  String localBuffaloOnly(String type) {
    return 'స్థానిక గేదె మాత్రమే ($type). ప్రొడక్షన్‌లో దాచబడింది.';
  }

  @override
  String get feedQuality => 'ఆహార నాణ్యత';

  @override
  String get feedHighProtein => 'అధిక ప్రోటీన్';

  @override
  String get feedStandard => 'ప్రామాణిక';

  @override
  String get feedLow => 'తక్కువ';

  @override
  String get ageYears => 'వయస్సు (సంవ.)';

  @override
  String get lactationNumber => 'పాలిచ్చే #';

  @override
  String get daysInMilk => 'పాలలో రోజులు';

  @override
  String get labelNoBuffaloDetected => 'గేదె కనుగొనబడలేదు';

  @override
  String get labelAiModelNotLoaded => 'AI మోడల్ లోడ్ కాలేదు';

  @override
  String get labelDetectionError => 'గుర్తింపు లోపం';

  @override
  String get labelPhotoNotSuitable => 'ఫోటో అనుకూలం కాదు';

  @override
  String get speciesBuffalo => 'గేదె';

  @override
  String get speciesUnknown => 'తెలియదు';

  @override
  String get speciesUncertain => 'అనిశ్చితం';

  @override
  String get sexFemale => 'స్త్రీ';

  @override
  String get sexMale => 'పురుష';

  @override
  String get lactationLactating => 'పాలు ఇస్తోంది';

  @override
  String get lactationDry => 'ఎండ / కనిపించదు';

  @override
  String get healthNormal => 'సాధారణ';

  @override
  String get healthCheckAsymmetry => 'అసమతుల్యత తనిఖీ';

  @override
  String get healthPoorImageQuality => 'చెడు ఫోటో నాణ్యత';

  @override
  String get stageEarly => 'ప్రారంభ (0–100 DIM)';

  @override
  String get stageMid => 'మధ్య (100–200 DIM)';

  @override
  String get stageLate => 'చివర (>200 DIM)';

  @override
  String get stepCaptureImage => 'ఫోటో క్యాప్చర్';

  @override
  String get stepRearPhoto => 'వెనుక మిల్క్-మిర్రర్ ఫోటో';

  @override
  String get stepAnimalDetection => 'పశువు గుర్తింపు';

  @override
  String get stepAnimalDetected => 'పశువు గుర్తించబడింది';

  @override
  String get stepFailed => 'విఫలం';

  @override
  String get stepSpecies => 'జాతి';

  @override
  String get stepSexCheck => 'లింగ తనిఖీ';

  @override
  String get stepLactation => 'పాలిచ్చే దశ';

  @override
  String get stepHealthScreen => 'ఆరోగ్య తనిఖీ';

  @override
  String get stepYieldPredict => 'దిగుబడి అంచనా';

  @override
  String get alertBlockedDefault =>
      'అంచనా నిలిపివేయబడింది — ఫోటో లేదా పశువు సరిచేయండి';

  @override
  String get alertMaleBuffalo => 'మగ గేదె — పాలు అంచనా పాలిచ్చే ఆడలకు మాత్రమే';

  @override
  String get tipMaleBuffalo =>
      'క్షీర గ్రంథి కనిపించే పాలిచ్చే ఆడ వెనుక ఫోటో తీయండి.';

  @override
  String get alertEscutcheonFailed =>
      'ఎస్కుచeon కొలవలేక — వెనుక క్షీర గ్రంథి దృశ్యం ఉపయోగించండి';

  @override
  String get tipEscutcheon =>
      '3–5 అడugala వెనుక నిలబడండి, కెమెరా క్షీర గ్రంథి ఎత్తులో, పూర్తి క్షీర గ్రంథి ఫ్రేమ్‌లో.';

  @override
  String get alertCaution =>
      'జాగ్రత్తతో అంచనా — TFLite శిక్షణ లేదా ఫోటో మళ్లీ తీయండి';

  @override
  String get tipCaution =>
      'స్పష్టమైన వెనుక క్షీర గ్రంథి ఫోటో; మరిన్ని లేబుల్ చేసిన చిత్రాలు జోడించండి.';

  @override
  String get alertHighConfidence => 'అధిక-నమ్మకం మిల్క్ మిర్రర్ విశ్లేషణ';

  @override
  String get tipHighConfidence =>
      'పోషకాహారం నిర్వహించండి మరియు వారanthanga క్షీర గ్రంథి ఆరోగ్యం పర్యవేక్షించండి.';

  @override
  String get alertComplete => 'విశ్లేషణ పూర్తి — క్రింద కొలతలు చూడండి';

  @override
  String get tipComplete =>
      'మెరుగైన ఖచ్చితత్వం కోసం DIM మరియు parity లాగ్ చేయండి.';

  @override
  String get overlayLeftPin => 'ఎడమ పిన్';

  @override
  String get overlayRightPin => 'కుడి పిన్';

  @override
  String get overlayUdder => 'క్షీర గ్రంథి';
}
