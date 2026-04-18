import 'package:event_maker/views/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../constants/app_colors.dart';
import '../../models/faq_model.dart';

class FAQView extends StatefulWidget {
  const FAQView({super.key});

  @override
  State<FAQView> createState() => _FAQViewState();
}

class _FAQViewState extends State<FAQView> {
  final ProfileController controller = Get.find<ProfileController>();
  final RxMap<int, RxBool> expandedStates = <int, RxBool>{}.obs;

  @override
  void initState() {
    super.initState();
    controller.fetchFaqs();
  }

  RxBool _getExpandedState(int faqId) {
    if (!expandedStates.containsKey(faqId)) {
      expandedStates[faqId] = false.obs;
    }
    return expandedStates[faqId]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'faq'.tr,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isFaqsLoading.value) {
          return Skeletonizer(
            enabled: true,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              itemCount: 5,
              separatorBuilder: (context, index) => Divider(
                color: AppColors.lightGrey.withOpacity(0.5),
                height: 32.h,
              ),
              itemBuilder: (context, index) => Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Container(
                          height: 16.h,
                          width: double.infinity,
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.faqs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.help_outline,
                  size: 64.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 16.h),
                Text(
                  'noFaq'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          itemCount: controller.faqs.length,
          separatorBuilder: (context, index) => Divider(
            color: AppColors.lightGrey.withOpacity(0.5),
            height: 32.h,
          ),
          itemBuilder: (context, index) {
            final FaqModel faq = controller.faqs[index];
            final isExpanded = _getExpandedState(faq.id);

            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    isExpanded.value = !isExpanded.value;
                  },
                  child: Row(
                    children: [
                      Icon(
                        isExpanded.value
                            ? Icons.remove_circle_outline
                            : Icons.add_circle_outline,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          faq.question.tr,
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
                    height: isExpanded.value ? null : 0,
                    child: isExpanded.value
                        ? Padding(
                            padding: EdgeInsets.only(
                              left: 32.w,
                              top: 12.h,
                              bottom: 8.h,
                            ),
                            child: Text(
                              faq.answer.tr,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }
}
