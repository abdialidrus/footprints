import 'package:footsteps/controllers/map/map_controller.dart';
import 'package:get/get.dart';

class MapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MapController>(
      () => MapController(),
    );
  }
}
