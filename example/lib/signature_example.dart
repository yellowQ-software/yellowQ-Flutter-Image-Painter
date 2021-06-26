import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(title: const Text("Image Painter Example")),
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ImagePainter.signature(
            height: 200,
            width: 300,
            key: _imageKey,
            signatureBgColor: Colors.grey[200],
          ),
        ),
      ),
    );
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
            TextButton(
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
