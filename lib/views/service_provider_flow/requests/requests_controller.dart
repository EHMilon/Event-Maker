import 'package:event_maker/data/mock/mock_data.dart';
import 'package:event_maker/data/models/service_model.dart';
import 'package:get/get.dart';

class RequestsController extends GetxController {
  final isLoading = true.obs;
  final requests = <ServiceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    isLoading.value = true;
    // Simulate 2s delay as requested in user rules
    await Future.delayed(const Duration(seconds: 2));
    requests.assignAll(MockData.requests);
    isLoading.value = false;
  }

  void acceptRequest(ServiceModel request) {
    // Logic to accept request
    requests.remove(request);
  }

  void rejectRequest(ServiceModel request) {
    // Logic to reject request
    requests.remove(request);
  }
}
