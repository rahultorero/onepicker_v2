import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'AppTheme.dart';

class FloatingElementsPainter extends CustomPainter {
  final double animationValue;

  FloatingElementsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw floating medical elements
    for (int i = 0; i < 6; i++) {
      final x = size.width * (0.1 + (i % 3) * 0.4);
      final y = size.height * (0.2 + (i ~/ 3) * 0.6) +
          math.sin(animationValue * 2 + i) * 20;

      paint.color = [
        AppTheme.primaryBlue.withOpacity(0.05),
        AppTheme.medicalTeal.withOpacity(0.08),
        AppTheme.mintGreen.withOpacity(0.06),
      ][i % 3];

      final radius = 15.0 + math.cos(animationValue + i * 0.5) * 8;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}