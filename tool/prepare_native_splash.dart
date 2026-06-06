import 'dart:io';

import 'package:image/image.dart' as img;

/// Builds native splash assets from `spash-logo.png`.
void main() {
  const sourcePath = 'assets/branding/splash/spash-logo.png';
  final sourceFile = File(sourcePath);
  final source = img.decodePng(sourceFile.readAsBytesSync());
  if (source == null) {
    stderr.writeln('Could not decode $sourcePath');
    exit(1);
  }

  final cream = img.ColorRgb8(250, 248, 242);
  const canvasWidth = 1080;
  const canvasHeight = 1920;
  const maxLogoWidthFactor = 0.92;

  final targetWidth = (canvasWidth * maxLogoWidthFactor).round();
  final scaled = img.copyResize(
    source,
    width: targetWidth,
    interpolation: img.Interpolation.average,
  );

  final canvas = img.Image(
    width: canvasWidth,
    height: canvasHeight,
    numChannels: 4,
  );
  img.fill(canvas, color: cream);
  final x = (canvasWidth - scaled.width) ~/ 2;
  final y = (canvasHeight - scaled.height) ~/ 2;
  img.compositeImage(canvas, scaled, dstX: x, dstY: y);

  final nativeOut = File('assets/branding/splash/splash-native.png');
  nativeOut.writeAsBytesSync(img.encodePng(canvas));

  const blankSize = 1152;
  final blank = img.Image(width: blankSize, height: blankSize, numChannels: 4);
  img.fill(blank, color: cream);
  final blankOut = File('assets/branding/splash/splash-icon-blank.png');
  blankOut.writeAsBytesSync(img.encodePng(blank));

  stdout.writeln('Source: $sourcePath (${source.width}x${source.height})');
  stdout.writeln('Wrote ${nativeOut.path} (${canvasWidth}x$canvasHeight)');
  stdout.writeln('Wrote ${blankOut.path} (${blankSize}x$blankSize, hides default app icon)');
}
