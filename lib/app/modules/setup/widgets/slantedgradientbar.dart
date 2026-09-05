import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../res/colors/colors.dart';

class AdjustableGradientRectangle extends StatelessWidget {
  final double width;
  final double height;
  final double reduceTopLeft;
  final double reduceBottomLeft;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;
  final Color shadowColor;
  final double shadowBlur;
  final double shadowSpread;
  final Gradient? gradient;
  final Color? color;

  const AdjustableGradientRectangle({
    super.key,
    required this.width,
    required this.height,
    this.reduceTopLeft = 0,
    this.reduceBottomLeft = 0,
    this.borderRadius = 8.0,
    this.borderWidth = 2.0,
    this.borderColor = Colors.black,
    this.shadowColor = Colors.black26,
    this.shadowBlur = 10,
    this.shadowSpread = 2,
    this.gradient,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _AdjustableGradientRectanglePainter(
        height: height,
        reduceTopLeft: reduceTopLeft,
        reduceBottomLeft: reduceBottomLeft,
        borderRadius: borderRadius,
        borderWidth: borderWidth,
        borderColor: borderColor,
        shadowColor: shadowColor,
        shadowBlur: shadowBlur,
        shadowSpread: shadowSpread,
        gradient: gradient,
        color: color,
      ),
    );
  }
}

class _AdjustableGradientRectanglePainter extends CustomPainter {
  final double height;
  final double reduceTopLeft;
  final double reduceBottomLeft;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;
  final Color shadowColor;
  final double shadowBlur;
  final double shadowSpread;
  final Gradient? gradient;
  final Color? color;

  _AdjustableGradientRectanglePainter({
    required this.height,
    required this.reduceTopLeft,
    required this.reduceBottomLeft,
    required this.borderRadius,
    required this.borderWidth,
    required this.borderColor,
    required this.shadowColor,
    required this.shadowBlur,
    required this.shadowSpread,
    this.gradient,
    this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color ?? Colors.purple
      ..style = PaintingStyle.fill;

    if (gradient != null) {
      paint.shader = gradient!.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    }

    final Path path = Path();
    path.moveTo(borderRadius, reduceTopLeft); // start after top-left radius
    path.lineTo(size.width - borderRadius, 0); // top-right
    path.quadraticBezierTo(
      size.width,
      0,
      size.width,
      borderRadius,
    ); // round top-right
    path.lineTo(size.width, height - borderRadius); // right side
    path.quadraticBezierTo(
      size.width,
      height,
      size.width - borderRadius,
      height,
    ); // bottom-right
    path.lineTo(borderRadius, height - reduceBottomLeft); // bottom-left
    path.quadraticBezierTo(
      0,
      height - reduceBottomLeft,
      0,
      height - reduceBottomLeft - borderRadius,
    ); // round bottom-left
    path.lineTo(0, reduceTopLeft + borderRadius); // left side
    path.quadraticBezierTo(
      0,
      reduceTopLeft,
      borderRadius,
      reduceTopLeft,
    ); // round top-left
    path.close();

    // Draw shadow
    canvas.drawShadow(path, shadowColor, shadowBlur, true);

    // Draw fill
    canvas.drawPath(path, paint);

    // Draw border
    if (borderWidth > 0) {
      final Paint borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
