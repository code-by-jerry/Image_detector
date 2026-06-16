import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'inference_logger.dart';
import 'udder_mask_geometry.dart';

/// On-device udder segmentation (`assets/model/udder_seg.tflite`).
class UdderSegTfliteService {
  UdderSegTfliteService._();
  static final UdderSegTfliteService instance = UdderSegTfliteService._();

  static const String modelAsset = 'assets/model/udder_seg.tflite';
  static const int inputSize = 256;

  Interpreter? _interpreter;
  bool _loadAttempted = false;
  String? _loadError;

  bool get isLoaded => _interpreter != null;
  String? get loadError => _loadError;

  Future<bool> ensureLoaded() async {
    if (_interpreter != null) return true;
    if (_loadAttempted) return false;
    _loadAttempted = true;

    try {
      await rootBundle.load(modelAsset);
    } catch (_) {
      _loadError = 'Asset missing: $modelAsset (run training/train_udder_seg.py)';
      InferenceLogger.log('UDDER_SEG', _loadError!);
      return false;
    }

    try {
      _interpreter = await Interpreter.fromAsset(modelAsset);
      InferenceLogger.log('UDDER_SEG', 'Loaded $modelAsset');
      return true;
    } catch (e) {
      _loadError = '$e';
      InferenceLogger.log('UDDER_SEG', 'Load failed: $e');
      return false;
    }
  }

  /// Returns flat mask (1 = udder) at [imageWidth]×[imageHeight].
  Future<({List<int> mask, int width, int height, double score})?> segmentFile(
    String imagePath, {
    int? imageWidth,
    int? imageHeight,
  }) async {
    if (!await ensureLoaded()) return null;
    final file = File(imagePath);
    if (!file.existsSync()) return null;

    final decoded = img.decodeImage(file.readAsBytesSync());
    if (decoded == null) return null;
    final oriented = img.bakeOrientation(decoded);
    return segmentImage(oriented);
  }

  Future<({List<int> mask, int width, int height, double score})?> segmentImage(
    img.Image image,
  ) async {
    final interpreter = _interpreter;
    if (interpreter == null) return null;

    final inputTensor = interpreter.getInputTensor(0);
    final outputTensor = interpreter.getOutputTensor(0);
    final inputType = inputTensor.type;
    final outputType = outputTensor.type;

    final resized = img.copyResize(
      image,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.linear,
    );

    final input = _buildInput(resized, inputType);
    final output = _buildOutput(outputTensor.shape, outputType);

    interpreter.run(input, output);

    final flat = _decodeOutput(output, outputType);
    final score = flat.where((v) => v > 127).length / flat.length;

    final fullMask = List<int>.filled(image.width * image.height, 0);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final sx = (x * inputSize / image.width).floor().clamp(0, inputSize - 1);
        final sy = (y * inputSize / image.height).floor().clamp(0, inputSize - 1);
        fullMask[y * image.width + x] = flat[sy * inputSize + sx];
      }
    }

    return (
      mask: fullMask,
      width: image.width,
      height: image.height,
      score: score,
    );
  }

  dynamic _buildInput(img.Image image, TensorType type) {
    if (type == TensorType.uint8) {
      final input = List.generate(
        1,
        (_) => List.generate(
          inputSize,
          (y) => List.generate(inputSize, (x) {
            final p = image.getPixel(x, y);
            return [p.r.toInt(), p.g.toInt(), p.b.toInt()];
          }),
        ),
      );
      return input;
    }

    final input = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(inputSize, (x) {
          final p = image.getPixel(x, y);
          return [
            (p.r / 127.5) - 1.0,
            (p.g / 127.5) - 1.0,
            (p.b / 127.5) - 1.0,
          ];
        }),
      ),
    );
    return input;
  }

  dynamic _buildOutput(List<int> shape, TensorType type) {
    final h = shape.length >= 3 ? shape[1] : inputSize;
    final w = shape.length >= 4 ? shape[2] : inputSize;
    if (type == TensorType.uint8) {
      return List.generate(1, (_) => List.generate(h, (_) => List.filled(w, 0)));
    }
    return List.generate(1, (_) => List.generate(h, (_) => List.filled(w, 0.0)));
  }

  List<int> _decodeOutput(dynamic output, TensorType type) {
    final plane = output[0] as List;
    final h = plane.length;
    final w = (plane[0] as List).length;
    final flat = List<int>.filled(h * w, 0);
    for (var y = 0; y < h; y++) {
      final row = plane[y] as List;
      for (var x = 0; x < w; x++) {
        final v = row[x];
        flat[y * w + x] = type == TensorType.uint8
            ? (v as int)
            : ((v as double) * 255).round().clamp(0, 255);
      }
    }
    return flat;
  }

  UdderMaskGeometry? geometryFromMask(
    List<int> mask,
    int width,
    int height,
  ) =>
      UdderMaskGeometry.fromMask(mask, width, height);

  void close() {
    _interpreter?.close();
    _interpreter = null;
    _loadAttempted = false;
  }
}
