import 'package:event_maker/data/models/service_model.dart';
import 'package:event_maker/data/mock/mock_data.dart';
import 'package:get/get.dart';

class ServicesController extends GetxController {
  final RxList<ServiceModel> services = <ServiceModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxInt selectedPackageIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadServices();
  }

  Future<void> loadServices() async {
    try {
      isLoading.value = true;
      // Simulate network check (mock)
      // var connectivityResult = await (Connectivity().checkConnectivity());
      // if (connectivityResult == ConnectivityResult.none) {
      //   Get.snackbar('Error', 'No Internet Connection');
      //   isLoading.value = false;
      //   return;
      // }

      await Future.delayed(const Duration(seconds: 2)); // Simulate API delay

      // Use centralized mock data
      services.value = MockData.homeServices;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load services: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectPackage(int index) {
    selectedPackageIndex.value = index;
  }
}
