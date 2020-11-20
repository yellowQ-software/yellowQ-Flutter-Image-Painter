# image_painter

A flutter implementation of painting over image.

# OverView
![image](screenshots/image_painter_sample.gif)

## Features

- Seven available paint modes. Line, Box/Rectangle, Circle, Freestyle/Signature, Dotted Line, Arrow and Text.
- Four constructors for adding image from Network Url, Asset Image, Image from file and From memory.
- Controls from constructors like strokeWidth and Colors.
- Export image as memory bytes which can be converted to image. [implementation provided on example]
- Ability to undo and clear drawings.

## Getting started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  image_painter:
```

In your library add the following import:

```dart
import 'package:image_painter/image_painter.dart';
```

For help getting started with Flutter, view the online [documentation](https://flutter.io/).

## Using the library

[Check out the example](./example)

Basic usage of the libary:

- `ImagePainter.network`: Painting over url from network.

```dart
//initialize the controller
Controller imageController = Controller();
//provide controller to the painter.
ImagePainter.asset("https://sample_image.png",
                  key: _imageKey, controller: imageController, scalable: true),
//To change color, strokewidth or paint mode: 
setState((){
    imageController.color = Colors.red;
    imageController.mode = PaintMode.Arrow;
    imageController.strokeWidth = 10.0;
})
```
