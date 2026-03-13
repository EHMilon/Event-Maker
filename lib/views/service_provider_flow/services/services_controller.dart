import 'package:event_maker/data/models/service_model.dart';
import 'package:event_maker/data/services/service_repository.dart';
import 'package:event_maker/shared/utils/logger.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Lightweight controller for shared service lists (customer flows, notifications, etc.)
class ServicesController extends GetxController {
  final RxList<ServiceModel> services = <ServiceModel>[].obs;
  final RxBool isLoading = true.obs;
  final TextEditingController searchController = TextEditingController();
  final ServiceRepository _repository = const ServiceRepository();

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  Future<void> fetchServices() async {
    try {
      isLoading.value = true;
      final response = await _repository.fetchServices();
      services.assignAll(response.services);
      Log.success('Loaded ${services.length} shared services from repo');
    } catch (e) {
      Get.snackbar('Error', 'Failed to load services: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
