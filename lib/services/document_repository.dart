import 'dart:io';
import '../models/document_model.dart';
import '../utils/logger.dart';
import '../constants/api_constant.dart';
import 'api_service.dart';
import 'api_exception.dart';

/// Repository for managing provider documents.
/// Handles CRUD operations for documents via API.
class DocumentRepository {
  final ApiService _api = ApiService();

  /// Fetch all documents for the authenticated provider.
  /// GET: api/providers/documents
  Future<DocumentListResponse> fetchDocuments() async {
    try {
      Log.d('=======> DocumentRepository: Fetching documents');
      final response = await _api.get(ApiConstant.providerDocuments);
      Log.d('=======> DocumentRepository: Response received: $response');
      return DocumentListResponse.fromJson(response);
    } on ApiException catch (e) {
      Log.e('=======> DocumentRepository: ApiException: ${e.message}');
      throw ApiException(message: e.message);
    } catch (e) {
      Log.e('=======> DocumentRepository: Error fetching documents: $e');
      throw ApiException(message: 'Failed to fetch documents: $e');
    }
  }

  /// Fetch a single document by ID.
  /// GET: api/providers/documents/detail/{id}
  Future<DocumentModel> fetchDocumentDetail(int documentId) async {
    try {
      Log.d('=======> DocumentRepository: Fetching document $documentId');
      final response = await _api.get(
        ApiConstant.providerDocumentDetail(documentId),
      );
      Log.d('=======> DocumentRepository: Response received: $response');

      // Handle response wrapped in 'data' key
      final data = response is Map ? (response['data'] ?? response) : response;
      return DocumentModel.fromJson(data);
    } on ApiException catch (e) {
      Log.e('=======> DocumentRepository: ApiException: ${e.message}');
      throw ApiException(message: e.message);
    } catch (e) {
      Log.e('=======> DocumentRepository: Error fetching document: $e');
      throw ApiException(message: 'Failed to fetch document details: $e');
    }
  }

  /// Create a new document with file upload.
  /// POST: api/providers/documents
  /// Returns the created document on success.
  Future<DocumentModel> createDocument({
    required String title,
    required File file,
  }) async {
    try {
      Log.d('=======> DocumentRepository: Creating document with title: $title');
      Log.d('=======> DocumentRepository: File path: ${file.path}');

      final response = await _api.multipart(
        'POST',
        ApiConstant.providerDocuments,
        fields: {'title': title},
        files: {'file': file},
      );

      Log.d('=======> DocumentRepository: Create response: $response');

      // Handle response wrapped in 'data' key
      final data = response is Map ? (response['data'] ?? response) : response;
      return DocumentModel.fromJson(data);
    } on ApiException catch (e) {
      Log.e('=======> DocumentRepository: ApiException: ${e.message}');
      throw ApiException(message: e.message);
    } catch (e) {
      Log.e('=======> DocumentRepository: Error creating document: $e');
      throw ApiException(message: 'Failed to create document: $e');
    }
  }

  /// Update an existing document.
  /// PATCH: api/providers/documents/update/{id}
  /// Can update title and/or file.
  Future<DocumentModel> updateDocument({
    required int documentId,
    String? title,
    File? file,
  }) async {
    try {
      Log.d(
        '=======> DocumentRepository: Updating document $documentId',
      );

      final fields = <String, String>{};
      if (title != null) {
        fields['title'] = title;
      }

      final files = <String, File>{};
      if (file != null) {
        files['file'] = file;
      }

      final response = await _api.multipart(
        'PATCH',
        ApiConstant.providerDocumentUpdate(documentId),
        fields: fields,
        files: files,
      );

      Log.d('=======> DocumentRepository: Update response: $response');

      // Handle response wrapped in 'data' key
      final data = response is Map ? (response['data'] ?? response) : response;
      return DocumentModel.fromJson(data);
    } on ApiException catch (e) {
      Log.e('=======> DocumentRepository: ApiException: ${e.message}');
      throw ApiException(message: e.message);
    } catch (e) {
      Log.e('=======> DocumentRepository: Error updating document: $e');
      throw ApiException(message: 'Failed to update document: $e');
    }
  }

  /// Delete a document by ID.
  /// DELETE: api/providers/documents/delete/{id}
  Future<void> deleteDocument(int documentId) async {
    try {
      Log.d('=======> DocumentRepository: Deleting document $documentId');
      await _api.delete(ApiConstant.providerDocumentDelete(documentId));
      Log.d('=======> DocumentRepository: Document deleted successfully');
    } on ApiException catch (e) {
      Log.e('=======> DocumentRepository: ApiException: ${e.message}');
      throw ApiException(message: e.message);
    } catch (e) {
      Log.e('=======> DocumentRepository: Error deleting document: $e');
      throw ApiException(message: 'Failed to delete document: $e');
    }
  }
}
