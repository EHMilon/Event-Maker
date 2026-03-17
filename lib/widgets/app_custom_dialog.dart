import 'package:event_maker/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AppCustomDialog extends StatelessWidget {
  final String? iconPath;
  final String title;
  final String? subTitle;
  final String mainButtonText;
  final VoidCallback mainButtonCallback;
  final String? secondaryButtonText;
  final VoidCallback? secondaryButtonCallback;
  final bool isVerticalButtons;
  final Color? mainButtonColor;
  final Color? iconColor;
  final double? iconHeight;

  const AppCustomDialog({
    super.key,
    this.iconPath,
    required this.title,
    this.subTitle,
    required this.mainButtonText,
    required this.mainButtonCallback,
    this.secondaryButtonText,
    this.secondaryButtonCallback,
    this.isVerticalButtons = false,
    this.mainButtonColor,
    this.iconColor,
    this.iconHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            if (iconPath != null) ...[
              _buildIcon(),
              SizedBox(height: 24.h),
            ],

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),

            // Subtitle
            if (subTitle != null) ...[
              SizedBox(height: 12.h),
              Text(
                subTitle!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],

            SizedBox(height: 32.h),

            // Buttons
            if (isVerticalButtons)
              Column(
                children: [
                  _buildMainButton(),
                  if (secondaryButtonText != null) ...[
                    SizedBox(height: 12.h),
                    _buildSecondaryButton(),
                  ],
                ],
              )
            else
              Row(
                children: [
                  if (secondaryButtonText != null)
                    Expanded(child: _buildSecondaryButton()),
                  if (secondaryButtonText != null) SizedBox(width: 12.w),
                  Expanded(child: _buildMainButton()),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (iconPath!.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        iconPath!,
        height: iconHeight ?? 120.h,
        fit: BoxFit.contain,
        colorFilter: iconColor != null
            ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
            : null,
      );
    } else {
      return Image.asset(
        iconPath!,
        height: iconHeight ?? 120.h,
        fit: BoxFit.contain,
        color: iconColor,
      );
    }
  }

  Widget _buildMainButton() {
    return InkWell(
      onTap: mainButtonCallback,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: mainButtonColor ?? AppColors.primary,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: (mainButtonColor ?? AppColors.primary).withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          mainButtonText,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return InkWell(
      onTap: secondaryButtonCallback,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFFE9E9E9),
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.center,
        child: Text(
          secondaryButtonText!,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
