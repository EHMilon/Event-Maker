import 'package:event_maker/data/mock/mock_data.dart';
import 'package:event_maker/data/models/service_model.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class RequestsController extends GetxController {
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final requests = <ServiceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        hasError.value = true;
        errorMessage.value = 'noInternet'.tr;
        isLoading.value = false;
        return;
      }

      // Simulate 2s delay as requested in user rules
      await Future.delayed(const Duration(seconds: 2));

      // Simulate potential server error (commented out for now)
      // throw Exception('Server Error');

      requests.assignAll(MockData.requests);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'serverError'.tr;
    } finally {
      isLoading.value = false;
    }
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
