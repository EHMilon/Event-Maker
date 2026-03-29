import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:event_maker/services/api_exception.dart';

class ErrorHandler {
  ErrorHandler._();

  static void handle(dynamic error) {
    final message = _extractMessage(error);
    showSnackbar(message);
  }

  static String _extractMessage(dynamic error) {
    if (error is ApiException) return error.message;
    if (error is String) return error;
    return 'An unexpected error occurred';
  }

  static void showSnackbar(String message, {bool isError = true}) {
    if (Get.isSnackbarOpen) return;
    Get.snackbar(
      isError ? 'Error' : 'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  static Future<bool> showErrorDialog(String message) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
