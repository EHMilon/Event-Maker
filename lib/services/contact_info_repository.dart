import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/models/contact_info_model.dart';
import 'package:event_maker/services/api_service.dart';

/// Repository for fetching contact information from the backend.
///
/// Backend Contract:
/// - GET /settings/contact-info: Returns contact information settings
///
/// The backend should return responses in the following format:
/// ```json
/// {
///   "success": true,
///   "message": "Contact setting retrieved successfully.",
///   "data": {
///     "id": 1,
///     "support_phone": "12321312",
///     "support_email": "",
///     "social_media": {
///       "instagram": "http://localhost:5173/settings",
///       "twitter": "http://localhost:5173/settings",
///       "facebook": "http://localhost:5173/settings"
///     },
///     "is_active": true,
///     "created_at": "2026-04-06T06:53:20.907600Z",
///     "updated_at": "2026-04-08T08:56:47.075135Z"
///   }
/// }
/// ```
class ContactInfoRepository {
  final ApiService _apiService = ApiService();

  /// Fetches contact information from the backend.
  ///
  /// Returns [ContactInfoModel] if successful.
  /// Returns null if the API call fails or data is not available.
  /// Throws an exception if the API call fails catastrophically.
  Future<ContactInfoModel?> fetchContactInfo() async {
    try {
      final response = await _apiService.get(ApiConstant.contactInfo);

      final contactInfoResponse = ContactInfoResponse.fromJson(response);
      if (contactInfoResponse.success && contactInfoResponse.data != null) {
        return contactInfoResponse.data;
      }

      // Return null if no data or unsuccessful
      return null;
    } catch (e) {
      // Re-throw to let the controller handle the error
      rethrow;
    }
  }
}
