import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/document_model.dart';
import '../../../services/document_repository.dart';
import '../../../services/api_exception.dart';
import '../../../constants/api_constant.dart';

class DocumentsController extends GetxController {
  final DocumentRepository _repository = DocumentRepository();

  // Observable states
  var isLoading = false.obs;
  var isUploading = false.obs;
  var isDeleting = false.obs;
  var documents = <DocumentModel>[].obs;
  var errorMessage = ''.obs;

  // For Add Document View
  var selectedFile = Rxn<File>();
  var fileName = ''.obs;
  var fileSize = ''.obs;
  var titleController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchDocuments();
  }

  /// Fetch all documents from backend
  Future<void> fetchDocuments() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.fetchDocuments();
      documents.value = response.data;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      debugPrint('API Error: ${e.message}');
    } catch (e) {
      errorMessage.value = 'failedToLoadDocuments'.tr;
      debugPrint('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Pick a document file using file picker
  Future<void> pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      selectedFile.value = file;
      fileName.value = result.files.single.name;
      fileSize.value = _formatBytes(result.files.single.size);
    }
  }

  /// Format bytes to human readable size
  String _formatBytes(int bytes, [int decimals = 1]) {
    if (bytes <= 0) return "0 B";
    const prefixes = ["B", "KB", "MB", "GB", "TB"];
    int index = (bytes > 0) ? (bytes.toString().length - 1) ~/ 3 : 0;
    if (index >= prefixes.length) index = prefixes.length - 1;
    double d = bytes / (index == 0 ? 1 : (1 << (10 * index)));
    return '${d.toStringAsFixed(decimals)} ${prefixes[index]}';
  }

  /// Add a new document (upload to backend)
  Future<void> addDocument(String title) async {
    if (selectedFile.value == null) {
      Get.snackbar(
        'error'.tr,
        'pleaseSelectFile'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (title.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'pleaseEnterTitle'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isUploading.value = true;

    try {
      final newDocument = await _repository.createDocument(
        title: title,
        file: selectedFile.value!,
      );

      // Add to local list
      documents.insert(0, newDocument);

      // Reset form
      _resetForm();

      // Go back to documents list
      Get.back();

      Get.snackbar(
        'success'.tr,
        'documentUploadedSuccess'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } on ApiException catch (e) {
      Get.snackbar(
        'error'.tr,
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failedToUploadDocument'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploading.value = false;
    }
  }

  /// Delete a document
  Future<void> deleteDocument(int documentId) async {
    try {
      isDeleting.value = true;
      await _repository.deleteDocument(documentId);

      // Remove from local list
      documents.removeWhere((doc) => doc.id == documentId);

      Get.snackbar(
        'success'.tr,
        'documentDeletedSuccess'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } on ApiException catch (e) {
      Get.snackbar(
        'error'.tr,
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failedToDeleteDocument'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isDeleting.value = false;
    }
  }

  /// Show delete confirmation dialog
  void confirmDelete(DocumentModel document) {
    Get.dialog(
      AlertDialog(
        title: Text('deleteDocument'.tr),
        content: Text(
          'deleteDocumentConfirm'.tr,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              Get.back();
              deleteDocument(document.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }

  /// Reset the form state
  void _resetForm() {
    selectedFile.value = null;
    fileName.value = '';
    fileSize.value = '';
  }

  /// Clear selected file
  void clearSelectedFile() {
    selectedFile.value = null;
    fileName.value = '';
    fileSize.value = '';
  }

  /// Get full URL for document file
  String getDocumentUrl(String filePath) {
    return ApiConstant.getFullMediaUrl(filePath);
  }

  /// Prepare fields for editing - called before navigating to edit view
  void prepareEdit(DocumentModel document) {
    // Set the editing document
    editingDocument.value = document;
    titleController.text = document.title;

    // Set file info from existing document
    selectedFile.value = null;
    fileName.value = document.fileName;

    // Try to get file size
    fileSize.value = '';
  }

  /// Clear all fields - called after adding/editing
  void clearFields() {
    selectedFile.value = null;
    fileName.value = '';
    fileSize.value = '';
    // Don't clear text controller here to avoid setState during dispose
    // The controller will be cleared when a new document is prepared
    editingDocument.value = null;
    errorMessage.value = '';
  }

  /// Update an existing document
  Future<void> updateDocument(int documentId, String title) async {
    if (title.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'Please enter a title',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isUploading.value = true;

    try {
      final updatedDocument = await _repository.updateDocument(
        documentId: documentId,
        title: title,
        file: selectedFile.value,
      );

      // Update the document in the list
      final index = documents.indexWhere((doc) => doc.id == documentId);
      if (index != -1) {
        documents[index] = updatedDocument;
        documents.refresh();
      }

      // Reset form
      _resetForm();

      // Go back
      Get.back();

      Get.snackbar(
        'success'.tr,
        'Document updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } on ApiException catch (e) {
      Get.snackbar(
        'error'.tr,
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'Failed to update document',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploading.value = false;
    }
  }

  /// Current document being edited
  var editingDocument = Rxn<DocumentModel>();
}
