import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/views/auth/auth_controller.dart';
import 'package:event_maker/widgets/primary_text_button.dart';

class SignupDocumentsListView extends GetView<AuthController> {
  const SignupDocumentsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Documents",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.signupDocuments.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  padding: EdgeInsets.all(24.w),
                  itemCount: controller.signupDocuments.length,
                  itemBuilder: (context, index) {
                    final doc = controller.signupDocuments[index];
                    return _buildDocumentCard(doc, index);
                  },
                );
              }),
            ),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Get.toNamed('/signup-add-document'),
                      icon: const Icon(Icons.add),
                      label: const Text("Add Document"),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  PrimaryTextButton(
                    text: "Continue",
                    onPressed: () => Get.back(),
                    isLoading: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 64.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              "No Documents Added",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Add your business documents to get verified faster",
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> doc, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              doc['isPdf'] == true ? Icons.picture_as_pdf : Icons.description_outlined,
              color: doc['isPdf'] == true ? Colors.red.shade400 : AppColors.primary,
              size: 24,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc['title'] ?? 'Document',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  doc['fileName'] ?? '',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red.shade400,
            onPressed: () => controller.removeSignupDocument(index),
          ),
        ],
      ),
    );
  }
}