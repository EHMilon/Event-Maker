import 'package:event_maker/services/api_exception.dart';
import 'package:event_maker/services/api_result.dart';
import 'package:event_maker/services/api_service.dart';
import 'package:event_maker/utils/logger.dart';

/// Repository for handling review-related API operations
class ReviewRepository {
  final ApiService _apiService = ApiService();

  /// Submit a new review for a service
  /// POST /services/customer/submit-review/{service_id}
  /// Body: { "rating": int, "comment": String }
  Future<Result<Map<String, dynamic>>> submitReview({
    required int serviceId,
    required int rating,
    required String comment,
  }) async {
    try {
      Log.d('=======> Submitting review for service $serviceId');

      final response = await _apiService.post(
        '/services/customer/submit-review/$serviceId',
        body: {'rating': rating, 'comment': comment},
      );

      if (response['success'] == true) {
        Log.d('=======> Review submitted successfully');
        return Success(response['data'] as Map<String, dynamic>? ?? {});
      } else {
        Log.e('=======> Failed to submit review: ${response['message']}');
        return Error(
          response['message']?.toString() ?? 'Failed to submit review',
        );
      }
    } on ApiException catch (e) {
      // Extract user-friendly message from API response
      final String userMessage = _extractErrorMessage(e);
      Log.e('=======> API Error submitting review', userMessage);
      return Error(userMessage);
    } catch (e) {
      Log.e('=======> Error submitting review', e);
      return Error('Failed to submit review. Please try again.');
    }
  }

  /// Update an existing review for a service
  /// PUT /services/customer/update-review/{service_id}
  /// Body: { "rating": int, "comment": String }
  Future<Result<Map<String, dynamic>>> updateReview({
    required int serviceId,
    required int rating,
    required String comment,
  }) async {
    try {
      Log.d('=======> Updating review for service $serviceId');

      final response = await _apiService.put(
        '/services/customer/update-review/$serviceId',
        body: {'rating': rating, 'comment': comment},
      );

      if (response['success'] == true) {
        Log.d('=======> Review updated successfully');
        return Success(response['data'] as Map<String, dynamic>? ?? {});
      } else {
        Log.e('=======> Failed to update review: ${response['message']}');
        return Error(
          response['message']?.toString() ?? 'Failed to update review',
        );
      }
    } on ApiException catch (e) {
      // Extract user-friendly message from API response
      final String userMessage = _extractErrorMessage(e);
      Log.e('=======> API Error updating review', userMessage);
      return Error(userMessage);
    } catch (e) {
      Log.e('=======> Error updating review', e);
      return Error('Failed to update review. Please try again.');
    }
  }

  /// Get review details for a service
  /// GET /services/customer/review-detail/{service_id}
  Future<Result<Map<String, dynamic>>> getReviewDetail(int serviceId) async {
    try {
      Log.d('=======> Fetching review detail for service $serviceId');

      final response = await _apiService.get(
        '/services/customer/review-detail/$serviceId',
      );

      if (response['success'] == true) {
        Log.d('=======> Review detail fetched successfully');
        return Success(response['data'] as Map<String, dynamic>? ?? {});
      } else {
        Log.e('=======> Failed to fetch review detail: ${response['message']}');
        return Error(
          response['message']?.toString() ?? 'Failed to fetch review detail',
        );
      }
    } on ApiException catch (e) {
      // Extract user-friendly message from API response
      final String userMessage = _extractErrorMessage(e);
      Log.e('=======> API Error fetching review detail', userMessage);
      return Error(userMessage);
    } catch (e) {
      Log.e('=======> Error fetching review detail', e);
      return Error('Failed to fetch review detail. Please try again.');
    }
  }

  /// Check if user has already reviewed a service
  /// Returns the existing review data if found, null otherwise
  Future<Result<Map<String, dynamic>>?> checkExistingReview(
    int serviceId,
  ) async {
    final result = await getReviewDetail(serviceId);
    return result;
  }

  /// Extract user-friendly error message from ApiException
  /// Prioritizes the 'message' field from API response body
  String _extractErrorMessage(ApiException exception) {
    // First try to get message from API response body
    if (exception.data is Map<String, dynamic>) {
      final message = exception.data['message'] as String?;
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }
    
    // Fall back to exception message but make it more user-friendly
    switch (exception.statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Please sign in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'Service not found.';
      case 408:
        return 'Request timed out. Please try again.';
      case 422:
        return 'Validation failed. Please check your input.';
      case 500:
        return 'Server error. Please try again later.';
      case 503:
        return 'Service temporarily unavailable. Please try again later.';
      default:
        return exception.message;
    }
  }
}
