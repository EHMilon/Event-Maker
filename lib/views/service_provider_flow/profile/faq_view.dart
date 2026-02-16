import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/themes/app_colors.dart';
import 'profile_controller.dart';

class FAQView extends GetView<ProfileController> {
  const FAQView({super.key});

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
          'FAQ',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Obx(
        () => Skeletonizer(
          enabled: controller.isLoading.value,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            itemCount: controller.faqs.length,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              final faq = controller.faqs[index];
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      faq['isExpanded'].value = !faq['isExpanded'].value;
                    },
                    child: Row(
                      children: [
                        Icon(
                          faq['isExpanded'].value
                              ? Icons.remove_circle_outline
                              : Icons.add_circle_outline,
                          color: Colors.grey,
                          size: 20.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            faq['question'],
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: faq['isExpanded'].value ? 100.h : 0,
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: faq['isExpanded'].value
                            ? Padding(
                                padding: EdgeInsets.only(
                                  left: 32.w,
                                  top: 8.h,
                                  bottom: 8.h,
                                ),
                                child: Text(
                                  faq['answer'],
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                    height: 1.5,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
