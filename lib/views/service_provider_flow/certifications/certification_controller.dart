import 'dart:io';
import 'package:event_maker/data/models/certification_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CertificationController extends GetxController {
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
    _loadMockCertifications();
  }

  void _loadMockCertifications() {
    isLoading.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      certifications.assignAll([
        CertificationModel(
          id: '1',
          title: 'Professional Chef',
          date: 'July, 2025',
          school: 'Sonargaon Cooking School',
          imageUrl: 'assets/images/certificate.png',
        ),
        CertificationModel(
          id: '2',
          title: 'Pizza Artisan',
          date: 'August, 2025',
          school: 'Lorenzo\'s Pizza',
          imageUrl: 'assets/images/certificate.png',
        ),
      ]);
      isLoading.value = false;
    });
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  void prepareEdit(CertificationModel cert) {
    titleController.text = cert.title;
    instituteController.text = cert.school;
    dateController.text = cert.date;
    imageUrl.value = cert.imageUrl;
    selectedImage.value = null;
  }

  void clearFields() {
    titleController.clear();
    instituteController.clear();
    dateController.clear();
    selectedImage.value = null;
    imageUrl.value = null;
  }

  void addCertification() {
    if (titleController.text.isEmpty || instituteController.text.isEmpty) {
      Get.snackbar('error'.tr, 'pleaseSelectAllFields'.tr);
      return;
    }

    isLoading.value = true;
    Future.delayed(const Duration(seconds: 1), () {
      final newCert = CertificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: titleController.text,
        school: instituteController.text,
        date: dateController.text,
        imageUrl: selectedImage.value?.path ?? 'assets/icons/scroll-text.svg',
      );
      certifications.insert(0, newCert);
      isLoading.value = false;
      Get.back();
      Get.snackbar(
        'success'.tr,
        'certAddedSuccess'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
      clearFields();
    });
  }

  void updateCertification(String id) {
    if (titleController.text.isEmpty || instituteController.text.isEmpty) {
      Get.snackbar('error'.tr, 'pleaseSelectAllFields'.tr);
      return;
    }

    final index = certifications.indexWhere((c) => c.id == id);
    if (index != -1) {
      isLoading.value = true;
      Future.delayed(const Duration(seconds: 1), () {
        certifications[index] = certifications[index].copyWith(
          title: titleController.text,
          school: instituteController.text,
          date: dateController.text,
          imageUrl: selectedImage.value?.path ?? imageUrl.value,
        );
        isLoading.value = false;
        Get.back(); // Back to list view
        Get.snackbar(
          'success'.tr,
          'certUpdatedSuccess'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
        clearFields();
      });
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
