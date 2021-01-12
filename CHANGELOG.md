# 1.0.0-nullsafety.0
- Migrated Package to null safety. 

# 0.2.0

- Fixed issue with image parsing failing when used with file. 
- Added exceptions to the image conversion failures.
- Fixed lint issues.

# 0.1.9

- Smoother look for signature mode.
- Local `InteractiveViewer` for future flutter version issues. 

# 0.1.8

- Added dynamic strokeMultiplier to compensate strokewidth for high resolution image.
- Pan or moving around image is available to use when mode is `PaintMode.None`. 
- Performance improvements and lint fixes. 
- Improved example. 

# 0.1.6

- ByteArray on `Image.memory` constructor now returns itself without conversion back if no action is performed on it.
- Code refactors.

# 0.1.5

- Breaking Change: Controller is immutable and can only be overridden with `.copyWith` Constructor.
- Added `PaintStyle` in constructor.
- Code refactor.

# 0.1.4

- Fixed `ImagePainter.memory` constructor taking `ui.Image` while it should be taking `Uint8List`. 

# 0.1.3

- Added `ImagePainter.signature` constructor for signature field. 
- Fixed scaling issues.
- Added example for signature field. 

# 0.1.1

- Added documentation to the class and functions.
- Improved docs and readMe.

# 0.1.0

Initial version of `image_painter` library.
 - Includes 7 modes of paint styles i.e. Line, Box/Rectangle, Circle, FreeStyle or Signature, Arrow, Dash/Dotted Lines and Text 
 - Includes controls for `Color` and `StrokeWidth`.