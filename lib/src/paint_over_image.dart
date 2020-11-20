import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart' hide Image;
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/services.dart';
import 'image_painter.dart';
export 'image_painter.dart';

class ImagePainter extends StatefulWidget {
  const ImagePainter._(
      {Key key,
      this.assetPath,
      this.networkUrl,
      this.image,
      this.file,
      this.height,
      this.width,
      this.controller,
      this.placeHolder,
      this.fit = BoxFit.contain,
      this.isScalable = false})
      : super(key: key);
  //Constructor for loading image from network url.
  factory ImagePainter.network(String url,
      {Key key,
      double height,
      double width,
      Widget placeholderWidget,
      BoxFit fit,
      bool scalable,
      @required Controller controller}) {
    return ImagePainter._(
        key: key,
        networkUrl: url,
        height: height,
        width: width,
        placeHolder: placeholderWidget,
        isScalable: scalable ?? false,
        fit: fit ?? BoxFit.contain,
        controller: Controller(
            strokeWidth: controller?.strokeWidth ?? 4.0,
            color: controller?.color ?? Colors.white,
            mode: controller?.mode ?? PaintMode.Line));
  }
  //Constructor for loading image from assetPath.
  factory ImagePainter.asset(String path,
      {Key key,
      double height,
      double width,
      BoxFit fit,
      bool scalable,
      Widget placeholderWidget,
      @required Controller controller}) {
    return ImagePainter._(
      key: key,
      assetPath: path,
      height: height,
      width: width,
      isScalable: scalable ?? false,
      fit: fit ?? BoxFit.contain,
      placeHolder: placeholderWidget,
      controller: Controller(
          strokeWidth: controller?.strokeWidth ?? 4.0,
          color: controller?.color ?? Colors.white,
          mode: controller?.mode ?? PaintMode.Line),
    );
  }
  //Constructor for loading image from file.
  factory ImagePainter.file(File file,
      {Key key,
      double height,
      double width,
      BoxFit fit,
      bool scalable,
      Widget placeholderWidget,
      @required Controller controller}) {
    return ImagePainter._(
        key: key,
        file: file,
        height: height,
        width: width,
        placeHolder: placeholderWidget,
        isScalable: scalable ?? false,
        fit: fit ?? BoxFit.contain,
        controller: Controller(
            strokeWidth: controller?.strokeWidth ?? 4.0,
            color: controller?.color ?? Colors.white,
            mode: controller?.mode ?? PaintMode.Line));
  }
  //Constructor for loading image from memory.
  factory ImagePainter.memory(ui.Image image,
      {Key key,
      double height,
      double width,
      BoxFit fit,
      bool scalable,
      Widget placeholderWidget,
      @required Controller controller}) {
    return ImagePainter._(
        key: key,
        image: image,
        height: height,
        width: width,
        placeHolder: placeholderWidget,
        isScalable: scalable ?? false,
        fit: fit ?? BoxFit.contain,
        controller: Controller(
            strokeWidth: controller?.strokeWidth ?? 4.0,
            color: controller?.color ?? Colors.white,
            mode: controller?.mode ?? PaintMode.Line));
  }
  //Only accessible through [Image.Network] constructor.
  final String networkUrl;
  //Only accessible through [Image.image] constructor.
  final ui.Image image;
  //Only accessible through [Image.file] constructor.
  final File file;
  //Only accessible through [Image.asset] constructor.
  final String assetPath;
  //Height of the Widget. Image is subjected to fit within the given height.
  final double height;
  //Width of the widget. Image is subjected to fit within the given width.
  final double width;
  //Widget to be shown during the rendering and conversion of image.
  final Widget placeHolder;
  //Controller has properties like color and strokewidth required for the painter.
  final Controller controller;
  //Defines whether the widget should be scaled or not. Defaults to [false].
  final bool isScalable;
  //Defines the fit type of the image inside fittedbox. Defaults to [BoxFit.contain].
  final BoxFit fit;

  @override
  ImagePainterState createState() => ImagePainterState();
}

class ImagePainterState extends State<ImagePainter> {
  ui.Image _image;
  bool _isLoaded = false;
  Color _color;
  PaintMode _mode;
  Paint get _painter => Paint()
    ..color = _color
    ..strokeWidth = _strokeWidth
    ..style = PaintingStyle.stroke;
  List<PaintHistory> paintHistory = List<PaintHistory>();
  List<Offset> points = List<Offset>();
  Offset start;
  Offset end;
  bool inDrag = false;
  double _strokeWidth;
  int pointer = 0;
  @override
  void initState() {
    super.initState();
    _resolveAndConvertImage();
    _strokeWidth = widget.controller.strokeWidth;
    _color = widget.controller.color;
    _mode = widget.controller.mode;
  }

  @override
  void didUpdateWidget(ImagePainter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller.color != widget.controller.color ||
        oldWidget.controller.strokeWidth != widget.controller.strokeWidth ||
        oldWidget.controller.mode != widget.controller.mode) {
      setState(() {
        _color = widget.controller.color;
        _strokeWidth = widget.controller.strokeWidth;
        _mode = widget.controller.mode;
      });
    }
  }

  _resolveAndConvertImage() async {
    if (widget.networkUrl != null) {
      _image = await loadNetworkImage(widget.networkUrl);
    } else if (widget.assetPath != null) {
      ByteData img = await rootBundle.load(widget.assetPath);
      _image = await convertImage(Uint8List.view(img.buffer));
    } else if (widget.file != null) {
      Uint8List img = await widget.file.readAsBytes();
      _image = await convertImage(img);
    } else {
      _isLoaded = true;
      _image = widget.image;
    }
  }

  //Completer function to convert asset or file image to [ui.image] before drawing on custompainter.
  Future<ui.Image> convertImage(List<int> img) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      setState(() {
        _isLoaded = true;
      });
      return completer.complete(img);
    });
    return completer.future;
  }

  //Completer function to convert network image to [ui.image] before drawing on custompainter.
  Future<ui.Image> loadNetworkImage(String path) async {
    Completer<ImageInfo> completer = Completer();
    var img = new NetworkImage(path);
    img
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info);
    }));
    ImageInfo imageInfo = await completer.future;
    setState(() {
      _isLoaded = true;
    });
    return imageInfo.image;
  }

  @override
  Widget build(BuildContext context) {
    if (this._isLoaded) {
      return _paintImage();
    } else {
      return widget.placeHolder ??
          Container(
            height: widget.height ?? double.maxFinite,
            width: widget.width ?? double.maxFinite,
            child: Center(
                child: widget.placeHolder ?? CircularProgressIndicator()),
          );
    }
  }

  Widget _paintImage() {
    return Container(
      height: widget.height ?? double.maxFinite,
      width: widget.width ?? double.maxFinite,
      child: FittedBox(
        alignment: FractionalOffset.center,
        child: Listener(
          onPointerDown: (event) => pointer++,
          onPointerUp: (event) => pointer = 0,
          child: InteractiveViewer(
            panEnabled: false,
            minScale: 0.4,
            maxScale: 2.4,
            scaleEnabled: widget.isScalable,
            onInteractionUpdate: _scaleUpdateGesture,
            onInteractionEnd: _scaleEndGesture,
            child: CustomPaint(
              size: Size(_image.width.toDouble(), _image.height.toDouble()),
              willChange: true,
              painter: DrawImage(
                image: _image,
                points: points,
                paintHistory: paintHistory,
                isDragging: inDrag,
                update: UpdatePoints(
                    start: start, end: end, painter: _painter, mode: _mode),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _scaleUpdateGesture(ScaleUpdateDetails onUpdate) {
    if (pointer < 2) {
      setState(() {
        inDrag = true;
        if (start == null) {
          start = onUpdate.focalPoint;
        }
        end = onUpdate.focalPoint;
        if (_mode == PaintMode.FreeStyle) {
          points.add(end);
        } else if (_mode == PaintMode.Text &&
            paintHistory.any((element) => element.map.value.text != null)) {
          paintHistory
              .lastWhere((element) => element.map.value.text != null)
              .map
              .value
              .offset = [end];
        }
      });
    }
  }

  void _scaleEndGesture(ScaleEndDetails onEnd) {
    if (pointer < 2) {
      setState(() {
        inDrag = false;
        if (_mode == PaintMode.None) {
        } else if (start != null &&
            end != null &&
            _mode != PaintMode.FreeStyle) {
          addEndPoints(start, end);
        } else if (start != null &&
            end != null &&
            _mode == PaintMode.FreeStyle) {
          points.add(null);
          addFreeStylePoints();
        }
        start = null;
        end = null;
      });
      points.clear();
    }
  }

  void addEndPoints(dx, dy) {
    paintHistory.add(
      PaintHistory(
        MapEntry<PaintMode, PaintInfo>(
          _mode,
          PaintInfo(offset: [dx, dy], painter: _painter),
        ),
      ),
    );
  }

  void addFreeStylePoints() {
    paintHistory.add(PaintHistory(
      MapEntry<PaintMode, PaintInfo>(
        _mode,
        PaintInfo(offset: List<Offset>()..addAll(points), painter: _painter),
      ),
    ));
  }

  Future<ui.Image> renderImage() async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    DrawImage painter = DrawImage(image: _image, paintHistory: paintHistory);
    var size = Size(_image.width.toDouble(), _image.height.toDouble());
    painter.paint(canvas, size);
    return recorder
        .endRecording()
        .toImage(size.width.floor(), size.height.floor());
  }

  Future<Uint8List> exportImage() async {
    ui.Image image = await renderImage();
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData.buffer.asUint8List();
  }

  void undo() {
    if (paintHistory.length > 0)
      setState(() {
        paintHistory.removeLast();
      });
  }

  void clearAll() {
    setState(() {
      paintHistory.clear();
    });
  }
}

class Controller extends ChangeNotifier {
  double strokeWidth;
  Color color;
  PaintMode mode;
  PaintHistory paintHistory;

  Controller(
      {this.color = Colors.red,
      this.strokeWidth = 4.0,
      this.mode = PaintMode.Line});
  undo() {}
  clear() {}
}
