import 'package:event_maker/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SubCategoryCard extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const SubCategoryCard({
    super.key,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(25.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightGrey,
            width: 1,
          ),
        ),
        child: Text(
          name,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? AppColors.white
                : AppColors.black.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
