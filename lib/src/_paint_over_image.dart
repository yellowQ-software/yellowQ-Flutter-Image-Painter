import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';

import '_image_painter.dart';
import '_signature_painter.dart';
import 'controller.dart';
import 'delegates/text_delegate.dart';
import 'widgets/_color_widget.dart';
import 'widgets/_mode_widget.dart';
import 'widgets/_range_slider.dart';
import 'widgets/_text_dialog.dart';

export '_image_painter.dart';

///[ImagePainter] widget.
@immutable
class ImagePainter extends StatefulWidget {
  const ImagePainter._(
      {Key? key,
      required this.controller,
      this.assetPath,
      this.networkUrl,
      this.byteArray,
      this.file,
      this.height,
      this.width,
      this.placeHolder,
      this.isScalable,
      this.brushIcon,
      this.clearAllIcon,
      this.colorIcon,
      this.undoIcon,
      this.isSignature = false,
      this.controlsAtTop = true,
      this.signatureBackgroundColor = Colors.white,
      this.colors,
      this.onColorChanged,
      this.onStrokeWidthChanged,
      this.onPaintModeChanged,
      this.textDelegate,
      this.showControls = true,
      this.controlsBackgroundColor,
      this.optionSelectedColor,
      this.optionUnselectedColor,
      this.optionColor,
      this.onUndo,
      this.onClear,
      this.imagePainterHideManager})
      : super(key: key);

  ///Constructor for loading image from network url.
  factory ImagePainter.network(
    String url, {
    required ImagePainterController controller,
    Key? key,
    double? height,
    double? width,
    Widget? placeholderWidget,
    bool? scalable,
    List<Color>? colors,
    Widget? brushIcon,
    Widget? undoIcon,
    Widget? clearAllIcon,
    Widget? colorIcon,
    ValueChanged<PaintMode>? onPaintModeChanged,
    ValueChanged<Color>? onColorChanged,
    ValueChanged<double>? onStrokeWidthChanged,
    TextDelegate? textDelegate,
    bool? controlsAtTop,
    bool? showControls,
    ImagePainterControlsHider? imagePainterHideManager,
    Color? controlsBackgroundColor,
    Color? selectedColor,
    Color? unselectedColor,
    Color? optionColor,
    VoidCallback? onUndo,
    VoidCallback? onClear,
  }) {
    return ImagePainter._(
      key: key,
      controller: controller,
      networkUrl: url,
      height: height,
      width: width,
      placeHolder: placeholderWidget,
      isScalable: scalable,
      colors: colors,
      brushIcon: brushIcon,
      undoIcon: undoIcon,
      colorIcon: colorIcon,
      clearAllIcon: clearAllIcon,
      onPaintModeChanged: onPaintModeChanged,
      onColorChanged: onColorChanged,
      onStrokeWidthChanged: onStrokeWidthChanged,
      textDelegate: textDelegate,
      controlsAtTop: controlsAtTop ?? true,
      showControls: showControls ?? true,
      imagePainterHideManager: imagePainterHideManager,
      controlsBackgroundColor: controlsBackgroundColor,
      optionSelectedColor: selectedColor,
      optionUnselectedColor: unselectedColor,
      optionColor: optionColor,
      onUndo: onUndo,
      onClear: onClear,
    );
  }

  ///Constructor for loading image from assetPath.
  factory ImagePainter.asset(
    String path, {
    required ImagePainterController controller,
    Key? key,
    double? height,
    double? width,
    bool? scalable,
    Widget? placeholderWidget,
    List<Color>? colors,
    Widget? brushIcon,
    Widget? undoIcon,
    Widget? clearAllIcon,
    Widget? colorIcon,
    ValueChanged<PaintMode>? onPaintModeChanged,
    ValueChanged<Color>? onColorChanged,
    ValueChanged<double>? onStrokeWidthChanged,
    TextDelegate? textDelegate,
    bool? controlsAtTop,
    bool? showControls,
    ImagePainterControlsHider? imagePainterHideManager,
    Color? controlsBackgroundColor,
    Color? selectedColor,
    Color? unselectedColor,
    Color? optionColor,
    VoidCallback? onUndo,
    VoidCallback? onClear,
  }) {
    return ImagePainter._(
      controller: controller,
      key: key,
      assetPath: path,
      height: height,
      width: width,
      isScalable: scalable ?? false,
      placeHolder: placeholderWidget,
      colors: colors,
      brushIcon: brushIcon,
      undoIcon: undoIcon,
      colorIcon: colorIcon,
      clearAllIcon: clearAllIcon,
      onPaintModeChanged: onPaintModeChanged,
      onColorChanged: onColorChanged,
      onStrokeWidthChanged: onStrokeWidthChanged,
      textDelegate: textDelegate,
      controlsAtTop: controlsAtTop ?? true,
      showControls: showControls ?? true,
      imagePainterHideManager: imagePainterHideManager,
      controlsBackgroundColor: controlsBackgroundColor,
      optionSelectedColor: selectedColor,
      optionUnselectedColor: unselectedColor,
      optionColor: optionColor,
      onUndo: onUndo,
      onClear: onClear,
    );
  }

  ///Constructor for loading image from [File].
  factory ImagePainter.file(
    File file, {
    required ImagePainterController controller,
    Key? key,
    double? height,
    double? width,
    bool? scalable,
    Widget? placeholderWidget,
    List<Color>? colors,
    Widget? brushIcon,
    Widget? undoIcon,
    Widget? clearAllIcon,
    Widget? colorIcon,
    ValueChanged<PaintMode>? onPaintModeChanged,
    ValueChanged<Color>? onColorChanged,
    ValueChanged<double>? onStrokeWidthChanged,
    TextDelegate? textDelegate,
    bool? controlsAtTop,
    bool? showControls,
    ImagePainterControlsHider? imagePainterHideManager,
    Color? controlsBackgroundColor,
    Color? selectedColor,
    Color? unselectedColor,
    Color? optionColor,
    VoidCallback? onUndo,
    VoidCallback? onClear,
  }) {
    return ImagePainter._(
      controller: controller,
      key: key,
      file: file,
      height: height,
      width: width,
      placeHolder: placeholderWidget,
      colors: colors,
      isScalable: scalable ?? false,
      brushIcon: brushIcon,
      undoIcon: undoIcon,
      colorIcon: colorIcon,
      clearAllIcon: clearAllIcon,
      onPaintModeChanged: onPaintModeChanged,
      onColorChanged: onColorChanged,
      onStrokeWidthChanged: onStrokeWidthChanged,
      textDelegate: textDelegate,
      controlsAtTop: controlsAtTop ?? true,
      showControls: showControls ?? true,
      imagePainterHideManager: imagePainterHideManager,
      controlsBackgroundColor: controlsBackgroundColor,
      optionSelectedColor: selectedColor,
      optionUnselectedColor: unselectedColor,
      optionColor: optionColor,
      onUndo: onUndo,
      onClear: onClear,
    );
  }

  ///Constructor for loading image from memory.
  factory ImagePainter.memory(
    Uint8List byteArray, {
    required ImagePainterController controller,
    Key? key,
    double? height,
    double? width,
    bool? scalable,
    Widget? placeholderWidget,
    List<Color>? colors,
    Widget? brushIcon,
    Widget? undoIcon,
    Widget? clearAllIcon,
    Widget? colorIcon,
    ValueChanged<PaintMode>? onPaintModeChanged,
    ValueChanged<Color>? onColorChanged,
    ValueChanged<double>? onStrokeWidthChanged,
    TextDelegate? textDelegate,
    bool? controlsAtTop,
    bool? showControls,
    ImagePainterControlsHider? imagePainterHideManager,
    Color? controlsBackgroundColor,
    Color? selectedColor,
    Color? unselectedColor,
    Color? optionColor,
    VoidCallback? onUndo,
    VoidCallback? onClear,
  }) {
    return ImagePainter._(
      controller: controller,
      key: key,
      byteArray: byteArray,
      height: height,
      width: width,
      placeHolder: placeholderWidget,
      isScalable: scalable ?? false,
      colors: colors,
      brushIcon: brushIcon,
      undoIcon: undoIcon,
      colorIcon: colorIcon,
      clearAllIcon: clearAllIcon,
      onPaintModeChanged: onPaintModeChanged,
      onColorChanged: onColorChanged,
      onStrokeWidthChanged: onStrokeWidthChanged,
      textDelegate: textDelegate,
      controlsAtTop: controlsAtTop ?? true,
      showControls: showControls ?? true,
      imagePainterHideManager: imagePainterHideManager,
      controlsBackgroundColor: controlsBackgroundColor,
      optionSelectedColor: selectedColor,
      optionUnselectedColor: unselectedColor,
      optionColor: optionColor,
      onUndo: onUndo,
      onClear: onClear,
    );
  }

  ///Constructor for signature painting.
  factory ImagePainter.signature({
    required ImagePainterController controller,
    required double height,
    required double width,
    Key? key,
    Color? signatureBgColor,
    List<Color>? colors,
    Widget? brushIcon,
    Widget? undoIcon,
    Widget? clearAllIcon,
    Widget? colorIcon,
    ValueChanged<PaintMode>? onPaintModeChanged,
    ValueChanged<Color>? onColorChanged,
    ValueChanged<double>? onStrokeWidthChanged,
    TextDelegate? textDelegate,
    bool? controlsAtTop,
    bool? showControls,
    ImagePainterControlsHider? imagePainterHideManager,
    Color? controlsBackgroundColor,
    Color? selectedColor,
    Color? unselectedColor,
    Color? optionColor,
    VoidCallback? onUndo,
    VoidCallback? onClear,
  }) {
    return ImagePainter._(
      controller: controller,
      key: key,
      height: height,
      width: width,
      isSignature: true,
      isScalable: false,
      colors: colors,
      signatureBackgroundColor: signatureBgColor ?? Colors.white,
      brushIcon: brushIcon,
      undoIcon: undoIcon,
      colorIcon: colorIcon,
      clearAllIcon: clearAllIcon,
      onPaintModeChanged: onPaintModeChanged,
      onColorChanged: onColorChanged,
      onStrokeWidthChanged: onStrokeWidthChanged,
      textDelegate: textDelegate,
      controlsAtTop: controlsAtTop ?? true,
      showControls: showControls ?? true,
      imagePainterHideManager: imagePainterHideManager,
      controlsBackgroundColor: controlsBackgroundColor,
      optionSelectedColor: selectedColor,
      optionUnselectedColor: unselectedColor,
      optionColor: optionColor,
      onUndo: onUndo,
      onClear: onClear,
    );
  }

  /// Class that holds the controller and it's methods.
  final ImagePainterController controller;

  ///Only accessible through [ImagePainter.network] constructor.
  final String? networkUrl;

  ///Only accessible through [ImagePainter.memory] constructor.
  final Uint8List? byteArray;

  ///Only accessible through [ImagePainter.file] constructor.
  final File? file;

  ///Only accessible through [ImagePainter.asset] constructor.
  final String? assetPath;

  ///Height of the Widget. Image is subjected to fit within the given height.
  final double? height;

  ///Width of the widget. Image is subjected to fit within the given width.
  final double? width;

  ///Widget to be shown during the conversion of provided image to [ui.Image].
  final Widget? placeHolder;

  ///Defines whether the widget should be scaled or not. Defaults to [false].
  final bool? isScalable;

  ///Flag to determine signature or image;
  final bool isSignature;

  ///Signature mode background color
  final Color signatureBackgroundColor;

  ///List of colors for color selection
  ///If not provided, default colors are used.
  final List<Color>? colors;

  ///Icon Widget of strokeWidth.
  final Widget? brushIcon;

  ///Widget of Color Icon in control bar.
  final Widget? colorIcon;

  ///Widget for Undo last action on control bar.
  final Widget? undoIcon;

  ///Widget for clearing all actions on control bar.
  final Widget? clearAllIcon;

  ///Define where the controls is located.
  ///`true` represents top.
  final bool controlsAtTop;

  final ValueChanged<Color>? onColorChanged;

  final ValueChanged<double>? onStrokeWidthChanged;

  final ValueChanged<PaintMode>? onPaintModeChanged;

  //the text delegate
  final TextDelegate? textDelegate;

  ///It will control displaying the Control Bar
  final bool showControls;

  final Color? controlsBackgroundColor;

  final Color? optionSelectedColor;

  final Color? optionUnselectedColor;

  final Color? optionColor;

  final VoidCallback? onUndo;

  final VoidCallback? onClear;

  ///This model can use when you want to hide some of the controls of the toolbar
  ///Default is null and it means that all controls will show
  ///[showControls] can hide toolbar totally
  final ImagePainterControlsHider? imagePainterHideManager;

  @override
  ImagePainterState createState() => ImagePainterState();
}

///
class ImagePainterState extends State<ImagePainter> {
  final _repaintKey = GlobalKey();
  ui.Image? _image;
  late final ImagePainterController _controller;
  late final ValueNotifier<bool> _isLoaded;
  late final TextEditingController _textController;
  late final TransformationController _transformationController;

  int _strokeMultiplier = 1;
  late TextDelegate textDelegate;

  @override
  void initState() {
    super.initState();
    _isLoaded = ValueNotifier<bool>(false);
    _controller = widget.controller;
    if (widget.isSignature) {
      _controller.update(
        mode: PaintMode.freeStyle,
        color: Colors.black,
      );
      _controller.setRect(Size(widget.width!, widget.height!));
    }
    _resolveAndConvertImage();
    _textController = TextEditingController();
    _transformationController = TransformationController();
    textDelegate = widget.textDelegate ?? TextDelegate();
  }

  @override
  void dispose() {
    _controller.dispose();
    _isLoaded.dispose();
    _textController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  bool get isEdited => _controller.paintHistory.isNotEmpty;

  Size get imageSize =>
      Size(_image?.width.toDouble() ?? 0, _image?.height.toDouble() ?? 0);

  ///Converts the incoming image type from constructor to [ui.Image]
  Future<void> _resolveAndConvertImage() async {
    if (widget.networkUrl != null) {
      _image = await _loadNetworkImage(widget.networkUrl!);
      if (_image != null) {
        _controller.setImage(_image!);
        _setStrokeMultiplier();
      } else {
        throw ("${widget.networkUrl} couldn't be resolved.");
      }
    } else if (widget.assetPath != null) {
      final img = await rootBundle.load(widget.assetPath!);
      _image = await _convertImage(Uint8List.view(img.buffer));
      if (_image != null) {
        _controller.setImage(_image!);
        _setStrokeMultiplier();
      } else {
        throw ("${widget.assetPath} couldn't be resolved.");
      }
    } else if (widget.file != null) {
      final img = await widget.file!.readAsBytes();
      _image = await _convertImage(img);
      if (_image != null) {
        _controller.setImage(_image!);
        _setStrokeMultiplier();
      } else {
        throw ("Image couldn't be resolved from provided file.");
      }
    } else if (widget.byteArray != null) {
      _image = await _convertImage(widget.byteArray!);
      if (_image != null) {
        _controller.setImage(_image!);
        _setStrokeMultiplier();
      } else {
        throw ("Image couldn't be resolved from provided byteArray.");
      }
    } else {
      _isLoaded.value = true;
    }
  }

  ///Dynamically sets stroke multiplier on the basis of widget size.
  ///Implemented to avoid thin stroke on high res images.
  _setStrokeMultiplier() {
    if ((_image!.height + _image!.width) > 1000) {
      _strokeMultiplier = (_image!.height + _image!.width) ~/ 1000;
    }
    _controller.update(strokeMultiplier: _strokeMultiplier);
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
    final img = NetworkImage(path);
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
      child: Column(
        children: [
          if (widget.controlsAtTop && widget.showControls) _buildControls(),
          Expanded(
            child: FittedBox(
              alignment: FractionalOffset.center,
              child: ClipRect(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return InteractiveViewer(
                      transformationController: _transformationController,
                      maxScale: 2.4,
                      minScale: 1,
                      panEnabled: _controller.mode == PaintMode.none,
                      scaleEnabled: widget.isScalable!,
                      onInteractionUpdate: _scaleUpdateGesture,
                      onInteractionEnd: _scaleEndGesture,
                      child: CustomPaint(
                        size: imageSize,
                        willChange: true,
                        isComplex: true,
                        painter: DrawImage(
                          controller: _controller,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (!widget.controlsAtTop && widget.showControls) _buildControls(),
          SizedBox(height: MediaQuery.of(context).padding.bottom)
        ],
      ),
    );
  }

  Widget _paintSignature() {
    return Stack(
      children: [
        RepaintBoundary(
          key: _repaintKey,
          child: ClipRect(
            child: Container(
              width: widget.width ?? double.maxFinite,
              height: widget.height ?? double.maxFinite,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, __) {
                  return InteractiveViewer(
                    transformationController: _transformationController,
                    panEnabled: false,
                    scaleEnabled: false,
                    onInteractionStart: _scaleStartGesture,
                    onInteractionUpdate: _scaleUpdateGesture,
                    onInteractionEnd: _scaleEndGesture,
                    child: CustomPaint(
                      willChange: true,
                      isComplex: true,
                      painter: SignaturePainter(
                        backgroundColor: widget.signatureBackgroundColor,
                        controller: _controller,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        if (widget.showControls)
          Positioned(
            top: 0,
            right: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: textDelegate.undo,
                  icon: widget.undoIcon ??
                      Icon(Icons.reply, color: Colors.grey[700]),
                  onPressed: () => _controller.undo(),
                ),
                IconButton(
                  tooltip: textDelegate.clearAllProgress,
                  icon: widget.clearAllIcon ??
                      Icon(Icons.clear, color: Colors.grey[700]),
                  onPressed: () => _controller.clear(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  _scaleStartGesture(ScaleStartDetails onStart) {
    final _zoomAdjustedOffset =
        _transformationController.toScene(onStart.localFocalPoint);
    if (!widget.isSignature) {
      _controller.setStart(_zoomAdjustedOffset);
      _controller.addOffsets(_zoomAdjustedOffset);
    }
  }

  ///Fires while user is interacting with the screen to record painting.
  void _scaleUpdateGesture(ScaleUpdateDetails onUpdate) {
    final _zoomAdjustedOffset =
        _transformationController.toScene(onUpdate.localFocalPoint);
    _controller.setInProgress(true);
    if (_controller.start == null) {
      _controller.setStart(_zoomAdjustedOffset);
    }
    _controller.setEnd(_zoomAdjustedOffset);
    if (_controller.mode == PaintMode.freeStyle) {
      _controller.addOffsets(_zoomAdjustedOffset);
    }
    if (_controller.onTextUpdateMode) {
      _controller.paintHistory
          .lastWhere((element) => element.mode == PaintMode.text)
          .offsets = [_zoomAdjustedOffset];
    }
  }

  ///Fires when user stops interacting with the screen.
  void _scaleEndGesture(ScaleEndDetails onEnd) {
    _controller.setInProgress(false);
    if (_controller.start != null &&
        _controller.end != null &&
        (_controller.mode == PaintMode.freeStyle)) {
      _controller.addOffsets(null);
      _addFreeStylePoints();
      _controller.offsets.clear();
    } else if (_controller.start != null &&
        _controller.end != null &&
        _controller.mode != PaintMode.text) {
      _addEndPoints();
    }
    _controller.resetStartAndEnd();
  }

  void _addEndPoints() => _addPaintHistory(
        PaintInfo(
          offsets: <Offset?>[_controller.start, _controller.end],
          mode: _controller.mode,
          color: _controller.color,
          strokeWidth: _controller.scaledStrokeWidth,
          fill: _controller.fill,
        ),
      );

  void _addFreeStylePoints() => _addPaintHistory(
        PaintInfo(
          offsets: <Offset?>[..._controller.offsets],
          mode: PaintMode.freeStyle,
          color: _controller.color,
          strokeWidth: _controller.scaledStrokeWidth,
        ),
      );

  PopupMenuItem _showOptionsRow() {
    return PopupMenuItem(
      enabled: false,
      child: Center(
        child: SizedBox(
          child: Wrap(
            children: paintModes(textDelegate)
                .map(
                  (item) => SelectionItems(
                    data: item,
                    isSelected: _controller.mode == item.mode,
                    selectedColor: widget.optionSelectedColor,
                    unselectedColor: widget.optionUnselectedColor,
                    onTap: () {
                      if (widget.onPaintModeChanged != null) {
                        widget.onPaintModeChanged!(item.mode);
                      }
                      _controller.setMode(item.mode);

                      Navigator.of(context).pop();
                      if (item.mode == PaintMode.text) {
                        _openTextDialog();
                      }
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  PopupMenuItem _showRangeSlider() {
    return PopupMenuItem(
      enabled: false,
      child: SizedBox(
        width: double.maxFinite,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return RangedSlider(
              value: _controller.strokeWidth,
              onChanged: (value) {
                _controller.setStrokeWidth(value);
                if (widget.onStrokeWidthChanged != null) {
                  widget.onStrokeWidthChanged!(value);
                }
              },
            );
          },
        ),
      ),
    );
  }

  PopupMenuItem _showColorPicker() {
    return PopupMenuItem(
      enabled: false,
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: (widget.colors ?? editorColors).map((color) {
            return ColorItem(
              isSelected: color == _controller.color,
              color: color,
              onTap: () {
                _controller.setColor(color);
                if (widget.onColorChanged != null) {
                  widget.onColorChanged!(color);
                }
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _addPaintHistory(PaintInfo info) {
    if (info.mode != PaintMode.none) {
      _controller.addPaintInfo(info);
    }
  }

  void _openTextDialog() {
    _controller.setMode(PaintMode.text);
    final fontSize = 6 * _controller.strokeWidth;
    TextDialog.show(
      context,
      _textController,
      fontSize,
      _controller.color,
      textDelegate,
      onFinished: (context) {
        if (_textController.text.isNotEmpty) {
          _addPaintHistory(
            PaintInfo(
              mode: PaintMode.text,
              text: _textController.text,
              offsets: [],
              color: _controller.color,
              strokeWidth: _controller.scaledStrokeWidth,
            ),
          );
          _textController.clear();
        }
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildControls() {
    return Container(
      padding: (widget.imagePainterHideManager != null &&
              widget.imagePainterHideManager!.allHide)
          ? EdgeInsets.zero
          : const EdgeInsets.all(4),
      color: widget.controlsBackgroundColor ?? Colors.grey[200],
      child: Row(
        children: [
          (widget.imagePainterHideManager != null &&
                  widget.imagePainterHideManager!.hideShapeControl != null &&
                  widget.imagePainterHideManager!.hideShapeControl!)
              ? const SizedBox()
              : AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) {
                    final icon = paintModes(textDelegate)
                        .firstWhere((item) => item.mode == _controller.mode)
                        .icon;
                    return PopupMenuButton(
                      tooltip: textDelegate.changeMode,
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      surfaceTintColor: Colors.transparent,
                      icon: Icon(icon,
                          color: widget.optionColor ?? Colors.grey[700]),
                      itemBuilder: (_) => [_showOptionsRow()],
                    );
                  },
                ),
          (widget.imagePainterHideManager != null &&
                  widget.imagePainterHideManager!.hideColorControl != null &&
                  widget.imagePainterHideManager!.hideColorControl!)
              ? const SizedBox()
              : AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) {
                    return PopupMenuButton(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      surfaceTintColor: Colors.transparent,
                      tooltip: textDelegate.changeColor,
                      icon: widget.colorIcon ??
                          Container(
                            padding: const EdgeInsets.all(2.0),
                            height: 24,
                            width: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                              color: _controller.color,
                            ),
                          ),
                      itemBuilder: (_) => [_showColorPicker()],
                    );
                  },
                ),
          (widget.imagePainterHideManager != null &&
                  widget.imagePainterHideManager!.hideBrushControl != null &&
                  widget.imagePainterHideManager!.hideBrushControl!)
              ? const SizedBox()
              : PopupMenuButton(
                  tooltip: textDelegate.changeBrushSize,
                  surfaceTintColor: Colors.transparent,
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  icon: widget.brushIcon ??
                      Icon(Icons.brush, color: Colors.grey[700]),
                  itemBuilder: (_) => [_showRangeSlider()],
                ),
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              if (_controller.canFill()) {
                if (widget.imagePainterHideManager != null &&
                    widget.imagePainterHideManager!.hideFillControl != null &&
                    widget.imagePainterHideManager!.hideFillControl!) {
                  return const SizedBox();
                }
                return Row(
                  children: [
                    Checkbox.adaptive(
                      value: _controller.shouldFill,
                      onChanged: (val) {
                        _controller.update(fill: val);
                      },
                    ),
                    Text(
                      textDelegate.fill,
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  ],
                );
              } else {
                return const SizedBox();
              }
            },
          ),
          const Spacer(),
          (widget.imagePainterHideManager != null &&
                  widget.imagePainterHideManager!.hideUndoControl != null &&
                  widget.imagePainterHideManager!.hideUndoControl!)
              ? const SizedBox()
              : IconButton(
                  tooltip: textDelegate.undo,
                  icon: widget.undoIcon ??
                      Icon(Icons.phonelink_erase_rounded,
                          color: Colors.grey[700]),
                  onPressed: () {
                    widget.onUndo?.call();
                    _controller.undo();
                  },
                ),
          (widget.imagePainterHideManager != null &&
                  widget.imagePainterHideManager!.hideClearControl != null &&
                  widget.imagePainterHideManager!.hideClearControl!)
              ? const SizedBox()
              : IconButton(
                  tooltip: textDelegate.clearAllProgress,
                  icon: widget.clearAllIcon ??
                      Icon(Icons.clear, color: Colors.grey[700]),
                  onPressed: () {
                    widget.onClear?.call();
                    _controller.clear();
                  },
                ),
        ],
      ),
    );
  }
}

class ImagePainterControlsHider {
  bool? hideShapeControl;
  bool? hideColorControl;
  bool? hideBrushControl;
  bool? hideFillControl;
  bool? hideUndoControl;
  bool? hideClearControl;
  bool? _allHide;

  ImagePainterControlsHider({
    this.hideShapeControl,
    this.hideColorControl,
    this.hideBrushControl,
    this.hideFillControl,
    this.hideUndoControl,
    this.hideClearControl,
  });

  bool get allHide => (hideShapeControl != null &&
      hideShapeControl! &&
      hideColorControl != null &&
      hideColorControl! &&
      hideBrushControl != null &&
      hideBrushControl! &&
      hideFillControl != null &&
      hideFillControl! &&
      hideUndoControl != null &&
      hideUndoControl! &&
      hideClearControl != null &&
      hideClearControl!);
}
