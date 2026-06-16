import 'dart:io';

import 'package:image/image.dart' as img;

/// Builds splash + light-background logo assets from `logo-3.png`.
void main() {
  final logoFile = File('assets/branding/logo/logo-3.png');
  final logo = img.decodePng(logoFile.readAsBytesSync());
  if (logo == null) {
    stderr.writeln('Could not decode logo-3.png');
    exit(1);
  }

  final displayLogo = _keyOutBlackBackground(logo);
  final displayOut = File('assets/branding/logo/logo-3-display.png');
  displayOut.writeAsBytesSync(img.encodePng(displayLogo));

  final cream = img.ColorRgb8(250, 248, 242);
  const canvasWidth = 1080;
  const canvasHeight = 1920;

  final scaled = img.copyResize(
    displayLogo,
    width: canvasWidth,
    interpolation: img.Interpolation.average,
  );

  final splashCanvas = img.Image(
    width: canvasWidth,
    height: canvasHeight,
    numChannels: 4,
  );
  img.fill(splashCanvas, color: cream);
  final splashY = (canvasHeight - scaled.height) ~/ 2;
  img.compositeImage(splashCanvas, scaled, dstX: 0, dstY: splashY);

  final splashOut = File('assets/branding/splash/splash-logo.png');
  splashOut.parent.createSync(recursive: true);
  splashOut.writeAsBytesSync(img.encodePng(splashCanvas));

  stdout.writeln('Source logo: ${logo.width}x${logo.height}');
  stdout.writeln('Display logo: ${displayOut.path} (${displayLogo.width}x${displayLogo.height})');
  stdout.writeln('Splash logo: ${splashOut.path} (${canvasWidth}x$canvasHeight, full width)');
}

img.Image _keyOutBlackBackground(img.Image source) {
  final out = img.Image(
    width: source.width,
    height: source.height,
    numChannels: 4,
  );

  for (var y = 0; y < source.height; y++) {
    for (var x = 0; x < source.width; x++) {
      final pixel = source.getPixel(x, y);
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();
      final isBackground = r < 42 && g < 42 && b < 42;
      if (isBackground) {
        out.setPixelRgba(x, y, 0, 0, 0, 0);
      } else {
        out.setPixelRgba(x, y, r, g, b, 255);
      }
    }
  }

  return out;
}
