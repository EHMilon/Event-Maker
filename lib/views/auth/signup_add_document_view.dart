import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/views/auth/auth_controller.dart';
import 'package:event_maker/widgets/primary_text_button.dart';

class SignupAddDocumentView extends StatefulWidget {
  const SignupAddDocumentView({super.key});

  @override
  State<SignupAddDocumentView> createState() => _SignupAddDocumentViewState();
}

class _SignupAddDocumentViewState extends State<SignupAddDocumentView> {
  final TextEditingController _titleController = TextEditingController();
  final AuthController controller = Get.find<AuthController>();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

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
          "Add Document",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: () => controller.pickSignupDocument(),
                child: Obx(
                  () => Container(
                    width: double.infinity,
                    height: 180.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: controller.selectedSignupFile.value == null
                            ? AppColors.lightGrey
                            : AppColors.primary,
                        style: BorderStyle.solid,
                        width: controller.selectedSignupFile.value == null
                            ? 1
                            : 2,
                      ),
                    ),
                    child: controller.selectedSignupFile.value == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF3F4F6),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.cloud_upload_outlined,
                                  color: AppColors.textSecondary,
                                  size: 32,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                "Upload Document",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                "PNG, JPG",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.insert_drive_file,
                                color: AppColors.primary,
                                size: 48,
                              ),
                              SizedBox(height: 12.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: Text(
                                  controller.fileName,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    controller.pickSignupDocument(),
                                child: const Text("Change"),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              Text(
                "Document Title",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Enter document title",
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.grey.withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.lightGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.lightGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "Document Type",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Obx(
                () => DropdownButtonFormField<String>(
                  value: controller.selectedDocumentType.value.isEmpty || 
                        ![
                          "National ID",
                          "Passport",
                          "Trade License",
                          "Commercial Registration",
                          "VAT Certificate",
                          "Training Certificate",
                          "Experience Certificate",
                          "Portfolio",
                          "Food Safety Certificate",
                          "Bank Document",
                          "Family Business Permit",
                          "Other",
                        ].contains(controller.selectedDocumentType.value)
                      ? null 
                      : controller.selectedDocumentType.value,

                  items:
                      [
                            "National ID",
                            "Passport",
                            "Trade License",
                            "Commercial Registration",
                            "VAT Certificate",
                            "Training Certificate",
                            "Experience Certificate",
                            "Portfolio",
                            "Food Safety Certificate",
                            "Bank Document",
                            "Family Business Permit",
                            "Other",
                          ]
                          .map(
                            (String type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.selectedDocumentType.value = value;
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(24.w),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  side: const BorderSide(color: AppColors.lightGrey),
                ),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Obx(
                () => PrimaryTextButton(
                  text: "Upload",
                  onPressed: () {
                    if (_titleController.text.isEmpty) {
                      controller.showWarning('Please enter document title');
                      return;
                    }
                    if (controller.selectedSignupFile.value == null) {
                      controller.showWarning('Please select a file');
                      return;
                    }
                    controller.addSignupDocument(
                      _titleController.text,
                      controller.selectedDocumentType.value,
                    );
                  },
                  isLoading: controller.isLoading.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
