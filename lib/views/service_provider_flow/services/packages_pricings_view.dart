import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/primary_text_button.dart';
import 'add_service_controller.dart';

class PackagesPricingsView extends GetView<AddServiceController> {
  const PackagesPricingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Packages & Pricings',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(
        () => Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                itemCount: controller.packages.length,
                itemBuilder: (context, packageIndex) {
                  final package = controller.packages[packageIndex];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Package ${packageIndex + 1}',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (controller.packages.length > 1)
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                                size: 20.r,
                              ),
                              onPressed: () =>
                                  controller.removePackage(packageIndex),
                            ),
                          TextButton.icon(
                            onPressed: () => controller.addPackage(),
                            icon: Icon(
                              Icons.add,
                              size: 16.sp,
                              color: AppColors.primary,
                            ),
                            label: Text(
                              'Add Package',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      CustomTextField(
                        controller: package.nameController,
                        labelText: 'Package name',
                        hintText: 'Item title here',
                      ),
                      SizedBox(height: 16.h),
                      CustomTextField(
                        controller: package.priceController,
                        labelText: 'Package price per hour',
                        hintText: '00.00',
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(14.r),
                          child: Text(
                            r'$',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Features',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Obx(
                        () => Column(
                          children: List.generate(package.features.length, (
                            featureIndex,
                          ) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: CustomTextField(
                                hintText: 'Item title here',
                                onChanged: (v) =>
                                    package.features[featureIndex] = v,
                              ),
                            );
                          }),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => package.features.add(''),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add,
                              size: 20.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Add Feature',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32.h),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.lightGrey),
                        minimumSize: Size(double.infinity, 56.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: PrimaryTextButton(
                      text: 'Update',
                      onPressed: () => Get.back(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
