import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/models/provider_home_model.dart';
import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/views/service_provider_flow/services_details/service_detail_view.dart';

/// Service Orders Detail View for Service Provider
///
/// Displays individual bookings for a specific service.
/// Each booking card shows customer info, date/time, and navigates to booking details.
class SPServiceOrdersView extends StatelessWidget {
  final String serviceTitle;
  final int orderCount;
  final List<ActiveBooking> bookings;

  const SPServiceOrdersView({
    super.key,
    required this.serviceTitle,
    this.orderCount = 0,
    this.bookings = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFBFE),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Text(
          'Orders',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: bookings.isEmpty
            ? _buildEmptyView()
            : GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 9.w,
                  mainAxisSpacing: 12.h,
                  mainAxisExtent: 240.h,
                ),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  return _buildBookingCard(bookings[index]);
                },
              ),
      ),
    );
  }

  /// Builds empty state view
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16.h),
          Text(
            'noBookingsFound'.tr,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a booking card with real booking data
  Widget _buildBookingCard(ActiveBooking booking) {
    return GestureDetector(
      onTap: () => _onBookingTap(booking),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFF1F1F5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: Image.network(
                booking.serviceImage.isNotEmpty
                    ? booking.serviceImage
                    : 'https://picsum.photos/300/200',
                height: 110.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 110.h,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Title
                  Text(
                    booking.serviceTitle,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  // Time and Date
                  Row(
                    children: [
                      SvgPicture.asset("assets/icons/service.svg"),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          booking.formattedDateTime,
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  // Divider
                  const Divider(height: 1, color: Color(0xFFF1F1F5)),
                  SizedBox(height: 10.h),
                  // Customer Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14.r,
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        backgroundImage:
                            (booking.customerAvatar?.isNotEmpty ?? false)
                            ? NetworkImage(booking.customerAvatar!)
                            : null,
                        child: (booking.customerAvatar?.isEmpty ?? true)
                            ? Text(
                                booking.customerName.isNotEmpty
                                    ? booking.customerName[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.customerName,
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              booking.customerEmail,
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handles booking card tap
  /// Navigate to ServiceDetailView with isRequest=true to fetch real booking details from API
  void _onBookingTap(ActiveBooking booking) {
    // Create a minimal ServiceModel - actual data will be fetched from API
    final serviceModel = ServiceModel(
      id: booking.serviceId.toString(),
      title: booking.serviceTitle,
      description: '',
      images: [booking.serviceImage],
      type: ServiceType.catering,
      provider: ServiceProvider(
        name: '',
        role: '',
        imageUrl: '',
        isVerified: false,
      ),
      location: '',
      rating: 0,
      reviewCount: 0,
      basePrice: 0,
    );

    // Navigate with isRequest=true to fetch real booking details from API
    Get.to(
      () => ServiceDetailView(
        service: serviceModel,
        isRequest: true,
        isOrder: true,
        bookingId: booking.id,
      ),
    );
  }
}
