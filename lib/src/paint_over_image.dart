import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide Image;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'image_painter.dart';
import 'ported_interactive_viewer.dart';

export 'image_painter.dart';

@immutable
class ImagePainter extends StatefulWidget {
  const ImagePainter._(
      {Key key,
      this.assetPath,
      this.networkUrl,
      this.byteArray,
      this.file,
      this.height,
      this.width,
      this.controller,
      this.placeHolder,
      this.isScalable,
      this.isSignature = false,
      this.signatureBackgroundColor})
      : super(key: key);

  ///Constructor for loading image from network url.
  factory ImagePainter.network(
    String url, {
    @required Controller controller,
    @required Key key,
    double height,
    double width,
    Widget placeholderWidget,
    bool scalable,
  }) {
    return ImagePainter._(
        key: key,
        networkUrl: url,
        height: height,
        width: width,
        placeHolder: placeholderWidget,
        isScalable: scalable ?? false,
        controller: controller);
  }

  ///Constructor for loading image from assetPath.
  factory ImagePainter.asset(
    String path, {
    @required Controller controller,
    @required Key key,
    double height,
    double width,
    bool scalable,
    Widget placeholderWidget,
  }) {
    return ImagePainter._(
        key: key,
        assetPath: path,
        height: height,
        width: width,
        isScalable: scalable ?? false,
        placeHolder: placeholderWidget,
        controller: controller);
  }

  ///Constructor for loading image from [File].
  factory ImagePainter.file(
    File file, {
    @required Controller controller,
    @required Key key,
    double height,
    double width,
    bool scalable,
    Widget placeholderWidget,
  }) {
    return ImagePainter._(
        key: key,
        file: file,
        height: height,
        width: width,
        placeHolder: placeholderWidget,
        isScalable: scalable ?? false,
        controller: controller);
  }

  ///Constructor for loading image from memory.
  factory ImagePainter.memory(
    Uint8List byteArray, {
    @required Controller controller,
    @required Key key,
    double height,
    double width,
    bool scalable,
    Widget placeholderWidget,
  }) {
    return ImagePainter._(
        key: key,
        byteArray: byteArray,
        height: height,
        width: width,
        placeHolder: placeholderWidget,
        isScalable: scalable ?? false,
        controller: controller);
  }

  ///Constructor for signature painting.
  factory ImagePainter.signature({
    @required Controller controller,
    @required Key key,
    Color signatureBgColor,
    double height,
    double width,
  }) {
    return ImagePainter._(
        key: key,
        height: height,
        width: width,
        isSignature: true,
        isScalable: false,
        signatureBackgroundColor: signatureBgColor ?? Colors.white,
        controller: controller.copyWith(mode: PaintMode.FreeStyle));
  }

  ///Only accessible through [ImagePainter.network] constructor.
  final String networkUrl;

  ///Only accessible through [ImagePainter.memory] constructor.
  final Uint8List byteArray;

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
  final _isLoaded = ValueNotifier<bool>(false);
  bool _inDrag = false;
  final _controller = ValueNotifier<Controller>(null);
  final _paintHistory = <PaintHistory>[];
  final _points = <Offset>[];
  Offset _start, _end;
  int _strokeMultiplier = 1;
  @override
  void initState() {
    super.initState();
    _resolveAndConvertImage();
    _controller.value = widget.controller;
  }

  @override
  void didUpdateWidget(ImagePainter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.value = _controller.value.copyWith(
          color: widget.controller.color,
          strokeWidth: widget.controller.strokeWidth,
          mode: widget.controller.mode,
          paintingStyle: widget.controller.paintStyle);
    }
  }

  Paint get _painter => Paint()
    ..color = _controller.value.color
    ..strokeWidth = _controller.value.strokeWidth * _strokeMultiplier
    ..style = _controller.value.mode == PaintMode.DottedLine
        ? PaintingStyle.stroke
        : _controller.value.paintStyle;

  ///Converts the incoming image type from constructor to [ui.Image]
  Future<void> _resolveAndConvertImage() async {
    if (widget.networkUrl != null) {
      _image = await _loadNetworkImage(widget.networkUrl);
      if (_image == null) {
        throw ("${widget.networkUrl} couldn't be resolved.");
      } else {
        _setStrokeMultiplier();
      }
    } else if (widget.assetPath != null) {
      final img = await rootBundle.load(widget.assetPath);
      _image = await _convertImage(Uint8List.view(img.buffer));
      if (_image == null) {
        throw ("${widget.assetPath} couldn't be resolved.");
      } else {
        _setStrokeMultiplier();
      }
    } else if (widget.file != null) {
      final img = await widget.file.readAsBytes();
      _image = await _convertImage(img);
      if (_image == null) {
        throw ("Image couldn't be resolved from provided file.");
      } else {
        _setStrokeMultiplier();
      }
    } else if (widget.byteArray != null) {
      _image = await _convertImage(widget.byteArray);
      if (_image == null) {
        throw ("Image couldn't be resolved from provided byteArray.");
      } else {
        _setStrokeMultiplier();
      }
    } else {
      _isLoaded.value = true;
    }
  }

  _setStrokeMultiplier() {
    if ((_image.height + _image.width) > 1000) {
      _strokeMultiplier = (_image.height + _image.width) ~/ 1000;
    }
  }

  ///Completer function to convert asset or file image to [ui.Image] before drawing on custompainter.
  Future<ui.Image> _convertImage(Uint8List img) async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(img, (image) {
      _isLoaded.value = true;
      return completer.complete(image);
    });
    return completer.future;
  }

  ///Completer function to convert network image to [ui.Image] before drawing on custompainter.
  Future<ui.Image> _loadNetworkImage(String path) async {
    final completer = Completer<ImageInfo>();
    var img = NetworkImage(path);
    img.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((info, _) => completer.complete(info)));
    final imageInfo = await completer.future;
    _isLoaded.value = true;
    return imageInfo.image;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoaded,
      builder: (_, loaded, __) {
        if (loaded) {
          return widget.isSignature ? _paintSignature() : _paintImage();
        } else {
          return Container(
            height: widget.height ?? double.maxFinite,
            width: widget.width ?? double.maxFinite,
            child: Center(
              child: widget.placeHolder ?? const CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  ///paints image on given constrains for drawing if image is not null.
  Widget _paintImage() {
    return Container(
      height: widget.height ?? double.maxFinite,
      width: widget.width ?? double.maxFinite,
      child: FittedBox(
        alignment: FractionalOffset.center,
        child: ClipRect(
          child: ValueListenableBuilder<Controller>(
            valueListenable: _controller,
            builder: (_, controller, __) {
              return ImagePainterTransformer(
                maxScale: 2.4,
                minScale: 1,
                panEnabled: controller.mode == PaintMode.None,
                scaleEnabled: widget.isScalable,
                onInteractionUpdate: (details) =>
                    _scaleUpdateGesture(details, controller),
                onInteractionEnd: (details) =>
                    _scaleEndGesture(details, controller),
                child: CustomPaint(
                  size: Size(_image.width.toDouble(), _image.height.toDouble()),
                  willChange: true,
                  isComplex: true,
                  painter: DrawImage(
                    image: _image,
                    points: _points,
                    paintHistory: _paintHistory,
                    isDragging: _inDrag,
                    update: UpdatePoints(
                        start: _start,
                        end: _end,
                        painter: _painter,
                        mode: controller.mode),
                  ),
                ),
              );
            },
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
          child: ValueListenableBuilder<Controller>(
            valueListenable: _controller,
            builder: (_, controller, __) {
              return ImagePainterTransformer(
                  panEnabled: false,
                  scaleEnabled: false,
                  onInteractionUpdate: (details) =>
                      _scaleUpdateGesture(details, controller),
                  onInteractionEnd: (details) =>
                      _scaleEndGesture(details, controller),
                  child: CustomPaint(
                    willChange: true,
                    isComplex: true,
                    painter: DrawImage(
                      isSignature: true,
                      backgroundColor: widget.signatureBackgroundColor,
                      points: _points,
                      paintHistory: _paintHistory,
                      isDragging: _inDrag,
                      update: UpdatePoints(
                          start: _start,
                          end: _end,
                          painter: _painter,
                          mode: controller.mode),
                    ),
                  ));
            },
          ),
        ),
      ),
    );
  }

  ///Fires while user is interacting with the screen to record painting.
  void _scaleUpdateGesture(ScaleUpdateDetails onUpdate, Controller controller) {
    setState(() {
      _inDrag = true;
      _start ??= onUpdate.focalPoint;
      _end = onUpdate.focalPoint;
      if (controller.mode == PaintMode.FreeStyle || widget.isSignature) {
        _points.add(_end);
      } else if (controller.mode == PaintMode.Text &&
          _paintHistory.any((element) => element.map.value.text != null)) {
        _paintHistory
            .lastWhere((element) => element.map.value.text != null)
            .map
            .value
            .offset = [_end];
      }
    });
  }

  ///Fires when user stops interacting with the screen.
  void _scaleEndGesture(ScaleEndDetails onEnd, Controller controller) {
    setState(() {
      _inDrag = false;
      if (controller.mode == PaintMode.None) {
      } else if (_start != null &&
          _end != null &&
          controller.mode != PaintMode.FreeStyle) {
        _addEndPoints(_start, _end, controller);
      } else if (_start != null &&
              _end != null &&
              controller.mode == PaintMode.FreeStyle ||
          widget.isSignature) {
        _points.add(null);
        _addFreeStylePoints(controller);
      } else {}
      _start = null;
      _end = null;
    });
    _points.clear();
  }

  void _addEndPoints(Offset dx, Offset dy, Controller controller) {
    _paintHistory.add(
      PaintHistory(
        MapEntry<PaintMode, PaintInfo>(
          controller.mode,
          PaintInfo(offset: [dx, dy], painter: _painter),
        ),
      ),
    );
  }

  void _addFreeStylePoints(Controller controller) {
    _paintHistory.add(
      PaintHistory(
        MapEntry<PaintMode, PaintInfo>(
          widget.isSignature ? PaintMode.FreeStyle : controller.mode,
          PaintInfo(offset: <Offset>[..._points], painter: _painter),
        ),
      ),
    );
  }

  ///Provides [ui.Image] of the recorded canvas to perform action.
  Future<ui.Image> _renderImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final painter = DrawImage(image: _image, paintHistory: _paintHistory);
    final size = Size(_image.width.toDouble(), _image.height.toDouble());
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
      final _boundary = _repaintKey.currentContext.findRenderObject()
          as RenderRepaintBoundary;
      _image = await _boundary.toImage(pixelRatio: 3);
    } else if (widget.byteArray != null && _paintHistory.isEmpty) {
      return widget.byteArray;
    } else {
      _image = await _renderImage();
    }
    final byteData = await _image.toByteData(format: ui.ImageByteFormat.png);
    return byteData.buffer.asUint8List();
  }

  ///Cancels or removes the last [PaintHistory].
  void undo() {
    if (_paintHistory.isNotEmpty) {
      setState(_paintHistory.removeLast);
    }
  }

  ///Cancels or clears all the previous [PaintHistory].
  void clearAll() {
    setState(_paintHistory.clear);
  }
}

///Gives access to manipulate the essential components like [strokeWidth], [Color] and [PaintMode].
@immutable
class Controller {
  ///Tracks [strokeWidth] of the [Paint] method.
  final double strokeWidth;

  ///Tracks [Color] of the [Paint] method.
  final Color color;

  ///Tracks [PaintingStyle] of the [Paint] method.
  final PaintingStyle paintStyle;

  ///Tracks [PaintMode] of the current [Paint] method.
  final PaintMode mode;

  ///Constructor of the [Controller] class.
  Controller(
      {this.strokeWidth = 4.0,
      this.color = Colors.red,
      this.mode = PaintMode.Line,
      this.paintStyle = PaintingStyle.stroke});

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Controller &&
        o.strokeWidth == strokeWidth &&
        o.color == color &&
        o.paintStyle == paintStyle &&
        o.mode == mode;
  }

  @override
  int get hashCode {
    return strokeWidth.hashCode ^
        color.hashCode ^
        paintStyle.hashCode ^
        mode.hashCode;
  }

  Controller copyWith({
    double strokeWidth,
    Color color,
    PaintMode mode,
    PaintingStyle paintingStyle,
  }) {
    return Controller(
        strokeWidth: strokeWidth ?? this.strokeWidth,
        color: color ?? this.color,
        mode: mode ?? this.mode,
        // ignore: unnecessary_this
        paintStyle: paintingStyle ?? this.paintStyle);
  }
}
