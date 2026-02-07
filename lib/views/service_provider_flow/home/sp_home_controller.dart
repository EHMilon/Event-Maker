import 'package:get/get.dart';

class SPHomeController extends GetxController {
  final isLoading = true.obs;

  // Analytics data
  final totalEarnings = "2,788AED".obs;
  final totalRequests = 80.obs;
  final completedOrders = 62.obs;
  final pendingOrders = 18.obs;
  final totalBalance = "2,788 USD".obs;

  // Analytics changes
  final earningsChange = "12.3%".obs; // Up
  final requestsChange = "12.3%".obs; // Up
  final completedChange = "4.3%".obs; // Down
  final pendingChange = "12.3%".obs; // Up

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    // Simulate 2s delay as requested
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
  }

  // TODO: Add methods to handle quick actions and orders
}
