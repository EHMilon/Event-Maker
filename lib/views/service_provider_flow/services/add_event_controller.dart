import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/service_model.dart';
import '../../../views/service_provider_flow/services/sp_services_controller.dart';

class AddEventController extends GetxController {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final timeController = TextEditingController();
  final dateController = TextEditingController();
  final locationController = TextEditingController();
  final chargesController = TextEditingController();
  final capacityController = TextEditingController();

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
    capacityController.dispose();
    super.onClose();
  }

  Future<bool> addEvent({bool isEdit = false, ServiceModel? existingService}) async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));

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

    final newService = ServiceModel(
      id: existingService?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text,
      description: descriptionController.text,
      location: locationController.text,
      images: existingService?.images ?? [],
      type: ServiceType.event,
      provider: existingService?.provider ?? ServiceProvider(
        name: 'Current User',
        role: 'Event Provider',
        imageUrl: 'https://i.pravatar.cc/150?u=user',
      ),
      basePrice: double.tryParse(chargesController.text) ?? 0,
      priceUnit: 'AED',
      date: parsedDate,
    );

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
      isEdit ? 'Event updated successfully' : 'Event added successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    return true;
  }
}
