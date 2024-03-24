import 'package:flutter/material.dart';
import 'package:image_painter/image_painter.dart';

import 'dart:js' as js;
import 'dart:html' as html;

class WebExample extends StatefulWidget {
  const WebExample({Key? key}) : super(key: key);

  @override
  State<WebExample> createState() => _WebExampleState();
}

class _WebExampleState extends State<WebExample> {
  final ImagePainterController _controller = ImagePainterController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Painter Example"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: saveImage,
          )
        ],
      ),
      body: ImagePainter.asset(
        "assets/sample.jpg",
        controller: _controller,
        scalable: true,
        textDelegate: TextDelegate(),
      ),
    );
  }

  void saveImage() async {
    final image = await _controller.exportImage();
    final imageName = '${DateTime.now().millisecondsSinceEpoch}.png';
    js.context.callMethod('webSaveAs', [
      html.Blob([image]),
      "$imageName"
    ]);
  }
}
