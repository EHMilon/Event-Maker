import 'package:event_maker/app_routes.dart';
import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/models/vendor_profile_model.dart';
import 'package:event_maker/widgets/review_card.dart';
import 'package:event_maker/widgets/services_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class VendorProfileView extends StatelessWidget {
  final VendorProfileModel vendor;
  final bool showCustomerActions;

  const VendorProfileView({
    super.key,
    required this.vendor,
    this.showCustomerActions = false,
  });

  /// Get avatar image provider based on URL
  ImageProvider _getAvatarImage(String avatarPath) {
    if (avatarPath.isEmpty) {
      return const AssetImage('assets/images/default_avatar.png');
    }
    final fullUrl = ApiConstant.getFullMediaUrl(avatarPath);
    if (fullUrl.startsWith('http://') || fullUrl.startsWith('https://')) {
      return NetworkImage(fullUrl);
    }
    return AssetImage(fullUrl);
  }

  /// Get cover image URL for services
  String _getCoverImageUrl(String coverPath) {
    if (coverPath.isEmpty) return '';
    return ApiConstant.getFullMediaUrl(coverPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      height: 200.h,
                      width: double.infinity,
                      child: vendor.bannerUrl != null
                          ? (vendor.bannerUrl!.startsWith('http')
                                ? Image.network(
                                    vendor.bannerUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    vendor.bannerUrl!,
                                    fit: BoxFit.cover,
                                  ))
                          : Container(
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                    ),
                    Container(
                      height: 200.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 150.h,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 100.w,
                          height: 100.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            image: DecorationImage(
                              image: _getAvatarImage(vendor.avatar),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 250.h),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      Text(
                        vendor.name,
                        style: GoogleFonts.inter(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      // Availability badge
                      if (vendor.isAvailable)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            'Available',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/icons/star_fill.svg",
                            height: 20.h,
                            width: 20.w,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            vendor.ratingAvg,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '(${vendor.totalReviews})',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32.h),
                      _buildSectionTitle('Bio'),
                      SizedBox(height: 12.h),
                      Text(
                        vendor.bio ?? 'No bio available',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.darkGrey,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      _buildSectionTitle("${vendor.name}'s Services"),
                      SizedBox(height: 16.h),
                      SizedBox(
                        height: 230.h,
                        child: vendor.services.isEmpty
                            ? Center(
                                child: Text(
                                  'No services listed',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: vendor.services.length,
                                itemBuilder: (context, index) {
                                  final service = vendor.services[index];
                                  return ServicesCard(
                                    imagePath: _getCoverImageUrl(
                                      service.coverImage,
                                    ),
                                    title: service.title,
                                    location: service.firstAddress ?? '',
                                    price: service.startingPrice,
                                    rating: vendor.ratingAvg,
                                    isBookmarked: false,
                                    onTap: () {
                                      // TODO: Navigate to service detail
                                      // Get.to(() => sp.ServiceDetailView(service: service));
                                    },
                                  );
                                },
                              ),
                      ),
                      SizedBox(height: 32.h),
                      _buildSectionTitle('Reviews'),
                      SizedBox(height: 16.h),
                      SizedBox(
                        height: 120.h,
                        child: vendor.reviews.isEmpty
                            ? Center(
                                child: Text(
                                  'No reviews yet',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: vendor.reviews.length,
                                itemBuilder: (context, index) {
                                  final review = vendor.reviews[index];
                                  return ReviewCard(
                                    review: _toReviewData(review),
                                  );
                                },
                              ),
                      ),
                      SizedBox(height: 50.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 40.h,
            left: 16.w,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.arrow_back, color: Colors.black, size: 20.r),
              ),
            ),
          ),
          if (showCustomerActions)
            Positioned(
              top: 40.h,
              right: 16.w,
              child: PopupMenuButton<String>(
                icon: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.3),
                  child: Icon(Icons.more_vert, color: Colors.black, size: 20.r),
                ),
                onSelected: (value) {
                  if (value == 'review') {
                    Get.toNamed(
                      AppRoutes.addReview,
                      arguments: {
                        'vendorName': vendor.name,
                        'vendorLogo': vendor.avatar,
                        'providerId': vendor.id,
                        'serviceId': vendor.services.isNotEmpty ? vendor.services.first.id : null,
                      },
                    );
                  } else if (value == 'certification') {
                    Get.toNamed(
                      AppRoutes.viewCertificate,
                      arguments: {
                        'providerId': vendor.id,
                      },
                    );
                   } else if (value == 'report') {
                     Get.toNamed(
                       AppRoutes.spamReport,
                       arguments: {'providerId': vendor.id},
                     );
                   }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'review',
                    child: Text('Leave a Review', style: GoogleFonts.inter()),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'certification',
                    child: Text(
                      'View Certification',
                      style: GoogleFonts.inter(),
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'report',
                    child: Text(
                      'Spam & Report',
                      style: GoogleFonts.inter(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Convert VendorReviewModel to ReviewData for ReviewCard widget
  ReviewData _toReviewData(VendorReviewModel review) {
    return ReviewData(
      userName: review.customerName,
      userImageUrl: '',
      date: review.createdAt,
      rating: review.rating.toDouble(),
      reviewText: review.comment,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 20.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
