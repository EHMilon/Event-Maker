import 'package:event_maker/views/customer_flow/service_booking/payment_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/widgets/primary_text_button.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PaymentView extends StatelessWidget {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PaymentController>();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'payment'.tr,
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
        () => Skeletonizer(
          enabled: controller.isLoading.value,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'bookingSummary'.tr,
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),

                // Summary Card
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.lightGrey),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.service?.title ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16.r,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 8.w),
                        Obx(() => Text(
                          controller.bookingDate.value.isEmpty ? 'Not selected' : controller.bookingDate.value,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        )),
                        SizedBox(width: 16.w),
                        Icon(
                          Icons.access_time,
                          size: 16.r,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 8.w),
                        Obx(() => Text(
                          controller.bookingTime.value.isEmpty ? 'Not selected' : controller.bookingTime.value,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        )),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Divider(color: AppColors.lightGrey),
                      SizedBox(height: 16.h),
                      _buildSummaryRow(
                        controller.selectedPackage?.name.tr ?? 'standard'.tr,
                        '${_parsePrice(controller.selectedPackage?.price) ?? controller.service?.basePrice ?? 0} ${controller.service?.priceUnit ?? 'AED'}',
                      ),
                      SizedBox(height: 8.h),
                      _buildSummaryRow(
                        'additionalFee'.tr,
                        '0 ${controller.service?.priceUnit ?? 'AED'}',
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'total'.tr,
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${_parsePrice(controller.selectedPackage?.price) ?? controller.service?.basePrice ?? 0} ${controller.service?.priceUnit ?? 'AED'}',
                            style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                Text(
                  'paymentMethod'.tr,
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),

                // Payment Methods
                _buildPaymentMethodOption(
                  controller,
                  0,
                  'stripe'.tr,
                  "assets/icons/stripe.png",
                ),
                SizedBox(height: 16.h),
                _buildPaymentMethodOption(
                  controller,
                  1,
                  'paypal'.tr,
                  "assets/icons/paypal.png",
                ),

                SizedBox(height: 16.h),
                Text(
                  'paymentDisclaimer'.tr,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 40.h),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(() => PrimaryTextButton(
          onPressed: controller.isProcessingPayment.value
              ? null
              : () => controller.processPayment(),
          text: controller.isProcessingPayment.value
              ? 'processing'.tr
              : 'payNow'.tr,
          isLoading: controller.isProcessingPayment.value,
        )),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// Parses price from String or num type
  String? _parsePrice(dynamic price) {
    if (price == null) return null;
    if (price is num) return price.toString();
    if (price is String) return price;
    return null;
  }

  Widget _buildPaymentMethodOption(
    PaymentController controller,
    int index,
    String name,
    String iconPath,
  ) {
    return Obx(() {
      final isSelected = controller.selectedPaymentMethod.value == index;
      return GestureDetector(
        onTap: () => controller.selectPaymentMethod(index),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.lightGrey,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Image.asset(iconPath, height: 20.h, width: 20.w),
              ),
              SizedBox(width: 16.w),
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                width: 24.r,
                height: 24.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.lightGrey,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12.r,
                          height: 12.r,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      );
    });
  }
}
