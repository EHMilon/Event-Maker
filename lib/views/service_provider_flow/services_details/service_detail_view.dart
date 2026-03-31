import 'package:event_maker/app_routes.dart';
import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/models/vendor_profile_model.dart';
import 'package:event_maker/services/service_repository.dart';
import 'package:event_maker/views/profile/vendor_profile.dart';
import 'package:event_maker/models/review_model.dart';
import 'package:event_maker/widgets/primary_text_button.dart';
import 'package:event_maker/views/service_provider_flow/add_service/add_service_view.dart';
import 'package:event_maker/views/service_provider_flow/add_service/add_screens_binding.dart';
import 'package:event_maker/views/service_provider_flow/services_details/sp_service_detail_controller.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart' hide Path;
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
    bool? hideActionButtons,
  }) : hideActionButtons = hideActionButtons ?? false;

  final bool isOrder;
  final bool isRequest;
  final ServiceModel service;
  final bool showEditButton;
  final bool hideActionButtons;
  final ServiceRepository _repository = const ServiceRepository();

  void _showRejectDialog(BuildContext context) {
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
          _showRejectSuccessDialog(context);
        },
        secondaryButtonText: 'cancel'.tr,
        secondaryButtonCallback: () => Get.back(),
      ),
    );
  }

  void _showRejectSuccessDialog(BuildContext context) {
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
          controller.rejectRequest(service);
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

  void _showAcceptDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AppCustomDialog(
        iconPath: 'assets/images/accept.svg',
        title: 'confirmAcceptTitle'.tr,
        subTitle: 'confirmAcceptSubtitle'.tr,
        mainButtonText: 'accept'.tr,
        mainButtonCallback: () {
          Get.back(); // Close confirmation dialog
          _showAcceptSuccessDialog(context);
        },
        secondaryButtonText: 'cancel'.tr,
        secondaryButtonCallback: () => Get.back(),
      ),
    );
  }

  void _showAcceptSuccessDialog(BuildContext context) {
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
          controller.acceptRequest(service);
          Get.back(); // Close success dialog
          Get.back(); // Go back to list
        },
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
                                .fetchVendorProfile(service.provider);
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
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 14.r,
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

                        if (service.type == ServiceType.event ||
                            service.type == ServiceType.training) ...[
                          SizedBox(height: 12.h),
                          if (service.type == ServiceType.event)
                            _buildInfoRow(
                              Icons.music_note,
                              'Mia lachetti + Atlanta\'s best',
                            ), // Static for now based on image
                          if (service.type == ServiceType.event) ...[
                            SizedBox(height: 12.h),
                            _buildInfoRow(Icons.people_outline, '250'),
                          ],
                        ],

                        SizedBox(height: 24.h),

                        // Location Header and Map
                        Text(
                          'location'.tr,
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          service.displayLocation,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        GestureDetector(
                          onTap: () async {
                            Get.toNamed(AppRoutes.mapResults);
                          },
                          child: SizedBox(
                            height: 180.h,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.r),
                              child: FlutterMap(
                                options: MapOptions(
                                  initialCenter: const LatLng(24.4539, 54.3773),
                                  initialZoom: 13.0,
                                  interactionOptions: const InteractionOptions(
                                    flags: InteractiveFlag.none,
                                  ),
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
                                    userAgentPackageName:
                                        'com.example.event_maker',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      const Marker(
                                        point: LatLng(24.4539, 54.3773),
                                        child: Icon(
                                          Icons.location_on,
                                          color: AppColors.error,
                                          size: 30,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        if (isRequest || isOrder) ...[
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
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000&auto=format&fit=crop',
                                  width: 45.w,
                                  height: 45.w,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Jenny Smith',
                                    style: GoogleFonts.inter(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Jenny@gmail.com',
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
                          Text(
                            'details'.tr,
                            style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          _buildDetailRow('name'.tr, 'Jenny'),
                          _buildDetailRow(
                            'mobileNumber'.tr,
                            '+971 5X xxx xxxx',
                          ),
                          _buildDetailRow('email'.tr, 'jenny@gmail.com'),
                          _buildDetailRow(
                            'dateTime'.tr,
                            '8PM - 11PM, 21 Nov',
                            isLast: true,
                          ),
                          SizedBox(height: 24.h),
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
                                  '\$46',
                                  style: GoogleFonts.inter(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

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
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AppCustomDialog(
                            iconPath: 'assets/images/accept.svg',
                            title:
                                'Are you sure you want to complete the service?',
                            mainButtonText: 'yes'.tr,
                            mainButtonCallback: () {
                              // TODO: Handle actual completion logic (e.g., API call)
                              Get.back(); // Close dialog
                              Get.back(); // Go back
                            },
                            secondaryButtonText: 'no'.tr,
                            secondaryButtonCallback: () => Get.back(),
                          ),
                        );
                      },
                      text: 'markAsComplete'.tr,
                    )
                  else
                    isRequest
                        ? Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _showRejectDialog(context),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: AppColors.white,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 16.h,
                                    ),
                                    side: const BorderSide(
                                      color: AppColors.lightGrey,
                                    ),
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
                                  onPressed: () {
                                    // TODO: Integrate backend for accepting request
                                    _showAcceptDialog(context);
                                  },
                                  text: 'accept'.tr,
                                ),
                              ),
                            ],
                          )
                        : PrimaryTextButton(
                            onPressed: () {
                              if (isHospitality) {
                                Get.toNamed(
                                  AppRoutes.bookServiceDate,
                                  arguments: {
                                    'service': service,
                                    'package': service.packages.isNotEmpty
                                        ? service.packages[selectedPackageIndex
                                              .value]
                                        : null,
                                  },
                                );
                              } else {
                                Get.toNamed(
                                  AppRoutes.payment,
                                  arguments: {
                                    'service': service,
                                    'package': service.packages.isNotEmpty
                                        ? service.packages[selectedPackageIndex
                                              .value]
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
