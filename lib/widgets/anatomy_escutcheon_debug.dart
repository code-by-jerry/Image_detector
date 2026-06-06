import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../services/milk_mirror_measurement_service.dart';

/// Faint legacy escutcheon box (A–B × C–D) drawn under the diamond overlay.
void paintEscutcheonDebugLayer(
  Canvas canvas,
  Size size, {
  MilkMirrorUiMetrics? metrics,
  required List<Offset> keypoints,
}) {
  if (keypoints.length < 3) return;

  Offset pt(Offset n) => Offset(n.dx * size.width, n.dy * size.height);

  final leftPinN = keypoints[0];
  final rightPinN = keypoints[1];
  final udderN = keypoints[2];
  final tailN = keypoints.length > 3
      ? keypoints[3]
      : Offset((leftPinN.dx + rightPinN.dx) / 2, leftPinN.dy - 0.08);

  final pointAN = metrics?.pointA ?? tailN;
  final pointBN = metrics?.pointB ?? udderN;
  final pointCN = metrics?.pointC ??
      Offset(leftPinN.dx, (leftPinN.dy + udderN.dy) / 2);
  final pointDN = metrics?.pointD ??
      Offset(rightPinN.dx, (rightPinN.dy + udderN.dy) / 2);

  final pointA = pt(pointAN);
  final pointB = pt(pointBN);
  final pointC = pt(pointCN);
  final pointD = pt(pointDN);

  final escutcheonRect = ui.Rect.fromPoints(
    Offset(pointC.dx, pointA.dy),
    Offset(pointD.dx, pointB.dy),
  );
  if (escutcheonRect.width < 4 || escutcheonRect.height < 4) return;

  final fillPaint = Paint()
    ..color = const Color(0xFFFFD54F).withValues(alpha: 0.07)
    ..style = PaintingStyle.fill;
  final strokePaint = Paint()
    ..color = const Color(0xFFFFD54F).withValues(alpha: 0.38)
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;

  canvas.drawRect(escutcheonRect, fillPaint);
  canvas.drawRect(escutcheonRect, strokePaint);

  final spineX = (pointC.dx + pointD.dx) / 2;
  canvas.drawLine(
    Offset(spineX, pointA.dy),
    Offset(spineX, pointB.dy),
    strokePaint,
  );
  canvas.drawLine(pointC, pointD, strokePaint);

  for (final entry in [
    (pointA, 'A'),
    (pointB, 'B'),
    (pointC, 'C'),
    (pointD, 'D'),
  ]) {
    _drawFaintCornerLabel(canvas, entry.$1, entry.$2);
  }

  final hNorm = metrics?.heightNorm ??
      (pointBN.dy - pointAN.dy).abs().clamp(0.0, 1.0);
  final wNorm = metrics?.widthNorm ??
      (pointDN.dx - pointCN.dx).abs().clamp(0.0, 1.0);
  final dbgText =
      'dbg H: ${(hNorm * 100).toStringAsFixed(0)}%  W: ${(wNorm * 100).toStringAsFixed(0)}%';
  final tp = TextPainter(
    text: TextSpan(
      text: dbgText,
      style: TextStyle(
        color: const Color(0xFFFFD54F).withValues(alpha: 0.55),
        fontSize: 9,
        fontWeight: FontWeight.w600,
        shadows: const [Shadow(blurRadius: 2, color: Colors.black54)],
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(
    canvas,
    Offset(escutcheonRect.left + 4, escutcheonRect.bottom - tp.height - 4),
  );
}

void _drawFaintCornerLabel(Canvas canvas, Offset point, String label) {
  canvas.drawCircle(
    point,
    4,
    Paint()..color = const Color(0xFFFFD54F).withValues(alpha: 0.35),
  );
  final tp = TextPainter(
    text: TextSpan(
      text: label,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.65),
        fontSize: 8,
        fontWeight: FontWeight.w600,
        shadows: const [Shadow(blurRadius: 2, color: Colors.black54)],
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(canvas, Offset(point.dx - tp.width / 2, point.dy - 14));
}
