import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/service_model.dart';
import '../../../views/service_provider_flow/services/sp_services_controller.dart';

class AddServiceController extends GetxController {
  // Step 1: Details
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  var outsideLocation = false.obs;
  var availability = <String>[].obs; // Days like 'Mon', 'Tue'

  // Step 2: Packages
  var packages = <PackageFormData>[].obs;

  // Step 3: Timings
  var timings =
      <String, Map<String, dynamic>>{}.obs; // Day: {start: '', end: ''}

  var currentStep = 0.obs;
  var isLoading = false.obs;

  /// Initialize controller with existing service data for editing
  void initWithService(ServiceModel service) {
    titleController.text = service.title;
    descriptionController.text = service.description;
    locationController.text = service.location;
    if (service.packages != null) {
      packages.clear();
      for (var package in service.packages!) {
        final sp = PackageFormData();
        sp.nameController.text = package.name;
        sp.priceController.text = package.price.toString();
        sp.features.clear();
        sp.features.addAll(package.features);
        packages.add(sp);
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize with one empty package
    if (packages.isEmpty) {
      addPackage();
    }
  }

  void addPackage() {
    packages.add(PackageFormData());
  }

  void removePackage(int index) {
    if (packages.length > 1) {
      packages.removeAt(index);
    }
  }

  Future<bool> saveService({bool isEdit = false, ServiceModel? existingService}) async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));

    // Create the service model from form data
    final newService = ServiceModel(
      id: existingService?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text,
      description: descriptionController.text,
      location: locationController.text,
      images: existingService?.images ?? [],
      type: existingService?.type ?? ServiceType.photography,
      provider: existingService?.provider ?? ServiceProvider(
        name: 'Current User',
        role: 'Service Provider',
        imageUrl: 'https://i.pravatar.cc/150?u=user',
      ),
      basePrice: 0,
      priceUnit: 'AED',
      packages: packages.map((p) => ServicePackage(
        name: p.nameController.text,
        price: double.tryParse(p.priceController.text) ?? 0,
        features: p.features.where((f) => f.isNotEmpty).toList(),
      )).toList(),
    );

    // Update the services list
    final spController = Get.find<SPServicesController>();
    if (isEdit && existingService != null) {
      spController.updateService(newService);
    } else {
      spController.addService(newService);
    }

    isLoading.value = false;
    Get.back(result: true);
    Get.snackbar('Success', isEdit ? 'Service updated successfully' : 'Service added successfully');
    return true;
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.onClose();
  }
}

class PackageFormData {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  var features = <String>[].obs;

  PackageFormData() {
    features.add(''); // Start with one empty feature
  }
}
