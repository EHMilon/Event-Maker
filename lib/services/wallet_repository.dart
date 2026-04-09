import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/models/wallet_model.dart';
import 'package:event_maker/services/api_service.dart';
import 'package:event_maker/services/api_exception.dart';
import 'package:event_maker/utils/logger.dart';
import 'package:url_launcher/url_launcher.dart';

/// Repository for Provider Wallet API operations
/// API Endpoint: GET /payments/provider-wallet-history
class WalletRepository {
  final ApiService _apiService;

  WalletRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Fetches provider wallet history with summary and paginated transactions
  ///
  /// [page] - Page number for pagination (default: 1)
  /// [pageSize] - Number of items per page (default: 10, max: 100)
  ///
  /// Returns [WalletHistoryResponse] containing:
  /// - WalletSummary with total_earned, available_balance, etc.
  /// - WalletHistory with paginated transactions
  Future<WalletHistoryResponse> fetchWalletHistory({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      // Validate pagination params
      final validPageSize = pageSize.clamp(1, ApiConstant.maxPageSize);

      Log.d(
        '=======> fetchWalletHistory - Page: $page, PageSize: $validPageSize',
      );

      final response = await _apiService.get(
        ApiConstant.providerWalletHistory,
        queryParams: {
          'page': page.toString(),
          'page_size': validPageSize.toString(),
        },
      );

      Log.d('=======> fetchWalletHistory - Response: $response');

      return WalletHistoryResponse.fromJson(response);
    } on ApiException catch (e) {
      Log.e('=======> fetchWalletHistory - ApiException: ${e.message}');
      rethrow;
    } catch (e) {
      Log.e('=======> fetchWalletHistory - Error: $e');
      throw ApiException(message: 'Failed to fetch wallet history: $e');
    }
  }

  /// Fetches only the wallet summary without transaction history
  /// Useful for quick balance checks
  Future<WalletSummary?> fetchWalletSummary() async {
    try {
      final responseData = await _apiService.get(
        ApiConstant.providerWalletHistory,
      );
      final response = _WalletHistoryResponseWrapper.fromJson(responseData);
      return response.summary;
    } on ApiException catch (e) {
      Log.e('=======> fetchWalletSummary - ApiException: ${e.message}');
      rethrow;
    } catch (e) {
      Log.e('=======> fetchWalletSummary - Error: $e');
      throw ApiException(message: 'Failed to fetch wallet summary: $e');
    }
  }

  /// Loads more transactions for infinite scroll pagination
  Future<List<WalletTransaction>> loadMoreTransactions({
    required int currentPage,
    int pageSize = 10,
  }) async {
    try {
      final nextPage = currentPage + 1;
      final response = await fetchWalletHistory(
        page: nextPage,
        pageSize: pageSize,
      );
      return response.history?.transactions ?? [];
    } catch (e) {
      Log.e('=======> loadMoreTransactions - Error: $e');
      rethrow;
    }
  }

  // ===== STRIPE CONNECT METHODS =====

  /// Fetches provider Stripe Connect status
  /// POST /payments/provider-connect
  ///
  /// Returns [ProviderConnectResponse] containing:
  /// - stripe_account_id
  /// - onboarding_url (if onboarding not completed)
  /// - charges_enabled
  /// - payouts_enabled
  /// - details_submitted
  Future<ProviderConnectResponse> fetchProviderConnect() async {
    try {
      Log.d('=======> fetchProviderConnect');

      final response = await _apiService.post(ApiConstant.providerConnect);

      Log.d('=======> fetchProviderConnect - Response: $response');

      return ProviderConnectResponse.fromJson(response);
    } on ApiException catch (e) {
      Log.e('=======> fetchProviderConnect - ApiException: ${e.message}');
      rethrow;
    } catch (e) {
      Log.e('=======> fetchProviderConnect - Error: $e');
      throw ApiException(message: 'Failed to fetch Stripe Connect status: $e');
    }
  }

  /// Opens Stripe Connect onboarding URL in external browser
  /// Returns true if URL was launched successfully
  Future<bool> openStripeOnboarding(String onboardingUrl) async {
    try {
      final uri = Uri.parse(onboardingUrl);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      Log.e('=======> openStripeOnboarding - Error: $e');
      return false;
    }
  }

  // ===== WITHDRAWAL METHODS =====

  /// Initiates a withdrawal request for the provider
  /// POST /payments/provider-withdrawal
  ///
  /// [amount] - Amount to withdraw (must be > 0)
  /// [method] - Withdrawal method (default: 'stripe')
  ///
  /// Returns [ProviderWithdrawalResponse] containing:
  /// - withdrawal_id
  /// - amount
  /// - status
  /// - created_at
  Future<ProviderWithdrawalResponse> requestWithdrawal({
    required double amount,
    String method = 'stripe',
  }) async {
    try {
      // Validate amount
      if (amount <= 0) {
        throw ApiException(message: 'Withdrawal amount must be greater than 0');
      }

      Log.d('=======> requestWithdrawal - Amount: $amount, Method: $method');

      final request = ProviderWithdrawalRequest(amount: amount, method: method);

      final response = await _apiService.post(
        ApiConstant.providerWithdrawal,
        body: request.toJson(),
      );

      Log.d('=======> requestWithdrawal - Response: $response');

      return ProviderWithdrawalResponse.fromJson(response);
    } on ApiException catch (e) {
      Log.e('=======> requestWithdrawal - ApiException: ${e.message}');
      rethrow;
    } catch (e) {
      Log.e('=======> requestWithdrawal - Error: $e');
      throw ApiException(message: 'Failed to process withdrawal: $e');
    }
  }
}

/// Helper wrapper for extracting only summary from full response
class _WalletHistoryResponseWrapper {
  final bool success;
  final String message;
  final WalletSummary? summary;
  final WalletHistory? history;

  _WalletHistoryResponseWrapper({
    required this.success,
    required this.message,
    this.summary,
    this.history,
  });

  factory _WalletHistoryResponseWrapper.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return _WalletHistoryResponseWrapper(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      summary: data['summary'] != null
          ? WalletSummary.fromJson(data['summary'] as Map<String, dynamic>)
          : null,
      history: data['history'] != null
          ? WalletHistory.fromJson(data['history'] as Map<String, dynamic>)
          : null,
    );
  }
}
