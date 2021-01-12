import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:image_painter/image_painter.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class SignatureExample extends StatefulWidget {
  @override
  _SignatureExampleState createState() => _SignatureExampleState();
}

class _SignatureExampleState extends State<SignatureExample> {
  final _imageKey = GlobalKey<ImagePainterState>();
  final _key = GlobalKey<ScaffoldState>();
  final _controller = ValueNotifier<Controller>(null);
  @override
  void initState() {
    _controller.value =
        Controller(color: Colors.black, mode: PaintMode.line, strokeWidth: 4.0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: const Text("Image Painter Example"),
        actions: [
          IconButton(
            icon: const Icon(Icons.brush_sharp),
            onPressed: _openStrokeDialog,
          ),
          IconButton(
              icon: const Icon(Icons.color_lens),
              onPressed: () {
                _openMainColorPicker();
              }),
          IconButton(icon: const Icon(Icons.save), onPressed: saveImage),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  icon: const Icon(Icons.reply, color: Colors.white),
                  onPressed: () => _imageKey.currentState.undo()),
              IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () => _imageKey.currentState.clearAll()),
            ],
          ),
        ),
      ),
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ValueListenableBuilder<Controller>(
              valueListenable: _controller,
              builder: (_, controller, __) {
                return ImagePainter.signature(
                  height: 200,
                  width: 300,
                  key: _imageKey,
                  controller: controller,
                  signatureBgColor: Colors.grey[200],
                );
              }),
        ),
      ),
    );
  }

  _updateController(Controller controller) => _controller.value = controller;

  void _openMainColorPicker() {
    showDialog(
      context: context,
      builder: (_) {
        return ValueListenableBuilder<Controller>(
          valueListenable: _controller,
          builder: (__, value, _) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(6.0),
              title: const Text("Pick a color"),
              content: MaterialColorPicker(
                  shrinkWrap: true,
                  selectedColor: value.color,
                  allowShades: false,
                  onMainColorChange: (color) =>
                      _updateController(value.copyWith(color: color))),
              actions: [
                FlatButton(
                    child: const Text('Done'),
                    onPressed: () => Navigator.of(context).pop()),
              ],
            );
          },
        );
      },
    );
  }

  void _openStrokeDialog() {
    showDialog(
        context: context,
        builder: (_) {
          return ValueListenableBuilder<Controller>(
              valueListenable: _controller,
              builder: (_, ctrl, __) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AlertDialog(
                      contentPadding: const EdgeInsets.all(6.0),
                      title: const Text("Set StrokeWidth"),
                      content: Column(
                        children: [
                          CupertinoSlider(
                            value: ctrl.strokeWidth,
                            min: 2.0,
                            max: 20.0,
                            divisions: 9,
                            onChanged: (value) => _updateController(
                                ctrl.copyWith(strokeWidth: value)),
                          ),
                          Text(
                            "${ctrl.strokeWidth.toInt()}",
                            style: const TextStyle(
                                fontSize: 20, color: Colors.blue),
                          )
                        ],
                      ),
                      actions: [
                        FlatButton(
                          child: const Text('Done'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ],
                );
              });
        });
  }

  void saveImage() async {
    final image = await _imageKey.currentState.exportImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    await Directory('$directory/sample').create(recursive: true);
    final fullPath = '$directory/sample/image.png';
    final imgFile = File('$fullPath');
    imgFile.writeAsBytesSync(image);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.grey[700],
        padding: const EdgeInsets.only(left: 10),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Image Exported successfully.",
                style: TextStyle(color: Colors.white)),
            FlatButton(
              onPressed: () => OpenFile.open("$fullPath"),
              child: Text(
                "Open",
                style: TextStyle(color: Colors.blue[200]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
