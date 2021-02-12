import 'package:flutter/material.dart';

class RangedSlider extends StatelessWidget {
  const RangedSlider({Key key, this.value, this.onChanged}) : super(key: key);

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Slider(
      max: 40,
      min: 2,
      divisions: 19,
      value: value,
      onChanged: onChanged,
    );
  }
}
