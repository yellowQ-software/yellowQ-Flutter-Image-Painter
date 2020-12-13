import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/rendering.dart';
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
      this.isScalable = false,
      this.isSignature = false,
      this.signatureBackgroundColor})
      : super(key: key);

  ///Constructor for loading image from network url.
  factory ImagePainter.network(String url,
      {Key key,
      double height,
      double width,
      Widget placeholderWidget,
      bool scalable,
      @required Controller controller}) {
    return ImagePainter._(
        key: key,
        networkUrl: url,
        height: height,
        width: width,
        placeHolder: placeholderWidget,
        isScalable: scalable ?? false,
        controller: Controller(
            strokeWidth: controller?.strokeWidth ?? 4.0,
            color: controller?.color ?? Colors.white,
            mode: controller?.mode ?? PaintMode.Line));
  }

  ///Constructor for loading image from assetPath.
  factory ImagePainter.asset(String path,
      {Key key,
      double height,
      double width,
      bool scalable,
      Widget placeholderWidget,
      @required Controller controller}) {
    return ImagePainter._(
      key: key,
      assetPath: path,
      height: height,
      width: width,
      isScalable: scalable ?? false,
      placeHolder: placeholderWidget,
      controller: Controller(
          strokeWidth: controller?.strokeWidth ?? 4.0,
          color: controller?.color ?? Colors.white,
          mode: controller?.mode ?? PaintMode.Line),
    );
  }

  ///Constructor for loading image from file.
  factory ImagePainter.file(File file,
      {Key key,
      double height,
      double width,
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
        controller: Controller(
            strokeWidth: controller?.strokeWidth ?? 4.0,
            color: controller?.color ?? Colors.white,
            mode: controller?.mode ?? PaintMode.Line));
  }

  ///Constructor for loading image from memory.
  factory ImagePainter.memory(ui.Image image,
      {Key key,
      double height,
      double width,
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
        controller: Controller(
            strokeWidth: controller?.strokeWidth ?? 4.0,
            color: controller?.color ?? Colors.white,
            mode: controller?.mode ?? PaintMode.Line));
  }

  ///Constructor for signature painting.
  factory ImagePainter.signature({
    Key key,
    Color signatureBgColor,
    double height,
    double width,
    @required Controller controller,
  }) {
    return ImagePainter._(
        key: key,
        height: height,
        width: width,
        isSignature: true,
        signatureBackgroundColor: signatureBgColor ?? Colors.white,
        controller: Controller(
            strokeWidth: controller?.strokeWidth ?? 4.0,
            color: controller?.color ?? Colors.black,
            mode: PaintMode.FreeStyle));
  }

  ///Only accessible through [ImagePainter.network] constructor.
  final String networkUrl;

  ///Only accessible through [ImagePainter.memory] constructor.
  final ui.Image image;

  ///Only accessible through [ImagePainter.file] constructor.
  final File file;

  ///Only accessible through [ImagePainter.asset] constructor.
  final String assetPath;

  ///Height of the Widget. Image is subjected to fit within the given height.
  final double height;

  ///Width of the widget. Image is subjected to fit within the given width.
  final double width;

  ///Widget to be shown during the conversion of provided image to [ui.Image].
  final Widget placeHolder;

  ///Controller has properties like [Color] and [strokeWidth] required for the painter.
  final Controller controller;

  ///Defines whether the widget should be scaled or not. Defaults to [false].
  final bool isScalable;

  final bool isSignature;

  final Color signatureBackgroundColor;

  @override
  ImagePainterState createState() => ImagePainterState();
}

class ImagePainterState extends State<ImagePainter> {
  final _repaintKey = GlobalKey();
  ui.Image _image;
  bool _isLoaded = false, inDrag = false;
  PaintMode _mode;
  Color _color;
  double _strokeWidth;
  Paint get _painter => Paint()
    ..color = _color
    ..strokeWidth = _strokeWidth
    ..style = PaintingStyle.stroke;
  List<PaintHistory> paintHistory = List<PaintHistory>();
  List<Offset> points = List<Offset>();
  Offset start, end;
  int pointer = 0;
  @override
  void initState() {
    super.initState();
    _resolveAndConvertImage();
    _mode = widget.controller.mode;
    _color = widget.controller.color;
    _strokeWidth = widget.controller.strokeWidth;
  }

  @override
  void didUpdateWidget(ImagePainter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller.color != widget.controller.color ||
        oldWidget.controller.mode != widget.controller.mode ||
        oldWidget.controller.strokeWidth != widget.controller.strokeWidth) {
      setState(() {
        _color = widget.controller.color;
        _mode = widget.controller.mode;
        _strokeWidth = widget.controller.strokeWidth;
      });
    }
  }

  ///Converts the incoming image type from constructor to [ui.Image]
  _resolveAndConvertImage() async {
    if (widget.networkUrl != null) {
      _image = await loadNetworkImage(widget.networkUrl);
    } else if (widget.assetPath != null) {
      ByteData img = await rootBundle.load(widget.assetPath);
      _image = await convertImage(Uint8List.view(img.buffer));
    } else if (widget.file != null) {
      Uint8List img = await widget.file.readAsBytes();
      _image = await convertImage(img);
    } else if (widget.image != null) {
      _isLoaded = true;
      _image = widget.image;
    } else {
      _isLoaded = true;
    }
  }

  ///Completer function to convert asset or file image to [ui.Image] before drawing on custompainter.
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

  ///Completer function to convert network image to [ui.Image] before drawing on custompainter.
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
      return widget.isSignature ? _paintSignature() : _paintImage();
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

  ///paints image on given constrains for drawing if image is not null.
  Widget _paintImage() {
    return Container(
      height: widget.height ?? double.maxFinite,
      width: widget.width ?? double.maxFinite,
      child: FittedBox(
        alignment: FractionalOffset.center,
        child: Listener(
          onPointerDown: (event) => pointer++,
          onPointerUp: (event) => pointer = 0,
          child: ClipRect(
            child: InteractiveViewer(
              maxScale: 2.4,
              panEnabled: false,
              minScale: 0.4,
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
      ),
    );
  }

  Widget _paintSignature() {
    return RepaintBoundary(
      key: _repaintKey,
      child: ClipRect(
        child: Container(
          width: widget.width ?? double.maxFinite,
          height: widget.height ?? double.maxFinite,
          child: InteractiveViewer(
            panEnabled: false,
            scaleEnabled: false,
            onInteractionUpdate: _scaleUpdateGesture,
            onInteractionEnd: _scaleEndGesture,
            child: CustomPaint(
              willChange: true,
              painter: DrawImage(
                isSignature: true,
                backgroundColor: widget.signatureBackgroundColor,
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

  ///Fires while user is interacting with the screen to record painting.
  void _scaleUpdateGesture(ScaleUpdateDetails onUpdate) {
    if (pointer < 2) {
      setState(() {
        inDrag = true;
        if (start == null) {
          start = onUpdate.focalPoint;
        }
        end = onUpdate.focalPoint;
        if (_mode == PaintMode.FreeStyle || widget.isSignature) {
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

  ///Fires when user stops interacting with the screen.
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
                _mode == PaintMode.FreeStyle ||
            widget.isSignature) {
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
    if (widget.isSignature) {
      paintHistory.add(PaintHistory(
        MapEntry<PaintMode, PaintInfo>(
          PaintMode.FreeStyle,
          PaintInfo(
              offset: List<Offset>()..addAll(points),
              painter: Paint()
                ..color = _color
                ..strokeWidth = _strokeWidth),
        ),
      ));
    } else {
      paintHistory.add(PaintHistory(
        MapEntry<PaintMode, PaintInfo>(
          _mode,
          PaintInfo(offset: List<Offset>()..addAll(points), painter: _painter),
        ),
      ));
    }
  }

  ///Provides [ui.Image] of the recorded canvas to perform action.
  Future<ui.Image> renderImage() async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    DrawImage painter = DrawImage(
        image: _image,
        backgroundColor: widget.signatureBackgroundColor,
        paintHistory: paintHistory,
        isSignature: widget.isSignature);
    Size size = widget.isSignature
        ? Size(widget.width ?? MediaQuery.of(context).size.width,
            widget.height ?? MediaQuery.of(context).size.height)
        : Size(_image.width.toDouble(), _image.height.toDouble());
    painter.paint(canvas, size);
    return recorder
        .endRecording()
        .toImage(size.width.floor(), size.height.floor());
  }

  ///Generates [Uint8List] of the [ui.Image] generated by the [renderImage()] method.
  ///Can be converted to image file by writing as bytes.
  Future<Uint8List> exportImage() async {
    ui.Image _image;
    if (widget.isSignature) {
      RenderRepaintBoundary _boundary =
          _repaintKey.currentContext.findRenderObject();
      _image = await _boundary.toImage(pixelRatio: 3);
    } else {
      _image = await renderImage();
    }
    ByteData byteData = await _image.toByteData(format: ui.ImageByteFormat.png);
    return byteData.buffer.asUint8List();
  }

  ///Cancels or removes the last [PaintHistory].
  void undo() {
    if (paintHistory.length > 0)
      setState(() {
        paintHistory.removeLast();
      });
  }

  ///Cancels or clears all the previous [PaintHistory].
  void clearAll() {
    setState(() {
      paintHistory.clear();
    });
  }
}

///Gives access to manipulate the essential components like [strokeWidth], [Color] and [PaintMode].
class Controller {
  ///Tracks [strokeWidth] of the [Paint] class.
  double strokeWidth;

  ///Tracks [Color] of the [Paint] class.
  Color color;

  ///Tracks [PaintMode] of the current paint method.
  PaintMode mode;

  ///Constructor of the [Controller] class.
  Controller(
      {this.color = Colors.red,
      this.strokeWidth = 4.0,
      this.mode = PaintMode.Line});
}
