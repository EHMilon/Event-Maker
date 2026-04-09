import 'dart:io';
import '../models/certification_model.dart';
import '../utils/logger.dart';
import '../constants/api_constant.dart';
import 'api_service.dart';
import 'api_exception.dart';

/// Repository for managing provider certifications.
/// Handles CRUD operations for certifications via API.
class CertificationRepository {
  final ApiService _api = ApiService();

  /// Fetch all certifications for the authenticated provider.
  /// GET: api/providers/certificates
  Future<CertificationListResponse> fetchCertifications() async {
    try {
      Log.d('=======> CertificationRepository: Fetching certifications');
      final response = await _api.get(ApiConstant.providerCertificates);
      Log.d('=======> CertificationRepository: Response received: $response');
      return CertificationListResponse.fromJson(response);
    } on ApiException catch (e) {
      Log.e('=======> CertificationRepository: ApiException: ${e.message}');
      throw ApiException(message: e.message);
    } catch (e) {
      Log.e('=======> CertificationRepository: Error fetching certifications: $e');
      throw ApiException(message: 'Failed to fetch certifications: $e');
    }
  }

  /// Fetch certifications for a specific provider by ID.
  /// GET: api/providers/provider-certificates?provider_id={providerId}
  Future<CertificationListResponse> fetchProviderCertifications(int providerId) async {
    try {
      Log.d('=======> CertificationRepository: Fetching certifications for provider $providerId');
      final response = await _api.get(
        '/providers/provider-certificates?provider_id=$providerId',
      );
      Log.d('=======> CertificationRepository: Response received: $response');
      return CertificationListResponse.fromJson(response);
    } on ApiException catch (e) {
      Log.e('=======> CertificationRepository: ApiException: ${e.message}');
      throw ApiException(message: e.message);
    } catch (e) {
      Log.e('=======> CertificationRepository: Error fetching provider certifications: $e');
      throw ApiException(message: 'Failed to fetch provider certifications: $e');
    }
  }

  /// Fetch a single certification by ID.
  /// GET: api/providers/certificates/detail/{id}
  Future<CertificationModel> fetchCertificationDetail(int certificationId) async {
    try {
      Log.d('=======> CertificationRepository: Fetching certification $certificationId');
      final response = await _api.get(
        ApiConstant.providerCertificateDetail(certificationId),
      );
      Log.d('=======> CertificationRepository: Response received: $response');

      final data = response is Map ? (response['data'] ?? response) : response;
      return CertificationModel.fromJson(data);
    } on ApiException catch (e) {
      Log.e('=======> CertificationRepository: ApiException: ${e.message}');
      throw ApiException(message: e.message);
    } catch (e) {
      Log.e('=======> CertificationRepository: Error fetching certification: $e');
      throw ApiException(message: 'Failed to fetch certification details: $e');
    }
  }

  /// Create a new certification with file upload.
  /// POST: api/providers/certificates
  Future<CertificationModel> createCertification({
    required String title,
    required String institute,
    required String issueDate,
    required File file,
  }) async {
    try {
      Log.d('=======> CertificationRepository: Creating certification with title: $title');

      final response = await _api.multipart(
        'POST',
        ApiConstant.providerCertificates,
        fields: {
          'title': title,
          'institute': institute,
          'issue_date': issueDate,
        },
        files: {'file': file},
      );

      Log.d('=======> CertificationRepository: Create response: $response');

      final data = response is Map ? (response['data'] ?? response) : response;
      return CertificationModel.fromJson(data);
    } on ApiException catch (e) {
      Log.e('=======> CertificationRepository: ApiException: ${e.message}');
      throw ApiException(message: e.message);
    } catch (e) {
      Log.e('=======> CertificationRepository: Error creating certification: $e');
      throw ApiException(message: 'Failed to create certification: $e');
    }
  }

  /// Update an existing certification.
  /// PATCH: api/providers/certificates/update/{id}
  Future<CertificationModel> updateCertification({
    required int certificationId,
    String? title,
    String? institute,
    String? issueDate,
    File? file,
  }) async {
    try {
      Log.d('=======> CertificationRepository: Updating certification $certificationId');

      final fields = <String, String>{};
      if (title != null) fields['title'] = title;
      if (institute != null) fields['institute'] = institute;
      if (issueDate != null) fields['issue_date'] = issueDate;

      final files = <String, File>{};
      if (file != null) files['file'] = file;

      final response = await _api.multipart(
        'PATCH',
        ApiConstant.providerCertificateUpdate(certificationId),
        fields: fields,
        files: files,
      );

      Log.d('=======> CertificationRepository: Update response: $response');

      final data = response is Map ? (response['data'] ?? response) : response;
      return CertificationModel.fromJson(data);
    } on ApiException catch (e) {
      Log.e('=======> CertificationRepository: ApiException: ${e.message}');
      throw ApiException(message: e.message);
    } catch (e) {
      Log.e('=======> CertificationRepository: Error updating certification: $e');
      throw ApiException(message: 'Failed to update certification: $e');
    }
  }

  /// Delete a certification by ID.
  /// DELETE: api/providers/certificates/delete/{id}
  Future<void> deleteCertification(int certificationId) async {
    try {
      Log.d('=======> CertificationRepository: Deleting certification $certificationId');
      await _api.delete(ApiConstant.providerCertificateDelete(certificationId));
      Log.d('=======> CertificationRepository: Certification deleted successfully');
    } on ApiException catch (e) {
      Log.e('=======> CertificationRepository: ApiException: ${e.message}');
      throw ApiException(message: e.message);
    } catch (e) {
      Log.e('=======> CertificationRepository: Error deleting certification: $e');
      throw ApiException(message: 'Failed to delete certification: $e');
    }
  }
}
