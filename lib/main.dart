import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:footsteps/firebase_options.dart';
import 'package:footsteps/models/footprint.dart';
import 'package:footsteps/views/camera/bindings/camera_binding.dart';
import 'package:footsteps/views/camera/custom_camera_view.dart';
import 'package:footsteps/views/map/bindings/map_binding.dart';
import 'package:footsteps/views/map/map_view.dart';
import 'package:get/route_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';

const footprintBoxName = 'footprints';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  Hive.registerAdapter(FootprintAdapter());
  await Hive.openBox<Footprint>(footprintBoxName);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Footprints',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/index',
      getPages: [
        GetPage(
          name: '/index',
          page: () => const MapView(),
          binding: MapBinding(),
        ),
        GetPage(
          name: '/camera',
          page: () => const CustomCameraView(),
          binding: CameraBinding(),
        ),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}
