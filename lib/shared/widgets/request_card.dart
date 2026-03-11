import 'package:event_maker/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable Request Card widget for displaying service requests
/// Used in SP Requests view and My Services view
class RequestCard extends StatelessWidget {
  const RequestCard({
    super.key,
    required this.image,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String image;
  final String date;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.lightGrey),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: image.isNotEmpty
                    ? (image.startsWith('http')
                          ? Image.network(
                              image,
                              width: 80.w,
                              height: 80.h,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildPlaceholderImage(),
                            )
                          : Image.asset(
                              image,
                              width: 80.w,
                              height: 80.h,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildPlaceholderImage(),
                            ))
                    : _buildPlaceholderImage(),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      // TODO: Uncomment if subtitle is needed
                      // SizedBox(height: 4.h),
                      // Text(
                      //   subtitle,
                      //   overflow: TextOverflow.ellipsis,
                      //   style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.textSecondary),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80.w,
      height: 80.h,
      color: AppColors.lightGrey,
      child: Icon(Icons.image_not_supported, color: AppColors.grey, size: 28.r),
    );
  }
}
