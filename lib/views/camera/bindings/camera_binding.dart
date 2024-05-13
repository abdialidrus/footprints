import 'package:footsteps/controllers/camera/custom_camera_controller.dart';
import 'package:get/get.dart';

class CameraBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomCameraController>(
      () => CustomCameraController(),
    );
  }
}
