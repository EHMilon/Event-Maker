import 'dart:io';
import 'package:event_maker/models/certification_model.dart';
import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/services/certification_repository.dart';
import 'package:event_maker/services/api_exception.dart';
import 'package:event_maker/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CertificationController extends GetxController {
  final CertificationRepository _repository = CertificationRepository();
  final RxList<CertificationModel> certifications = <CertificationModel>[].obs;
  final RxBool isLoading = false.obs;

  // Controllers for Add/Edit
  final titleController = TextEditingController();
  final instituteController = TextEditingController();
  final dateController = TextEditingController();
  final Rxn<File> selectedImage = Rxn<File>();
  final RxnString imageUrl = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchCertificates();
  }

  /// Fetch all certificates from API
  Future<void> fetchCertificates() async {
    try {
      isLoading.value = true;
      Log.d('=======> CertificationController: Fetching certificates');
      final response = await _repository.fetchCertifications();
      certifications.assignAll(response.data);
    } on ApiException catch (e) {
      Log.e('=======> CertificationController: ApiException: ${e.message}');
      Get.snackbar(
        'error'.tr,
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Log.e('=======> CertificationController: Error fetching certificates: $e');
      Get.snackbar(
        'error'.tr,
        'failedToFetchCertificates'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _isPickingImage = false;
  Future<void> pickImage() async {
    if (_isPickingImage) return;
    _isPickingImage = true;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } finally {
      _isPickingImage = false;
    }
  }

  void prepareEdit(CertificationModel cert) {
    titleController.text = cert.title;
    instituteController.text = cert.institute;
    dateController.text = cert.issueDateForForm;
    imageUrl.value = ApiConstant.getFullMediaUrl(cert.file);
    selectedImage.value = null;
  }

  void clearFields() {
    titleController.clear();
    instituteController.clear();
    dateController.clear();
    selectedImage.value = null;
    imageUrl.value = null;
  }

  /// Add new certificate via API
  Future<void> addCertification() async {
    if (titleController.text.isEmpty || instituteController.text.isEmpty || dateController.text.isEmpty) {
      Get.snackbar('error'.tr, 'pleaseSelectAllFields'.tr);
      return;
    }

    if (selectedImage.value == null) {
      Get.snackbar('error'.tr, 'pleaseSelectAllFields'.tr);
      return;
    }

    try {
      isLoading.value = true;

      // Convert date from DD/MM/YYYY to YYYY-MM-DD for API
      final dateParts = dateController.text.split('/');
      String issueDate = dateController.text;
      if (dateParts.length == 3) {
        issueDate = '${dateParts[2]}-${dateParts[1].padLeft(2, '0')}-${dateParts[0].padLeft(2, '0')}';
      }

      Log.d('=======> CertificationController: Creating certificate');
      final newCert = await _repository.createCertification(
        title: titleController.text,
        institute: instituteController.text,
        issueDate: issueDate,
        file: selectedImage.value!,
      );

      certifications.insert(0, newCert);

      Get.back();
      Get.snackbar(
        'success'.tr,
        'certAddedSuccess'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
      clearFields();
    } on ApiException catch (e) {
      Log.e('=======> CertificationController: ApiException: ${e.message}');
      Get.snackbar(
        'error'.tr,
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Log.e('=======> CertificationController: Error creating certificate: $e');
      Get.snackbar(
        'error'.tr,
        'failedToCreateCertificate'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update certificate via API
  Future<void> updateCertification(int id) async {
    if (titleController.text.isEmpty || instituteController.text.isEmpty || dateController.text.isEmpty) {
      Get.snackbar('error'.tr, 'pleaseSelectAllFields'.tr);
      return;
    }

    try {
      isLoading.value = true;

      // Convert date from DD/MM/YYYY to YYYY-MM-DD for API
      final dateParts = dateController.text.split('/');
      String issueDate = dateController.text;
      if (dateParts.length == 3) {
        issueDate = '${dateParts[2]}-${dateParts[1].padLeft(2, '0')}-${dateParts[0].padLeft(2, '0')}';
      }

      Log.d('=======> CertificationController: Updating certificate $id');
      final updatedCert = await _repository.updateCertification(
        certificationId: id,
        title: titleController.text,
        institute: instituteController.text,
        issueDate: issueDate,
        file: selectedImage.value,
      );

      final index = certifications.indexWhere((c) => c.id == id);
      if (index != -1) {
        certifications[index] = updatedCert;
      }

      Get.back();
      Get.snackbar(
        'success'.tr,
        'certUpdatedSuccess'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
      clearFields();
    } on ApiException catch (e) {
      Log.e('=======> CertificationController: ApiException: ${e.message}');
      Get.snackbar(
        'error'.tr,
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Log.e('=======> CertificationController: Error updating certificate: $e');
      Get.snackbar(
        'error'.tr,
        'failedToUpdateCertificate'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete certificate via API
  Future<void> deleteCertificate(int id) async {
    try {
      isLoading.value = true;
      Log.d('=======> CertificationController: Deleting certificate $id');
      await _repository.deleteCertification(id);

      certifications.removeWhere((c) => c.id == id);

      Get.snackbar(
        'success'.tr,
        'certDeletedSuccess'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } on ApiException catch (e) {
      Log.e('=======> CertificationController: ApiException: ${e.message}');
      Get.snackbar(
        'error'.tr,
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Log.e('=======> CertificationController: Error deleting certificate: $e');
      Get.snackbar(
        'error'.tr,
        'failedToDeleteCertificate'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    instituteController.dispose();
    dateController.dispose();
    super.onClose();
  }
}
