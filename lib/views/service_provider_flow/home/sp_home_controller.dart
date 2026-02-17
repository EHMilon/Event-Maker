import 'package:event_maker/data/models/dashboard_stats_model.dart';
import 'package:event_maker/data/models/order_model.dart';
import 'package:event_maker/data/services/connectivity_service.dart';
import 'package:get/get.dart';

class SPHomeController extends GetxController {
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();

  final isLoading = true.obs;
  final stats = DashboardStats.empty().obs;
  final activeOrders = <OrderModel>[].obs;
  final hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    if (!_connectivityService.isConnected.value) {
      Get.snackbar('Error', 'noInternet'.tr);
      return;
    }

    try {
      isLoading.value = true;
      hasError.value = false;

      // FIXME: Replace with actual backend API call
      // Simulate 2s delay as requested
      await Future.delayed(const Duration(seconds: 2));

      // Mock data representing backend response
      final mockResponse = {
        'total_earnings': '2,788 AED',
        'total_requests': 80,
        'completed_orders': 62,
        'pending_orders': 18,
        'total_balance': '2,788 USD',
        'earnings_change': '12.3%',
        'requests_change': '12.3%',
        'completed_change': '4.3%',
        'pending_change': '12.3%',
        'is_earnings_up': true,
        'is_requests_up': true,
        'is_completed_up': false,
        'is_pending_up': true,
      };

      stats.value = DashboardStats.fromJson(mockResponse);

      // Mock active orders response
      final mockOrdersResponse = [
        {
          'id': '1',
          'title': 'Catering services for home event',
          'image_url': 'https://picsum.photos/id/40/120/120',
          'badge_count': 2,
          'status': 'active',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'id': '2',
          'title': 'Outdoor party catering services',
          'image_url': 'https://picsum.photos/id/41/120/120',
          'badge_count': 5,
          'status': 'active',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'id': '3',
          'title': 'Corporate inhouse event managment',
          'image_url': 'https://picsum.photos/id/42/120/120',
          'badge_count': 1,
          'status': 'active',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'id': '4',
          'title': 'Wedding catering service',
          'image_url': 'https://picsum.photos/id/43/120/120',
          'badge_count': 3,
          'status': 'active',
          'created_at': DateTime.now().toIso8601String(),
        },
      ];

      activeOrders.value = mockOrdersResponse
          .map((e) => OrderModel.fromJson(e))
          .toList();
    } catch (e) {
      hasError.value = true;
      Get.snackbar('Error', 'serverError'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  // TODO: Add methods to handle quick actions and orders
  void retry() {
    fetchDashboardData();
  }
}
