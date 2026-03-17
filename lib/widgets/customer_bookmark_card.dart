import 'package:event_maker/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// A reusable horizontal service card widget for customer views.
/// Used by both Bookmarks and Bookings screens.
///
/// [showBookmarkButton] - When true, displays the bookmark button (for Bookmarks screen)
///                       When false, hides the bookmark button (for Bookings screen)
class CustomerBookmarkCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final String location;
  final String price;
  final String priceUnit;
  final String rating;
  final bool showBookmarkButton;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;

  const CustomerBookmarkCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.price,
    this.priceUnit = 'AED',
    required this.rating,
    this.showBookmarkButton = true,
    this.onTap,
    this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: imagePath.startsWith('http')
                  ? Image.network(
                      imagePath,
                      width: 90.w,
                      height: 90.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildImageError(),
                    )
                  : Image.asset(
                      imagePath,
                      width: 90.w,
                      height: 90.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildImageError(),
                    ),
            ),
            SizedBox(width: 16.w),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row with optional bookmark button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (showBookmarkButton) ...[
                        SizedBox(width: 8.w),
                        _buildBookmarkButton(),
                      ],
                    ],
                  ),
                  // SizedBox(height: 4.h),
                  // Subtitle (provider name)
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: AppColors.grey500,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Location
                  Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/location.svg",
                        height: 16.h,
                        width: 16.w,
                        colorFilter: ColorFilter.mode(
                          AppColors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child:       Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.grey500,
                            fontWeight: FontWeight.w500,
                            height: 1.2.h
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  // Price and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            "$price $priceUnit",
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.2.sp,
                            ),
                          ),
                          Text(
                            "/hr",
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: AppColors.grey400,
                              height: 1.2.sp,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SvgPicture.asset(
                            "assets/icons/star_fill.svg",
                            height: 16.h,
                            width: 16.w,
                            colorFilter: ColorFilter.mode(
                              Colors.yellow,
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            rating,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
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

  Widget _buildImageError() {
    return Container(
      width: 90.w,
      height: 90.h,
      color: AppColors.lightGrey,
      child: const Icon(Icons.image_not_supported, color: AppColors.grey),
    );
  }

  Widget _buildBookmarkButton() {
    return GestureDetector(
      onTap: onBookmarkTap,
      child: Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: const Icon(Icons.bookmark, color: AppColors.primary, size: 20),
      ),
    );
  }
}
