# image_painter

A flutter implementation of painting over image.

# Overview
![demo!](https://raw.githubusercontent.com/yellowQ-software/yellowQ-Flutter-Image-Painter/main/screenshots/image_painter_sample.gif)

## Features

- Seven available paint modes. Line, Box/Rectangle, Circle, Freestyle/Signature, Dotted Line, Arrow and Text.
- Four constructors for adding image from Network Url, Asset Image, Image from file and from memory.
- Controls from constructors like strokeWidth and Colors.
- Export image as memory bytes which can be converted to image. [Implementation provided on example](./example)
- Ability to undo and clear drawings.

[Note]
  Tested and working only on flutter stable channel. Please make sure you are on stable channel of flutter before using the package.

## Getting started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  image_painter: latest
```

In your library add the following import:

```dart
import 'package:image_painter/image_painter.dart';
```

For help getting started with Flutter, view the online [documentation](https://flutter.io/).

## Using the library

[Check out the example](./example)

Basic usage of the libary:

- `ImagePainter.network`: Painting over image from network url.

```dart
///Initialize the controller
Controller imageController = Controller();
///Provide controller to the painter.
ImagePainter.network("https://sample_image.png",
                  key: _imageKey, controller: imageController, scalable: true),
///To change color, strokewidth or paint mode: 
setState((){
    imageController.color = Colors.red;
    imageController.mode = PaintMode.Arrow;
    imageController.strokeWidth = 10.0;
})
///Export the image:
Uint8List image = await _imageKey.currentState.exportImage();
///Now you use [Uint8List] data and convert it to file.
File imgFile = new File('directory/sample.png');
    imgFile.writeAsBytesSync(image);
```
