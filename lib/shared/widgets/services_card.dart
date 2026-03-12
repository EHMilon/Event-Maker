import 'package:event_maker/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ServicesCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String location;
  final String price;
  final String rating;
  final bool isBookmarked;
  final bool useFullWidth;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;

  const ServicesCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.location,
    required this.price,
    required this.rating,
    this.isBookmarked = false,
    this.useFullWidth = false,
    this.onTap,
    this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = useFullWidth ? double.infinity : 230.w;
    final cardMargin = useFullWidth
        ? EdgeInsets.only(bottom: 16.h)
        : EdgeInsets.only(right: 16.w);
    final imageHeight = useFullWidth ? 230.h : 120.h;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        margin: cardMargin,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightGrey),
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.r),
                  ),
                  child: imagePath.startsWith('http')
                      ? Image.network(
                          imagePath,
                          height: imageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: imageHeight,
                                color: AppColors.lightGrey,
                                child: const Icon(Icons.broken_image),
                              ),
                        )
                      : Image.asset(
                          imagePath,
                          height: imageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: imageHeight,
                                color: AppColors.lightGrey,
                                child: const Icon(Icons.broken_image),
                              ),
                        ),
                ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: GestureDetector(
                    onTap: onBookmarkTap,
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        size: 18.r,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Content Section
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
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
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: price,
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.black,
                              ),
                            ),
                            TextSpan(
                              text: '/hr',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
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
                              fontWeight: FontWeight.w400,
                              color: AppColors.grey,
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
}
