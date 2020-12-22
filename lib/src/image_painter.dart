import 'dart:ui';
import 'package:flutter/material.dart' hide Image;

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

  ///Keeps track whether the paint action is running or not.
  final bool isDragging;

  final bool isSignature;

  final Color backgroundColor;

  DrawImage(
      {this.image,
      this.isDragging = false,
      this.update,
      this.points,
      this.isSignature = false,
      this.backgroundColor,
      this.paintHistory});

  @override
  void paint(Canvas canvas, Size size) {
    if (isSignature) {
      canvas.drawRect(
          Rect.fromPoints(Offset(0, 0), Offset(size.width, size.height)),
          Paint()
            ..style = PaintingStyle.fill
            ..color = backgroundColor);
    } else {
      ///paints [ui.Image] on the canvas for reference to draw over it.
      paintImage(
          canvas: canvas,
          image: image,
          filterQuality: FilterQuality.high,
          rect: Rect.fromPoints(Offset(0, 0), Offset(size.width, size.height)));
    }

    ///paints all the previoud paintInfo history recorded on [PaintHistory]
    for (var item in paintHistory) {
      final _offset = item.map.value.offset;
      final _painter = item.map.value.painter;
      switch (item.map.key) {
        case PaintMode.Box:
          canvas.drawRect(Rect.fromPoints(_offset[0], _offset[1]), _painter);
          break;
        case PaintMode.Line:
          canvas.drawLine(_offset[0], _offset[1], _painter);
          break;
        case PaintMode.Circle:
          Path path = new Path();
          path.addOval(Rect.fromCircle(
              center: _offset[1], radius: (_offset[0] - _offset[1]).distance));
          canvas.drawPath(path, _painter);
          break;
        case PaintMode.Arrow:
          drawArrow(canvas, _offset[0], _offset[1], _painter);
          break;
        case PaintMode.DottedLine:
          Path path = Path()
            ..moveTo(_offset[0].dx, _offset[0].dy)
            ..lineTo(_offset[1].dx, _offset[1].dy);
          canvas.drawPath(_dashPath(path, _painter.strokeWidth), _painter);
          break;
        case PaintMode.FreeStyle:
          for (int i = 0; i < _offset.length - 1; i++) {
            if (_offset[i] != null && _offset[i + 1] != null) {
              Path _path = Path()
                ..moveTo(_offset[i].dx, _offset[i].dy)
                ..lineTo(_offset[i + 1].dx, _offset[i + 1].dy);
              canvas.drawPath(_path, _painter);
            } else if (_offset[i] != null && _offset[i + 1] == null) {
              canvas.drawPoints(
                  PointMode.points, [_offset[i]], item.map.value.painter);
            }
          }
          break;
        case PaintMode.Text:
          final textSpan = TextSpan(
            text: item.map.value.text,
            style: TextStyle(
                color: _painter.color,
                fontSize: 12 * _painter.strokeWidth / 2,
                fontWeight: FontWeight.bold),
          );
          final textPainter = TextPainter(
            text: textSpan,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout(minWidth: 0, maxWidth: size.width);
          final textOffset = _offset.length < 1
              ? Offset(size.width / 2 - textPainter.width / 2,
                  size.height / 2 - textPainter.height / 2)
              : Offset(_offset[0].dx - textPainter.width / 2,
                  _offset[0].dy - textPainter.height / 2);
          textPainter.paint(canvas, textOffset);
          break;
        default:
      }
    }

    ///Draws ongoing action on the canvas while indrag.
    if (isDragging) {
      final _start = update.start;
      final _end = update.end;
      final _painter = update.painter;
      switch (update.mode) {
        case PaintMode.Box:
          canvas.drawRect(Rect.fromPoints(_start, _end), _painter);
          break;
        case PaintMode.Line:
          canvas.drawLine(_start, _end, _painter);
          break;
        case PaintMode.Circle:
          Path path = new Path();
          path.addOval(
              Rect.fromCircle(center: _end, radius: (_end - _start).distance));
          canvas.drawPath(path, _painter);
          break;
        case PaintMode.Arrow:
          drawArrow(canvas, _start, _end, _painter);
          break;
        case PaintMode.DottedLine:
          Path path = Path()
            ..moveTo(_start.dx, _start.dy)
            ..lineTo(_end.dx, _end.dy);
          canvas.drawPath(_dashPath(path, _painter.strokeWidth), _painter);
          break;
        case PaintMode.FreeStyle:
          for (int i = 0; i < points.length - 1; i++) {
            if (points[i] != null && points[i + 1] != null) {
              canvas.drawLine(Offset(points[i].dx, points[i].dy),
                  Offset(points[i + 1].dx, points[i + 1].dy), _painter);
            } else if (points[i] != null && points[i + 1] == null) {
              canvas.drawPoints(PointMode.points,
                  [Offset(points[i].dx, points[i].dy)], _painter);
            }
          }
          break;
        default:
      }
    }

    ///Draws all the completed actions of painting on the canvas.
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
    return (oldInfo.update != update ||
        oldInfo.paintHistory.length == paintHistory.length);
  }
}

///All the paint method available for use.

enum PaintMode {
  ///Prefer using [None] while doing scaling operations.
  None,

  ///Allows for drawing freehand shapes or text.
  FreeStyle,

  ///Allows to draw line between two points.
  Line,

  ///Allows to draw rectangle.
  Box,

  ///Allows to write texts over an image.
  Text,

  ///Allows us to draw line with arrow at the end point.
  Arrow,

  ///Allows to draw circle from a point.
  Circle,

  ///Allows to draw dashed line between two point.
  DottedLine
}

///[PaintInfo] keeps track of a single unit of shape, whichever selected.
class PaintInfo {
  ///Used to save specific paint utils used for the specific shape.
  Paint painter;

  ///Used to save offsets. two point in case of other shapes and list of points for [FreeStyle].
  List<Offset> offset;

  ///Used to save text in case of text type.
  String text;

  ///In case of string, it is used to save string value entered.
  PaintInfo({this.offset, this.painter, this.text});
}

///Records realtime updates of ongoing [PaintInfo] when inDrag.
class UpdatePoints {
  Offset start;
  Offset end;
  Paint painter;
  PaintMode mode;
  UpdatePoints({this.start, this.end, this.painter, this.mode});

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is UpdatePoints &&
        o.start == start &&
        o.end == end &&
        o.painter == painter &&
        o.mode == mode;
  }

  @override
  int get hashCode {
    return start.hashCode ^ end.hashCode ^ painter.hashCode ^ mode.hashCode;
  }
}

///Records the [PaintMode] as well as [PaintInfo] of that particular [PaintMode] in a map.
class PaintHistory {
  MapEntry<PaintMode, PaintInfo> map;
  PaintHistory(this.map);
}
