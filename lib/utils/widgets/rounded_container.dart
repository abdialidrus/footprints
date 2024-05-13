import 'package:flutter/material.dart';

class RoundedContainer extends StatelessWidget {
  final Widget child;
  final double radius;
  final double? width;
  final Color backgroundColor;
  const RoundedContainer(
      {super.key,
      required this.child,
      this.radius = 100,
      this.backgroundColor = Colors.white,
      this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            offset: const Offset(
              2.0,
              3.0,
            ),
            blurRadius: 8.0,
            spreadRadius: 0.2,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(0.0, 0.0),
            blurRadius: 0.0,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: child,
    );
  }
}
