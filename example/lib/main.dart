import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_annotation/image_annotation.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Annotation Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Image annotation'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _imageKey = GlobalKey<ImagePainterState>();
  final _key = GlobalKey<ScaffoldState>();
  Controller imageController;
  double strokeWidth = 4.0;
  Color color = Colors.white;
  @override
  void initState() {
    imageController = Controller();
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
        title: Text(widget.title),
        actions: [
          IconButton(
              icon: Icon(Icons.brush),
              onPressed: () {
                setState(() {
                  imageController.color = Colors.green;
                });
              }),
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                saveImage();
              }),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  icon: Icon(Icons.reply, color: Colors.white),
                  onPressed: () {
                    _imageKey.currentState.undo();
                  }),
              IconButton(
                  icon: Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    _imageKey.currentState.clearAll();
                  }),
            ],
          ),
        ),
      ),
      body: ImagePainter.network(
          "https://homepages.cae.wisc.edu/~ece533/images/cat.png",
          key: _imageKey,
          controller: imageController,
          scalable: true),
    );
  }
}
