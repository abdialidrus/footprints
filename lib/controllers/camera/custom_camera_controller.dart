import 'package:camera/camera.dart';
import 'package:footsteps/models/footprint.dart';
import 'package:footsteps/controllers/map/map_controller.dart';
import 'package:get/get.dart';

class CustomCameraController extends GetxController {
  late List<CameraDescription> cameras;
  late CameraController cameraController;
  late Future<void> initializeControllerFuture;
  final isCameraInitialized = false.obs;

  late MapController mapController;
  Footprint? footprint;

  @override
  void onInit() async {
    super.onInit();

    mapController = Get.find<MapController>();
    final footprintId = Get.arguments['footprintId'];
    footprint = mapController.getFootprint(footprintId);

    setupCamera();
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }

  Future<void> setupCamera() async {
    cameras = await availableCameras();

    if (cameras.isEmpty) {
      return;
    }

    // To display the current output from the Camera,
    // create a CameraController.
    cameraController = CameraController(
      // Get a specific camera from the list of available cameras.
      cameras.first,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    initializeControllerFuture = cameraController.initialize();

    isCameraInitialized.value = true;
  }

  void saveFootprintImage(String path) {
    if (footprint != null) {
      mapController.updateFootprint(footprint!.id, path);
    }
  }
}
