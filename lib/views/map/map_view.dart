import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:footsteps/controllers/map/map_controller.dart';
import 'package:footsteps/views/map/widgets/edit_footprint_form.dart';
import 'package:footsteps/views/map/widgets/finding_location_loading.dart';
import 'package:footsteps/views/map/widgets/map_guide.dart';
import 'package:footsteps/views/map/widgets/new_footprint_form.dart';
import 'package:footsteps/utils/widgets/rounded_container.dart';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MapView extends GetView<MapController> {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<MapController>(builder: (controller) {
        return Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
              initialCameraPosition: controller.initialCameraPosition,
              markers: {...controller.markers},
              onMapCreated: (GoogleMapController mapController) {
                if (!controller.mapController.isCompleted) {
                  controller.mapController.complete(mapController);
                  controller.customInfoWindowController.googleMapController =
                      mapController;
                }
              },
              onCameraMove: (position) {
                controller.onMapCameraMove(position);
              },
              onCameraIdle: () => controller.onCameraIdle(),
              onTap: (latLng) {
                controller.clearNewMarkerPosition();
              },
              onLongPress: (latLng) {
                controller.onMapTap(latLng);
              },
            ),
            CustomInfoWindow(
              controller: controller.customInfoWindowController,
              height: 170,
              width: 300,
              offset: 30,
            ),
            const Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: SafeArea(
                child: MapGuide(),
              ),
            ),
            controller.isFindingCurrentLocation.value
                ? const Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: FindingLocationLoading(),
                    ),
                  )
                : const SizedBox.shrink(),
            controller.newFootprintMarkerPosition != null
                ? Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: NewFootprintForm(
                      controller: controller,
                      latLngText: controller.getLatLngText(
                          controller.newFootprintMarkerPosition!),
                      textEditingController:
                          controller.newFootprintNameController,
                      onCancel: () => controller.clearNewMarkerPosition(),
                      onSave: (imagePath) =>
                          controller.saveFootprint(imagePath, null),
                    ),
                  )
                : const SizedBox.shrink(),
            Obx(
              () => !controller.isUserMarkerVisible.value &&
                      !controller.isFindingCurrentLocation.value &&
                      controller.newFootprintMarkerPosition == null &&
                      !controller.isFocusing.value
                  ? Positioned(
                      bottom: 15.0,
                      right: 15.0,
                      child: RoundedContainer(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        child: InkWell(
                          onTap: () => controller.returnToMyLocation(),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.locateFixed),
                                const SizedBox(width: 5),
                                Text(
                                  "Return to my location",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Obx(() => controller.isEditing.value
                ? Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: EditFootprintForm(
                      footprint: controller.editingFootprint!,
                      onCancel: () {
                        controller.editingFootprint = null;
                        controller.isEditing.value = false;
                      },
                      onSave: (imagePath, title) =>
                          controller.saveFootprint(imagePath, title),
                      onDelete: () => controller.deleteFootprint(),
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        );
      }),
    );
  }
}
