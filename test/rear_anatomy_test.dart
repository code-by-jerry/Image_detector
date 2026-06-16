import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_detector/services/rear_anatomy_detector.dart';

void main() {
  test('pin bones above udder on rear buffalo photo', () {
    const path = r'assets/images/animal photos/9 lit/k3 (2).jpg';
    if (!File(path).existsSync()) return;

    final landmarks = RearAnatomyDetector().detectFromPath(path);
    expect(landmarks, isNotNull);

    expect(landmarks!.leftPin.dy, lessThan(landmarks.udder.dy));
    expect(landmarks.rightPin.dy, lessThan(landmarks.udder.dy));
    expect(landmarks.udder.dy, lessThan(0.8));
    expect(landmarks.leftPin.dy, greaterThan(0.2));
    expect(landmarks.rightPin.dx - landmarks.leftPin.dx, greaterThan(0.1));
  });

  test('lower cropped torso keeps landmark clamps ordered', () {
    final image = img.Image(width: 600, height: 800);
    img.fill(image, color: img.ColorRgb8(245, 245, 245));

    for (var y = 250; y < 650; y++) {
      for (var x = 120; x < 480; x++) {
        image.setPixelRgb(x, y, 78, 70, 62);
      }
    }

    final landmarks = RearAnatomyDetector().detect(image);
    expect(landmarks, isNotNull);
    expect(landmarks!.pointA.dy, lessThan(landmarks.udder.dy));
    expect(landmarks.leftPin.dy, lessThan(landmarks.udder.dy));
    expect(landmarks.udder.dx, greaterThan(landmarks.leftPin.dx));
    expect(landmarks.udder.dx, lessThan(landmarks.rightPin.dx));
  });
}
