import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/models/customer_payment_history_model.dart';
import 'package:event_maker/services/api_service.dart';
import 'package:event_maker/services/api_exception.dart';
import 'package:event_maker/utils/logger.dart';

/// Repository for Customer Payment History API operations
/// API Endpoint: GET /payments/customer-history
class CustomerPaymentRepository {
  final ApiService _apiService;

  CustomerPaymentRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Fetches customer payment history with pagination
  ///
  /// [page] - Page number for pagination (default: 1)
  /// [pageSize] - Number of items per page (default: 10, max: 100)
  ///
  /// Returns [CustomerPaymentHistoryResponse] containing:
  /// - Pagination info (total, page, pageSize, totalPages)
  /// - List of payment transactions
  Future<CustomerPaymentHistoryResponse> fetchCustomerPaymentHistory({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      // Validate pagination params
      final validPageSize = pageSize.clamp(1, ApiConstant.maxPageSize);

      Log.d(
          '=======> fetchCustomerPaymentHistory - Page: $page, PageSize: $validPageSize');

      final response = await _apiService.get(
        ApiConstant.customerPaymentHistory,
        queryParams: {
          'page': page.toString(),
          'page_size': validPageSize.toString(),
        },
      );

      Log.d('=======> fetchCustomerPaymentHistory - Response: $response');

      return CustomerPaymentHistoryResponse.fromJson(response);
    } on ApiException catch (e) {
      Log.e('=======> fetchCustomerPaymentHistory - ApiException: ${e.message}');
      rethrow;
    } catch (e) {
      Log.e('=======> fetchCustomerPaymentHistory - Error: $e');
      throw ApiException(message: 'Failed to fetch customer payment history: $e');
    }
  }

  /// Loads more transactions for infinite scroll pagination
  Future<List<CustomerPaymentTransaction>> loadMoreTransactions({
    required int currentPage,
    int pageSize = 10,
  }) async {
    try {
      final nextPage = currentPage + 1;
      final response = await fetchCustomerPaymentHistory(
        page: nextPage,
        pageSize: pageSize,
      );
      return response.data;
    } catch (e) {
      Log.e('=======> loadMoreTransactions - Error: $e');
      rethrow;
    }
  }
}
