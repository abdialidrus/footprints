import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BlankImagePlaceholder extends StatelessWidget {
  const BlankImagePlaceholder({
    super.key,
    this.size = 60,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image(
          image: const AssetImage('assets/images/img_placeholder.png'),
          width: size,
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: Icon(
            LucideIcons.plus,
            size: 15,
            color: Colors.grey.shade100,
          ),
        )
      ],
    );
  }
}
