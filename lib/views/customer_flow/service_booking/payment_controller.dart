import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/app_routes.dart';
import 'package:get/get.dart';

class PaymentController extends GetxController {
  final isLoading = true.obs;
  final selectedPaymentMethod = 0.obs; // 0: Stripe, 1: Paypal

  late ServiceModel service;
  late ServicePackage? selectedPackage;

  @override
  void onInit() {
    super.onInit();

    // Get arguments passed from previous screen
    final args = Get.arguments;
    if (args is Map) {
      service = args['service'];
      selectedPackage = args['package'];
    } else {
      // Fallback for safety
      if (args is ServiceModel) {
        service = args;
        selectedPackage = null;
      }
    }

    simulateLoading();
  }

  Future<void> simulateLoading() async {
    isLoading.value = true;
    // Simulate 2s delay as requested
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
  }

  void selectPaymentMethod(int index) {
    selectedPaymentMethod.value = index;
  }

  void processPayment() {
    // TODO: Integrate with backend payment gateway (Stripe/Paypal)

    // For now, just navigate to confirmation
    Get.toNamed(AppRoutes.paymentConfirmation);
  }
}
