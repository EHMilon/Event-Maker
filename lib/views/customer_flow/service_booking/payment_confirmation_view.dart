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
/// Used when user completes payment via Stripe or PayPal and returns to app.
class PaymentConfirmationView extends StatelessWidget {
  const PaymentConfirmationView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get arguments passed from payment controller
    final args = Get.arguments as Map<String, dynamic>?;
    final paymentMethod = args?['payment_method'] as String? ?? '';
    final successMessage = args?['success_message'] as String?;
    final bookingId = args?['booking_id'] as int?;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        titleSpacing: 24.w,
        title: Text(
          'paymentConfirmation'.tr,
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // Success icon
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 80.r,
                color: AppColors.primary,
              ),
            ),

            SizedBox(height: 32.h),

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

            // Payment method used
            if (paymentMethod.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Paid via $paymentMethod',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),

            SizedBox(height: 16.h),

            // Success message from backend
            if (successMessage != null && successMessage.isNotEmpty)
              Text(
                successMessage,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              )
            else
              Text(
                'bookingConfirmedSubtitle'.tr,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

            // Booking ID display
            if (bookingId != null) ...[
              SizedBox(height: 24.h),
              Text(
                'Booking ID: #$bookingId',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],

            const Spacer(),

            // Back to Home button
            PrimaryTextButton(
              onPressed: () {
                // Navigate back to home screen (clears navigation stack)
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
