import 'package:event_maker/app_routes.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/constants/app_config.dart';
import 'package:event_maker/models/customer_booking_model.dart';
import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/services/service_repository.dart';
import 'package:event_maker/views/chats/chat_repository.dart';
import 'package:event_maker/views/profile/vendor_profile.dart';
import 'package:event_maker/widgets/primary_text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceDetailView extends StatelessWidget {
  final ServiceModel service;
  final bool showEditButton;
  final bool isAlreadyBooked; // When true, hide "Book Now" button
  final CustomerBookingPackageInfo?
  bookedPackage; // Pre-selected package from booking

  const ServiceDetailView({
    super.key,
    required this.service,
    this.showEditButton = false,
    this.isAlreadyBooked = false,
    this.bookedPackage,
  });
  ServiceRepository get _repository => const ServiceRepository();

  /// Get full image URL from relative path
  String _getFullImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    // Handle relative paths like /media/services/covers/...
    return '${ApiConstant.mediaBaseUrl}$path';
  }

  /// Check if image path is a network URL
  bool _isNetworkImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  /// Build cover image - use images array first, then coverImage
  Widget _buildCoverImage() {
    // First try to use images from the service
    if (service.images.isNotEmpty) {
      final imagePath = service.images.first;
      final fullUrl = _getFullImageUrl(imagePath);
      // Check if the full URL is a network URL
      if (_isNetworkImage(fullUrl) && fullUrl.isNotEmpty) {
        return Image.network(
          fullUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildPlaceholderImage(),
        );
      } else {
        // Try as asset
        return Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildPlaceholderImage(),
        );
      }
    }

    // Fall back to coverImage if images is empty
    if (service.coverImage.isNotEmpty) {
      final coverPath = service.coverImage;
      final fullUrl = _getFullImageUrl(coverPath);
      // Check if the full URL is a network URL
      if (_isNetworkImage(fullUrl) && fullUrl.isNotEmpty) {
        return Image.network(
          fullUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildPlaceholderImage(),
        );
      } else {
        return Image.asset(
          coverPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildPlaceholderImage(),
        );
      }
    }

    return _buildPlaceholderImage();
  }

  /// Build placeholder image when no cover is available
  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.lightGrey,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.grey,
          size: 50,
        ),
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image - use coverImage if images is empty
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250.h,
            child: _buildCoverImage(),
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
                                      .fetchVendorProfile(
                                        service.provider,
                                        providerId: service.providerId > 0
                                            ? service.providerId
                                            : null,
                                      );
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
                                            _getFullImageUrl(
                                              service.provider.imageUrl,
                                            ),
                                          ),
                                          fit: BoxFit.cover,
                                          onError: (exception, stackTrace) {},
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
                                              SvgPicture.asset(
                                                "assets/icons/star_fill.svg",
                                                height: 14.h,
                                                width: 14.w,
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
                              onTap: () async {
                                // Show loading indicator
                                Get.snackbar(
                                  'Opening Chat',
                                  'Connecting to provider...',
                                  showProgressIndicator: true,
                                  snackPosition: SnackPosition.BOTTOM,
                                  duration: const Duration(seconds: 10),
                                );
                                
                                try {
                                  // Get provider user ID directly from service
                                  // The customer-services API now returns provider_user_id
                                  final userId = service.providerUserId;
                                   
                                  if (userId == null || userId.isEmpty) {
                                    Get.snackbar(
                                      'Error',
                                      'Provider not available for chat.',
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                    return;
                                  }
                                   
                                  // Create/get private chat with provider
                                  final chatRepo = ChatRepository();
                                  final chat = await chatRepo.createOrGetPrivateChat(userId);
                                  
                                  // Close loading snackbar
                                  Get.closeAllSnackbars();
                                  
                                   if (chat != null) {
                                     // Get the other member (not current user)
                                     final otherMember = chat.members.firstWhereOrNull(
                                       (m) => m.id != null, // We'll filter by non-current user in detail view
                                     );
                                     // For now, use the first member with avatar, or provider image
                                     String? memberAvatar;
                                     if (otherMember?.avatar?.isNotEmpty == true) {
                                       memberAvatar = otherMember!.avatar;
                                     } else if (chat.members.isNotEmpty && chat.members.first.avatar?.isNotEmpty == true) {
                                       memberAvatar = chat.members.first.avatar;
                                     } else {
                                       memberAvatar = _getFullImageUrl(service.provider.imageUrl);
                                     }
                                     
                                     Get.toNamed(
                                       AppRoutes.chatDetail,
                                       arguments: {
                                         'id': chat.id,
                                         'name': otherMember?.fullName?.isNotEmpty == true 
                                             ? otherMember!.fullName! 
                                             : (chat.members.isNotEmpty && chat.members.first.fullName?.isNotEmpty == true 
                                                 ? chat.members.first.fullName! 
                                                 : service.provider.name),
                                         'image': memberAvatar,
                                         'isAdmin': false,
                                       },
                                     );
                                  } else {
                                    Get.snackbar(
                                      'Error',
                                      'Could not start chat. Please try again.',
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  }
                                } catch (e) {
                                  Get.closeAllSnackbars();
                                  Get.snackbar(
                                    'Error',
                                    'Failed to connect. Please try again.',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
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
                        Text(
                          'availability'.tr,
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 10.h),
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

                        // Display availability from API with dropdown for multiple
                        if (service.availabilities.isNotEmpty) ...[
                          _AvailabilityDropdown(
                            availabilities: service.availabilities,
                            formatTimeFromApi: _formatTimeFromApi,
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
                        SizedBox(height: 16.h),
                        _buildLocationMap(context),
                        SizedBox(height: 24.h),

                        // Pricing / Packages
                        if (service.packages.isNotEmpty) ...[
                          Text(
                            isAlreadyBooked
                                ? 'selectedPackage'.tr
                                : 'packagesPricings'.tr,
                            style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          // If already booked, show only the booked package
                          if (isAlreadyBooked && bookedPackage != null)
                            _buildSelectedPackageCard(bookedPackage!)
                          // Otherwise, show all packages with selection
                          else
                            Obx(
                              () => Column(
                                children: List.generate(
                                  service.packages.length,
                                  (index) {
                                    final package = service.packages[index];
                                    final isSelected =
                                        selectedPackageIndex.value == index;
                                    return GestureDetector(
                                      onTap: () =>
                                          selectedPackageIndex.value = index,
                                      child: _buildPackageCard(
                                        package: package,
                                        isSelected: isSelected,
                                        isInteractive: !isAlreadyBooked,
                                      ),
                                    );
                                  },
                                ),
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

          // Bottom Buttons - hide when editing or already booked
          if (!showEditButton && !isAlreadyBooked)
            Positioned(
              bottom: 30.h,
              left: 24.w,
              right: 24.w,
              child: PrimaryTextButton(
                onPressed: () {
                  // Use requiresConfirmation to determine flow
                  // Both hospitality and non-hospitality need to go through date/time selection first
                  // The routing to payment vs booking request sent happens in ServiceBookingController
                  Get.toNamed(
                    AppRoutes.bookServiceDate,
                    arguments: {
                      'service': service,
                      'package': service.packages.isNotEmpty
                          ? service.packages[selectedPackageIndex.value]
                          : null,
                    },
                  );
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
        SizedBox(width: 12.w),
      ],
    );
  }

  /// Build availability card for each availability entry
  Widget _buildAvailabilityCard(ServiceAvailability availability, int index) {
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

  /// Build the selected package card (when user already booked)
  Widget _buildSelectedPackageCard(CustomerBookingPackageInfo package) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: Icon(Icons.check, size: 16.r, color: Colors.white),
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
        ],
      ),
    );
  }

  /// Build a package card for selection
  Widget _buildPackageCard({
    required ServicePackage package,
    required bool isSelected,
    required bool isInteractive,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.lightGrey,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.grey,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.check, size: 16.r, color: Colors.white)
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
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: [
                  Icon(Icons.check, size: 18.r, color: const Color(0xFF00C566)),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      featureTitle,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build location map using availability coordinates
  Widget _buildLocationMap(BuildContext context) {
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
                : service.location,
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
