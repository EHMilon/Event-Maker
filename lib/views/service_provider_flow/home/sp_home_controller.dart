import 'package:event_maker/models/dashboard_stats_model.dart';
import 'package:event_maker/models/order_model.dart';
import 'package:event_maker/services/connectivity_service.dart';
import 'package:event_maker/utils/user_preferences.dart';
import 'package:get/get.dart';

class SPHomeController extends GetxController {
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();

  final isLoading = true.obs;
  final stats = DashboardStats.empty().obs;
  final activeOrders = <OrderModel>[].obs;
  final hasError = false.obs;
  final userName = ''.obs;
  final businessName = ''.obs;
  
  // TODO: Set to false when backend is ready
  final bool useMockData = true;

  @override
  void onInit() {
    super.onInit();
    fetchUserInfo();
    fetchDashboardData();
  }

  Future<void> fetchUserInfo() async {
    try {
      final userDetails = await UserPreferences.getUserDetails();
      if (userDetails != null) {
        userName.value = userDetails['name'] ?? '';
        // TODO: Fetch business name from provider profile when backend is ready
        // For now, use user name as business name
        businessName.value = userName.value;
      }
    } catch (e) {
      // Silently fail - business name will be empty
    }
  }

  Future<void> fetchDashboardData() async {
    if (!_connectivityService.isConnected.value) {
      Get.snackbar('Error', 'noInternet'.tr);
      return;
    }

    try {
      isLoading.value = true;
      hasError.value = false;

      if (useMockData) {
        // Mock data for development - remove when backend is ready
        await Future.delayed(const Duration(seconds: 2));
        
        // Mock dashboard stats
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

        // Mock active orders
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
      } else {
        // TODO: Uncomment and use when backend is ready
        /*
        // Fetch dashboard stats from API
        final statsResponse = await _apiService.get(ApiConstant.providerDashboard);
        if (statsResponse != null && statsResponse['data'] != null) {
          stats.value = DashboardStats.fromJson(statsResponse['data']);
        }

        // Fetch active orders from API
        final ordersResponse = await _apiService.get(ApiConstant.providerActiveOrders);
        if (ordersResponse != null && ordersResponse['data'] != null) {
          final List<dynamic> ordersList = ordersResponse['data'];
          activeOrders.value = ordersList
              .map((e) => OrderModel.fromJson(e))
              .toList();
        }
        */
      }
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
