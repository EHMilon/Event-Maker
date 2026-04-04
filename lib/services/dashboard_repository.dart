import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/models/dashboard_stats_model.dart';
import 'package:event_maker/models/order_model.dart';
import 'package:event_maker/services/api_service.dart';

/// Repository for fetching dashboard data from the backend.
/// 
/// Backend Contract:
/// - GET /provider/dashboard: Returns dashboard statistics
/// - GET /provider/orders/active: Returns list of active orders
/// 
/// The backend should return responses in the following format:
/// ```json
/// {
///   "success": true,
///   "data": {
///     "total_earnings": "2,788 AED",
///     "total_requests": 80,
///     "completed_orders": 62,
///     "pending_orders": 18,
///     "total_balance": "2,788 USD",
///     "earnings_change": "12.3%",
///     "requests_change": "12.3%",
///     "completed_change": "4.3%",
///     "pending_change": "12.3%",
///     "is_earnings_up": true,
///     "is_requests_up": true,
///     "is_completed_up": false,
///     "is_pending_up": true
///   }
/// }
/// ```
/// 
/// For active orders:
/// ```json
/// {
///   "success": true,
///   "data": [
///     {
///       "id": "1",
///       "title": "Catering services for home event",
///       "image_url": "https://picsum.photos/id/40/120/120",
///       "badge_count": 2,
///       "status": "active",
///       "created_at": "2024-01-15T10:30:00Z"
///     }
///   ]
/// }
/// ```
class DashboardRepository {
  final ApiService _apiService = ApiService();

  /// Fetches dashboard statistics from the backend.
  /// 
  /// Returns [DashboardStats] if successful.
  /// Throws an exception if the API call fails.
  Future<DashboardStats> fetchDashboardStats() async {
    try {
      final response = await _apiService.get(ApiConstant.providerDashboard);
      
      if (response != null && response['data'] != null) {
        return DashboardStats.fromJson(response['data']);
      }
      
      // Return empty stats if no data
      return DashboardStats.empty();
    } catch (e) {
      // Re-throw to let the controller handle the error
      rethrow;
    }
  }

  /// Fetches active orders from the backend.
  /// 
  /// Returns a list of [OrderModel] if successful.
  /// Throws an exception if the API call fails.
  Future<List<OrderModel>> fetchActiveOrders() async {
    try {
      final response = await _apiService.get(ApiConstant.providerActiveOrders);
      
      if (response != null && response['data'] != null) {
        final List<dynamic> ordersList = response['data'];
        return ordersList
            .map((orderJson) => OrderModel.fromJson(orderJson))
            .toList();
      }
      
      // Return empty list if no data
      return [];
    } catch (e) {
      // Re-throw to let the controller handle the error
      rethrow;
    }
  }
}