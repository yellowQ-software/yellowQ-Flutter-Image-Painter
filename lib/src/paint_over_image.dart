import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide Image;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'image_painter.dart';

export 'image_painter.dart';

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
        controller: controller);
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
        controller: controller);
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
        controller: controller);
  }

  ///Constructor for loading image from memory.
  factory ImagePainter.memory(Uint8List byteArray,
      {Key key,
      double height,
      double width,
      bool scalable,
      Widget placeholderWidget,
      @required Controller controller}) {
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
  bool _isLoaded = false, _inDrag = false;
  Controller _controller;
  List<PaintHistory> _paintHistory = List<PaintHistory>();
  List<Offset> _points = List<Offset>();
  Offset _start, _end;
  int _pointer = 0;
  @override
  void initState() {
    super.initState();
    _resolveAndConvertImage();
    _controller = widget.controller;
  }

  Paint get _painter => Paint()
    ..color = _controller.color
    ..strokeWidth = _controller.strokeWidth
    ..style = _controller.mode == PaintMode.DottedLine
        ? PaintingStyle.stroke
        : _controller.paintStyle;
  @override
  void didUpdateWidget(ImagePainter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      setState(() {
        _controller = widget.controller;
      });
    }
  }

  ///Converts the incoming image type from constructor to [ui.Image]
  _resolveAndConvertImage() async {
    if (widget.networkUrl != null) {
      _image = await _loadNetworkImage(widget.networkUrl);
    } else if (widget.assetPath != null) {
      ByteData img = await rootBundle.load(widget.assetPath);
      _image = await _convertImage(Uint8List.view(img.buffer));
    } else if (widget.file != null) {
      Uint8List img = await widget.file.readAsBytes();
      _image = await _convertImage(img);
    } else if (widget.byteArray != null) {
      _image = await _convertImage(widget.byteArray);
    } else {
      _isLoaded = true;
    }
  }

  ///Completer function to convert asset or file image to [ui.Image] before drawing on custompainter.
  Future<ui.Image> _convertImage(List<int> img) async {
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
  Future<ui.Image> _loadNetworkImage(String path) async {
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
          onPointerDown: (event) => _pointer++,
          onPointerUp: (event) => _pointer = 0,
          child: ClipRect(
            child: InteractiveViewer(
              maxScale: 2.4,
              panEnabled: false,
              scaleEnabled: widget.isScalable,
              minScale: 0.4,
              onInteractionUpdate: _scaleUpdateGesture,
              onInteractionEnd: _scaleEndGesture,
              child: CustomPaint(
                size: Size(_image.width.toDouble(), _image.height.toDouble()),
                willChange: true,
                painter: DrawImage(
                  image: _image,
                  points: _points,
                  paintHistory: _paintHistory,
                  isDragging: _inDrag,
                  update: UpdatePoints(
                      start: _start,
                      end: _end,
                      painter: _painter,
                      mode: _controller.mode),
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
                points: _points,
                paintHistory: _paintHistory,
                isDragging: _inDrag,
                update: UpdatePoints(
                    start: _start,
                    end: _end,
                    painter: _painter,
                    mode: _controller.mode),
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///Fires while user is interacting with the screen to record painting.
  void _scaleUpdateGesture(ScaleUpdateDetails onUpdate) {
    if (_pointer < 2) {
      setState(() {
        _inDrag = true;
        if (_start == null) {
          _start = onUpdate.focalPoint;
        }
        _end = onUpdate.focalPoint;
        if (_controller.mode == PaintMode.FreeStyle || widget.isSignature) {
          _points.add(_end);
        } else if (_controller.mode == PaintMode.Text &&
            _paintHistory.any((element) => element.map.value.text != null)) {
          _paintHistory
              .lastWhere((element) => element.map.value.text != null)
              .map
              .value
              .offset = [_end];
        }
      });
    }
  }

  ///Fires when user stops interacting with the screen.
  void _scaleEndGesture(ScaleEndDetails onEnd) {
    if (_pointer < 2) {
      setState(() {
        _inDrag = false;
        if (_controller.mode == PaintMode.None) {
        } else if (_start != null &&
            _end != null &&
            _controller.mode != PaintMode.FreeStyle) {
          _addEndPoints(_start, _end);
        } else if (_start != null &&
                _end != null &&
                _controller.mode == PaintMode.FreeStyle ||
            widget.isSignature) {
          _points.add(null);
          _addFreeStylePoints();
        }
        _start = null;
        _end = null;
      });
      _points.clear();
    }
  }

  void _addEndPoints(dx, dy) {
    _paintHistory.add(
      PaintHistory(
        MapEntry<PaintMode, PaintInfo>(
          _controller.mode,
          PaintInfo(offset: [dx, dy], painter: _painter),
        ),
      ),
    );
  }

  void _addFreeStylePoints() {
    if (widget.isSignature) {
      _paintHistory.add(PaintHistory(
        MapEntry<PaintMode, PaintInfo>(
          PaintMode.FreeStyle,
          PaintInfo(
              offset: List<Offset>()..addAll(_points),
              painter: Paint()
                ..color = _controller.color
                ..strokeWidth = _controller.strokeWidth),
        ),
      ));
    } else {
      _paintHistory.add(PaintHistory(
        MapEntry<PaintMode, PaintInfo>(
          _controller.mode,
          PaintInfo(offset: List<Offset>()..addAll(_points), painter: _painter),
        ),
      ));
    }
  }

  ///Provides [ui.Image] of the recorded canvas to perform action.
  Future<ui.Image> _renderImage() async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    DrawImage painter = DrawImage(
        image: _image,
        backgroundColor: widget.signatureBackgroundColor,
        paintHistory: _paintHistory,
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
      _image = await _renderImage();
    }
    ByteData byteData = await _image.toByteData(format: ui.ImageByteFormat.png);
    return byteData.buffer.asUint8List();
  }

  ///Cancels or removes the last [PaintHistory].
  void undo() {
    if (_paintHistory.length > 0)
      setState(() {
        _paintHistory.removeLast();
      });
  }

  ///Cancels or clears all the previous [PaintHistory].
  void clearAll() {
    setState(() {
      _paintHistory.clear();
    });
  }
}

///Gives access to manipulate the essential components like [strokeWidth], [Color] and [PaintMode].
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
        paintStyle: paintingStyle ?? this.paintStyle);
  }
}
