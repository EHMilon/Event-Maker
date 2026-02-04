import 'package:get/get.dart';

class HomeController extends GetxController {
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    isLoading.value = true;
    // Simulate 2s delay as requested
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
  }

  // TODO: Add methods for searching, filtering, etc.
  // FIXME: Handle network connectivity
}
