import 'package:flutter/material.dart' hide Image;
import 'dart:ui';

class DrawImage extends CustomPainter {
  final Image image;
  final List<PaintHistory> paintHistory;
  final UpdatePoints update;
  final List<Offset> points;
  final bool isDragging;

  DrawImage(
      {this.image,
      this.isDragging = false,
      this.update,
      this.points,
      this.paintHistory});

  @override
  void paint(Canvas canvas, Size size) {
    paintImage(
        canvas: canvas,
        image: image,
        filterQuality: FilterQuality.high,
        rect: Rect.fromPoints(Offset(0, 0), Offset(size.width, size.height)));
    if (isDragging) {
      switch (update.mode) {
        case PaintMode.Box:
          canvas.drawRect(
              Rect.fromPoints(update.start, update.end), update.painter);
          break;
        case PaintMode.Line:
          canvas.drawLine(update.start, update.end, update.painter);
          break;
        case PaintMode.Circle:
          Path path = new Path();
          path.addOval(Rect.fromCircle(
              center: update.end,
              radius: (update.end - update.start).distance));
          canvas.drawPath(path, update.painter);
          break;
        case PaintMode.Arrow:
          drawArrow(canvas, update.start, update.end, update.painter);
          break;
        case PaintMode.DottedLine:
          Path path = Path()
            ..moveTo(update.start.dx, update.start.dy)
            ..lineTo(update.end.dx, update.end.dy);
          canvas.drawPath(
              _dashPath(path, update.painter.strokeWidth), update.painter);
          break;
        case PaintMode.FreeStyle:
          for (int i = 0; i < points.length - 1; i++) {
            if (points[i] != null && points[i + 1] != null) {
              canvas.drawLine(Offset(points[i].dx, points[i].dy),
                  Offset(points[i + 1].dx, points[i + 1].dy), update.painter);
            } else if (points[i] != null && points[i + 1] == null) {
              canvas.drawPoints(PointMode.points,
                  [Offset(points[i].dx, points[i].dy)], update.painter);
            }
          }
          break;
        default:
      }
    }
    for (var item in paintHistory) {
      switch (item.map.key) {
        case PaintMode.Box:
          canvas.drawRect(
              Rect.fromPoints(
                  item.map.value.offset[0], item.map.value.offset[1]),
              item.map.value.painter);
          break;
        case PaintMode.Line:
          canvas.drawLine(item.map.value.offset[0], item.map.value.offset[1],
              item.map.value.painter);
          break;
        case PaintMode.Circle:
          Path path = new Path();
          path.addOval(Rect.fromCircle(
              center: item.map.value.offset[1],
              radius: (item.map.value.offset[0] - item.map.value.offset[1])
                  .distance));
          canvas.drawPath(path, item.map.value.painter);
          break;
        case PaintMode.Arrow:
          drawArrow(canvas, item.map.value.offset[0], item.map.value.offset[1],
              item.map.value.painter);
          break;
        case PaintMode.DottedLine:
          Path path = Path()
            ..moveTo(item.map.value.offset[0].dx, item.map.value.offset[0].dy)
            ..lineTo(item.map.value.offset[1].dx, item.map.value.offset[1].dy);
          canvas.drawPath(_dashPath(path, item.map.value.painter.strokeWidth),
              item.map.value.painter);
          break;
        case PaintMode.FreeStyle:
          for (int i = 0; i < item.map.value.offset.length - 1; i++) {
            if (item.map.value.offset[i] != null &&
                item.map.value.offset[i + 1] != null) {
              canvas.drawLine(item.map.value.offset[i],
                  item.map.value.offset[i + 1], item.map.value.painter);
            } else if (item.map.value.offset[i] != null &&
                item.map.value.offset[i + 1] == null) {
              canvas.drawPoints(PointMode.points, [item.map.value.offset[i]],
                  item.map.value.painter);
            }
          }
          break;
        case PaintMode.Text:
          final textSpan = TextSpan(
            text: item.map.value.text,
            style: TextStyle(
                color: item.map.value.painter.color,
                fontSize: 12 * item.map.value.painter.strokeWidth / 2,
                fontWeight: FontWeight.bold),
          );
          final textPainter = TextPainter(
            text: textSpan,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout(
            minWidth: 0,
            maxWidth: size.width,
          );
          final textOffset = item.map.value.offset.length < 1
              ? Offset(size.width / 2 - textPainter.width / 2,
                  size.height / 2 - textPainter.height / 2)
              : Offset(item.map.value.offset[0].dx - textPainter.width / 2,
                  item.map.value.offset[0].dy - textPainter.height / 2);
          textPainter.paint(canvas, textOffset);
          break;
        default:
      }
    }
  }

  //Drawing arrowhead and line.
  void drawArrow(Canvas canvas, Offset start, Offset end, Paint painter) {
    Paint arrowPainter = Paint()
      ..color = painter.color
      ..strokeWidth = painter.strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawLine(start, end, painter);
    double _pathOffset = painter.strokeWidth / 15;
    var path = Path()
      ..lineTo(-15 * _pathOffset, 10 * _pathOffset)
      ..lineTo(-15 * _pathOffset, -10 * _pathOffset)
      ..close();
    canvas.save();
    canvas.translate(end.dx, end.dy);
    canvas.rotate((end - start).direction);
    canvas.drawPath(path, arrowPainter);
    canvas.restore();
  }

  //Drawing dashed path. It depends on [strokeWidth] for space to line proportion.
  Path _dashPath(Path path, double width) {
    Path dashPath = Path();
    double dashWidth = 10.0 * width / 5;
    double dashSpace = 10.0 * width / 5;
    double distance = 0.0;
    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth;
        distance += dashSpace;
      }
    }
    return dashPath;
  }

  @override
  bool shouldRepaint(DrawImage oldInfo) {
    return true;
  }
}

enum PaintMode { None, FreeStyle, Line, Box, Text, Arrow, Circle, DottedLine }

class PaintInfo {
  Paint painter;
  List<Offset> offset;
  String text;
  PaintInfo({this.offset, this.painter, this.text});
}

class UpdatePoints {
  Offset start;
  Offset end;
  Paint painter;
  PaintMode mode;
  UpdatePoints({this.start, this.end, this.painter, this.mode});
}

class PaintHistory {
  MapEntry<PaintMode, PaintInfo> map;
  PaintHistory(this.map);
}
