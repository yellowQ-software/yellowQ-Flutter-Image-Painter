import 'package:flutter/material.dart';
import '../../image_painter.dart';

typedef DragDetails = Function(DraggableDetails);

class DraggableText extends StatelessWidget {
  final PaintInfo item;
  final DragDetails onDragEnd;
  const DraggableText({Key key, this.item, this.onDragEnd}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable(
      onDragEnd: onDragEnd,
      childWhenDragging: const SizedBox(),
      child: Text(
        item.text,
        style: TextStyle(fontSize: 40),
      ),
      feedback: Material(
        child: Text(
          item.text,
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
