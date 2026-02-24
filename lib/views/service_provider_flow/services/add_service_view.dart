import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/themes/app_colors.dart';
import '../../../data/models/service_model.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/primary_text_button.dart';
import '../../../shared/widgets/upload_widget.dart';
import '../../../shared/widgets/availability_widget_card.dart';
import 'add_service_controller.dart';

import 'packages_pricings_view.dart';

class AddServiceView extends StatefulWidget {
  final ServiceModel? service;
  final bool isEdit;

  const AddServiceView({super.key, this.service, this.isEdit = false});

  @override
  State<AddServiceView> createState() => _AddServiceViewState();
}

class _AddServiceViewState extends State<AddServiceView> {
  late final AddServiceController controller;
  final _days = [
    {'key': 'Mon', 'label': 'mon'.tr},
    {'key': 'Tue', 'label': 'tue'.tr},
    {'key': 'Wed', 'label': 'wed'.tr},
    {'key': 'Thu', 'label': 'thu'.tr},
    {'key': 'Fri', 'label': 'fri'.tr},
    {'key': 'Sat', 'label': 'sat'.tr},
    {'key': 'Sun', 'label': 'sun'.tr},
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.find<AddServiceController>();
    // Initialize with service data if editing
    Future.delayed(Duration.zero, () {
      if (widget.isEdit && widget.service != null) {
        controller.initWithService(widget.service!);
      }
    });
  }

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
          widget.isEdit ? 'editService'.tr : 'addNewService'.tr,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(
        () => Skeletonizer(
          enabled: controller.isLoading.value,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UploadWidget(onTap: () {}),
                SizedBox(height: 16.h),
                Obx(
                  () => DropdownButtonFormField<ServiceCategory>(
                    value: controller.selectedCategory.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateCategory(value);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'selectServiceType'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 4.h,
                      ),
                    ),
                    items: ServiceCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(
                          _categoryLabel(category),
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                    dropdownColor: Colors.white,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                CustomTextField(
                  controller: controller.titleController,
                  labelText: 'serviceTitle'.tr,
                  hintText: 'serviceTitleHint'.tr,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: controller.descriptionController,
                  labelText: 'description'.tr,
                  hintText: 'descriptionHint'.tr,
                  keyboardType: TextInputType.multiline,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: controller.locationController,
                  labelText: 'selectLocation'.tr,
                  hintText: 'selectAddressHint'.tr,
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                    size: 20.r,
                  ),
                ),

                SizedBox(height: 24.h),
                
                // Primary Availability Card
                AvailabilityWidgetCard(
                  card: controller.primaryAvailabilityCard,
                  days: _days,
                  canSelectDay: controller.canSelectPrimaryDay,
                  onDayTap: controller.togglePrimaryDay,
                  isPrimary: true,
                  isEnabled: true,
                ),

                // Additional Availability Section
                _buildAdditionalAvailabilitySection(),
                
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'packagesPricings'.tr,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _openPackages(context),
                      icon: Icon(
                        Icons.add,
                        size: 18.sp,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        'addPackage'.tr,
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
                PrimaryTextButton(
                  text: widget.isEdit ? 'updateService'.tr : 'addService'.tr,
                  onPressed: () async {
                    // TODO: Implement field validation before saving
                    await controller.saveService(
                      isEdit: widget.isEdit,
                      existingService: widget.service,
                    );
                  },
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _categoryLabel(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.hospitality:
        return 'hospitality'.tr;
      case ServiceCategory.event:
        return 'event'.tr;
      case ServiceCategory.trainer:
        return 'professionalTrainer'.tr;
    }
  }

  void _openPackages(BuildContext context) {
    Get.to(() => const PackagesPricingsView());
  }

  Widget _buildAdditionalAvailabilitySection() {
    return Obx(() {
      final isDisabled = controller.isAdditionalAvailabilityDisabled;
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Disabled message when "cannot go outside location" is enabled
          if (isDisabled)
            Container(
              padding: EdgeInsets.all(16.w),
              margin: EdgeInsets.only(top: 8.h),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.textSecondary,
                    size: 20.r,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'additionalAvailabilityDisabledMsg'.tr,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // List of additional availability cards
          ...controller.additionalAvailabilityCards.map((card) {
            return AvailabilityWidgetCard(
              key: ValueKey(card.id),
              card: card,
              days: _days,
              canSelectDay: (day) => controller.canSelectAdditionalDay(card, day),
              onDayTap: (day) => controller.toggleAdditionalDay(card.id, day),
              showRemoveButton: true,
              onRemove: () => controller.removeAdditionalAvailabilityCard(card.id),
              isPrimary: false,
              isEnabled: !isDisabled,
            );
          }),
          
          // Add Additional Availability Button (at the bottom)
          if (!isDisabled)
            GestureDetector(
              onTap: controller.addAdditionalAvailabilityCard,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  color: AppColors.primary.withOpacity(0.05),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primary,
                      size: 20.r,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'addAdditionalAvailability'.tr,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }
}
