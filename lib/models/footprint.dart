import 'package:hive/hive.dart';

part 'footprint.g.dart';

@HiveType(typeId: 1)
class Footprint {
  Footprint({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    this.imagePath,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double latitude;

  @HiveField(3)
  double longitude;

  @HiveField(4)
  String? imagePath;
}
