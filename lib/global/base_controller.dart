import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_result.dart';
import '../services/connectivity_service.dart';

/// Base controller providing common state management functionality.
///
/// Provides:
/// - Loading state management (initial, refreshing, loading more)
/// - Error state management with user-friendly messages
/// - Network connectivity awareness
/// - Result handling helpers
///
/// Usage:
/// ```dart
/// class MyController extends BaseController {
///   Future<void> fetchData() async {
///     await handleAsync(
///       () => repository.getData(),
///       onSuccess: (data) => items.value = data,
///     );
///   }
/// }
/// ```
abstract class BaseController extends GetxController {
  /// Connectivity service instance
  final connectivity = Get.find<ConnectivityService>();

  // ===== Loading States =====

  /// Initial loading state (first load)
  final isLoading = false.obs;

  /// Refreshing state (pull-to-refresh)
  final isRefreshing = false.obs;

  /// Loading more state (pagination)
  final isLoadingMore = false.obs;

  /// Loading message for display
  final loadingMessage = ''.obs;

  // ===== Error States =====

  /// Current error message
  final errorMessage = ''.obs;

  /// Current error type
  final errorType = Rxn<ErrorType>();

  /// Validation errors by field
  final validationErrors = Rxn<Map<String, List<String>>>();

  /// Whether an error is currently shown
  final hasError = false.obs;

  // ===== Computed Properties =====

  /// Returns true if any loading state is active
  bool get isAnyLoading =>
      isLoading.value || isRefreshing.value || isLoadingMore.value;

  /// Returns true if connected to network
  bool get isConnected => connectivity.isConnected.value;

  // ===== Loading State Management =====

  /// Sets the loading state with optional message.
  void setLoading(bool value, {String? message}) {
    isLoading.value = value;
    loadingMessage.value = message ?? '';
    if (value) {
      clearError();
    }
  }

  /// Sets the refreshing state.
  void setRefreshing(bool value) {
    isRefreshing.value = value;
    if (value) {
      clearError();
    }
  }

  /// Sets the loading more state.
  void setLoadingMore(bool value) {
    isLoadingMore.value = value;
    if (value) {
      clearError();
    }
  }

  // ===== Error State Management =====

  /// Sets the error state with message and optional details.
  void setError(
    String message, {
    ErrorType? type,
    Map<String, List<String>>? errors,
  }) {
    errorMessage.value = message;
    errorType.value = type;
    validationErrors.value = errors;
    hasError.value = true;
  }

  /// Sets error from an Error result.
  void setErrorFromResult<T>(Error<T> error) {
    setError(
      error.message,
      type: error.errorType,
      errors: error.validationErrors,
    );
  }

  /// Clears the error state.
  void clearError() {
    errorMessage.value = '';
    errorType.value = null;
    validationErrors.value = null;
    hasError.value = false;
  }

  // ===== Network Checks =====

  /// Checks network connectivity and returns true if connected.
  /// Shows error snackbar if not connected.
  bool checkNetwork() {
    if (!isConnected) {
      showError('No internet connection. Please check your network.');
      return false;
    }
    return true;
  }

  // ===== Async Operation Handler =====

  /// Handles an async operation with automatic loading/error states.
  ///
  /// [operation] - The async operation to execute
  /// [onSuccess] - Called with the data on success
  /// [onError] - Called with the error message on failure (optional)
  /// [loadingMessage] - Optional loading message to display
  /// [showSuccessSnackbar] - Whether to show success snackbar
  /// [successMessage] - Custom success message
  /// [loadingType] - Type of loading state to set
  Future<T?> handleAsync<T>(
    Future<T> Function() operation, {
    void Function(T data)? onSuccess,
    void Function(String message, ErrorType? type)? onError,
    String? loadingMessage,
    bool showSuccessSnackbar = false,
    String? successMessage,
    LoadingType loadingType = LoadingType.initial,
  }) async {
    // Check network first
    if (!checkNetwork()) {
      return null;
    }

    // Set loading state
    _setLoadingByType(loadingType, true, loadingMessage);

    try {
      final result = await operation();

      // Clear loading state
      _setLoadingByType(loadingType, false);

      // Handle success
      clearError();
      onSuccess?.call(result);

      if (showSuccessSnackbar && successMessage != null) {
        showSuccess(successMessage);
      }

      return result;
    } catch (e) {
      // Clear loading state
      _setLoadingByType(loadingType, false);

      // Handle error
      final message = _getErrorMessage(e);
      final errorType = _getErrorType(e);

      setError(message, type: errorType);
      onError?.call(message, errorType);
      showError(message);

      return null;
    }
  }

  /// Handles a Result with automatic state management.
  ///
  /// [result] - The Result to handle
  /// [onSuccess] - Called with the data on success
  /// [onError] - Called with the error on failure (optional)
  /// [showSuccessSnackbar] - Whether to show success snackbar
  /// [successMessage] - Custom success message
  Future<void> handleResult<T>(
    Result<T> result, {
    void Function(T data)? onSuccess,
    void Function(Error<T> error)? onError,
    bool showSuccessSnackbar = false,
    String? successMessage,
  }) async {
    switch (result) {
      case Success<T>(data: final data):
        clearError();
        onSuccess?.call(data);
        if (showSuccessSnackbar && successMessage != null) {
          showSuccess(successMessage);
        }

      case Error<T>(
        message: final message,
        errorType: final type,
        validationErrors: final errors,
      ):
        setError(message, type: type, errors: errors);
        onError?.call(
          Error<T>(message, errorType: type, validationErrors: errors),
        );
        showError(message);

      case Loading<T>():
        // Loading state should be handled before calling this
        break;
    }
  }

  // ===== UI Helpers =====

  /// Shows a success snackbar.
  void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.primaryColor.withValues(alpha: 0.1),
      colorText: Get.theme.primaryColor,
      duration: const Duration(seconds: 3),
    );
  }

  /// Shows an error snackbar.
  void showError(String message, {Duration? duration}) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
      colorText: Get.theme.colorScheme.error,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  /// Shows a warning snackbar.
  void showWarning(String message) {
    Get.snackbar(
      'Warning',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.withValues(alpha: 0.1),
      colorText: Colors.orange,
      duration: const Duration(seconds: 3),
    );
  }

  /// Shows an info snackbar.
  void showInfo(String message) {
    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withValues(alpha: 0.1),
      colorText: Colors.blue,
      duration: const Duration(seconds: 3),
    );
  }

  // ===== Private Helpers =====

  void _setLoadingByType(LoadingType type, bool value, [String? message]) {
    switch (type) {
      case LoadingType.initial:
        setLoading(value, message: message);
      case LoadingType.refresh:
        setRefreshing(value);
      case LoadingType.loadMore:
        setLoadingMore(value);
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is Error) {
      return error.message;
    }
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return 'Something went wrong. Please try again.';
  }

  ErrorType _getErrorType(dynamic error) {
    if (error is Error) {
      return error.errorType;
    }
    return ErrorType.unknown;
  }
}

/// Type of loading state.
enum LoadingType {
  /// Initial load (first time loading data)
  initial,

  /// Refresh (pull-to-refresh)
  refresh,

  /// Load more (pagination)
  loadMore,
}

/// Mixin for controllers that need retry functionality.
mixin RetryableController on BaseController {
  /// Current retry count
  final retryCount = 0.obs;

  /// Maximum retry attempts
  static const int maxRetries = 3;

  /// Retries the last failed operation.
  /// Override this method in your controller.
  Future<void> retry();

  /// Increments retry count and checks if can retry.
  bool canRetry() {
    if (retryCount.value < maxRetries) {
      retryCount.value++;
      return true;
    }
    return false;
  }

  /// Resets retry count.
  void resetRetryCount() {
    retryCount.value = 0;
  }
}

/// Mixin for controllers that need pagination.
mixin PaginationController<T> on BaseController {
  /// Current page number
  final currentPage = 1.obs;

  /// Items per page
  final pageSize = 20.obs;

  /// Total number of items
  final totalItems = 0.obs;

  /// Whether there are more items to load
  final hasMore = true.obs;

  /// List of items
  final items = <T>[].obs;

  /// Loads the first page of items.
  Future<void> loadFirstPage();

  /// Loads the next page of items.
  Future<void> loadNextPage();

  /// Refreshes all items.
  Future<void> refreshItems() async {
    currentPage.value = 1;
    hasMore.value = true;
    await loadFirstPage();
  }

  /// Appends new items to the list.
  void appendItems(List<T> newItems, {int? total}) {
    if (currentPage.value == 1) {
      items.assignAll(newItems);
    } else {
      items.addAll(newItems);
    }

    if (total != null) {
      totalItems.value = total;
      hasMore.value = items.length < total;
    } else {
      hasMore.value = newItems.length >= pageSize.value;
    }
  }

  /// Clears all items.
  void clearItems() {
    items.clear();
    currentPage.value = 1;
    totalItems.value = 0;
    hasMore.value = true;
  }
}
