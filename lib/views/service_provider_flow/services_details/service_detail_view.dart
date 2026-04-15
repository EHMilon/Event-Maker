import 'package:event_maker/app_routes.dart';
import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/constants/app_config.dart';
import 'package:event_maker/models/booking_request_model.dart';
import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/services/service_repository.dart';
import 'package:event_maker/services/booking_request_repository.dart';
import 'package:event_maker/views/profile/vendor_profile.dart';
import 'package:event_maker/views/service_provider_flow/home/sp_home_controller.dart';
import 'package:event_maker/widgets/primary_text_button.dart';
import 'package:event_maker/views/service_provider_flow/add_service/add_service_view.dart';
import 'package:event_maker/views/service_provider_flow/add_service/add_screens_binding.dart';
import 'package:event_maker/views/service_provider_flow/services_details/sp_service_detail_controller.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:event_maker/widgets/app_custom_dialog.dart';
import 'package:event_maker/views/service_provider_flow/requests/requests_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceDetailView extends StatelessWidget {
  const ServiceDetailView({
    super.key,
    required this.service,
    this.showEditButton = false,
    this.isRequest = false,
    this.isOrder = false,
    this.isPastRequest = false,
    this.isPendingRequest = false,
    bool? hideActionButtons,
    this.bookingId,
  }) : hideActionButtons = hideActionButtons ?? false;

  final bool isOrder;
  final bool isRequest;
  final bool isPastRequest;
  final bool isPendingRequest;
  final ServiceModel service;
  final bool showEditButton;
  final bool hideActionButtons;
  final int? bookingId;
  final ServiceRepository _repository = const ServiceRepository();

  void _showRejectDialog(BuildContext context, int bookingId) {
    showDialog(
      context: context,
      builder: (context) => AppCustomDialog(
        iconPath: 'assets/images/reject.svg',
        title: 'confirmRejectTitle'.tr,
        subTitle: 'confirmRejectSubtitle'.tr,
        mainButtonText: 'reject'.tr,
        mainButtonColor: AppColors.error,
        mainButtonCallback: () {
          Get.back(); // Close confirmation dialog
          _showRejectSuccessDialog(context, bookingId);
        },
        secondaryButtonText: 'cancel'.tr,
        secondaryButtonCallback: () => Get.back(),
      ),
    );
  }

  void _showRejectSuccessDialog(BuildContext context, int bookingId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppCustomDialog(
        iconPath: 'assets/images/reject.svg',
        title: 'rejectSuccessTitle'.tr,
        subTitle: 'rejectSuccessSubtitle'.tr,
        mainButtonText: 'done'.tr,
        mainButtonColor: AppColors.error,
        mainButtonCallback: () {
          final controller = Get.find<RequestsController>();
          controller.rejectRequest(bookingId);
          Get.back(); // Close success dialog
          Get.back(); // Go back to list
        },
      ),
    );
  }

  Future<void> _onEditPressed() async {
    final result = await Get.to(
      () => AddServiceView(service: service, isEdit: true),
      binding: AddScreensBinding(),
    );

    // If edit was successful, refresh the service detail
    if (result == true) {
      try {
        final controller = Get.find<SPServicedetailController>();
        await controller.refresh();
      } catch (_) {
        // Controller not found, ignore
      }
    }
  }

  void _showAcceptDialog(BuildContext context, int bookingId) {
    showDialog(
      context: context,
      builder: (context) => AppCustomDialog(
        iconPath: 'assets/images/accept.svg',
        title: 'confirmAcceptTitle'.tr,
        subTitle: 'confirmAcceptSubtitle'.tr,
        mainButtonText: 'accept'.tr,
        mainButtonCallback: () {
          Get.back(); // Close confirmation dialog
          _showAcceptSuccessDialog(context, bookingId);
        },
        secondaryButtonText: 'cancel'.tr,
        secondaryButtonCallback: () => Get.back(),
      ),
    );
  }

  void _showAcceptSuccessDialog(BuildContext context, int bookingId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppCustomDialog(
        iconPath: 'assets/images/accept.svg',
        title: 'acceptSuccessTitle'.tr,
        subTitle: 'acceptSuccessSubtitle'.tr,
        mainButtonText: 'done'.tr,
        mainButtonCallback: () {
          final controller = Get.find<RequestsController>();
          controller.acceptRequest(bookingId);
          Get.back(); // Close success dialog
          Get.back(); // Go back to list
        },
      ),
    );
  }

  /// Shows confirmation dialog for marking booking as complete
  void _showMarkAsCompleteDialog(BuildContext context) {
    if (bookingId == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AppCustomDialog(
        iconPath: 'assets/images/accept.svg',
        title: 'Are you sure you want to complete the service?',
        mainButtonText: 'yes'.tr,
        mainButtonCallback: () async {
          // Close dialog
          Navigator.of(dialogContext).pop();

          // Call API
          final repository = BookingRequestRepository();
          final response = await repository.markBookingAsCompleted(bookingId!);
          final success = response['success'] as bool? ?? false;

          if (success) {
            // Navigate back to active orders
            Get.back(); // Go back from ServiceDetailView
            Get.back(); // Go back from service orders to active orders

            // Refresh data
            if (Get.isRegistered<SPHomeController>()) {
              await Get.find<SPHomeController>().refreshData();
            }

            // Show success message
            Get.snackbar(
              'success'.tr,
              'Service marked as completed successfully',
            );
          } else {
            final message =
                response['message'] as String? ?? 'Failed to complete service';
            Get.snackbar('error'.tr, message);
          }
        },
        secondaryButtonText: 'no'.tr,
        secondaryButtonCallback: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Local state for package selection
    final RxInt selectedPackageIndex = 0.obs;
    final isHospitality =
        service.type == ServiceType.cleaning ||
        service.type == ServiceType.catering;

    // If this is a request with bookingId, fetch and show real booking data
    if (isRequest && bookingId != null) {
      return _BookingRequestDetailView(
        bookingId: bookingId!,
        service: service,
        isPastRequest: isPastRequest,
        isOrder: isOrder,
        isPendingRequest: isPendingRequest,
        // Show accept/reject only for pending requests (from notifications)
        showAcceptReject: isPendingRequest,
        onAccept: isPendingRequest
            ? () => _showAcceptDialog(context, bookingId!)
            : null,
        onReject: isPendingRequest
            ? () => _showRejectDialog(context, bookingId!)
            : null,
        onMarkComplete: isOrder
            ? () => _showMarkAsCompleteDialog(context)
            : null,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250.h,
            child: service.images.isNotEmpty
                ? Image.network(
                    ApiConstant.getFullMediaUrl(service.images.first),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: AppColors.lightGrey),
                  )
                : Container(color: AppColors.lightGrey),
          ),

          // Content
          Positioned.fill(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  expandedHeight: 180.h,
                  leading: IconButton(
                    icon: CircleAvatar(
                      backgroundColor: AppColors.white,
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.black,
                        size: 20.r,
                      ),
                    ),
                    onPressed: () => Get.back(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.r),
                        topRight: Radius.circular(30.r),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 24.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                service.title,
                                style: GoogleFonts.inter(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            if (showEditButton)
                              Align(
                                child: IconButton(
                                  onPressed: _onEditPressed,
                                  icon: SvgPicture.asset(
                                    'assets/icons/edit.svg',
                                    colorFilter: ColorFilter.mode(
                                      AppColors.primary,
                                      BlendMode.srcIn,
                                    ),
                                    width: 30.w,
                                    height: 30.h,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        GestureDetector(
                          onTap: () async {
                            final profile = await _repository
                                .fetchVendorProfile(
                                  service.provider,
                                  providerId: service.providerId > 0
                                      ? service.providerId
                                      : null,
                                );
                            Get.to(() => VendorProfileView(vendor: profile));
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 45.w,
                                height: 45.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                  color: AppColors.lightGrey,
                                  image: service.provider.imageUrl.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(
                                            ApiConstant.getFullMediaUrl(
                                              service.provider.imageUrl,
                                            ),
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: service.provider.imageUrl.isEmpty
                                    ? Icon(
                                        Icons.person,
                                        color: AppColors.textSecondary,
                                        size: 24.r,
                                      )
                                    : null,
                              ),
                              SizedBox(width: 12.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        service.provider.name,
                                        style: GoogleFonts.inter(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      if (service.provider.isVerified) ...[
                                        SizedBox(width: 4.w),
                                        Icon(
                                          Icons.verified,
                                          color: Colors.orange,
                                          size: 16.r,
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (service.rating != null)
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/star_fill.svg',
                                          width: 14.w,
                                          height: 14.h,
                                          colorFilter: ColorFilter.mode(
                                            Colors.amber,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          '${service.rating} (${'reviewsCount'.trParams({'count': service.reviewCount.toString()})})',
                                          style: GoogleFonts.inter(
                                            fontSize: 12.sp,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Text(
                                      service.provider.role,
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Description
                        Text(
                          'description'.tr,
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          service.description,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          'serviceType'.tr,
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          '${service.type.name.tr} (${service.provider.role.tr})',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        // Service As display
                        if (service.serviceAs != null) ...[
                          SizedBox(height: 24.h),
                          Text(
                            'serviceAs'.tr,
                            style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            service.serviceAs!.label,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                        SizedBox(height: 24.h),

                        // Date & Time + Location (If applicable)
                        Text(
                          'availability'.tr,
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 10.h),

                        // Display availability from API with dropdown for multiple
                        if (service.availabilities.isNotEmpty) ...[
                          _AvailabilityDropdown(
                            availabilities: service.availabilities,
                            formatTimeFromApi: _formatTimeFromApi,
                          ),
                        ] else ...[
                          // Fallback for services without availabilities data
                          if (service.date != null) ...[
                            _buildInfoRow(
                              Icons.calendar_today_outlined,
                              _formatDate(service.date!),
                            ),
                            SizedBox(height: 12.h),
                          ],
                          _buildInfoRow(
                            Icons.location_on_outlined,
                            service.displayLocation,
                          ),
                        ],

                        // Event-specific fields from API
                        if (service.type == ServiceType.event) ...[
                          if (service.attendanceCapacity != null) ...[
                            SizedBox(height: 12.h),
                            _buildInfoRow(
                              Icons.people_outline,
                              '${service.attendanceCapacity}',
                            ),
                          ],
                        ],

                        SizedBox(height: 16.h),

                        // Location Header and Map
                        Text(
                          'location'.tr,
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        // SizedBox(height: 10.h),
                        // Text(
                        //   service.displayLocation,
                        //   style: GoogleFonts.inter(
                        //     fontSize: 14.sp,
                        //     color: AppColors.textSecondary,
                        //   ),
                        // ),
                        SizedBox(height: 16.h),
                        _buildLocationMap(context, isServiceProvider: true),
                        SizedBox(height: 24.h),

                        // Pricing / Packages
                        if (!isRequest &&
                            !isOrder &&
                            service.packages.isNotEmpty) ...[
                          Text(
                            'packagesPricings'.tr,
                            style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Obx(
                            () => Column(
                              children: List.generate(service.packages.length, (
                                index,
                              ) {
                                final package = service.packages[index];
                                final isSelected =
                                    selectedPackageIndex.value == index;
                                return GestureDetector(
                                  onTap: () =>
                                      selectedPackageIndex.value = index,
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 16.h),
                                    padding: EdgeInsets.all(20.r),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.lightGrey,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.black.withOpacity(
                                            0.05,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              package.name,
                                              style: GoogleFonts.inter(
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            Container(
                                              width: 24.r,
                                              height: 24.r,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : Colors.transparent,
                                                border: Border.all(
                                                  color: isSelected
                                                      ? AppColors.primary
                                                      : AppColors.grey,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: isSelected
                                                  ? Icon(
                                                      Icons.check,
                                                      size: 16.r,
                                                      color: AppColors.white,
                                                    )
                                                  : null,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          '${package.price} ${service.priceUnit}',
                                          style: GoogleFonts.inter(
                                            fontSize: 22.sp,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        SizedBox(height: 20.h),
                                        ...package.featureTitles.map((
                                          featureTitle,
                                        ) {
                                          // Parse JSON if the feature contains JSON format
                                          // Backend sends: {'title': 'value', 'sort_order': 0} with single quotes
                                          String displayText = featureTitle;
                                          if (featureTitle.contains('title')) {
                                            try {
                                              // Try single-quoted JSON: {'title': 'value', ...}
                                              final singleMatch = RegExp(
                                                r"'title'\s*:\s*'([^']+)'",
                                              ).firstMatch(featureTitle);
                                              // Try double-quoted JSON: {"title": "value", ...}
                                              final doubleMatch = RegExp(
                                                r'"title"\s*:\s*"([^"]+)"',
                                              ).firstMatch(featureTitle);

                                              if (singleMatch != null &&
                                                  singleMatch.group(1) !=
                                                      null) {
                                                displayText = singleMatch.group(
                                                  1,
                                                )!;
                                              } else if (doubleMatch != null &&
                                                  doubleMatch.group(1) !=
                                                      null) {
                                                displayText = doubleMatch.group(
                                                  1,
                                                )!;
                                              }
                                            } catch (_) {
                                              // Fallback to original
                                            }
                                          }
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              bottom: 12.h,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.check,
                                                  size: 18.r,
                                                  color: const Color(
                                                    0xFF00C566,
                                                  ), // Green check
                                                ),
                                                SizedBox(width: 12.w),
                                                Flexible(
                                                  child: Text(
                                                    displayText,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14.sp,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ] else if (!isRequest && !isOrder) ...[
                          Row(
                            children: [
                              Text(
                                'pricing'.tr,
                                style: GoogleFonts.inter(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '${service.basePrice?.toInt()} ${service.priceUnit}',
                                style: GoogleFonts.inter(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              if (service.type == ServiceType.event ||
                                  service.type == ServiceType.training ||
                                  service.type == ServiceType.cleaning ||
                                  service.type == ServiceType.filming ||
                                  service.type == ServiceType.catering)
                                Text(
                                  '/hr',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ],

                        SizedBox(height: 120.h), // Space for bottom button
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Buttons
          if (!showEditButton && !hideActionButtons)
            Positioned(
              bottom: 30.h,
              left: 24.w,
              right: 24.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isOrder)
                    PrimaryTextButton(
                      onPressed: () => _showMarkAsCompleteDialog(context),
                      text: 'markAsComplete'.tr,
                    )
                  else
                    PrimaryTextButton(
                      onPressed: () {
                        if (isHospitality) {
                          Get.toNamed(
                            AppRoutes.bookServiceDate,
                            arguments: {
                              'service': service,
                              'package': service.packages.isNotEmpty
                                  ? service.packages[selectedPackageIndex.value]
                                  : null,
                            },
                          );
                        } else {
                          Get.toNamed(
                            AppRoutes.payment,
                            arguments: {
                              'service': service,
                              'package': service.packages.isNotEmpty
                                  ? service.packages[selectedPackageIndex.value]
                                  : null,
                            },
                          );
                        }
                      },
                      text: 'bookNow'.tr,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18.r, color: AppColors.primary),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            "Attendence Capacity: $text",
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// Build availability card for each availability entry
  Widget _buildAvailabilityCard(ServiceAvailability availability, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
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
          // // Header with availability number
          // if (service.availabilities.length > 1) ...[
          //   Text(
          //     '${'availability'.tr} ${index + 1}',
          //     style: GoogleFonts.inter(
          //       fontSize: 14.sp,
          //       fontWeight: FontWeight.w600,
          //       color: AppColors.textPrimary,
          //     ),
          //   ),
          //   SizedBox(height: 12.h),
          // ],

          // Days
          if (availability.weekDays.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18.r,
                  color: AppColors.primary,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    availability.weekDays.join(', '),
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
          ],

          // Time
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.access_time, size: 18.r, color: AppColors.primary),
              SizedBox(width: 12.w),
              Text(
                '${_formatTimeFromApi(availability.startTime)} - ${_formatTimeFromApi(availability.endTime)}',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Location/Address
          if (availability.address.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18.r,
                  color: AppColors.primary,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    availability.address,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Format time string from API (e.g., "09:00:00" -> "9:00 AM")
  String _formatTimeFromApi(String timeString) {
    try {
      // Parse time string like "09:00:00" or "14:00:00"
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        final displayMinute = minute.toString().padLeft(2, '0');

        return '$displayHour:$displayMinute $period';
      }
    } catch (_) {
      // Return original if parsing fails
    }
    return timeString;
  }

  String _formatDate(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final dayName = days[date.weekday - 1];
    final day = date.day;
    final monthName = months[date.month - 1];
    final year = date.year;

    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$dayName, $day $monthName, $year $hour.$minute$period';
  }

  /// Build location map using availability coordinates
  Widget _buildLocationMap(
    BuildContext context, {
    bool isServiceProvider = false,
  }) {
    // Get first availability for map display
    final firstAvailability = service.availabilities.isNotEmpty
        ? service.availabilities.first
        : null;

    // Default coordinates (UAE)
    double latitude = 24.4539;
    double longitude = 54.3773;

    // Use availability coordinates if available
    if (firstAvailability != null) {
      try {
        latitude = double.parse(firstAvailability.latitude);
        longitude = double.parse(firstAvailability.longitude);
      } catch (_) {
        // Keep default coordinates
      }
    }

    return GestureDetector(
      onTap: () {
        if (isServiceProvider) {
          return;
        }
        debugPrint('Map clicked - opening full map view');
        // Get first availability for coordinates
        final firstAvailability = service.availabilities.isNotEmpty
            ? service.availabilities.first
            : null;

        if (firstAvailability == null) {
          Get.snackbar(
            'No Location',
            'This service does not have a location set.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        Get.toNamed(
          AppRoutes.mapResults,
          arguments: {
            'is_single_service_view': true,
            'service_id': service.apiId,
            'service_title': service.title,
            'service_description': service.description,
            'service_address': firstAvailability.address.isNotEmpty
                ? firstAvailability.address
                : service.displayLocation,
            'latitude': double.tryParse(firstAvailability.latitude) ?? 24.4539,
            'longitude':
                double.tryParse(firstAvailability.longitude) ?? 54.3773,
            'cover_image': service.coverImage,
            'provider_id': service.providerId,
            'provider_name': service.provider.name,
            'provider_avatar': service.provider.imageUrl,
            'starting_price': service.basePrice ?? 0.0,
            'currency': service.priceUnit.split(' ').first,
            'role_name': service.provider.role,
            'rating': service.rating ?? 0.0,
            'total_reviews': service.reviewCount,
            'service_type_name': service.type.name,
            'service_as_name': service.serviceAs?.label ?? '',
            'requires_confirmation': service.requiresConfirmation,
            'is_featured': service.isFeatured,
          },
        );
      },
      child: Container(
        height: 180.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Static map image using Google Maps Static API
              Image.network(
                _buildStaticMapUrl(latitude, longitude),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFE8E8E8),
                  child: Center(
                    child: Icon(Icons.map, size: 50.r, color: AppColors.grey),
                  ),
                ),
              ),
              // Location marker overlay
              Center(
                child: Icon(
                  Icons.location_on,
                  size: 40.r,
                  color: AppColors.primary,
                ),
              ),
              // Tap overlay to ensure gestures work
              Container(color: Colors.transparent),
            ],
          ),
        ),
      ),
    );
  }

  /// Build Google Maps Static API URL
  String _buildStaticMapUrl(double latitude, double longitude) {
    // Using Google Maps Static API
    final String apiKey = AppConfig.googleMapsApiKey;
    const int width = 600;
    const int height = 300;
    const int zoom = 15;

    return 'https://maps.googleapis.com/maps/api/staticmap?'
        'center=$latitude,$longitude'
        '&zoom=$zoom'
        '&size=${width}x$height'
        '&markers=color:red%7C$latitude,$longitude'
        '&key=$apiKey';
  }
}

/// Widget to display booking request details fetched from backend
class _BookingRequestDetailView extends StatefulWidget {
  final int bookingId;
  final ServiceModel service;
  final bool isPastRequest;
  final bool isOrder;
  final bool isPendingRequest;
  final bool showAcceptReject;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onMarkComplete;

  const _BookingRequestDetailView({
    required this.bookingId,
    required this.service,
    required this.isPastRequest,
    required this.isOrder,
    required this.isPendingRequest,
    this.showAcceptReject = false,
    this.onAccept,
    this.onReject,
    this.onMarkComplete,
  });

  @override
  State<_BookingRequestDetailView> createState() =>
      _BookingRequestDetailViewDetailState();
}

class _BookingRequestDetailViewDetailState
    extends State<_BookingRequestDetailView> {
  final BookingRequestRepository _repository = BookingRequestRepository();
  BookingRequestDetailModel? _bookingDetail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBookingDetail();
  }

  Future<void> _fetchBookingDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _repository.fetchBookingRequestDetail(
        widget.bookingId,
      );

      // ignore: unnecessary_set_state
      if (mounted) {
        setState(() {
          _bookingDetail = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
          ? _buildErrorState()
          : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return Stack(
      children: [
        // Background skeleton
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 250.h,
          child: Container(color: AppColors.lightGrey),
        ),
        Positioned.fill(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                expandedHeight: 220.h,
                leading: IconButton(
                  icon: CircleAvatar(
                    backgroundColor: AppColors.white,
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.black,
                      size: 20.r,
                    ),
                  ),
                  onPressed: () => Get.back(),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.r),
                      topRight: Radius.circular(30.r),
                    ),
                  ),
                  padding: EdgeInsets.all(24.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 200.w,
                        height: 24.h,
                        color: AppColors.lightGrey,
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Container(
                            width: 45.w,
                            height: 45.w,
                            color: AppColors.lightGrey,
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 120.w,
                                height: 16.h,
                                color: AppColors.lightGrey,
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                width: 80.w,
                                height: 12.h,
                                color: AppColors.lightGrey,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: CircleAvatar(
            backgroundColor: AppColors.lightGrey,
            child: Icon(Icons.arrow_back, color: AppColors.black),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.r, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              'failedToLoadBookingDetails'.tr,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _fetchBookingDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text('retry'.tr),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final detail = _bookingDetail!;
    final imageUrl = detail.service.coverImage.isNotEmpty
        ? ApiConstant.getFullMediaUrl(detail.service.coverImage)
        : '';

    return Stack(
      children: [
        // Background Image
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 250.h,
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: AppColors.lightGrey),
                )
              : Container(color: AppColors.lightGrey),
        ),

        // Content
        Positioned.fill(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                expandedHeight: 180.h,
                leading: IconButton(
                  icon: CircleAvatar(
                    backgroundColor: AppColors.white,
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.black,
                      size: 20.r,
                    ),
                  ),
                  onPressed: () => Get.back(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.r),
                      topRight: Radius.circular(30.r),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 24.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.title,
                        style: GoogleFonts.inter(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Provider info
                      Row(
                        children: [
                          Container(
                            width: 45.w,
                            height: 45.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              color: AppColors.lightGrey,
                              image:
                                  detail.provider.avatar != null &&
                                      detail.provider.avatar!.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        ApiConstant.getFullMediaUrl(
                                          detail.provider.avatar!,
                                        ),
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child:
                                detail.provider.avatar == null ||
                                    detail.provider.avatar!.isEmpty
                                ? Icon(
                                    Icons.person,
                                    color: AppColors.textSecondary,
                                    size: 24.r,
                                  )
                                : null,
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                detail.provider.fullName,
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 14.r,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${detail.provider.ratingAvg} (${'reviewsCount'.trParams({'count': detail.provider.totalReviews.toString()})})',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // Date & Time
                      _buildInfoRow(
                        Icons.calendar_today_outlined,
                        detail.displayDateTime,
                      ),
                      SizedBox(height: 12.h),
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        detail.location,
                      ),
                      if (detail.guestCount != null) ...[
                        SizedBox(height: 12.h),
                        _buildInfoRow(
                          Icons.people_outline,
                          '${detail.guestCount}',
                        ),
                      ],

                      SizedBox(height: 24.h),

                      // Customer Section
                      Text(
                        'customer'.tr,
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50.r),
                            child:
                                detail.customer.avatar != null &&
                                    detail.customer.avatar!.isNotEmpty
                                ? Image.network(
                                    ApiConstant.getFullMediaUrl(
                                      detail.customer.avatar!,
                                    ),
                                    width: 45.w,
                                    height: 45.w,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      width: 45.w,
                                      height: 45.w,
                                      color: AppColors.lightGrey,
                                      child: Icon(
                                        Icons.person,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 45.w,
                                    height: 45.w,
                                    color: AppColors.lightGrey,
                                    child: Icon(
                                      Icons.person,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                detail.customer.fullName,
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                detail.customer.email,
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // Details Section
                      Text(
                        'details'.tr,
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _buildDetailRow('name'.tr, detail.customer.fullName),
                      _buildDetailRow('mobileNumber'.tr, detail.customer.phone),
                      _buildDetailRow('email'.tr, detail.customer.email),
                      _buildDetailRow(
                        'dateTime'.tr,
                        detail.displayDateTime,
                        isLast: true,
                      ),

                      // Special Request
                      if (detail.specialRequest != null &&
                          detail.specialRequest!.isNotEmpty) ...[
                        SizedBox(height: 24.h),
                        Text(
                          'specialRequest'.tr,
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          detail.specialRequest!,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],

                      // Selected Package
                      if (detail.selectedPackage != null) ...[
                        SizedBox(height: 24.h),
                        Text(
                          'selectedPackage'.tr,
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                detail.selectedPackage!.name,
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${detail.selectedPackage!.price} ${detail.currency}',
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: 24.h),

                      // Subtotal
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 13.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7FF),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'subTotal'.tr,
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              detail.displaySubtotal,
                              style: GoogleFonts.inter(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 120.h), // Space for bottom button
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom Buttons - show for orders (mark as complete) OR pending requests (accept/reject)
        if (widget.isOrder || widget.isPendingRequest)
          Positioned(
            bottom: 30.h,
            left: 24.w,
            right: 24.w,
            child: widget.showAcceptReject
                ? Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onReject,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            side: const BorderSide(color: AppColors.lightGrey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'reject'.tr,
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: PrimaryTextButton(
                          onPressed: widget.onAccept,
                          text: 'accept'.tr,
                        ),
                      ),
                    ],
                  )
                : widget.onMarkComplete != null
                ? PrimaryTextButton(
                    onPressed: widget.onMarkComplete,
                    text: 'markAsComplete'.tr,
                  )
                : const SizedBox.shrink(),
          ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18.r, color: AppColors.primary),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: AppColors.lightGrey.withOpacity(0.5)),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              softWrap: true,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dropdown widget for displaying multiple availabilities
class _AvailabilityDropdown extends StatefulWidget {
  final List<ServiceAvailability> availabilities;
  final String Function(String) formatTimeFromApi;

  const _AvailabilityDropdown({
    required this.availabilities,
    required this.formatTimeFromApi,
  });

  @override
  State<_AvailabilityDropdown> createState() => _AvailabilityDropdownState();
}

class _AvailabilityDropdownState extends State<_AvailabilityDropdown> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // If only one availability, show it directly without dropdown
    if (widget.availabilities.length == 1) {
      return _buildAvailabilityCard(widget.availabilities.first, 0);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First availability always visible
        _buildAvailabilityCard(widget.availabilities.first, 0),

        // Dropdown button to show more
        if (widget.availabilities.length > 1) ...[
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                    size: 20.r,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _isExpanded
                        ? 'showLess'.tr
                        : 'showMoreAvailabilities'.trParams({
                            'count': '${widget.availabilities.length - 1}',
                          }),
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Additional availabilities (hidden by default)
          if (_isExpanded) ...[
            SizedBox(height: 12.h),
            ...widget.availabilities.skip(1).toList().asMap().entries.map((
              entry,
            ) {
              final index = entry.key + 1; // Start from 1 since we skip first
              final availability = entry.value;
              return _buildAvailabilityCard(availability, index);
            }),
          ],
        ],
      ],
    );
  }

  Widget _buildAvailabilityCard(ServiceAvailability availability, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Days
          if (availability.weekDays.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16.r,
                  color: AppColors.primary,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    availability.weekDays.join(', '),
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
          ],

          // Time
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.access_time, size: 16.r, color: AppColors.primary),
              SizedBox(width: 10.w),
              Text(
                '${widget.formatTimeFromApi(availability.startTime)} - ${widget.formatTimeFromApi(availability.endTime)}',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Location/Address
          if (availability.address.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16.r,
                  color: AppColors.primary,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    availability.address,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
