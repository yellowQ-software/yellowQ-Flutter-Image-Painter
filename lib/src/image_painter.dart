import 'package:flutter/material.dart' hide Image;
import 'dart:ui';

///Handles all the painting ongoing on the canvas.
class DrawImage extends CustomPainter {
  ///Converted image from [ImagePainter] constructor.
  final Image image;

  ///Keeps track of all the units of [PaintHistory].
  final List<PaintHistory> paintHistory;

  ///Keeps track of points on currently drawing state.
  final UpdatePoints update;

  ///Keeps track of freestyle points on currently drawing state.
  final List<Offset> points;

  ///Keeps track whether the paint action is running or not.F
  final bool isDragging;

  DrawImage(
      {this.image,
      this.isDragging = false,
      this.update,
      this.points,
      this.paintHistory});

  @override
  void paint(Canvas canvas, Size size) {
    ///paints [Image] on the canvas for reference to draw over it.
    paintImage(
        canvas: canvas,
        image: image,
        filterQuality: FilterQuality.high,
        rect: Rect.fromPoints(Offset(0, 0), Offset(size.width, size.height)));

    ///Draws ongoing action on the canvas.
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

    ///Draws all the completed actions of painting on the canvas.
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

  ///Draws line as well as the arrowhead on top of it.
  ///Uses [strokeWidth] of the painter for sizing.
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

  ///Draws dashed path.
  ///It depends on [strokeWidth] for space to line proportion.
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

///All the paint method available for use.
///Prefer using [None] while doing scaling operations.
///[FreeStyle] allows for drawing freehand shapes or text.
///[Line] allows to draw line between two points.
///[Box] or rectangle allows to draw rectangle.
///[Arrow] allows us to draw line with arrow at the end point.
///[Circle] allows to draw circle from a point.
///[DottedLine] allows to draw dashed line between two point.
enum PaintMode { None, FreeStyle, Line, Box, Text, Arrow, Circle, DottedLine }

///[PaintInfo] keeps track of a single unit of shape, whichever selected.
class PaintInfo {
  ///Used to save specific paint utils used for the specific shape.
  Paint painter;

  ///Used to save offsets. two point in case of other shapes and list of points for [FreeStyle].
  List<Offset> offset;

  String text;

  ///In case of string, it is used to save string value entered.
  PaintInfo({this.offset, this.painter, this.text});
}

class UpdatePoints {
  Offset start;
  Offset end;
  Paint painter;
  PaintMode mode;
  UpdatePoints({this.start, this.end, this.painter, this.mode});
}

///[PaintHistory] records the [PaintMode] as well as [PaintInfo] of that particular [PaintMode] in a map.
class PaintHistory {
  MapEntry<PaintMode, PaintInfo> map;
  PaintHistory(this.map);
}
