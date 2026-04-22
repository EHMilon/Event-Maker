import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../constants/app_colors.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/primary_text_button.dart';
import 'add_service_controller.dart';

/// View for managing packages and pricings for services
class PackagesPricingsView extends StatefulWidget {
  const PackagesPricingsView({super.key});

  @override
  State<PackagesPricingsView> createState() => _PackagesPricingsViewState();
}

class _PackagesPricingsViewState extends State<PackagesPricingsView> {
  final AddServiceController controller = Get.find<AddServiceController>();
  bool _isPickingImage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            // Sync all packages' controller values to reactive properties before closing
            for (var package in controller.packages) {
              package.syncToReactive();
            }
            // Return true to indicate changes were made
            Get.back(result: true);
          },
        ),
        title: Text(
          'packagesPricings'.tr,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: controller.addPackage,
            icon: Icon(Icons.add, color: AppColors.primary, size: 20.r),
            label: Text(
              'add'.tr,
              style: GoogleFonts.inter(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instructions
              Text(
                'packagesInstructions'.tr,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 24.h),

              // Package list
              ...List.generate(
                controller.packages.length,
                (index) => _buildPackageCard(index),
              ),

              // Add package button if no packages
              if (controller.packages.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64.r,
                        color: AppColors.grey,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'noPackagesAdded'.tr,
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextButton.icon(
                        onPressed: controller.addPackage,
                        icon: Icon(Icons.add, color: AppColors.primary),
                        label: Text(
                          'addFirstPackage'.tr,
                          style: GoogleFonts.inter(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20.w),
        child: PrimaryTextButton(
          text: 'savePackages'.tr,
          onPressed: () {
            // Sync all packages' controller values to reactive properties
            // This ensures the AddServiceView will display updated values
            for (var package in controller.packages) {
              package.syncToReactive();
            }
            // Return true to indicate packages were saved/updated
            Get.back(result: true);
          },
        ),
      ),
    );
  }

  Widget _buildPackageCard(int index) {
    final package = controller.packages[index];

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with package number and delete button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'packageLabel'.trParams({'index': '${index + 1}'}),
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (controller.packages.length > 1)
                IconButton(
                  onPressed: () => controller.removePackage(index),
                  icon: Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 22.r,
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),

          // Package name
          CustomTextField(
            controller: package.nameController,
            labelText: 'packageName'.tr,
            hintText: 'packageHint'.tr,
          ),
          SizedBox(height: 12.h),

          // Package price
          CustomTextField(
            controller: package.priceController,
            labelText: 'priceAED'.tr,
            hintText: '0.00',
            keyboardType: TextInputType.number,
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
          ),
          SizedBox(height: 16.h),

          // Features section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'features'.tr,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: () => package.addFeature(),
                icon: Icon(Icons.add, size: 18.r, color: AppColors.primary),
                label: Text(
                  'addFeature'.tr,
                  style: GoogleFonts.inter(color: AppColors.primary),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Features list - uses Obx to listen to features changes
          Obx(
            () => Column(
              children: List.generate(package.features.length, (
                featureIndex,
              ) {
                final feature = package.features[featureIndex];
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Feature Image Picker
                      Obx(
                        () => GestureDetector(
                          onTap: () async {
                            if (_isPickingImage) return;
                            _isPickingImage = true;
                            
                            try {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 70,
                              );
                              if (image != null) {
                                feature.selectedImagePath.value = image.path;
                              }
                            } finally {
                              _isPickingImage = false;
                            }
                          },
                          child: Container(
                            width: 45.r,
                            height: 45.r,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: AppColors.borderLight),
                              image:
                                  feature.selectedImagePath.value != null
                                      ? DecorationImage(
                                          image: feature.selectedImagePath.value!
                                                  .startsWith('http')
                                              ? NetworkImage(
                                                  feature.selectedImagePath.value!,
                                                )
                                              : FileImage(
                                                  File(
                                                    feature
                                                        .selectedImagePath
                                                        .value!,
                                                  ),
                                                ) as ImageProvider,
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                            ),
                            child:
                                feature.selectedImagePath.value == null
                                    ? Icon(
                                        Icons.add_a_photo_outlined,
                                        size: 20.r,
                                        color: AppColors.textSecondary,
                                      )
                                    : null,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      // Feature Title Field
                      Expanded(
                        child: TextField(
                          controller: feature.titleController,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText: 'enterFeatureHint'.tr,
                            hintStyle: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 10.h,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: AppColors.borderLight,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: AppColors.borderLight,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(color: AppColors.primary),
                            ),
                            suffixIcon: IconButton(
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              onPressed: () {
                                package.removeFeature(featureIndex);
                              },
                              icon: Icon(
                                Icons.close,
                                size: 18.r,
                                color: AppColors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // Empty features placeholder
          Obx(
            () => package.features.isEmpty
                ? Text(
                    'noFeaturesAdded'.tr,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
