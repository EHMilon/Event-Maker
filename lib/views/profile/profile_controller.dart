import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../models/review_model.dart';
import '../../mock_data/mock_data.dart';
import '../../utils/user_preferences.dart';
import '../../app_routes.dart';
import '../../constants/app_colors.dart';
import '../customer_flow/home/customer_home_controller.dart';
import '../../services/connectivity_service.dart';
import '../../localization/app_localization.dart';

/// Controller for managing profile and settings related logic.
/// Follows SOLID principles by separating concerns and using dependency injection.
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

  // Password visibility states (Reactive UI)
  final RxBool isCurrentPasswordVisible = false.obs;
  final RxBool isNewPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  // Toggle visibility methods
  void toggleCurrentPasswordVisibility() => isCurrentPasswordVisible.toggle();

  void toggleNewPasswordVisibility() => isNewPasswordVisible.toggle();

  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();

  final RxString userName = 'John Doe'.obs;
  final RxString userEmail = 'example@gmail.com'.obs;
  final RxString profileImage = 'assets/images/person.jpg'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isServiceProvider = false.obs;
  final RxBool isAvailable = true.obs;
  final RxString walletBalance = '1250'.obs;

  // Mock data lists - TODO: Replace with actual backend models later
  final RxList<Map<String, dynamic>> transactions =
      <Map<String, dynamic>>[].obs;
  final RxList<ServiceModel> bookmarks = <ServiceModel>[].obs;
  final RxList<Map<String, dynamic>> faqs = <Map<String, dynamic>>[].obs;
  final RxList<ServiceModel> providerServices = <ServiceModel>[].obs;
  final RxList<ReviewModel> providerReviews = <ReviewModel>[].obs;

  // Language selection
  final Rx<SupportedLanguage> selectedLanguage = SupportedLanguage.english.obs;

  final RxString bio = ''.obs;
  final RxList<Map<String, String>> certifications =
      <Map<String, String>>[].obs;

  final RxDouble rating = 4.9.obs;
  final RxInt reviewCount = 3657.obs;

  @override
  void onInit() {
    super.onInit();
    _initialize();
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
    // if (_connectivityService.isConnected.value) { ... }
  }

  Future<void> _initialize() async {
    await loadUserData();
    loadMockData();
  }

  /// Loads user data from local storage or backend.
  /// Backend Compatible: Placeholder for API integration.
  Future<void> loadUserData() async {
    if (!_connectivityService.isConnected.value) {
      _showConnectivityError();
      return;
    }

    isLoading.value = true;
    // User Rule: 2s delay for shimmer effect visibility
    await Future.delayed(const Duration(seconds: 2));

    try {
      // FIXME: Integrate with actual Auth API/Service
      final userData = await UserPreferences.getUserDetails();
      if (userData != null) {
        userName.value = userData['name'] ?? 'John Doe';
        userEmail.value = userData['email'] ?? 'example@gmail.com';
        isServiceProvider.value =
            userData['type'] == UserPreferences.USER_TYPE_SERVICE_PROVIDER;

        nameController.text = userName.value;
        emailController.text = userEmail.value;
        phoneController.text = '000-0000-000'; // TODO: Fetch from backend
        nationalityController.text = 'UAE'; // TODO: Fetch from backend
      } else {
        isServiceProvider.value = await UserPreferences.isServiceProvider();
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'somethingWentWrong'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  /// Populates mock data for UI development.
  /// Backend Compatible: Replace with API calls in the future.
  void loadMockData() {
    transactions.assignAll([
      {'title': 'John Doe', 'time': 'Just Now', 'amount': '105'},
      {'title': 'John Doe', 'time': 'Just Now', 'amount': '105'},
      {'title': 'John Doe', 'time': 'Just Now', 'amount': '105'},
    ]);

    bookmarks.assignAll(MockData.bookmarkedServices);

    faqs.assignAll([
      {
        'question': 'What payment methods do you accept?',
        'answer': 'We accept online payment platforms such as PayPal & Stripe.',
        'isExpanded': false.obs,
      },
    ]);

    providerServices.assignAll(MockData.homeServices.take(5).toList());

    providerReviews.assignAll([
      ReviewModel(
        userName: 'John Doe',
        userImageUrl: 'https://picsum.photos/id/10/100/100',
        date: '10 Feb',
        rating: 4,
        reviewText: 'Great service!',
      ),
    ]);

    bio.value =
        'Amazing service! The team made our wedding day stress-free and truly magical. Everything was perfectly organized from the décor to the timeline. Highly recommend them.';

    certifications.assignAll([
      {
        'title': 'Professional Chef',
        'date': 'July, 2025',
        'school': 'Sonargaon Cooking School',
      },
      {
        'title': 'Pizza Artisan',
        'date': 'August, 2025',
        'school': 'Lorenzo\'s Pizza',
      },
    ]);
  }

  /// Handles bookmark removal and syncs with Home.
  void removeBookmark(String serviceId) {
    bookmarks.removeWhere((service) => service.id == serviceId);
    _syncHomeController(serviceId, false);

    Get.snackbar(
      'removed'.tr,
      'removedFromBookmarks'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
    );
  }

  /// Handles bookmark addition and syncs with Home.
  void addBookmark(ServiceModel service) {
    if (!bookmarks.any((s) => s.id == service.id)) {
      bookmarks.add(service);
      _syncHomeController(service.id, true);

      Get.snackbar(
        'bookmarked'.tr,
        'addedToBookmarks'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[700],
        colorText: Colors.white,
      );
    }
  }

  /// Syncs bookmark state with HomeController to maintain data flow integrity.
  void _syncHomeController(String serviceId, bool isBookmarked) {
    try {
      if (Get.isRegistered<HomeController>()) {
        final HomeController homeController = Get.find<HomeController>();
        homeController.toggleBookmark(serviceId); // Assuming toggle exists
      }
    } catch (e) {
      // HomeController not active
    }
  }

  /// Backend Integration for password update.
  Future<void> changePassword() async {
    if (!_connectivityService.isConnected.value) {
      _showConnectivityError();
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar('error'.tr, 'passwordsDoNotMatch'.tr);
      return;
    }

    // TODO: Validate current password and call Backend API
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;

    Get.toNamed(
      '/otp-verification',
      parameters: {'authFlow': 'change-password'},
    );
  }

  /// Backend Integration for profile update.
  Future<void> updateProfile() async {
    if (!_connectivityService.isConnected.value) {
      _showConnectivityError();
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));

    try {
      // TODO: Call Profile Update API
      userName.value = nameController.text;
      userEmail.value = emailController.text;

      isLoading.value = false;
      Get.back();
      Get.snackbar(
        'success'.tr,
        'profileUpdatedSuccessfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[700],
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('error'.tr, 'somethingWentWrong'.tr);
    }
  }

  /// Logic for logging out and clearing preferences.
  Future<void> logOut() async {
    await UserPreferences.clearUserData();
    await UserPreferences.resetOnboarding();
    Get.offAllNamed(AppRoutes.onboarding);
  }

  /// Handles account deletion confirmation and backend request if needed.
  Future<void> deleteAccount() async {
    if (!_connectivityService.isConnected.value) {
      _showConnectivityError();
      return;
    }

    // TODO: Integrate delete account API
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

  /// Backend Integration for availability toggle.
  void toggleAvailability(bool value) {
    if (!_connectivityService.isConnected.value) {
      _showConnectivityError();
      return;
    }
    isAvailable.value = value;
    // TODO: Update availability via Backend API
  }

  void _showConnectivityError() {
    Get.snackbar(
      'error'.tr,
      'noInternet'.tr,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  // NOTE: TextEditingControllers are NOT disposed here because this controller
  // is a singleton managed by GetX. Disposing them would cause errors when
  // the controller is reused after navigation (e.g., returning to ChangePasswordView).
  // For singleton controllers, TextEditingControllers persist for the app's lifetime.
  @override
  void onClose() {
    // TextEditingControllers intentionally not disposed for singleton lifecycle
    super.onClose();
  }
}
