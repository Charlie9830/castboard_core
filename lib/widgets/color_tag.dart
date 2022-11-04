import 'package:flutter/material.dart';

class ColorTag extends StatelessWidget {
  final Color color;
  final double radius;
  const ColorTag({
    Key? key,
    required this.color,
    this.radius = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: radius,
        height: radius,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ));
  }
}
