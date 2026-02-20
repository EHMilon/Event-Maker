import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/review_model.dart';
import '../../../data/mock/mock_data.dart';
import '../../../shared/utils/user_preferences.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/themes/app_colors.dart';
import '../../../data/services/connectivity_service.dart';
import '../../../views/customer_flow/home/home_controller.dart';
import '../../../core/localization/app_localization.dart';

class ProfileController extends GetxController {
  final _connectivityService = Get.find<ConnectivityService>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final nationalityController = TextEditingController();
  final captionController = TextEditingController();

  // Change Password Controllers
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Password visibility states
  final RxBool isCurrentPasswordVisible = false.obs;
  final RxBool isNewPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  // Toggle visibility methods
  void toggleCurrentPasswordVisibility() {
    isCurrentPasswordVisible.value = !isCurrentPasswordVisible.value;
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  final RxString userName = 'John Doe'.obs;
  final RxString userEmail = 'example@gmail.com'.obs;
  final RxString profileImage = 'assets/images/person.jpg'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isServiceProvider = false.obs;
  final RxBool isAvailable = true.obs;
  final RxString walletBalance = '1250'.obs;

  // Mock data lists
  final RxList<Map<String, dynamic>> transactions =
      <Map<String, dynamic>>[].obs;
  final RxList<ServiceModel> bookmarks = <ServiceModel>[].obs;
  final RxList<Map<String, dynamic>> faqs = <Map<String, dynamic>>[].obs;
  final RxList<ServiceModel> providerServices = <ServiceModel>[].obs;
  final RxList<ReviewModel> providerReviews = <ReviewModel>[].obs;

  // Reactive property to notify when bookmarks change
  final RxBool bookmarksChanged = false.obs;

  // Language selection
  final Rx<SupportedLanguage> selectedLanguage = SupportedLanguage.english.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadMockData();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final langCode = await UserPreferences.getLanguageCode();
    selectedLanguage.value = SupportedLanguage.values.firstWhere(
      (e) => e.code == langCode,
      orElse: () => SupportedLanguage.english,
    );
  }

  /// Updates the application language and saves preference.
  /// Backend Compatible: TODO - Sync language preference with backend API.
  void changeLanguage(SupportedLanguage language) async {
    selectedLanguage.value = language;
    await UserPreferences.setLanguageCode(language.code);
    Get.updateLocale(Locale(language.code));

    // TODO: Implement backend sync here
    // if (isConnected) { ... }
  }

  Future<void> loadUserData() async {
    isLoading.value = true;
    // Simulate network delay as per user rules
    await Future.delayed(const Duration(seconds: 2));

    final userData = await UserPreferences.getUserDetails();
    if (userData != null) {
      userName.value = userData['name'] ?? 'John Doe';
      userEmail.value = userData['email'] ?? 'example@gmail.com';
      isServiceProvider.value =
          userData['type'] == UserPreferences.USER_TYPE_SERVICE_PROVIDER;

      nameController.text = userName.value;
      emailController.text = userEmail.value;
      phoneController.text = '000-0000-000'; // Mock data
      nationalityController.text = 'UAE'; // Mock data
    } else {
      // Default to guest or customer
      isServiceProvider.value = await UserPreferences.isServiceProvider();
    }
    isLoading.value = false;
  }

  void loadMockData() {
    transactions.assignAll([
      {'title': 'John Doe', 'time': 'Just Now', 'amount': '105'},
      {'title': 'John Doe', 'time': 'Just Now', 'amount': '105'},
      {'title': 'John Doe', 'time': 'Just Now', 'amount': '105'},
      {'title': 'John Doe', 'time': 'Just Now', 'amount': '105'},
      {'title': 'John Doe', 'time': 'Just Now', 'amount': '105'},
      {'title': 'John Doe', 'time': 'Just Now', 'amount': '105'},
      {'title': 'John Doe', 'time': 'Just Now', 'amount': '105'},
    ]);

    // Use bookmarked services from centralized mock data
    bookmarks.assignAll(MockData.bookmarkedServices);

    faqs.assignAll([
      {
        'question': 'What payment methods do you accept?',
        'answer':
            'We accept online payment platforms such as PayPal & Stripe. Additional payment options may be available depending on your region.',
        'isExpanded': false.obs,
      },
      {
        'question': 'Is my payment information secure?',
        'answer':
            'Yes, we use industry-standard encryption for all transactions.',
        'isExpanded': false.obs,
      },
      {
        'question': 'Can I request a refund if needed?',
        'answer':
            'Refund policies vary depending on the service provider. Please check the contract.',
        'isExpanded': false.obs,
      },
      {
        'question': 'Will I receive an invoice for my payment?',
        'answer':
            'Yes, we will send an automated invoice once the booking is confirmed.',
        'isExpanded': false.obs,
      },
    ]);

    // Populate provider specific data
    providerServices.assignAll(MockData.homeServices.take(5).toList());

    providerReviews.assignAll([
      ReviewModel(
        userName: 'John Doe',
        userImageUrl: 'https://picsum.photos/id/10/100/100',
        date: '10 Feb',
        rating: 4,
        reviewText: 'Thank you, Fresh Food L.L.C! That was a great event.',
      ),
      ReviewModel(
        userName: 'Jane Smith',
        userImageUrl: 'https://picsum.photos/id/11/100/100',
        date: '08 Feb',
        rating: 5,
        reviewText:
            'Excellent catering service. The food was delicious and the staff was very professional.',
      ),
      ReviewModel(
        userName: 'Mike Johnson',
        userImageUrl: 'https://picsum.photos/id/12/100/100',
        date: '05 Feb',
        rating: 5,
        reviewText:
            'Highly recommended for any corporate event. Perfectly organized.',
      ),
      ReviewModel(
        userName: 'Sarah Wilson',
        userImageUrl: 'https://picsum.photos/id/13/100/100',
        date: '01 Feb',
        rating: 4,
        reviewText:
            'Great experience overall. Just a small delay in setup but everything else was perfect.',
      ),
    ]);
  }

  /// Remove a bookmark by service ID and sync with HomeController
  void removeBookmark(String serviceId) {
    bookmarks.removeWhere((service) => service.id == serviceId);

    // Notify HomeController to update its state
    _syncHomeController(serviceId, false);

    // Show snackbar for feedback
    Get.snackbar(
      'Removed',
      'Service removed from bookmarks',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey[800],
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  /// Add a bookmark by service ID and sync with HomeController
  void addBookmark(ServiceModel service) {
    if (!bookmarks.any((s) => s.id == service.id)) {
      bookmarks.add(service);

      // Notify HomeController to update its state
      _syncHomeController(service.id, true);

      // Show snackbar for feedback
      Get.snackbar(
        'Bookmarked',
        'Service added to bookmarks',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[700],
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    }
  }

  /// Sync HomeController when bookmarks change
  void _syncHomeController(String serviceId, bool isBookmarked) {
    try {
      final HomeController homeController = Get.find<HomeController>();

      // Update allServices in HomeController
      final serviceIndex = homeController.allServices.indexWhere(
        (s) => s.id == serviceId,
      );
      if (serviceIndex != -1) {
        final service = homeController.allServices[serviceIndex];
        homeController.allServices[serviceIndex] = ServiceModel(
          id: service.id,
          title: service.title,
          description: service.description,
          images: service.images,
          type: service.type,
          provider: service.provider,
          location: service.location,
          rating: service.rating,
          reviewCount: service.reviewCount,
          date: service.date,
          basePrice: service.basePrice,
          priceUnit: service.priceUnit,
          packages: service.packages,
          isBookmarked: isBookmarked,
        );
      }

      // Also update searchResults if searching
      if (homeController.searchResults.isNotEmpty) {
        final searchIndex = homeController.searchResults.indexWhere(
          (s) => s.id == serviceId,
        );
        if (searchIndex != -1) {
          final service = homeController.searchResults[searchIndex];
          homeController.searchResults[searchIndex] = ServiceModel(
            id: service.id,
            title: service.title,
            description: service.description,
            images: service.images,
            type: service.type,
            provider: service.provider,
            location: service.location,
            rating: service.rating,
            reviewCount: service.reviewCount,
            date: service.date,
            basePrice: service.basePrice,
            priceUnit: service.priceUnit,
            packages: service.packages,
            isBookmarked: isBookmarked,
          );
        }
      }
    } catch (e) {
      // HomeController might not be initialized yet
    }
  }

  /// Check if a service is bookmarked
  bool isBookmarked(String serviceId) {
    return bookmarks.any((service) => service.id == serviceId);
  }

  Future<void> changePassword() async {
    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    // TODO: Validate current password with backend
    // Navigate to OTP verification for password change with auth flow parameter
    Get.toNamed(
      '/otp-verification',
      parameters: {'authFlow': 'change-password'},
    );
  }

  Future<void> updateProfile() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));

    userName.value = nameController.text;
    userEmail.value = emailController.text;

    // TODO: Integrate with backend

    isLoading.value = false;
    Get.back();
    Get.snackbar(
      'Success',
      'Profile updated successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> logOut() async {
    await UserPreferences.clearUserData();
    await UserPreferences.resetOnboarding();
    Get.offAllNamed(AppRoutes.onboarding);
  }

  /// Handles the delete account flow with backend reminder and cleanup.
  Future<void> deleteAccount() async {
    if (!_connectivityService.isConnected.value) {
      _showConnectivityError();
      return;
    }
    // TODO: create backend API call for deleting account
    Get.snackbar(
      'success'.tr,
      'accountDeletionSuccess'.tr,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
    await UserPreferences.clearUserData();
    await UserPreferences.resetOnboarding();
    Get.offAllNamed(AppRoutes.onboarding);
  }

  void _showConnectivityError() {
    Get.snackbar(
      'error'.tr,
      'noInternet'.tr,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void toggleAvailability(bool value) {
    isAvailable.value = value;
    // TODO: Update availability on backend
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    nationalityController.dispose();
    captionController.dispose();
    super.onClose();
  }
}
