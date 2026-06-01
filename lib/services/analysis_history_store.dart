import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'classifier_service_new.dart';

/// Persisted + in-memory recent analyses for Home / Galleries UI.
class AnalysisHistoryEntry {
  const AnalysisHistoryEntry({
    required this.id,
    required this.capturedAt,
    this.imageFile,
    this.imagePath,
    required this.litersPerDay,
    required this.confidence,
    required this.healthStatus,
    required this.healthy,
    this.captureId,
  });

  final String id;
  final DateTime capturedAt;
  final File? imageFile;
  final String? imagePath;
  final double litersPerDay;
  final double confidence;
  final String healthStatus;
  final bool healthy;
  final String? captureId;

  File? get resolvedImageFile {
    if (imageFile != null && imageFile!.existsSync()) return imageFile;
    if (imagePath != null) {
      final f = File(imagePath!);
      if (f.existsSync()) return f;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'capturedAt': capturedAt.toIso8601String(),
        'imagePath': imagePath,
        'litersPerDay': litersPerDay,
        'confidence': confidence,
        'healthStatus': healthStatus,
        'healthy': healthy,
        'captureId': captureId,
      };

  factory AnalysisHistoryEntry.fromJson(Map<String, dynamic> json) {
    final path = json['imagePath'] as String?;
    return AnalysisHistoryEntry(
      id: json['id'] as String,
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      imagePath: path,
      imageFile: path != null ? File(path) : null,
      litersPerDay: (json['litersPerDay'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      healthStatus: json['healthStatus'] as String,
      healthy: json['healthy'] as bool? ?? true,
      captureId: json['captureId'] as String?,
    );
  }
}

class AnalysisHistoryStore extends ChangeNotifier {
  AnalysisHistoryStore._();

  static final AnalysisHistoryStore instance = AnalysisHistoryStore._();

  static const _prefsKey = 'analysis_history_v1';
  static const _maxEntries = 30;

  final List<AnalysisHistoryEntry> _entries = [];
  bool _loaded = false;

  List<AnalysisHistoryEntry> get entries => List.unmodifiable(_entries);
  AnalysisHistoryEntry? get latest => _entries.isEmpty ? null : _entries.first;
  bool get isLoaded => _loaded;

  Future<void> loadFromDisk() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List<dynamic>;
        for (final item in list) {
          final entry = AnalysisHistoryEntry.fromJson(
            Map<String, dynamic>.from(item as Map),
          );
          if (entry.resolvedImageFile != null || entry.imagePath == null) {
            _entries.add(entry);
          }
        }
      }
    } catch (e) {
      debugPrint('AnalysisHistoryStore load failed: $e');
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> recordFromPrediction({
    required PredictionResult result,
    File? imageFile,
    String? captureId,
    bool healthy = true,
  }) async {
    if (result.estimatedLiters <= 0 &&
        (result.label == 'No Buffalo Detected' ||
            result.label == 'AI Model Not Loaded' ||
            result.label == 'Photo Not Suitable' ||
            result.label == 'Detection Error')) {
      return;
    }

    final report = result.pipeline;
    final health = report?.healthStatus ?? (healthy ? 'Healthy' : 'Not healthy');
    final savedPath = await _persistImageCopy(imageFile);

    _entries.insert(
      0,
      AnalysisHistoryEntry(
        id: captureId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        capturedAt: DateTime.now(),
        imagePath: savedPath,
        imageFile: savedPath != null ? File(savedPath) : imageFile,
        litersPerDay: result.estimatedLiters,
        confidence: report?.yieldConfidence ?? result.confidence,
        healthStatus: health,
        healthy: healthy,
        captureId: captureId,
      ),
    );

    if (_entries.length > _maxEntries) {
      _entries.removeRange(_maxEntries, _entries.length);
    }
    await _persist();
    notifyListeners();
  }

  Future<String?> _persistImageCopy(File? source) async {
    if (source == null || !await source.exists()) return null;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final scansDir = Directory(p.join(dir.path, 'scan_history'));
      if (!await scansDir.exists()) {
        await scansDir.create(recursive: true);
      }
      final name =
          '${DateTime.now().millisecondsSinceEpoch}_${p.basename(source.path)}';
      final dest = File(p.join(scansDir.path, name));
      await source.copy(dest.path);
      return dest.path;
    } catch (e) {
      debugPrint('AnalysisHistoryStore image copy failed: $e');
      return source.path;
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_entries.map((e) => e.toJson()).toList());
      await prefs.setString(_prefsKey, encoded);
    } catch (e) {
      debugPrint('AnalysisHistoryStore persist failed: $e');
    }
  }

  void clear() {
    _entries.clear();
    _persist();
    notifyListeners();
  }
}
