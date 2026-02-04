import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../core/themes/app_colors.dart';
import 'profile_controller.dart';

class BookmarksView extends GetView<ProfileController> {
  const BookmarksView({super.key});

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
          'My Bookmarks',
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
            itemCount: controller.bookmarks.length,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              final item = controller.bookmarks[index];
              return Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.asset(
                        item['image'],
                        width: 80.w,
                        height: 80.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item['title'],
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Icon(
                                Icons.bookmark,
                                color: AppColors.error,
                                size: 18,
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            item['provider'],
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[400],
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14.sp,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                item['location'],
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Text(
                                item['price'],
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'AED/hr',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
