import 'package:event_maker/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final int badgeCount;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color titleColor;
  final List<BoxShadow>? boxShadow;

  const OrderCard({
    super.key,
    required this.title,
    required this.imageUrl,
    this.badgeCount = 0,
    this.onTap,
    this.backgroundColor = AppColors.white,
    this.titleColor = AppColors.textPrimary,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: boxShadow ?? [
            BoxShadow(
              color: const Color(0x12000000),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 64.w,
                      height: 64.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 64.w,
                        height: 64.h,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    )
                  : Container(
                      width: 64.w,
                      height: 64.h,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: titleColor,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (badgeCount > 0) ...[
              SizedBox(width: 16.w),
              Container(
                height: 24.h,
                width: 24.h,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFB485FF),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badgeCount',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
