import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddServiceController extends GetxController {
  // Step 1: Details
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  var outsideLocation = false.obs;
  var availability = <String>[].obs; // Days like 'Mon', 'Tue'

  // Step 2: Packages
  var packages = <ServicePackage>[].obs;

  // Step 3: Timings
  var timings =
      <String, Map<String, dynamic>>{}.obs; // Day: {start: '', end: ''}

  var currentStep = 0.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with one empty package
    addPackage();
  }

  void addPackage() {
    packages.add(ServicePackage());
  }

  void removePackage(int index) {
    if (packages.length > 1) {
      packages.removeAt(index);
    }
  }

  Future<void> saveService() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
    Get.back();
    Get.snackbar('Success', 'Service added successfully');
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.onClose();
  }
}

class ServicePackage {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  var features = <String>[].obs;

  ServicePackage() {
    features.add(''); // Start with one empty feature
  }
}
