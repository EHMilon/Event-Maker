import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddEventController extends GetxController {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final timeController = TextEditingController();
  final dateController = TextEditingController();
  final locationController = TextEditingController();
  final chargesController = TextEditingController();
  final capacityController = TextEditingController();

  var isLoading = false.obs;

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    timeController.dispose();
    dateController.dispose();
    locationController.dispose();
    chargesController.dispose();
    capacityController.dispose();
    super.onClose();
  }

  Future<void> addEvent() async {
    isLoading.value = true;
    // Add 2s delay as requested in user global rules
    await Future.delayed(const Duration(seconds: 2));

    // TODO: Implement actual API call

    isLoading.value = false;
    Get.back();
    Get.snackbar(
      'Success',
      'Event added successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
