import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/views/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WalletView extends GetView<ProfileController> {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'My Wallet',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Obx(
        () => Skeletonizer(
          enabled: controller.isLoading.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32.h),
              // Earnings Section
              Center(
                child: Column(
                  children: [
                    Text(
                      'Total Earnings',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          controller.walletBalance.value,
                          style: GoogleFonts.inter(
                            fontSize: 72.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(
                              0xFF6366F1,
                            ), // Matching design blue/purple
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'AED',
                          style: GoogleFonts.inter(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              // Withdraw Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement Withdraw flow
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Withdraw',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 48.h),
              // Transactions Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  'Transactions',
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3F414E),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // Transactions List
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  itemCount: controller.isLoading.value
                      ? 5
                      : controller.transactions.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1.h, color: Colors.grey.shade100),
                  itemBuilder: (context, index) {
                    final tx = controller.isLoading.value
                        ? {
                            'title': 'John Doe',
                            'time': 'Just Now',
                            'amount': '105',
                          }
                        : controller.transactions[index];
                    return _buildTransactionItem(tx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            tx['title'] ?? 'User Name',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                tx['time'] ?? 'Just Now',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Colors.grey.shade400,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Text(
                    tx['amount'] ?? '0',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6366F1),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Aed',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
