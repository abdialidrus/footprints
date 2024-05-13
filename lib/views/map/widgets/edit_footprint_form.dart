import 'dart:io';

import 'package:flutter/material.dart';
import 'package:footsteps/models/footprint.dart';
import 'package:footsteps/controllers/map/new_footprint_form_controller.dart';
import 'package:footsteps/utils/widgets/blank_image_placeholder.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EditFootprintForm extends StatelessWidget {
  EditFootprintForm({
    super.key,
    required this.onCancel,
    required this.onSave,
    required this.footprint,
    required this.onDelete,
  });

  final Footprint footprint;
  final TextEditingController textEditingController = TextEditingController();
  final Function() onCancel;
  final Function(String, String) onSave;
  final Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NewFootprintFormController());
    controller.newImagePath("");
    textEditingController.text = footprint.title;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Edit Footprint",
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(width: 5),
                            const Icon(LucideIcons.footprints, size: 20),
                          ],
                        ),
                        Text(
                          "${footprint.latitude}, ${footprint.longitude}",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => onDelete(),
                    iconSize: 20,
                    color: Colors.red,
                    icon: const Icon(LucideIcons.trash),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        controller.navigateToCameraView();
                      },
                      child: footprint.imagePath == null ||
                              footprint.imagePath!.isEmpty
                          ? Obx(() => controller.newImagePath.value.isNotEmpty
                              ? Image.file(
                                  File(controller.newImagePath.value),
                                  width: 70,
                                  fit: BoxFit.cover,
                                )
                              : const BlankImagePlaceholder())
                          : Image.file(
                              File(footprint.imagePath!),
                              width: 70,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: textEditingController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Give it a name',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton.tonal(
                    onPressed: onCancel,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: () => onSave(
                      controller.newImagePath.value == ""
                          ? footprint.imagePath!
                          : controller.newImagePath.value,
                      textEditingController.text,
                    ),
                    child: const Text('Save changes'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
