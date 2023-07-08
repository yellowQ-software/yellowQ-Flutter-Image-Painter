import 'dart:ui';

import 'package:flutter/material.dart';

import '../image_painter.dart';
import '_controller.dart';

class SignaturePainter extends CustomPainter {
  final Color backgroundColor;
  late Controller _controller;
  SignaturePainter({
    required Controller controller,
    required this.backgroundColor,
  }) : super(repaint: controller) {
    _controller = controller;
  }
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height)),
      Paint()
        ..style = PaintingStyle.fill
        ..color = backgroundColor,
    );
    for (final item in _controller.paintHistory) {
      final _offsets = item.offsets;
      final _painter = item.paint;
      if (item.mode == PaintMode.freeStyle) {
        for (int i = 0; i < _offsets.length - 1; i++) {
          if (_offsets[i] != null && _offsets[i + 1] != null) {
            final _path = Path()
              ..moveTo(_offsets[i]!.dx, _offsets[i]!.dy)
              ..lineTo(_offsets[i + 1]!.dx, _offsets[i + 1]!.dy);
            canvas.drawPath(_path, _painter..strokeCap = StrokeCap.round);
          } else if (_offsets[i] != null && _offsets[i + 1] == null) {
            canvas.drawPoints(
              PointMode.points,
              [_offsets[i]!],
              _painter..strokeCap = StrokeCap.round,
            );
          }
        }
      }
    }
    if (_controller.busy) {
      final _paint = _controller.brush;
      final points = _controller.offsets;
      for (int i = 0; i < _controller.offsets.length - 1; i++) {
        final currentPoint = points[i];
        final nextPoint = points[i + 1];
        if (currentPoint != null && nextPoint != null) {
          canvas.drawLine(
              Offset(currentPoint.dx, currentPoint.dy),
              Offset(nextPoint.dx, nextPoint.dy),
              _paint..strokeCap = StrokeCap.round);
        } else if (currentPoint != null && nextPoint == null) {
          canvas.drawPoints(
            PointMode.points,
            [
              Offset(currentPoint.dx, currentPoint.dy),
            ],
            _paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) {
    return oldDelegate._controller != _controller;
  }
}
