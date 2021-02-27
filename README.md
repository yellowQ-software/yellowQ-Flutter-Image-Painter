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
final _imageKey = GlobalKey<ImagePainterState>();
//Provide controller to the painter.
ImagePainter.network("https://sample_image.png",
                  key: _imageKey,scalable: true),

///Export the image:
Uint8List byteArray = await _imageKey.currentState.exportImage();
//Now you use `Uint8List` data and convert it to file.
File imgFile = new File('directoryPath/fileName.png');
imgFile.writeAsBytesSync(image);
```
**For more thorough implementation guide, check the [example](./example).**