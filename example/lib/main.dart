// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_painter/image_painter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

final _imageKey = GlobalKey<ImagePainterState>();
bool editing = false;
XFile? file;
final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final ImagePicker _picker = ImagePicker();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      scaffoldMessengerKey: snackbarKey,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(child: NewWidget(picker: _picker)),
      ),
    );
  }
}

class NewWidget extends StatefulWidget {
  const NewWidget({
    Key? key,
    required ImagePicker picker,
  })  : _picker = picker,
        super(key: key);

  final ImagePicker _picker;

  @override
  State<NewWidget> createState() => _NewWidgetState();
}

class _NewWidgetState extends State<NewWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: file == null
          ? ElevatedButton(
              onPressed: () async {
                final selectedFile =
                    await widget._picker.pickImage(source: ImageSource.gallery);
                if (selectedFile != null) {
                  setState(() {
                    file = selectedFile;
                    editing = true;
                  });
                }
              },
              child: const Text("Choose and edit image"),
            )
          : ImagePainter.file(File(file!.path),
              key: _imageKey,
              addTextIcon:
                  Icon(Icons.text_fields_outlined, color: Colors.white),
              showClearAllButton: false,
              selectedColor: Colors.red,
              iconsColor: Colors.white,
              scalable: false,
              clearAllIcon: const Icon(Icons.cancel, color: Colors.white),
              placeholderWidget: const CircularProgressIndicator(),
              controlsBackgroundColor: Colors.blue),
    );
  }

  void saveImage() async {
    final image = await _imageKey.currentState?.exportImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    await Directory('$directory/sample').create(recursive: true);
    final fullPath =
        '$directory/sample/${DateTime.now().millisecondsSinceEpoch}.png';
    final imgFile = File(fullPath);
    imgFile.writeAsBytesSync(image!);
    final SnackBar snackBar =
        SnackBar(content: Text("File saved to: $fullPath"));
    snackbarKey.currentState?.showSnackBar(snackBar);
  }

  void closeImage() {
    setState(() {
      file = null;
      editing = true;
    });
  }
}
