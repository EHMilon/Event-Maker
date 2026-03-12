import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/data/models/review_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final bool useFullWidth;

  const ReviewCard({
    super.key,
    required this.review,
    this.useFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: useFullWidth ? double.infinity : 250.w,
      margin: useFullWidth
          ? EdgeInsets.only(bottom: 16.h)
          : EdgeInsets.only(right: 16.w),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightGrey),
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
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundImage: review.userImageUrl.startsWith('http')
                    ? NetworkImage(review.userImageUrl)
                    : AssetImage(review.userImageUrl) as ImageProvider,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return SvgPicture.asset(
                          "assets/icons/star_fill.svg",
                          height: 12.h,
                          width: 12.w,
                          color: index < review.rating
                              ? Colors.amber
                              : AppColors.lightGrey,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Text(
                review.date,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            review.reviewText,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
