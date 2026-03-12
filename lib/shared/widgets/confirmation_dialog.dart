import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/shared/widgets/primary_text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String mainButtonText;
  final Color mainButtonColor;
  final VoidCallback onMainButtonPressed;
  final Widget? icon;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.mainButtonText,
    required this.mainButtonColor,
    required this.onMainButtonPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, SizedBox(height: 24.h)],
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),
            PrimaryTextButton(
              onPressed: onMainButtonPressed,
              text: mainButtonText,
              backgroundColor: mainButtonColor,
            ),
            SizedBox(height: 12.h),
            // TextButton(
            //   onPressed: () => Navigator.pop(context),
            //   child: Text(
            //     'cancel'.tr,
            //     style: GoogleFonts.inter(
            //       fontSize: 14.sp,
            //       color: AppColors.textSecondary,
            //       fontWeight: FontWeight.w500,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
