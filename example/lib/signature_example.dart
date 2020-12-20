import 'dart:io';
import 'dart:typed_data';
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
  Controller imageController;
  List<MapEntry<IconData, PaintMode>> options = [
    MapEntry(Icons.zoom_out_map, PaintMode.None),
    MapEntry(Icons.horizontal_rule, PaintMode.Line),
    MapEntry(Icons.crop_free, PaintMode.Box),
    MapEntry(Icons.edit, PaintMode.FreeStyle),
    MapEntry(Icons.lens_outlined, PaintMode.Circle),
    MapEntry(Icons.arrow_right_alt_outlined, PaintMode.Arrow),
    MapEntry(Icons.power_input, PaintMode.DottedLine)
  ];
  @override
  void initState() {
    imageController =
        Controller(color: Colors.black, mode: PaintMode.Line, strokeWidth: 4.0);
    super.initState();
  }

  void saveImage() async {
    Uint8List image = await _imageKey.currentState.exportImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    await Directory('$directory/sample').create(recursive: true);
    String fullPath = '$directory/sample/image.png';
    File imgFile = new File('$fullPath');
    imgFile.writeAsBytesSync(image);
    _key.currentState.showSnackBar(
      SnackBar(
        backgroundColor: Colors.grey[700],
        padding: EdgeInsets.only(left: 10),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Image Exported successfully.",
                style: TextStyle(color: Colors.white)),
            FlatButton(
                onPressed: () => OpenFile.open("$fullPath"),
                child: Text("Open", style: TextStyle(color: Colors.blue[200])))
          ],
        ),
      ),
    );
  }

  void _openMainColorPicker() async {
    await showDialog<Color>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setstate) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(6.0),
              title: Text("Pick a color"),
              content: MaterialColorPicker(
                shrinkWrap: true,
                selectedColor: imageController.color,
                allowShades: false,
                onMainColorChange: (color) => setstate(() =>
                    imageController = imageController.copyWith(color: color)),
              ),
              actions: [
                FlatButton(
                  child: Text('Done'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openStrokeDialog() async {
    await showDialog<double>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setstate) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AlertDialog(
                  contentPadding: const EdgeInsets.all(6.0),
                  title: Text("Set StrokeWidth"),
                  content: Column(
                    children: [
                      CupertinoSlider(
                        value: imageController.strokeWidth,
                        min: 2.0,
                        max: 20.0,
                        divisions: 9,
                        onChanged: (value) {
                          setState(() {});
                          imageController =
                              imageController.copyWith(strokeWidth: value);
                        },
                      ),
                      Text(
                        "${imageController.strokeWidth.toInt()}",
                        style: TextStyle(fontSize: 20, color: Colors.blue),
                      )
                    ],
                  ),
                  actions: [
                    FlatButton(
                      child: Text('Done'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _key,
        appBar: AppBar(
          title: Text("Image Painter Example"),
          actions: [
            IconButton(
                icon: Icon(Icons.brush_sharp),
                onPressed: () {
                  _openStrokeDialog();
                }),
            IconButton(
                icon: Icon(Icons.color_lens),
                onPressed: () {
                  _openMainColorPicker();
                }),
            IconButton(icon: Icon(Icons.save), onPressed: () => saveImage()),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    icon: Icon(Icons.reply, color: Colors.white),
                    onPressed: () => _imageKey.currentState.undo()),
                IconButton(
                    icon: Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      _imageKey.currentState.clearAll();
                    }),
              ],
            ),
          ),
        ),
        body: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ImagePainter.signature(
              height: 200,
              width: 300,
              key: _imageKey,
              controller: imageController,
              signatureBgColor: Colors.grey[200],
            ),
          ),
        ));
  }
}
