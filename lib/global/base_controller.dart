import 'package:event_maker/app_routes.dart';
import 'package:event_maker/global/loading_controller.dart';
import 'package:event_maker/services/api_exception.dart';
import 'package:event_maker/services/storage_service.dart';
import 'package:event_maker/utils/error_handler.dart';
import 'package:get/get.dart';


abstract class BaseController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final hasError = false.obs;

  LoadingController get _loadingController => Get.find<LoadingController>();

  Future<T?> apiCall<T>(
    Future<T> Function() call, {
    bool showLoading = true,
    bool showOverlay = false,
    bool handleError = true,
    Function(ApiException)? onError,
  }) async {
    try {
      errorMessage.value = '';
      hasError.value = false;

      if (showOverlay) {
        _loadingController.show();
      } else if (showLoading) {
        isLoading.value = true;
      }

      final result = await call();
      return result;
    } on ApiException catch (e) {
      hasError.value = true;
      errorMessage.value = e.message;

      if (e.isUnauthorized) {
        _handleUnauthorized();
        return null;
      }

      if (onError != null) {         
        onError(e);
      } else if (handleError) {
        ErrorHandler.handle(e);
      }
      return null;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'An unexpected error occurred';
      if (handleError) ErrorHandler.handle(e);
      return null;
    } finally {
      if (showOverlay) {
        _loadingController.hide();
      } else if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  void _handleUnauthorized() {
    StorageService().removeToken();
    Get.offAllNamed(AppRoutes.login);
  }
}
