import 'package:event_maker/models/dashboard_stats_model.dart';
import 'package:event_maker/models/order_model.dart';
import 'package:event_maker/models/provider_home_model.dart';
import 'package:event_maker/services/connectivity_service.dart';
import 'package:event_maker/services/provider_home_repository.dart';
import 'package:event_maker/views/profile/profile_controller.dart';
import 'package:get/get.dart';

/// Controller for Service Provider Home Screen
///
/// Handles fetching and managing provider home data including:
/// - Dashboard statistics (earnings, requests, completed, pending)
/// - Active orders grouped by service
/// - User information display
class SPHomeController extends GetxController {
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();
  final ProviderHomeRepository _repository = ProviderHomeRepository();

  // Use ProfileController directly for realtime user data
  ProfileController get _profileController => Get.find<ProfileController>();

  // Loading and error states
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Realtime user info from ProfileController (api/providers/my-profile)
  String get userName => _profileController.userName.value;
  String get businessName =>
      _profileController.providerProfile.value?.companyName ?? '';

  // Legacy dashboard stats (for backward compatibility with UI)
  final stats = DashboardStats.empty().obs;

  // Active orders for UI display
  final activeOrders = <OrderModel>[].obs;

  // Raw provider home data from API
  final providerHomeData = ProviderHomeData.empty().obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  /// Fetches dashboard data from API
  Future<void> fetchDashboardData() async {
    if (!_connectivityService.isConnected.value) {
      Get.snackbar('Error', 'noInternet'.tr);
      return;
    }

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      await _loadRealData();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'serverError'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads real data from API
  Future<void> _loadRealData() async {
    final data = await _repository.fetchProviderHomeData();
    providerHomeData.value = data;

    // Convert API data to UI-compatible models
    _updateStatsFromApi(data);
    _updateActiveOrdersFromApi(data);
  }

  /// Updates dashboard stats from API data
  void _updateStatsFromApi(ProviderHomeData data) {
    final analytics = data.analytics;

    stats.value = DashboardStats(
      totalEarnings: analytics.totalEarnings.displayValue,
      totalRequests: analytics.totalRequests.numericValue,
      completedOrders: analytics.completed.numericValue,
      pendingOrders: analytics.pending.numericValue,
      totalBalance: data.totalBalance.formattedAvailableBalance,
      earningsChange:
          '${analytics.totalEarnings.growthPercent.toStringAsFixed(1)}%',
      requestsChange:
          '${analytics.totalRequests.growthPercent.toStringAsFixed(1)}%',
      completedChange:
          '${analytics.completed.growthPercent.toStringAsFixed(1)}%',
      pendingChange: '${analytics.pending.growthPercent.toStringAsFixed(1)}%',
      isEarningsUp: analytics.totalEarnings.growthPercent >= 0,
      isRequestsUp: analytics.totalRequests.growthPercent >= 0,
      isCompletedUp: analytics.completed.growthPercent >= 0,
      isPendingUp: analytics.pending.growthPercent >= 0,
    );
  }

  /// Updates active orders from API data
  void _updateActiveOrdersFromApi(ProviderHomeData data) {
    final List<OrderModel> orders = [];

    for (final group in data.activeOrders.results) {
      // Create an OrderModel for each service group
      orders.add(
        OrderModel(
          id: group.serviceId.toString(),
          title: group.serviceTitle,
          imageUrl: group.serviceImage,
          badgeCount: group.totalBookings,
          status: 'active',
          createdAt: DateTime.now(),
        ),
      );
    }

    activeOrders.value = orders;
  }

  /// Refreshes data (for pull-to-refresh)
  Future<void> refreshData() async {
    try {
      // Refresh provider profile data to get latest name/company
      await _profileController.fetchProviderProfile();

      final data = await _repository.refreshProviderHomeData();
      providerHomeData.value = data;
      _updateStatsFromApi(data);
      _updateActiveOrdersFromApi(data);
    } catch (e) {
      Get.snackbar('Error', 'Failed to refresh: $e');
    }
  }

  /// Retries fetching data after error
  void retry() {
    fetchDashboardData();
  }

  /// Gets active orders for a specific service
  /// Used when navigating to service order details
  ServiceOrderGroup? getServiceOrderGroup(String serviceId) {
    try {
      final id = int.tryParse(serviceId);
      if (id == null) return null;

      return providerHomeData.value.activeOrders.results.firstWhereOrNull(
        (group) => group.serviceId == id,
      );
    } catch (e) {
      return null;
    }
  }

  /// Gets all active order groups
  List<ServiceOrderGroup> get allActiveOrderGroups {
    return providerHomeData.value.activeOrders.results;
  }

  /// Gets total count of active orders
  int get totalActiveOrdersCount {
    return providerHomeData.value.activeOrders.total;
  }
}
