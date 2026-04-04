import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/service_model.dart';
import '../../models/review_model.dart';
import '../../models/service_provider_profile_model.dart';
import '../../models/service_provider_review_model.dart';
import '../../models/personal_info_model.dart';
import '../../models/wallet_model.dart';
import '../../services/wallet_repository.dart';
import '../../services/service_repository.dart';
import '../../models/service_model.dart';
import '../../models/review_model.dart';
import '../../models/service_provider_profile_model.dart';
import '../../models/service_provider_review_model.dart';
import '../../models/personal_info_model.dart';
import '../../models/wallet_model.dart';
import '../../services/wallet_repository.dart';
import '../../services/service_repository.dart';
import '../../utils/user_preferences.dart';
import '../../app_routes.dart';
import '../../constants/app_colors.dart';
import '../../constants/api_constant.dart';
import '../customer_flow/home/customer_home_controller.dart';
import '../../services/connectivity_service.dart';
import '../../services/api_service.dart';
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

  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString profileImage = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isServiceProvider = false.obs;
  final RxBool isAvailable = true.obs;
  final RxString walletBalance = '0'.obs;

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

  final RxDouble rating = 0.0.obs;
  final RxInt reviewCount = 0.obs;

  // ===== SERVICE PROVIDER PROFILE API STATE =====
  final _apiService = ApiService();

  /// Provider profile data from API (about section)
  final Rx<ServiceProviderProfileModel?> providerProfile =
      Rx<ServiceProviderProfileModel?>(null);

  /// Provider reviews data from API (reviews section)
  final Rx<ProviderReviewInfo?> providerReviewInfo = Rx<ProviderReviewInfo?>(
    null,
  );

  /// Provider reviews list from API
  final RxList<ServiceProviderReview> providerApiReviews =
      <ServiceProviderReview>[].obs;

  /// Loading state for profile API calls
  final RxBool isProfileLoading = false.obs;

  /// Loading state for reviews API calls
  final RxBool isReviewsLoading = false.obs;

  /// Error message for profile API calls
  final RxString profileError = ''.obs;

  /// Error message for reviews API calls
  final RxString reviewsError = ''.obs;

  // ===== PERSONAL INFO API STATE =====

  /// Personal info data from API
  final Rx<PersonalInfoModel?> personalInfo = Rx<PersonalInfoModel?>(null);

  /// Loading state for personal info API calls
  final RxBool isPersonalInfoLoading = false.obs;

  /// Loading state for availability toggle API call
  final RxBool isTogglingAvailability = false.obs;

  /// Error message for personal info API calls
  final RxString personalInfoError = ''.obs;

  /// Bio controller for providers only
  final TextEditingController bioController = TextEditingController();

  /// Selected profile image file (for local picker)
  final Rxn<File> selectedProfileImage = Rxn<File>();

  /// Flag to prevent multiple image picker calls
  bool _isPickingImage = false;

  // ===== WALLET API STATE =====

  /// Wallet repository instance
  final WalletRepository _walletRepository = WalletRepository();

  /// Service repository instance for bookmarks
  final ServiceRepository _serviceRepository = const ServiceRepository();

  /// Wallet summary data from API
  final Rx<WalletSummary?> walletSummary = Rx<WalletSummary?>(null);

  /// Wallet transactions from API
  final RxList<WalletTransaction> walletTransactions =
      <WalletTransaction>[].obs;

  /// Loading state for wallet API calls
  final RxBool isWalletLoading = false.obs;

  /// Error message for wallet API calls
  final RxString walletError = ''.obs;

  /// Current page for wallet pagination
  final RxInt walletCurrentPage = 1.obs;

  /// Total pages for wallet pagination
  final RxInt walletTotalPages = 1.obs;

  /// Whether more transactions can be loaded
  bool get hasMoreWalletTransactions =>
      walletCurrentPage.value < walletTotalPages.value;

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
  void changeLanguage(SupportedLanguage language) async {
    selectedLanguage.value = language;
    await UserPreferences.setLanguageCode(language.code);
    Get.updateLocale(Locale(language.code));
  }

  Future<void> _initialize() async {
    await loadUserData();
    await fetchPersonalInfo();
    await fetchBookmarks();
  }

  /// Loads user data from local storage.
  Future<void> loadUserData() async {
    if (!_connectivityService.isConnected.value) {
      _showConnectivityError();
      return;
    }

    isLoading.value = true;

    try {
      final userData = await UserPreferences.getUserDetails();
      if (userData != null) {
        userName.value = userData['name'] ?? '';
        userEmail.value = userData['email'] ?? '';
        isServiceProvider.value =
            userData['type'] == UserPreferences.USER_TYPE_SERVICE_PROVIDER;

        nameController.text = userName.value;
        emailController.text = userEmail.value;
      } else {
        isServiceProvider.value = await UserPreferences.isServiceProvider();
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'somethingWentWrong'.tr);
    } finally {
      isLoading.value = false;
    }
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

  /// Handles password update.
  Future<void> changePassword() async {
    if (!_connectivityService.isConnected.value) {
      _showConnectivityError();
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar('error'.tr, 'passwordsDoNotMatch'.tr);
      return;
    }

    isLoading.value = true;
    isLoading.value = false;

    Get.toNamed(
      '/otp-verification',
      parameters: {'authFlow': 'change-password'},
    );
  }

  /// Handles profile update.
  Future<void> updateProfile() async {
    if (!_connectivityService.isConnected.value) {
      _showConnectivityError();
      return;
    }

    isLoading.value = true;

    try {
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
  /// Backend: Calls logout endpoint and clears local auth data
  Future<void> logOut() async {
    try {
      // Call logout API endpoint to invalidate token on server
      await _apiService.post(ApiConstant.logout);
    } catch (e) {
      // Log error but continue with local logout even if API fails
      debugPrint('Logout API error: $e');
    }

    // Clear all user data and tokens from local storage
    await UserPreferences.clearUserData();
    await UserPreferences.resetOnboarding();

    // Navigate to onboarding screen and clear navigation stack
    Get.offAllNamed(AppRoutes.onboarding);
  }

  /// Handles account deletion confirmation and backend request.
  /// API Endpoint: DELETE /settings/personal-info/me
  Future<void> deleteAccount() async {
    if (!_connectivityService.isConnected.value) {
      _showConnectivityError();
      return;
    }

    isLoading.value = true;

    try {
      // Call delete account API on the personal info endpoint
      final response = await _apiService.delete(ApiConstant.deleteAccountV1);

      if (response['success'] == true) {
        Get.snackbar(
          'success'.tr,
          response['message'] ?? 'accountDeletionSuccess'.tr,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        // Clear all user data and tokens
        await UserPreferences.clearUserData();
        await UserPreferences.resetOnboarding();

        // Navigate to onboarding screen
        Get.offAllNamed(AppRoutes.onboarding);
      } else {
        Get.snackbar(
          'error'.tr,
          response['message'] ?? 'accountDeletionFailed'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('Delete account error: $e');
      Get.snackbar(
        'error'.tr,
        'somethingWentWrong'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Backend Integration for availability toggle.
  /// API Endpoint: POST /providers/availability-toggle
  /// Only for service providers
  Future<void> toggleAvailability(bool value) async {
    // Prevent concurrent calls
    if (isTogglingAvailability.value) return;

    if (!_connectivityService.isConnected.value) {
      _showConnectivityError();
      return;
    }

    // Only allow for service providers
    if (!isServiceProvider.value) {
      Get.snackbar(
        'error'.tr,
        'availabilityToggleNotAllowed'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isTogglingAvailability.value = true;

    try {
      final response = await _apiService.post(
        ApiConstant.providerAvailabilityToggle,
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>?;
        final apiIsAvailable = data?['is_available'] as bool?;

        if (apiIsAvailable != null) {
          isAvailable.value = apiIsAvailable;
        } else {
          // Fallback to local value if API doesn't return the status
          isAvailable.value = value;
        }
      } else {
        // Revert local state on failure - fetch fresh data from server
        await fetchPersonalInfo();
        Get.snackbar(
          'error'.tr,
          response['message'] ?? 'failedToUpdateAvailability'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error toggling availability: $e');
      // On error, fetch fresh data from server to ensure sync
      await fetchPersonalInfo();
      Get.snackbar(
        'error'.tr,
        'somethingWentWrong'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isTogglingAvailability.value = false;
    }
  }

  void _showConnectivityError() {
    Get.snackbar(
      'error'.tr,
      'noInternet'.tr,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  // ===== SERVICE PROVIDER PROFILE API METHODS =====

  /// Fetches service provider profile data (about section) from API
  /// API Endpoint: /providers/my-profile?section=about
  Future<void> fetchProviderProfile() async {
    if (!_connectivityService.isConnected.value) {
      _showConnectivityError();
      return;
    }

    isProfileLoading.value = true;
    profileError.value = '';

    try {
      final response = await _apiService.get(
        ApiConstant.providerMyProfile,
        queryParams: {'section': 'about'},
      );

      final profileResponse = ServiceProviderProfileResponse.fromJson(response);
      if (profileResponse.success) {
        providerProfile.value = profileResponse.data;
        // Update legacy fields for backward compatibility
        userName.value = profileResponse.data.name;
        bio.value = profileResponse.data.bio;
        rating.value = profileResponse.data.ratingValue;
        reviewCount.value = profileResponse.data.totalReviews;
        if (profileResponse.data.avatar != null &&
            profileResponse.data.avatar!.isNotEmpty) {
          profileImage.value = profileResponse.data.fullAvatarUrl ?? '';
        }
      } else {
        profileError.value = profileResponse.message;
      }
    } catch (e) {
      profileError.value = e.toString();
      debugPrint('Error fetching provider profile: $e');
    } finally {
      isProfileLoading.value = false;
    }
  }

  /// Fetches service provider reviews from API
  /// API Endpoint: /providers/my-profile?section=reviews
  Future<void> fetchProviderReviews() async {
    if (!_connectivityService.isConnected.value) {
      _showConnectivityError();
      return;
    }

    isReviewsLoading.value = true;
    reviewsError.value = '';

    try {
      final response = await _apiService.get(
        ApiConstant.providerMyProfile,
        queryParams: {'section': 'reviews'},
      );

      final reviewsResponse = ServiceProviderReviewsResponse.fromJson(response);
      if (reviewsResponse.success) {
        providerReviewInfo.value = reviewsResponse.provider;
        providerApiReviews.assignAll(reviewsResponse.data);
        // Update legacy fields for backward compatibility
        rating.value = reviewsResponse.provider.ratingValue;
        reviewCount.value = reviewsResponse.provider.totalReviews;
      } else {
        reviewsError.value = reviewsResponse.message;
      }
    } catch (e) {
      reviewsError.value = e.toString();
      debugPrint('Error fetching provider reviews: $e');
    } finally {
      isReviewsLoading.value = false;
    }
  }

  /// Fetches both profile and reviews data
  /// Useful for initial load or refresh
  Future<void> fetchAllProviderData() async {
    await Future.wait([fetchProviderProfile(), fetchProviderReviews()]);
  }

  /// Refreshes provider profile data
  Future<void> refreshProviderProfile() async {
    await fetchProviderProfile();
  }

  /// Refreshes provider reviews data
  Future<void> refreshProviderReviews() async {
    await fetchProviderReviews();
  }

  // ===== PERSONAL INFO API METHODS =====

  /// Fetches personal info from API
  /// API Endpoint: GET /settings/personal-info/me
  Future<void> fetchPersonalInfo() async {
    if (!_connectivityService.isConnected.value) {
      _showConnectivityError();
      return;
    }

    isPersonalInfoLoading.value = true;
    personalInfoError.value = '';

    try {
      final response = await _apiService.get(ApiConstant.personalInfoMe);

      final personalInfoResponse = PersonalInfoResponse.fromJson(response);
      if (personalInfoResponse.success) {
        personalInfo.value = personalInfoResponse.data;

        // Update controllers with fetched data
        nameController.text = personalInfoResponse.data.fullName;
        emailController.text = personalInfoResponse.data.email;
        phoneController.text = personalInfoResponse.data.phoneNumber ?? '';
        nationalityController.text =
            personalInfoResponse.data.nationality ?? '';

        // Set bio only for providers
        if (personalInfoResponse.data.isProvider) {
          bioController.text = personalInfoResponse.data.bio ?? '';
        }

        // Update legacy fields
        userName.value = personalInfoResponse.data.fullName;
        userEmail.value = personalInfoResponse.data.email;
        isServiceProvider.value = personalInfoResponse.data.isProvider;

        // Update availability status for service providers
        if (personalInfoResponse.data.isProvider) {
          isAvailable.value = personalInfoResponse.data.isAvailable;
        }

        // Update avatar if available
        if (personalInfoResponse.data.avatar != null &&
            personalInfoResponse.data.avatar!.isNotEmpty) {
          profileImage.value = personalInfoResponse.data.fullAvatarUrl ?? '';
        }
      } else {
        personalInfoError.value = personalInfoResponse.message;
      }
    } catch (e) {
      personalInfoError.value = e.toString();
      debugPrint('Error fetching personal info: $e');
    } finally {
      isPersonalInfoLoading.value = false;
    }
  }

  /// Picks profile image from device gallery
  /// Opens image picker directly without navigating to another screen
  Future<void> pickProfileImage() async {
    if (_isPickingImage) return;
    _isPickingImage = true;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        selectedProfileImage.value = File(image.path);
        // Upload image to server immediately
        await uploadAvatar();
      }
    } finally {
      _isPickingImage = false;
    }
  }

  /// Uploads avatar image to server via multipart/form-data
  /// Uses PATCH /settings/personal-info/me with avatar file
  Future<void> uploadAvatar() async {
    if (selectedProfileImage.value == null) return;

    if (!_connectivityService.isConnected.value) {
      _showConnectivityError();
      return;
    }

    try {
      final response = await _apiService.multipart(
        'PATCH',
        ApiConstant.uploadAvatar,
        files: {'avatar': selectedProfileImage.value!},
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>?;
        if (data != null && data['avatar'] != null) {
          // Update profile image with the URL from server
          final avatarPath = data['avatar'] as String;
          profileImage.value = ApiConstant.getFullMediaUrl(avatarPath);

          Get.snackbar(
            'success'.tr,
            'avatarUploaded'.tr.isNotEmpty
                ? 'avatarUploaded'.tr
                : 'Avatar uploaded successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green[700],
            colorText: Colors.white,
          );
        }
      } else {
        final message = response['message'] ?? 'Failed to upload avatar';
        Get.snackbar('error'.tr, message);
      }
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      Get.snackbar('error'.tr, 'somethingWentWrong'.tr);
    }
  }

  /// Updates personal info via API
  /// API Endpoint: PATCH /settings/personal-info/me
  /// Note: Email cannot be changed (read-only on backend)
  Future<void> updatePersonalInfo() async {
    if (!_connectivityService.isConnected.value) {
      _showConnectivityError();
      return;
    }

    isPersonalInfoLoading.value = true;

    try {
      final requestBody = <String, dynamic>{
        'full_name': nameController.text.trim(),
        'nationality': nationalityController.text.trim(),
        'phone_number': phoneController.text.trim(),
      };

      // Include bio only for providers
      if (isServiceProvider.value) {
        requestBody['bio'] = bioController.text.trim();
      }

      final response = await _apiService.patch(
        ApiConstant.personalInfoMe,
        body: requestBody,
      );

      final personalInfoResponse = PersonalInfoResponse.fromJson(response);
      if (personalInfoResponse.success) {
        personalInfo.value = personalInfoResponse.data;

        // Update legacy fields
        userName.value = personalInfoResponse.data.fullName;
        bio.value = personalInfoResponse.data.bio ?? '';

        Get.back();
        Get.snackbar(
          'success'.tr,
          'profileUpdatedSuccessfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[700],
          colorText: Colors.white,
        );
      } else {
        personalInfoError.value = personalInfoResponse.message;
        Get.snackbar('error'.tr, personalInfoResponse.message);
      }
    } catch (e) {
      personalInfoError.value = e.toString();
      debugPrint('Error updating personal info: $e');
      Get.snackbar('error'.tr, 'somethingWentWrong'.tr);
    } finally {
      isPersonalInfoLoading.value = false;
    }
  }

  // ===== WALLET API METHODS =====

  /// Fetches provider wallet history from API
  /// API Endpoint: GET /payments/provider-wallet-history
  ///
  /// [refresh] - If true, resets pagination and fetches from page 1
  Future<void> fetchWalletHistory({bool refresh = false}) async {
    if (!_connectivityService.isConnected.value) {
      _showConnectivityError();
      return;
    }

    // Reset pagination on refresh
    if (refresh) {
      walletCurrentPage.value = 1;
      walletTransactions.clear();
    }

    isWalletLoading.value = true;
    walletError.value = '';

    try {
      final response = await _walletRepository.fetchWalletHistory(
        page: walletCurrentPage.value,
        pageSize: 10,
      );

      if (response.success) {
        // Update summary
        walletSummary.value = response.summary;

        // Update wallet balance legacy field
        if (response.summary != null) {
          walletBalance.value = response.summary!.availableBalance;
        }

        // Update pagination info
        if (response.history?.pagination != null) {
          walletTotalPages.value = response.history!.pagination.totalPages;
        }

        // Append transactions (for load more)
        if (response.history?.transactions != null) {
          walletTransactions.addAll(response.history!.transactions);
        }
      } else {
        walletError.value = response.message;
      }
    } catch (e) {
      walletError.value = e.toString();
      debugPrint('Error fetching wallet history: $e');
    } finally {
      isWalletLoading.value = false;
    }
  }

  /// Loads more wallet transactions for pagination
  Future<void> loadMoreWalletTransactions() async {
    if (!hasMoreWalletTransactions || isWalletLoading.value) return;

    walletCurrentPage.value++;
    await fetchWalletHistory();
  }

  /// Refreshes wallet data
  Future<void> refreshWallet() async {
    await fetchWalletHistory(refresh: true);
  }

  // ===== BOOKMARKS API METHODS =====

  /// Fetches user's bookmarked services from API
  /// API Endpoint: GET /services/my-bookmarked?page=1&page_size=10
  Future<void> fetchBookmarks() async {
    if (!_connectivityService.isConnected.value) {
      _showConnectivityError();
      return;
    }

    try {
      final response = await _serviceRepository.getMyBookmarkedServices(
        page: 1,
        pageSize: 20,
      );

      if (response.success) {
        bookmarks.assignAll(response.data);
      } else {
        debugPrint('Failed to fetch bookmarks: ${response.message}');
      }
    } catch (e) {
      debugPrint('Error fetching bookmarks: $e');
    }
  }

  /// Refreshes bookmarks data
  Future<void> refreshBookmarks() async {
    await fetchBookmarks();
  }

  /// NOTE: TextEditingControllers are NOT disposed here because this controller
  /// is a singleton managed by GetX. Disposing them would cause errors when
  /// the controller is reused after navigation (e.g., returning to ChangePasswordView).
  /// For singleton controllers, TextEditingControllers persist for the app's lifetime.
  @override
  void onClose() {
    // TextEditingControllers intentionally not disposed for singleton lifecycle
    super.onClose();
  }
}
