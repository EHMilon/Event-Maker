import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:event_maker/global/base_controller.dart';
import 'package:event_maker/models/contact_info_model.dart';
import 'package:event_maker/services/contact_info_repository.dart';

/// Controller for managing Contact Us screen state and API calls.
///
/// Uses Repository Pattern to decouple UI from Data.
/// Extends BaseController for common loading/error state management.
class ContactUsController extends BaseController {
  final ContactInfoRepository _repository = ContactInfoRepository();

  /// Contact info data from API
  final Rx<ContactInfoModel?> contactInfo = Rx<ContactInfoModel?>(null);

  @override
  void onInit() {
    super.onInit();
    // Fetch contact info when controller initializes
    fetchContactInfo();
  }

  /// Fetches contact information from the backend API.
  ///
  /// Automatically manages loading and error states via BaseController.
  /// On success: populates contactInfo with API data
  /// On error: displays error snackbar with message
  Future<void> fetchContactInfo() async {
    debugPrint('ContactUsController: Fetching contact info...');
    
    if (!checkNetwork()) {
      return;
    }
    
    setLoading(true, message: 'Loading contact info...');
    
    try {
      final data = await _repository.fetchContactInfo();
      debugPrint('ContactUsController: Received data: $data');
      
      if (data != null) {
        contactInfo.value = data;
        debugPrint('ContactUsController: Phone: "${data.supportPhone}"');
        debugPrint('ContactUsController: Email: "${data.supportEmail}"');
        debugPrint('ContactUsController: Instagram: "${data.socialMedia.instagram}"');
        debugPrint('ContactUsController: Twitter: "${data.socialMedia.twitter}"');
        debugPrint('ContactUsController: Facebook: "${data.socialMedia.facebook}"');
        debugPrint('ContactUsController: hasPhone: $hasPhone');
        debugPrint('ContactUsController: hasEmail: $hasEmail');
        debugPrint('ContactUsController: hasSocialMedia: $hasSocialMedia');
      } else {
        setError('No contact information available');
      }
    } catch (e) {
      debugPrint('ContactUsController: Error: $e');
      setError('Failed to load contact information');
    } finally {
      setLoading(false);
    }
  }

  /// Refreshes contact information from the API.
  ///
  /// Useful for pull-to-refresh functionality.
  Future<void> refreshContactInfo() async {
    debugPrint('ContactUsController: Refreshing contact info...');
    
    if (!checkNetwork()) {
      return;
    }
    
    setRefreshing(true);
    
    try {
      final data = await _repository.fetchContactInfo();
      debugPrint('ContactUsController: Refresh received data: $data');
      
      if (data != null) {
        contactInfo.value = data;
        clearError();
      } else {
        setError('No contact information available');
      }
    } catch (e) {
      debugPrint('ContactUsController: Refresh error: $e');
      setError('Failed to refresh contact information');
    } finally {
      setRefreshing(false);
    }
  }

  /// Gets the formatted phone number or returns a fallback.
  String get supportPhone => contactInfo.value?.supportPhone ?? '';

  /// Gets the formatted email or returns a fallback.
  String get supportEmail => contactInfo.value?.supportEmail ?? '';

  /// Gets Instagram URL or returns empty string.
  String get instagramUrl => contactInfo.value?.socialMedia.instagram ?? '';

  /// Gets Twitter URL or returns empty string.
  String get twitterUrl => contactInfo.value?.socialMedia.twitter ?? '';

  /// Gets Facebook URL or returns empty string.
  String get facebookUrl => contactInfo.value?.socialMedia.facebook ?? '';

  /// Checks if phone number is available.
  bool get hasPhone => supportPhone.isNotEmpty;

  /// Checks if email is available.
  bool get hasEmail => supportEmail.isNotEmpty;

  /// Checks if any social media links are available.
  bool get hasSocialMedia {
    return instagramUrl.isNotEmpty || 
           twitterUrl.isNotEmpty || 
           facebookUrl.isNotEmpty;
  }
}
