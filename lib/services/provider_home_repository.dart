import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/models/provider_home_model.dart';
import 'package:event_maker/services/api_service.dart';
import 'package:event_maker/services/api_exception.dart';
import 'package:event_maker/utils/logger.dart';

/// Repository for Provider Home API operations
/// API Endpoint: GET /providers/home
///
/// This repository handles fetching provider home data including:
/// - This month's earnings
/// - Analytics (total earnings, requests, completed, pending)
/// - Total balance/wallet summary
/// - Active orders grouped by service
class ProviderHomeRepository {
  final ApiService _apiService;

  ProviderHomeRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Fetches provider home screen data
  ///
  /// Returns [ProviderHomeData] containing:
  /// - this_month_earning: Current month's earning with growth percent
  /// - analytics: Statistics based on last 30 days
  /// - total_balance: Wallet summary
  /// - active_orders: Grouped active orders by service
  ///
  /// Throws [ApiException] on API errors
  Future<ProviderHomeData> fetchProviderHomeData() async {
    try {
      Log.d('=======> fetchProviderHomeData - Starting request');

      final response = await _apiService.get(ApiConstant.providerHome);

      Log.d('=======> fetchProviderHomeData - Response received');

      final homeResponse = ProviderHomeResponse.fromJson(response);

      if (!homeResponse.success) {
        throw ApiException(message: homeResponse.message);
      }

      return homeResponse.data;
    } on ApiException catch (e) {
      Log.e('=======> fetchProviderHomeData - ApiException: ${e.message}');
      rethrow;
    } catch (e) {
      Log.e('=======> fetchProviderHomeData - Error: $e');
      throw ApiException(message: 'Failed to fetch provider home data: $e');
    }
  }

  /// Refreshes provider home data
  /// Same as [fetchProviderHomeData] but intended for pull-to-refresh
  Future<ProviderHomeData> refreshProviderHomeData() async {
    return fetchProviderHomeData();
  }
}
