import 'package:flutter/material.dart';
import 'package:image_painter_example/paint_over_camera_image.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(ExampleApp());

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Painter Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(title: 'Paint over image.'),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _file;
  pickImage() async {
    PickedFile file = await ImagePicker().getImage(source: ImageSource.camera);
    _file = file.path;
    if (_file != null)
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PaintOverImage(filePath: _file)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () => pickImage(),
        ),
      ),
    );
  }
}
