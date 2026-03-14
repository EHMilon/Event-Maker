import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/themes/app_colors.dart';
import '../../../data/models/service_model.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_dropdown_field.dart';
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
          style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 20.sp, fontWeight: FontWeight.w600),
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
                UploadWidget(imagePath: controller.selectedImagePath.value, onImageSelected: (path) => controller.selectedImagePath.value = path),
                SizedBox(height: 16.h),
                CustomTextField(controller: controller.titleController, labelText: 'serviceTitle'.tr, hintText: 'serviceTitleHint'.tr),
                SizedBox(height: 24.h),
                Obx(
                  () => CustomDropdownField<ServiceCategory>(
                    value: controller.selectedCategory.value,
                    labelText: 'selectServiceType'.tr,
                    hintText: 'selectServiceType'.tr,
                    items: ServiceCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(_categoryLabel(category)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateCategory(value);
                      }
                    },
                  ),
                ),
                
                // Event Venue dropdown - only shown when category is Event
                Obx(() {
                  if (!controller.showEventVenueDropdown) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 16.h),
                    child: CustomDropdownField<EventVenue>(
                      value: controller.selectedEventVenue.value,
                      labelText: 'eventVenue'.tr,
                      hintText: 'selectEventVenue'.tr,
                      items: EventVenue.values.map((venue) {
                        return DropdownMenuItem(
                          value: venue,
                          child: Text(venue.label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        controller.selectedEventVenue.value = value;
                      },
                    ),
                  );
                }),
                
                SizedBox(height: 24.h),
                Obx(
                  () => CustomDropdownField<ProviderRole>(
                    value: controller.selectedRole.value,
                    labelText: 'whatIsYourRole'.tr,
                    hintText: 'selectRole'.tr,
                    items: ProviderRole.values.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(_roleLabel(role)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.selectedRole.value = value;
                        // Reset ServiceAs when role changes since options change
                        controller.selectedServiceAs.value = null;
                      }
                    },
                  ),
                ),
                SizedBox(height: 24.h),
                
                // Service As section - only show when there are options available
                Obx(() {
                  final options = controller.availableServiceAsOptions;
                  if (options.isEmpty) {
                    return const SizedBox.shrink(); // Hide for Productive Family
                  }
                  return CustomDropdownField<ServiceAs>(
                    value: controller.selectedServiceAs.value,
                    labelText: 'serviceAs'.tr,
                    hintText: 'selectServiceAs'.tr,
                    items: options.map((serviceAs) {
                      return DropdownMenuItem(
                        value: serviceAs,
                        child: Text(serviceAs.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      controller.selectedServiceAs.value = value;
                      // Reset sub-options when ServiceAs changes
                      controller.selectedSubOptions.clear();
                    },
                  );
                }),
                
                // Sub-Options checklist - shown when Event + Business + Buffet/LiveCooking/OutdoorCafeKiosk
                Obx(() {
                  if (!controller.showSubOptionsChecklist) {
                    return const SizedBox.shrink();
                  }
                  final subOptions = controller.availableSubOptions;
                  if (subOptions.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'selectOptions'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.lightGrey),
                          ),
                          child: Column(
                            children: subOptions.map((option) {
                              final isSelected = controller.selectedSubOptions.contains(option);
                              return GestureDetector(
                                onTap: () => controller.toggleSubOption(option),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: subOptions.last == option
                                          ? BorderSide.none
                                          : BorderSide(color: AppColors.lightGrey.withOpacity(0.5)),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 20.w,
                                        height: 20.w,
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppColors.primary : Colors.transparent,
                                          borderRadius: BorderRadius.circular(25.r),
                                          border: Border.all(
                                            color: isSelected ? AppColors.primary : AppColors.lightGrey,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: isSelected
                                            ? Icon(Icons.check, size: 14.r, color: Colors.white)
                                            : null,
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Text(
                                          option.label,
                                          style: GoogleFonts.inter(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                
                SizedBox(height: 24.h),
                
                CustomTextField(
                  controller: controller.descriptionController,
                  labelText: 'description'.tr,
                  hintText: 'descriptionHint'.tr,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                ),

                // SizedBox(height: 16.h),
                // CustomTextField(
                //   controller: controller.locationController,
                //   labelText: 'selectLocation'.tr,
                //   hintText: 'selectAddressHint'.tr,
                //   prefixIcon: Icon(
                //     Icons.location_on_outlined,
                //     color: AppColors.primary,
                //     size: 20.r,
                //   ),
                // ),
                SizedBox(height: 24.h),

                // Primary Availability Card
                AvailabilityWidgetCard(
                  card: controller.primaryAvailabilityCard,
                  days: _days,
                  canSelectDay: controller.canSelectPrimaryDay,
                  onDayTap: controller.togglePrimaryDay,
                  isPrimary: true,
                  isEnabled: true,
                  showCannotGoOutside: true,
                ),

                // Additional Availability Section
                _buildAdditionalAvailabilitySection(),

                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'packagesPricings'.tr,
                      style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    TextButton.icon(
                      onPressed: () => _openPackages(context),
                      icon: Icon(Icons.add, size: 18.sp, color: AppColors.primary),
                      label: Text('addPackage'.tr, style: TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // Display added packages
                Obx(() {
                  if (controller.packages.isEmpty) {
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: Center(
                        child: Text(
                          'noPackagesAdded'.tr,
                          style: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.textSecondary),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: controller.packages.asMap().entries.map((entry) {
                      final index = entry.key;
                      final package = entry.value;
                      return _buildPackageSummaryCard(index, package);
                    }).toList(),
                  );
                }),

                SizedBox(height: 40.h),
                PrimaryTextButton(
                  text: widget.isEdit ? 'updateService'.tr : 'addService'.tr,
                  onPressed: () async {
                    // TODO: Implement field validation before saving
                    await controller.saveService(isEdit: widget.isEdit, existingService: widget.service);
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

  String _roleLabel(ProviderRole role) {
    switch (role) {
      case ProviderRole.freelancer:
        return 'freelancer'.tr;
      case ProviderRole.business:
        return 'business'.tr;
      case ProviderRole.productiveFamily:
        return 'productiveFamily'.tr;
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
                  Icon(Icons.info_outline, color: AppColors.textSecondary, size: 20.r),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'additionalAvailabilityDisabledMsg'.tr,
                      style: GoogleFonts.inter(fontSize: 13.sp, color: AppColors.textSecondary),
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
              showCannotGoOutside: false,
            );
          }),

          // Add Additional Availability Button (at the bottom)
          if (!isDisabled)
            GestureDetector(
              onTap: controller.addAdditionalAvailabilityCard,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary.withOpacity(0.3), style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(12.r),
                  color: AppColors.primary.withOpacity(0.05),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20.r),
                    SizedBox(width: 8.w),
                    Text(
                      'addAdditionalAvailability'.tr,
                      style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildPackageSummaryCard(int index, PackageFormData package) {
    return GestureDetector(
      onTap: () => _openPackages(context),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    package.nameController.text.isEmpty ? 'packageLabel'.trParams({'index': '${index + 1}'}) : package.nameController.text,
                    style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      package.priceController.text.isEmpty ? '0.00' : '${package.priceController.text} AED',
                      style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () => controller.removePackage(index),
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(Icons.close, size: 16.r, color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (package.features.isNotEmpty && package.features.any((f) => f.isNotEmpty)) ...[
              SizedBox(height: 8.h),
              Column(
                spacing: 8.w,
                // runSpacing: 4.h,
                children: package.features
                    .where((f) => f.isNotEmpty)
                    .take(3)
                    .map(
                      (feature) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4.r)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, size: 12.r, color: AppColors.primary),
                            SizedBox(width: 4.w),
                            Text(
                              feature,
                              style: GoogleFonts.inter(fontSize: 11.sp, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
