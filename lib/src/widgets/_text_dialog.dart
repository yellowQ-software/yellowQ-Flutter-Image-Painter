import 'package:flutter/material.dart';
import '../delegates/text_delegate.dart';

class TextDialog extends StatelessWidget {
  const TextDialog(
      {Key? key,
      required this.controller,
      required this.fontSize,
      required this.onFinished,
      required this.color,
      required this.textDelegate})
      : super(key: key);
  final TextEditingController controller;
  final double fontSize;
  final VoidCallback onFinished;
  final Color color;
  final TextDelegate textDelegate;
  static void show(BuildContext context, TextEditingController controller,
      double fontSize, Color color, TextDelegate textDelegate,
      {required ValueChanged<BuildContext> onFinished}) {
    showDialog(
        context: context,
        builder: (context) {
          return TextDialog(
            controller: controller,
            fontSize: fontSize,
            onFinished: () => onFinished(context),
            color: color,
            textDelegate: textDelegate,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(
                fontSize: fontSize, fontWeight: FontWeight.bold, color: color),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              border: InputBorder.none,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
                child: Text(
                  textDelegate.done,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: onFinished),
          ),
        ],
      ),
    );
  }
}
