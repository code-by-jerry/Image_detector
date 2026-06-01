import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Copies a bundled asset image to a temp file for ML / File-based APIs.
class AssetImageLoader {
  static Future<String> assetPathToTempFile(String assetPath) async {
    final bytes = await rootBundle.load(assetPath);
    final dir = await getTemporaryDirectory();
    final safeName = assetPath.replaceAll(RegExp(r'[^\w\.\-]+'), '_');
    final file = File(p.join(dir.path, safeName));
    if (!await file.exists() || await file.length() != bytes.lengthInBytes) {
      await file.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      );
    }
    return file.path;
  }
}
