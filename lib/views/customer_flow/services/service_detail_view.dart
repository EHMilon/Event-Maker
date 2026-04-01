import 'package:event_maker/app_routes.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/services/service_repository.dart';
import 'package:event_maker/views/profile/vendor_profile.dart';
import 'package:event_maker/widgets/primary_text_button.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceDetailView extends StatelessWidget {
  final ServiceModel service;
  final bool showEditButton;

  const ServiceDetailView({
    super.key,
    required this.service,
    this.showEditButton = false,
  });
  ServiceRepository get _repository => const ServiceRepository();

  @override
  Widget build(BuildContext context) {
    // Local state for package selection
    final RxInt selectedPackageIndex = 0.obs;
    final isHospitality =
        service.type == ServiceType.cleaning ||
        service.type == ServiceType.catering;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250.h,
            child: service.images.isNotEmpty
                ? (service.images.first.startsWith('http')
                      ? Image.network(service.images.first, fit: BoxFit.cover)
                      : Image.asset(service.images.first, fit: BoxFit.cover))
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
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
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
                      color: Colors.white,
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
                            // if (showEditButton)
                            //   IconButton(
                            //     onPressed: _onEditPressed,
                            //     icon: Icon(
                            //       Icons.edit_outlined,
                            //       color: AppColors.primary,
                            //       size: 24.r,
                            //     ),
                            //   ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // Provider Info
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final profile = await _repository
                                      .fetchVendorProfile(service.provider);
                                  Get.to(
                                    () => VendorProfileView(
                                      vendor: profile,
                                      showCustomerActions: true,
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      width: 45.w,
                                      height: 45.w,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            service.provider.imageUrl,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            if (service
                                                .provider
                                                .isVerified) ...[
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
                                                  color:
                                                      AppColors.textSecondary,
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
                            ),
                            SizedBox(width: 12.w),
                            InkWell(
                              onTap: () {
                                // TODO: use real chat thread id when backend chat API is available
                                Get.toNamed(
                                  AppRoutes.chatDetail,
                                  arguments: {
                                    'id': service.id,
                                    'name': service.provider.name,
                                    'image': service.provider.imageUrl,
                                    'isAdmin': false,
                                  },
                                );
                              },
                              borderRadius: BorderRadius.circular(14.r),
                              child: Container(
                                width: 42.w,
                                height: 42.w,
                                decoration: BoxDecoration(
                                  color: Color(0xFFE6E8FF),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(10.r),
                                child: SvgPicture.asset(
                                  'assets/icons/chat.svg',
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.primary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                          service.location,
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
                          service.location, // Or more detailed address
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        GestureDetector(
                          onTap: () {
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

                        // Pricing / Packages
                        if (service.packages.isNotEmpty) ...[
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
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.lightGrey,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
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
                                                      color: Colors.white,
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
                                        ...package.featureTitles.map(
                                          (featureTitle) => Padding(
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
                                                Text(
                                                  featureTitle,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14.sp,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ] else ...[
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
                                  'perHr'.tr,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ],

                        SizedBox(height: 100.h), // Space for bottom button
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Buttons
          if (!showEditButton)
            Positioned(
              bottom: 30.h,
              left: 24.w,
              right: 24.w,
              child: PrimaryTextButton(
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
}
