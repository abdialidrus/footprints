import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:footsteps/controllers/camera/custom_camera_controller.dart';
import 'package:get/get.dart';
//import 'dart:math' as math;

class CustomCameraView extends GetView<CustomCameraController> {
  const CustomCameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => controller.isCameraInitialized.value
            ? FutureBuilder<void>(
                future: controller.initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return SafeArea(
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child:
                                FullscreenCameraPreview(controller: controller),
                          ),
                          // Expanded(
                          //   flex: 1,
                          //   child:
                          //       FullscreenCameraPreview(controller: controller),
                          // ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              height: 120,
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  _cameraControlWidget(context),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _cameraControlWidget(context) {
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () async {
                try {
                  await controller.initializeControllerFuture;
                  final image = await controller.cameraController.takePicture();

                  if (!context.mounted) return;
                  controller.saveFootprintImage(image.path);
                  Get.back<String>(result: image.path);
                } catch (e) {
                  print(e);
                }
              },
              child: const Icon(
                Icons.camera,
                color: Colors.black,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FullscreenCameraPreview extends StatelessWidget {
  const FullscreenCameraPreview({
    super.key,
    required this.controller,
  });

  final CustomCameraController controller;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var scale =
        size.aspectRatio * controller.cameraController.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;
    final double mirror = 0; //selectedCameraIndex == 1 ? math.pi : 0;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(mirror),
      child: Transform.scale(
        scale: scale,
        child: Center(
          child: CameraPreview(controller.cameraController),
        ),
      ),
    );
  }
}
