import 'package:flutter/material.dart';

/// Microsoft-style 2×2 grid icon
class MsGrid extends StatelessWidget {
  final Color color;
  final double size;

  const MsGrid({super.key, required this.color, this.size = 18});

  @override
  Widget build(BuildContext context) {
    final dot = size * 0.42;
    final gap = size * 0.16;
    return SizedBox(
      width: size,
      height: size,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _sq(dot), SizedBox(width: gap), _sq(dot),
          ]),
          SizedBox(height: gap),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _sq(dot), SizedBox(width: gap), _sq(dot),
          ]),
        ],
      ),
    );
  }

  Widget _sq(double s) => Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      );
}
