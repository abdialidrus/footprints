import 'dart:io';

import 'package:flutter/material.dart';
import 'package:footsteps/models/footprint.dart';
import 'package:footsteps/controllers/map/map_controller.dart';
import 'package:footsteps/utils/widgets/blank_image_placeholder.dart';
import 'package:footsteps/utils/widgets/rounded_container.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class FootprintList extends StatelessWidget {
  const FootprintList({
    super.key,
    required this.controller,
    required this.footprints,
  });

  final MapController controller;
  final List<Footprint> footprints;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ScrollablePositionedList.builder(
        padding: const EdgeInsets.only(right: 15.0),
        itemCount: footprints.length,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        initialScrollIndex: controller.initialScrollIndex,
        itemScrollController: controller.itemScrollController,
        scrollOffsetController: controller.scrollOffsetController,
        itemPositionsListener: controller.itemPositionsListener,
        scrollOffsetListener: controller.scrollOffsetListener,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              controller.onFootprintListItemTap(index);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0, bottom: 15.0),
              child: RoundedContainer(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                radius: 10,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          controller.navigateToCamera(footprints[index].id);
                        },
                        child: footprints[index].imagePath == null
                            ? const BlankImagePlaceholder()
                            : Image.file(
                                File(footprints[index].imagePath!),
                                width: 60,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            footprints[index].title.isEmpty
                                ? "No Title"
                                : footprints[index].title,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Latitude: ${footprints[index].latitude}",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                          ),
                          Text(
                            "Longitude: ${footprints[index].longitude}",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
