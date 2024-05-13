import 'package:get/get.dart';

class NewFootprintFormController extends GetxController {
  final newImagePath = "".obs;

  void navigateToCameraView() async {
    var imagePath =
        await Get.toNamed('/camera', arguments: {'footprintId': ""});

    if (imagePath != null) {
      newImagePath(imagePath);
    }
  }
}
