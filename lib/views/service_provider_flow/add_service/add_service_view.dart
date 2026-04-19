import 'package:event_maker/views/service_provider_flow/add_service/drop_down_selector_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../constants/app_colors.dart';
import '../../../models/service_model.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/unified_dropdown_field.dart';
import '../../../widgets/primary_text_button.dart';
import '../../../widgets/upload_widget.dart';
import '../../../widgets/availability_widget_card.dart';
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

  bool _isEditInitialized = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AddServiceController>();
    if (widget.isEdit && widget.service != null) {
      controller.initWithService(widget.service!);
      _isEditInitialized = true;
    }
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
          style: TextStyle(
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
                UploadWidget(
                  imagePath: controller.selectedImagePath.value,
                  onImageSelected: (path) =>
                      controller.selectedImagePath.value = path,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: controller.titleController,
                  labelText: 'serviceTitle'.tr,
                  hintText: 'serviceTitleHint'.tr,
                ),
                SizedBox(height: 24.h),
                Obx(
                  () => UnifiedDropdownField<ServiceCategory>(
                    value: controller.selectedCategory.value,
                    label: 'selectServiceType'.tr,
                    hint: 'selectServiceType'.tr,
                    items: ServiceCategory.values,
                    itemLabel: _categoryLabel,
                    onSingleSelect: (value) {
                      if (value != null) {
                        controller.updateCategory(value);
                        setState(() {});
                      }
                    },
                    enabled: true,
                  ),
                ),
                SizedBox(height: 24.h),
                Obx(
                  () => UnifiedDropdownField<ProviderRole>(
                    value:
                        controller.availableRoleOptions.contains(
                          controller.selectedRole.value,
                        )
                        ? controller.selectedRole.value
                        : null,
                    label: 'whatIsYourRole'.tr,
                    hint: 'selectRole'.tr,
                    items: controller.availableRoleOptions,
                    itemLabel: _roleLabel,
                    onSingleSelect: (value) {
                      if (value != null) {
                        controller.updateRole(value);
                        setState(() {});
                      }
                    },
                    enabled: true,
                  ),
                ),

                SizedBox(height: 24.h),
                Obx(() {
                  final backendOptions = controller.backendServiceAsOptions;
                  if (backendOptions.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final selectedService =
                      controller.selectedServiceAsItems.isNotEmpty
                      ? controller.selectedServiceAsItems.first
                      : null;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'selectService'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DropdownSelectorScreen(
                                options: controller.backendServiceAsOptions,
                                onSelected: (selectedOption) {
                                  controller.toggleServiceAs(selectedOption);
                                  setState(() {});
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 50.h,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.grey200,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Row(
                              children: [
                                Text(
                                  selectedService ?? 'Select Service',
                                  style: TextStyle(
                                    color: selectedService != null
                                        ? AppColors.textPrimary
                                        : Colors.grey,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 24.sp,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: 5.w,)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),

                Obx(() {
                  final options = controller.subOptions;
                  final isLoading = controller.isLoadingDropdowns.value;

                  if (options.isEmpty && !isLoading) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: EdgeInsets.only(top: 24.h),
                    child: isLoading && options.isEmpty
                        ? Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2.r,
                              ),
                            ),
                          )
                        : Column(
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
                              SizedBox(height: 8.h),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => DropdownSelectorScreen(
                                        options: controller.subOptions,
                                        onSelected: (selectedOption) {
                                          controller.toggleSubService(
                                            selectedOption,
                                          );
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.grey200,
                                      style: BorderStyle.solid,
                                    ),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          controller
                                                  .selectedSubServiceItems
                                                  .isNotEmpty
                                              ? controller
                                                    .selectedSubServiceItems
                                                    .first
                                              : 'Select Options',
                                          style: TextStyle(
                                            color:
                                                controller
                                                    .selectedSubServiceItems
                                                    .isNotEmpty
                                                ? AppColors.textPrimary
                                                : Colors.grey,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          size: 20.sp,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  );
                }),

                Obx(() {
                  final options = controller.backendSubSubServiceOptions;
                  final isLoading = controller.isLoadingDropdowns.value;

                  if (options.isEmpty && !isLoading) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: EdgeInsets.only(top: 24.h),
                    child: isLoading && options.isEmpty
                        ? Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2.r,
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'selectSubOptions'.tr,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => DropdownSelectorScreen(
                                        options: controller
                                            .backendSubSubServiceOptions,
                                        onSelected: (selectedOption) {
                                          controller.toggleSubSubService(
                                            selectedOption,
                                          );
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.grey200,
                                      style: BorderStyle.solid,
                                    ),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          controller
                                                  .selectedSubSubServiceItems
                                                  .isNotEmpty
                                              ? controller
                                                    .selectedSubSubServiceItems
                                                    .first
                                              : 'Select Sub Options',
                                          style: TextStyle(
                                            color:
                                                controller
                                                    .selectedSubSubServiceItems
                                                    .isNotEmpty
                                                ? AppColors.textPrimary
                                                : Colors.grey,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          size: 20.sp,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
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

                Obx(() {
                  if (!controller.showAttendanceCapacity) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 0.h),
                    child: CustomTextField(
                      controller: controller.attendanceCapacityController,
                      labelText: 'attendanceCapacity'.tr,
                      hintText: 'attendanceCapacityHint'.tr,
                      keyboardType: TextInputType.number,
                    ),
                  );
                }),

                SizedBox(height: 24.h),

                AvailabilityWidgetCard(
                  card: controller.primaryAvailabilityCard,
                  days: _days,
                  canSelectDay: controller.canSelectPrimaryDay,
                  onDayTap: controller.togglePrimaryDay,
                  isPrimary: true,
                  isEnabled: true,
                  showCannotGoOutside: true,
                  isServiceProvider: true,
                ),

                _buildAdditionalAvailabilitySection(),

                SizedBox(height: 16.h),

                Obx(
                  () => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'needConfirmationBeforePayment'.tr,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Switch(
                          value:
                              controller.needsConfirmationBeforePayment.value,
                          onChanged: (value) {
                            controller.needsConfirmationBeforePayment.value =
                                value;
                          },
                          activeThumbColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),

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
                SizedBox(height: 8.h),

                _buildPackagesList(),

                SizedBox(height: 40.h),
                PrimaryTextButton(
                  text: widget.isEdit ? 'updateService'.tr : 'addService'.tr,
                  onPressed: () async {
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

  void _openPackages(BuildContext context) async {
    final result = await Get.to(() => const PackagesPricingsView());
    if (result == true) {
      controller.packages.refresh();
      setState(() {});
    }
  }

  Widget _buildPackagesList() {
    return Obx(() {
      final packageCount = controller.packages.length;

      if (packageCount == 0) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: Center(
            child: Text(
              'noPackagesAdded'.tr,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
      }

      return Column(
        children: List.generate(packageCount, (index) {
          final package = controller.packages[index];
          return _buildPackageSummaryCard(index, package);
        }),
      );
    });
  }

  Widget _buildAdditionalAvailabilitySection() {
    return Obx(() {
      final isDisabled = controller.isAdditionalAvailabilityDisabled;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          ...controller.additionalAvailabilityCards.map((card) {
            return AvailabilityWidgetCard(
              key: ValueKey(card.id),
              card: card,
              days: _days,
              canSelectDay: (day) =>
                  controller.canSelectAdditionalDay(card, day),
              onDayTap: (day) => controller.toggleAdditionalDay(card.id, day),
              showRemoveButton: true,
              onRemove: () =>
                  controller.removeAdditionalAvailabilityCard(card.id),
              isPrimary: false,
              isEnabled: !isDisabled,
              showCannotGoOutside: false,
              isServiceProvider: true,
            );
          }),

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

  Widget _buildPackageSummaryCard(int index, PackageFormData package) {
    final packageName = package.nameController.text;
    final packagePrice = package.priceController.text;
    final features = package.featureControllers
        .map((c) => c.text.trim())
        .where((f) => f.isNotEmpty)
        .toList();

    return GestureDetector(
      onTap: () => _openPackages(context),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    packageName.isEmpty
                        ? 'packageLabel'.trParams({'index': '${index + 1}'})
                        : packageName,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      packagePrice.isEmpty ? '0.00 AED' : '$packagePrice AED',
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () {
                        controller.removePackage(index);
                      },
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16.r,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (features.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 4.h,
                  children: features.map((feature) {
                    String displayText = feature;
                    if (feature.contains('title')) {
                      try {
                        final singleMatch = RegExp(
                          r"'title'\s*:\s*'([^']+)'",
                        ).firstMatch(feature);
                        final doubleMatch = RegExp(
                          r'"title"\s*:\s*"([^"]+)"',
                        ).firstMatch(feature);

                        if (singleMatch != null &&
                            singleMatch.group(1) != null) {
                          displayText = singleMatch.group(1)!;
                        } else if (doubleMatch != null &&
                            doubleMatch.group(1) != null) {
                          displayText = doubleMatch.group(1)!;
                        }
                      } catch (_) {}
                    }

                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check,
                            size: 12.r,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              displayText,
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: AppColors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
