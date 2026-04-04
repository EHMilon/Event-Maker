import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/widgets/primary_text_button.dart';
import 'package:event_maker/app_routes.dart';

/// View displayed when a service provider's account is verified
/// but pending admin approval.
class ProviderRequestSentView extends StatelessWidget {
  const ProviderRequestSentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 120.h),
              Image.asset(
                'assets/images/request_sent.png',
                width: 0.6.sw,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200.h,
                  width: 200.w,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.hourglass_top_outlined,
                    size: 80.r,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              Text(
                'accountVerifiedPendingApproval'.tr,
                style: GoogleFonts.inter(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                'providerApprovalSubtitle'.tr,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 60.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(24.w),
        child: PrimaryTextButton(
          onPressed: () {
            Get.offAllNamed(AppRoutes.login);
          },
          text: 'backToLogin'.tr,
        ),
      ),
    );
  }
}
