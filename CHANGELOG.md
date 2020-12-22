# 0.1.6

- ByteArray on memory constructor now returns itself without conversion back if no action is performed on it.
- Code refactors.

# 0.1.5

- Breaking Change: Controller is immutable and can only be overridden with copyWith Constructor.
- Added PaintStyle in constructor.
- Code refactor.

# 0.1.4

- Fixed ImagePainter.memory constructor taking ui.Image while it should be taking Uint8List. 

# 0.1.3

- Added signature field. 
- Fixed scaling issues.
- Added example for signature field. 

# 0.1.1

- Added documentation to the class and functions.
- Improved docs and readMe.

# 0.1.0

Initial version of image_painter library.
 - Includes 7 modes of paint styles i.e. Line, Box/Rectangle, Circle, FreeStyle or Signature, Arrow, Dash/Dotted Lines and Text 
 - Includes controls for color and StrokeWidth.