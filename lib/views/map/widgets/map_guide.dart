import 'package:flutter/material.dart';
import 'package:footsteps/utils/widgets/rounded_container.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MapGuide extends StatelessWidget {
  const MapGuide({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
      child: SizedBox(
        width: 300,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(LucideIcons.info, size: 30),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  "Tap and hold on the map to place a Footprint",
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
