import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/shared/widgets/primary_text_button.dart';
import 'package:event_maker/core/routes/app_routes.dart';

class BookServiceRequestView extends StatelessWidget {
  const BookServiceRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Book Service',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Request',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),

            Text(
              'Special Requests (Optional)',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),

            // Text Area
            Container(
              height: 150.h,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.lightGrey),
              ),
              child: TextField(
                maxLines: null,
                decoration: InputDecoration.collapsed(
                  hintText:
                      'Any special requirements or notes for the service provider...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            PrimaryTextButton(
              onPressed: () {
                Get.toNamed(
                  AppRoutes.bookingRequestSent,
                  arguments: Get.arguments,
                );
              },
              text: 'Continue',
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
