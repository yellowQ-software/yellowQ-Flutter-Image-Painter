import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_painter/image_painter.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class PaintOverImage extends StatefulWidget {
  final String filePath;
  PaintOverImage({this.filePath});
  @override
  _PaintOverImageState createState() => _PaintOverImageState();
}

class _PaintOverImageState extends State<PaintOverImage> {
  final _imageKey = GlobalKey<ImagePainterState>();
  final _key = GlobalKey<ScaffoldState>();
  Controller imageController;
  double strokeWidth = 4.0;
  Color color = Colors.white;
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
        Controller(color: Colors.black, mode: PaintMode.Line, strokeWidth: 4);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _key,
        appBar: AppBar(
          title: Text("Edit"),
          actions: [
            IconButton(
                icon: Icon(Icons.brush),
                onPressed: () {
                  setState(() {
                    imageController.color = Colors.green;
                    imageController.mode = PaintMode.FreeStyle;
                    imageController.strokeWidth = 10;
                  });
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
                        isSelected: imageController.mode == item.value,
                        onTap: () {
                          setState(() {
                            imageController.mode = item.value;
                          });
                        });
                  }).toList()),
            ),
            Expanded(
              child: ImagePainter.file(File(widget.filePath),
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
