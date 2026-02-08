import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/service_model.dart';
import '../../../views/service_provider_flow/services/sp_services_controller.dart';

class AddTrainingController extends GetxController {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final timeController = TextEditingController();
  final dateController = TextEditingController();
  final locationController = TextEditingController();
  final chargesController = TextEditingController();

  var isLoading = false.obs;

  /// Initialize controller with existing service data for editing
  void initWithService(ServiceModel service) {
    titleController.text = service.title;
    descriptionController.text = service.description;
    locationController.text = service.location;
    chargesController.text = service.basePrice?.toString() ?? '';
    if (service.date != null) {
      dateController.text = _formatDate(service.date!);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

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

  Future<bool> addTraining({bool isEdit = false, ServiceModel? existingService}) async {
    isLoading.value = true;
    // Add 2s delay as requested in user global rules
    await Future.delayed(const Duration(seconds: 2));

    // Parse the date
    DateTime? parsedDate;
    if (dateController.text.isNotEmpty) {
      final parts = dateController.text.split('/');
      if (parts.length == 3) {
        parsedDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    }

    // Create the service model from form data
    final newService = ServiceModel(
      id: existingService?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text,
      description: descriptionController.text,
      location: locationController.text,
      images: existingService?.images ?? [],
      type: ServiceType.training,
      provider: existingService?.provider ?? ServiceProvider(
        name: 'Current User',
        role: 'Training Provider',
        imageUrl: 'https://i.pravatar.cc/150?u=user',
      ),
      basePrice: double.tryParse(chargesController.text) ?? 0,
      priceUnit: 'AED',
      date: parsedDate,
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
    Get.snackbar(
      'Success',
      isEdit ? 'Training updated successfully' : 'Training added successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    return true;
  }
}
