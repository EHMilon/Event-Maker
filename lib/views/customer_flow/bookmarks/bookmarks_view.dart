import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/widgets/customer_bookmark_card.dart';
import 'package:event_maker/views/customer_flow/services/service_detail_view.dart';
import 'package:event_maker/views/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:event_maker/widgets/empty_widget.dart';

class BookmarksView extends GetView<ProfileController> {
  const BookmarksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => Get.back(),
              )
            : null,
        title: Text(
          'My Bookmarks',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(
        () => Skeletonizer(
          enabled: controller.isLoading.value,
          child: controller.bookmarks.isEmpty && !controller.isLoading.value
              ? EmptyWidget(
                  message: 'No bookmarks yet'.tr,
                  icon: Icons.bookmark_border,
                )
              : ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 20.h,
                  ),
                  itemCount: controller.isLoading.value
                      ? 5
                      : controller.bookmarks.length,
                  separatorBuilder: (context, index) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    if (controller.isLoading.value) {
                      return _buildShimmerItem();
                    }
                    final item = controller.bookmarks[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: CustomerBookmarkCard(
                        imagePath: item.images.first,
                        title: item.title,
                        subtitle: item.provider.name,
                        location: item.location,
                        price: '${item.basePrice}',
                        priceUnit: '${item.priceUnit}/hr',
                        rating: '${item.rating}',
                        showBookmarkButton: true,
                        onTap: () =>
                            Get.to(() => ServiceDetailView(service: item)),
                        onBookmarkTap: () => controller.removeBookmark(item.id),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 90.w,
            height: 90.h,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 150.w, height: 16.h, color: AppColors.white),
                SizedBox(height: 8.h),
                Container(width: 100.w, height: 12.h, color: AppColors.white),
                SizedBox(height: 12.h),
                Container(width: 120.w, height: 12.h, color: AppColors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
