# image_painter

[![pub package](https://img.shields.io/pub/v/image_painter.svg)](https://pub.dev/packages/image_painter)
![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)
[![Platform Badge](https://img.shields.io/badge/platform-android%20|%20ios%20-green.svg)](https://pub.dev/packages/image_painter)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A flutter implementation of painting over image.

# Overview
![demo!](https://raw.githubusercontent.com/yellowQ-software/yellowQ-Flutter-Image-Painter/main/screenshots/image_painter_sample.gif)

## Features

- Seven available paint modes. Line, Box/Rectangle, Circle, Freestyle/Signature, Dotted Line, Arrow and Text.
- Four constructors for adding image from Network Url, Asset Image, Image from file and from memory.
- Export image as memory bytes which can be converted to image. [Implementation provided on example](./example)
- Ability to undo and clear drawings.
- Built in control bar. 

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
/// Initialize `ImagePainterController`. 
final imagePainterController = ImagePainterController();

/// Provide controller to the painter.
ImagePainter.network("https://sample_image.png",
                  controller: imagePainterController,scalable: true),

///Export the image:
Uint8List byteArray = await imagePainterController.exportImage();

/// Create a file or create a File instance of existing file. 
File imgFile =  File('directoryPath/fileName.png');

/// Now you use `Uint8List` data and write it into the file.
imgFile.writeAsBytesSync(image);
```
**For more thorough implementation guide, check the [example](./example).**

## Issues and Support.

For any issues or support please visit the [Issues](https://github.com/yellowQ-software/yellowQ-Flutter-Image-Painter/issues).