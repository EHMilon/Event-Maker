import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/shared/widgets/primary_text_button.dart';
import 'package:event_maker/core/routes/app_routes.dart';

class BookingRequestSentView extends StatelessWidget {
  const BookingRequestSentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Image.asset(
              'assets/images/request_sent.png',
              width: 0.6.sw,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200.h,
                width: 200.w,
                color: AppColors.lightGrey,
                child: Icon(
                  Icons.check_circle_outline,
                  size: 100.r,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: 40.h),
            Text(
              'Request Sent Successfully!',
              style: GoogleFonts.inter(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Text(
              'Your booking request has been sent to the service provider. You will be notified once they accept it.',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            PrimaryTextButton(
              onPressed: () {
                Get.offAllNamed(AppRoutes.customerHome);
              },
              text: 'Back to Home',
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
