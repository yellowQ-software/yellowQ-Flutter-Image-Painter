import 'package:flutter/material.dart';

import '../../image_painter.dart';

class SelectionItems extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;

  const SelectionItems({Key key, this.isSelected, this.icon, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.transparent, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.black, size: 20),
          ),
        ),
        if (isSelected)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.green),
              child: const Icon(Icons.check, color: Colors.grey, size: 10),
            ),
          )
      ],
    );
  }
}

Map<IconData, PaintMode> paintModes = {
  Icons.zoom_out_map: PaintMode.none,
  Icons.horizontal_rule: PaintMode.line,
  Icons.crop_free: PaintMode.rect,
  Icons.edit: PaintMode.freeStyle,
  Icons.lens_outlined: PaintMode.circle,
  Icons.arrow_right_alt_outlined: PaintMode.arrow,
  Icons.power_input: PaintMode.dashLine,
};
