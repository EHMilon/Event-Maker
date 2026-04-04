import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/widgets/primary_text_button.dart';
import 'package:event_maker/app_routes.dart';

/// Payment confirmation screen shown after successful payment.
/// Displays a confirmation illustration and a button to return to home.
///
/// Used when user clicks on the payment screen to confirm their booking.
class PaymentConfirmationView extends StatelessWidget {
  const PaymentConfirmationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // Booking confirmation illustration
            Image.asset(
              'assets/images/booking_confirm.png',
              width: 0.7.sw,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 250.h,
                width: 250.w,
                color: AppColors.lightGrey,
                child: Icon(
                  Icons.check_circle_outline,
                  size: 120.r,
                  color: AppColors.primary,
                ),
              ),
            ),

            SizedBox(height: 40.h),

            // Success message
            Text(
              'paymentSuccessful'.tr,
              style: GoogleFonts.inter(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 16.h),

            // Subtitle
            Text(
              'bookingConfirmedSubtitle'.tr,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            // Back to Home button
            PrimaryTextButton(
              onPressed: () {
                // Navigate back to home screen
                Get.offAllNamed(AppRoutes.customerHome);
              },
              text: 'backToHome'.tr,
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
