import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/views/auth/auth_controller.dart';
import 'package:event_maker/widgets/primary_text_button.dart';

class SignupAddEditCertificateView extends StatefulWidget {
  const SignupAddEditCertificateView({super.key});

  @override
  State<SignupAddEditCertificateView> createState() =>
      _SignupAddEditCertificateViewState();
}

class _SignupAddEditCertificateViewState extends State<SignupAddEditCertificateView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _instituteController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final AuthController controller = Get.find<AuthController>();

  @override
  void dispose() {
    _titleController.dispose();
    _instituteController.dispose();
    _dateController.dispose();
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
          "Add Certification",
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
                onTap: () => controller.pickSignupCertificationImage(),
                child: Obx(
                  () => Container(
                    width: double.infinity,
                    height: 180.h,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: controller.selectedCertificationImage.value != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.file(
                              controller.selectedCertificationImage.value!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 40.sp,
                                color: AppColors.textSecondary.withOpacity(0.5),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                "Upload",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                "JPG or PNG",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                "Certificate Name",
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
                  hintText: "Your title goes here...",
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
              SizedBox(height: 16.h),
              Text(
                "Issued By",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _instituteController,
                decoration: InputDecoration(
                  hintText: "Institute Name",
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
              SizedBox(height: 16.h),
              Text(
                "Issue Date",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _dateController,
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    _dateController.text = date.toIso8601String().split('T')[0];
                  }
                },
                decoration: InputDecoration(
                  hintText: "YYYY-MM-DD",
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
                  prefixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.primary,
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
              SizedBox(height: 60.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(24.w),
        child: Obx(
          () => PrimaryTextButton(
            text: "Save",
            onPressed: () {
              if (_titleController.text.isEmpty) {
                controller.showWarning('Please enter certificate name');
                return;
              }
              if (_instituteController.text.isEmpty) {
                controller.showWarning('Please enter institute name');
                return;
              }
              controller.addSignupCertification(
                _titleController.text,
                _instituteController.text,
                _dateController.text,
              );
            },
            isLoading: controller.isLoading.value,
          ),
        ),
      ),
    );
  }
}
