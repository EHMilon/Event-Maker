import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddTrainingController extends GetxController {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final timeController = TextEditingController();
  final dateController = TextEditingController();
  final locationController = TextEditingController();
  final chargesController = TextEditingController();

  var isLoading = false.obs;

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    timeController.dispose();
    dateController.dispose();
    locationController.dispose();
    chargesController.dispose();
    super.onClose();
  }

  Future<void> addTraining() async {
    isLoading.value = true;
    // Add 2s delay as requested in user global rules
    await Future.delayed(const Duration(seconds: 2));

    // TODO: Implement actual API call

    isLoading.value = false;
    Get.back();
    Get.snackbar(
      'Success',
      'Training added successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
