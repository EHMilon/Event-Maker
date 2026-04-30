import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/widgets/customer_bookmark_card.dart';
import 'package:event_maker/views/customer_flow/services/service_detail_view.dart';
import 'package:event_maker/views/profile/profile_controller.dart';
import 'package:event_maker/services/service_repository.dart';
import 'package:event_maker/services/api_exception.dart';
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
          'myBookmarks'.tr,
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
                        priceUnit: item.priceUnit,
                        rating: '${item.rating}',
                        showBookmarkButton: true,
                        onTap: () => _openServiceDetail(
                          context,
                          serviceId: item.apiId,
                        ),
                        onBookmarkTap: () => controller.removeBookmark(item.id),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  /// Fetches full service details from API and navigates to ServiceDetailView
  Future<void> _openServiceDetail(BuildContext context, {required int serviceId}) async {
    // Show loading indicator
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final repository = const ServiceRepository();
      final fullService = await repository.fetchCustomerServiceDetail(serviceId);
      
      // Close loading dialog
      Get.back();

      // Navigate with full service details
      Get.to(() => ServiceDetailView(service: fullService));
    } on ApiException catch (e) {
      // Close loading dialog
      Get.back();

      Get.snackbar(
        'error'.tr,
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      // Close loading dialog
      Get.back();

      Get.snackbar(
        'error'.tr,
        'failedToLoadServiceDetails'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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
