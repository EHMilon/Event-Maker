import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/services/service_repository.dart';
import 'package:get/get.dart';

/// Controller for Service Provider's Service Detail view
/// Fetches service detail from API and manages loading/error states
class SPServicedetailController extends GetxController {
  final ServiceRepository _repository = const ServiceRepository();
  
  final Rx<ServiceModel?> service = Rx<ServiceModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  int? _serviceId;

  @override
  void onInit() {
    super.onInit();
    // Get service ID from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    _serviceId = args?['serviceId'] as int?;
    if (_serviceId != null) {
      fetchServiceDetail();
    }
  }

  /// Fetch service detail from API
  Future<void> fetchServiceDetail() async {
    if (_serviceId == null) {
      errorMessage.value = 'Service ID not provided';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _repository.fetchServiceDetail(_serviceId!);
      service.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh service detail
  @override
  Future<void> refresh() async {
    await fetchServiceDetail();
  }
}
