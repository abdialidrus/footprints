import 'package:flutter/material.dart';
import 'package:footsteps/utils/widgets/rounded_container.dart';
import 'package:lucide_icons/lucide_icons.dart';

class FootprintsCounter extends StatelessWidget {
  const FootprintsCounter({
    super.key,
    required this.footprintsCount,
    required this.onPressed,
  });

  final int footprintsCount;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
      child: Stack(
        children: [
          IconButton(
            onPressed: onPressed,
            icon: const Icon(LucideIcons.footprints),
          ),
          footprintsCount > 0
              ? Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    width: footprintsCount > 2 ? 30 : 18,
                    height: footprintsCount > 2 ? 21 : 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4848),
                      shape: BoxShape.circle,
                      border: Border.all(width: 1.5, color: Colors.white),
                    ),
                    child: Center(
                      child: Text(
                        footprintsCount.toString(),
                        style: const TextStyle(
                            fontSize: 9,
                            height: 1,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
