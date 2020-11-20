import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:image_painter/image_painter.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class PaintOverImage extends StatefulWidget {
  @override
  _PaintOverImageState createState() => _PaintOverImageState();
}

class _PaintOverImageState extends State<PaintOverImage> {
  final _imageKey = GlobalKey<ImagePainterState>();
  final _key = GlobalKey<ScaffoldState>();
  Controller imageController;
  Color _selectedColor = Colors.blue;
  double _strokeWidth = 4.0;
  List<MapEntry<IconData, PaintMode>> options = [
    MapEntry(Icons.zoom_out_map, PaintMode.None),
    MapEntry(Icons.horizontal_rule, PaintMode.Line),
    MapEntry(Icons.crop_free, PaintMode.Box),
    MapEntry(Icons.edit, PaintMode.FreeStyle),
    MapEntry(Icons.lens_outlined, PaintMode.Circle),
    MapEntry(Icons.arrow_right_alt_outlined, PaintMode.Arrow),
    MapEntry(Icons.power_input, PaintMode.DottedLine)
  ];
  PaintMode _selectedMode = PaintMode.Line;
  @override
  void initState() {
    imageController = Controller(
        color: _selectedColor, mode: _selectedMode, strokeWidth: _strokeWidth);
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
                selectedColor: _selectedColor,
                allowShades: false,
                onMainColorChange: (color) =>
                    setstate(() => _selectedColor = color),
              ),
              actions: [
                FlatButton(
                  child: Text('Done'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
    setState(() {
      imageController.color = _selectedColor;
    });
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
                        value: _strokeWidth,
                        min: 2.0,
                        max: 20.0,
                        divisions: 9,
                        onChanged: (value) {
                          setstate(() {
                            _strokeWidth = value;
                          });
                        },
                      ),
                      Text(
                        "${_strokeWidth.toInt()}",
                        style: TextStyle(fontSize: 20, color: Colors.blue),
                      )
                    ],
                  ),
                  actions: [
                    FlatButton(
                      child: Text('Done'),
                      onPressed: () {
                        Navigator.of(context).pop();
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
    setState(() {
      imageController.strokeWidth = _strokeWidth;
    });
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
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              color: Colors.black54,
              child: Wrap(
                  alignment: WrapAlignment.center,
                  runSpacing: 5,
                  spacing: 5,
                  children: options.map((item) {
                    return SelectionItems(
                        icon: item.key,
                        isSelected: _selectedMode == item.value,
                        onTap: () {
                          setState(() {
                            _selectedMode = item.value;
                            imageController.mode = item.value;
                          });
                        });
                  }).toList()),
            ),
            Expanded(
              child: ImagePainter.asset("assets/sample.jpg",
                  key: _imageKey, controller: imageController, scalable: true),
            ),
          ],
        ));
  }
}

class SelectionItems extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;

  const SelectionItems({Key key, this.isSelected, this.icon, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: isSelected ? Colors.white70 : Colors.transparent,
                shape: BoxShape.circle),
            child: Icon(icon,
                color: isSelected ? Colors.blue : Colors.white, size: 20),
          ),
        ),
        if (isSelected)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: Colors.green),
              child: Icon(Icons.check, color: Colors.white, size: 10),
            ),
          )
      ],
    );
  }
}
