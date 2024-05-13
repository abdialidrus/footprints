import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:footsteps/main.dart';
import 'package:footsteps/models/footprint.dart';
import 'package:footsteps/views/map/widgets/custom_marker_info_window.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';

import 'package:location/location.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MapController extends GetxController {
  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();

  var initialCameraPosition = const CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Position? userCurrentPosition;
  LocationData? currentLocation;
  LatLng? newFootprintMarkerPosition;
  double distanceToUserLocation = 0.0;

  var footprints = <Footprint>[].obs;
  late Box<Footprint> footprintBox;

  final isFindingCurrentLocation = true.obs;
  final markers = const <Marker>[].obs;
  var isFocusing = false.obs;
  var isUserMarkerVisible = false.obs;
  var isEditing = false.obs;
  Footprint? editingFootprint;

  final TextEditingController newFootprintNameController =
      TextEditingController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ScrollOffsetListener scrollOffsetListener =
      ScrollOffsetListener.create();
  var initialScrollIndex = 0;

  final CustomInfoWindowController customInfoWindowController =
      CustomInfoWindowController();

  @override
  void onInit() async {
    super.onInit();
    _getUserCurrentPosition();
    itemPositionsListener.itemPositions.addListener(() {
      debugPrint("List Position => ${itemPositionsListener.itemPositions}");
    });

    setupHiveBox();
    loadFootprints();
  }

  @override
  void onClose() {
    itemPositionsListener.itemPositions.removeListener(() {});
    customInfoWindowController.dispose();
    super.onClose();
  }

  void saveFootprintToBox(String id, String name, double latitude,
      double longitude, String? imagePath) {
    final newFootprint = Footprint(
      id: id,
      title: name,
      latitude: latitude,
      longitude: longitude,
      imagePath: imagePath,
    );

    footprintBox.put(id, newFootprint);
    loadFootprints();
  }

  void loadFootprints() {
    footprints(footprintBox.values.toList());
    update();
  }

  void setupHiveBox() {
    footprintBox = Hive.box(footprintBoxName);
  }

  Footprint? getFootprint(footprintId) {
    return footprintBox.get(footprintId);
  }

  void updateFootprint(String id, String path) {
    final footprint = getFootprint(id);
    if (footprint != null) {
      footprint.imagePath = path;
      footprintBox.put(id, footprint);
    }

    loadFootprints();
  }

  void deleteFootprintFromBox(String id) {
    footprintBox.delete(id);
    loadFootprints();
  }

  void onMapCameraMove(CameraPosition position) {
    if (!isFocusing.value) {
      initialCameraPosition = position;
    }

    customInfoWindowController.onCameraMove!();
  }

  void onCameraIdle() async {
    final userLocationMarker = markers.firstWhereOrNull(
      (element) => element.markerId.value == 'currentLocation',
    );
    if (userLocationMarker != null) {
      final GoogleMapController googleMapController =
          await mapController.future;
      final visibleLatLngBounds = await googleMapController.getVisibleRegion();
      final isMarkerVisible =
          visibleLatLngBounds.contains(userLocationMarker.position);
      debugPrint("isMarkerVisible => $isMarkerVisible");
      isUserMarkerVisible(isMarkerVisible);
    }
  }

  void returnToInitialCameraPosition() {
    animateMapToPosition(initialCameraPosition.target.latitude,
        initialCameraPosition.target.longitude, initialCameraPosition.zoom);
  }

  void _getUserCurrentPosition() async {
    isFindingCurrentLocation(true);
    await _determinePosition().then((position) async {
      userCurrentPosition = position;
      addMarker(userCurrentPosition!.latitude, userCurrentPosition!.longitude,
          'currentLocation', 'user', 'Your current location');
      await animateMapToCurrentLocation(position.latitude, position.longitude);
      loadSavedPositions(false);
      // listenToUserLocationChange();
    }).onError((error, stackTrace) {
      debugPrint("$error");
    });
    isFindingCurrentLocation(false);
    update();
  }

  Future<void> animateMapToPosition(
      double latitude, double longitude, double zoomLevel) async {
    final GoogleMapController controller = await mapController.future;
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: zoomLevel,
    )));
  }

  Future<void> animateMapToCurrentLocation(
    double latitude,
    double longitude,
  ) async {
    await animateMapToPosition(latitude, longitude, 14.4746);
  }

  Future<void> animateMapToFootprintLocation(
    double latitude,
    double longitude,
  ) async {
    final zoom =
        initialCameraPosition.zoom < 15.0 ? 15.0 : initialCameraPosition.zoom;
    await animateMapToPosition(latitude, longitude, zoom);
    isFocusing(true);
  }

  void resetMapZoom() {
    isFocusing(false);
    isEditing(false);
    returnToInitialCameraPosition();
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void listenToUserLocationChange() async {
    Location location = Location();
    location.getLocation().then(
      (location) {
        currentLocation = location;
      },
    );

    location.onLocationChanged.listen(
      (newLoc) {
        currentLocation = newLoc;
        animateMapToPosition(newLoc.latitude!, newLoc.longitude!, 14.4746);
        // markers.clear();
        addMarker(newLoc.latitude!, newLoc.longitude!, 'currentLocation',
            'user', 'Your current location');
      },
    );
  }

  void removeMarker(String id) {
    var savedIndex =
        markers.indexWhere((element) => element.markerId.value == id);

    if (savedIndex != -1) {
      markers.removeAt(savedIndex);
    }
  }

  void addMarker(
      double latitude, double longitude, String id, String type, String title) {
    var savedIndex =
        markers.indexWhere((element) => element.markerId.value == id);

    if (savedIndex != -1) {
      markers.removeAt(savedIndex);
    }

    markers.add(
      Marker(
        markerId: MarkerId(id),
        position: LatLng(latitude, longitude),
        icon: type == 'user'
            ? BitmapDescriptor.defaultMarker
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        draggable: type != 'user' && type != 'footprint',
        consumeTapEvents: true,
        onTap: () async {
          debugPrint("Marker Tapped");
          onMarkerTap(id, latitude, longitude);
        },
        // infoWindow: InfoWindow(
        //   title: title.isEmpty ? "No Title" : title,
        //   snippet: "$latitude, $longitude",
        //   anchor: const Offset(0.5, 0.0),
        //   onTap: () {},
        // ),
        onDragEnd: (newLatLng) {
          userCurrentPosition = Position(
            latitude: newLatLng.latitude,
            longitude: newLatLng.longitude,
            timestamp: userCurrentPosition?.timestamp ?? DateTime.now(),
            accuracy: userCurrentPosition?.accuracy ?? 1,
            altitude: userCurrentPosition?.altitude ?? 1,
            altitudeAccuracy: userCurrentPosition?.altitudeAccuracy ?? 1,
            heading: userCurrentPosition?.heading ?? 1,
            headingAccuracy: userCurrentPosition?.headingAccuracy ?? 1,
            speed: userCurrentPosition?.speed ?? 1,
            speedAccuracy: userCurrentPosition?.speedAccuracy ?? 1,
          );
        },
      ),
    );

    update();
  }

  void saveFootprint(String imagePath, String? title) async {
    if (newFootprintMarkerPosition == null && editingFootprint == null) return;

    final footprintName = title ?? newFootprintNameController.text;

    final latitude =
        editingFootprint?.latitude ?? newFootprintMarkerPosition!.latitude;
    final longitude =
        editingFootprint?.longitude ?? newFootprintMarkerPosition!.longitude;
    final footprintId = "footprint_${latitude}_$longitude";

    saveFootprintToBox(
        footprintId, footprintName, latitude, longitude, imagePath);

    if (title != null) {
      editingFootprint = null;
      isEditing(false);
    }

    clearNewMarkerPosition();
    newFootprintNameController.clear();
    await loadSavedPositions(true);

    showCustomMarkerInfoWindow(footprintId);
  }

  Future<void> toggleFocusMapToMarkerPosition(
      String markerId, double latitude, double longitude) async {
    final isMarkerInfoShown = await toggleMarkerInfoWindow(markerId, true);
    if (isMarkerInfoShown) {
      isFocusing(true);
      animateMapToFootprintLocation(
        latitude,
        longitude,
      );
    } else {
      isFocusing(false);
      returnToInitialCameraPosition();
    }
  }

  void focusMapToMarkerPosition(
      String markerId, double latitude, double longitude) async {
    final isMarkerInfoShown = await toggleMarkerInfoWindow(markerId, false);
    if (isMarkerInfoShown) {
      isFocusing(true);
      animateMapToFootprintLocation(
        latitude,
        longitude,
      );
    }
  }

  Future<bool> toggleMarkerInfoWindow(String id, bool needToHide) async {
    GoogleMapController googleMapController = await mapController.future;
    final isMarkerShown =
        await googleMapController.isMarkerInfoWindowShown(MarkerId(id));
    if (isMarkerShown && needToHide) {
      googleMapController.hideMarkerInfoWindow(MarkerId(id));
      return false;
    }
    googleMapController.showMarkerInfoWindow(MarkerId(id));
    return true;
  }

  void addNewFootprint(double latitude, double longitude) {
    animateMapToFootprintLocation(
      latitude,
      longitude,
    );
    newFootprintMarkerPosition = LatLng(latitude, longitude);
    addMarker(
        latitude, longitude, "newFootprint", "footprint", 'New Footprint');
  }

  void clearNewMarkerPosition() {
    resetMapZoom();
    newFootprintMarkerPosition = null;
    removeMarker("newFootprint");
    update();
  }

  String getLatLngText(LatLng latLng) {
    return "${latLng.latitude}, ${latLng.longitude}";
  }

  Future<void> loadSavedPositions(bool showLastAddedMarkerInfoWindow) async {
    markers.removeWhere((marker) => marker.markerId.value != "currentLocation");

    for (var footprint in footprints) {
      addMarker(
        footprint.latitude,
        footprint.longitude,
        footprint.id,
        "footprint",
        footprint.title,
      );
    }
  }

  void onMapTap(LatLng latLng) {
    if (isFocusing.value) {
      clearNewMarkerPosition();
    } else {
      addNewFootprint(
        latLng.latitude,
        latLng.longitude,
      );
    }

    customInfoWindowController.hideInfoWindow!();
  }

  void onFootprintListItemTap(int index) {
    focusMapToMarkerPosition(
      footprints[index].id,
      footprints[index].latitude,
      footprints[index].longitude,
    );

    scrollFootprintListToIndex(index);
  }

  int getFootprintItemIndex(String footprintId) {
    if (footprints.isNotEmpty) {
      final footprintIndex = footprints.indexWhere(
        (element) => element.id == footprintId,
      );

      return footprintIndex;
    }

    return -1;
  }

  void scrollFootprintListToIndex(int index) {
    if (!itemScrollController.isAttached) {
      initialScrollIndex = index;
      return;
    }

    itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic);
  }

  void onMarkerTap(String id, double latitude, double longitude) async {
    await toggleFocusMapToMarkerPosition(id, latitude, longitude);

    final footprintIndex = getFootprintItemIndex(id);

    if (footprintIndex != -1) {
      scrollFootprintListToIndex(footprintIndex);
    }

    showCustomMarkerInfoWindow(id);
  }

  void showCustomMarkerInfoWindow(String id) {
    final footprint = getFootprint(id);
    if (footprint != null) {
      addCustomMarkerInfoWindow(footprint);
    }
  }

  void addCustomMarkerInfoWindow(Footprint footprint) {
    customInfoWindowController.addInfoWindow!(
      CustomMarkerInfoWindow(
        footprint: footprint,
        onEdit: (footprint) {
          isEditing(true);
          editingFootprint = footprint;
        },
        onClose: () => customInfoWindowController.hideInfoWindow!(),
      ),
      LatLng(footprint.latitude, footprint.longitude),
    );
  }

  void navigateToCamera(String id) {
    Get.toNamed('/camera', arguments: {'footprintId': id});
  }

  void returnToMyLocation() {
    if (userCurrentPosition != null) {
      animateMapToCurrentLocation(
        userCurrentPosition!.latitude,
        userCurrentPosition!.longitude,
      );
    }
  }

  void deleteFootprint() async {
    if (editingFootprint == null) return;

    deleteFootprintFromBox(editingFootprint!.id);

    editingFootprint = null;
    isEditing(false);

    clearNewMarkerPosition();
    await loadSavedPositions(true);
    customInfoWindowController.hideInfoWindow!();
    update();
  }
}
