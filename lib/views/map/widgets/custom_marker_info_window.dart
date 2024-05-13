import 'dart:io';

import 'package:flutter/material.dart';
import 'package:footsteps/models/footprint.dart';
import 'package:footsteps/utils/widgets/blank_image_placeholder.dart';
import 'package:footsteps/utils/widgets/rounded_container.dart';

class CustomMarkerInfoWindow extends StatelessWidget {
  const CustomMarkerInfoWindow({
    super.key,
    required this.footprint,
    required this.onEdit,
    required this.onClose,
  });

  final Footprint footprint;
  final Function(Footprint) onEdit;
  final Function() onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, bottom: 15.0),
      child: RoundedContainer(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        radius: 10,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child:
                    footprint.imagePath == null || footprint.imagePath!.isEmpty
                        ? const BlankImagePlaceholder()
                        : Image.file(
                            File(footprint.imagePath!),
                            width: 70,
                            fit: BoxFit.cover,
                          ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      footprint.title.isEmpty ? "No Title" : footprint.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Latitude: ${footprint.latitude}",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                    ),
                    Text(
                      "Longitude: ${footprint.longitude}",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () => onEdit(footprint),
                            child: Text(
                              'Edit',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                          TextButton(
                            onPressed: () => onClose(),
                            child: Text(
                              'Close',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
