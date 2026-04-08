import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/views/customer_flow/map/map_results_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapResultsView extends StatelessWidget {
  const MapResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Register the controller
    final controller = Get.put(MapResultsController());

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return Stack(
          children: [
            // Google Map
            GoogleMap(
              initialCameraPosition: controller.initialCameraPosition,
              markers: controller.markers.toSet(),
              polylines: controller.polylines.toSet(),
              onMapCreated: controller.onMapCreated,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: true,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
            ),

            // Back Button
            Positioned(
              top: 50.h,
              left: 20.w,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.1),
                        blurRadius: 10.r,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 20.r,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),

            // Selected Service Card (shows only the selected service)
            if (controller.selectedService != null)
              Positioned(
                bottom: 20.h,
                left: 16.w,
                right: 16.w,
                child: _buildSelectedServiceCard(controller),
              ),

            // No results message
            if (controller.services.isEmpty)
              Positioned(
                bottom: 100.h,
                left: 20.w,
                right: 20.w,
                child: Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.1),
                        blurRadius: 10.r,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off, size: 48.r, color: AppColors.grey),
                      SizedBox(height: 12.h),
                      Text(
                        'No services found',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Try adjusting your search criteria',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildSelectedServiceCard(MapResultsController controller) {
    final service = controller.selectedService!;

    return GestureDetector(
      onTap: () => controller.onBottomCardTap(service.id),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.15),
              blurRadius: 20.r,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Cover Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: CachedNetworkImage(
                imageUrl: service.fullCoverImageUrl,
                width: 90.w,
                height: 90.w,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 90.w,
                  height: 90.w,
                  color: AppColors.lightGrey,
                  child: Icon(Icons.image, color: AppColors.grey, size: 40.r),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 90.w,
                  height: 90.w,
                  color: AppColors.lightGrey,
                  child: Icon(
                    Icons.image_not_supported,
                    color: AppColors.grey,
                    size: 40.r,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            // Service Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16.r,
                        color: AppColors.grey,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          service.address,
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            color: AppColors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      // Role badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          service.roleName,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Rating
                      if (service.rating > 0)
                        Row(
                          children: [
                            Icon(Icons.star, size: 16.r, color: Colors.amber),
                            SizedBox(width: 4.w),
                            Text(
                              service.rating.toStringAsFixed(1),
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Price
                  Row(
                    children: [
                      Text(
                        '${service.startingPrice.toStringAsFixed(2)} ${service.currency}',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Spacer(),
                      // Navigation Button
                      Obx(() {
                        final isNavigating = controller.isNavigating.value;
                        return GestureDetector(
                          onTap: () {
                            if (isNavigating) {
                              controller.stopNavigation();
                            } else {
                              controller.startNavigation();
                            }
                          },
                          child: Container(
                            width: 30.w,
                            height: 30.w,
                            decoration: BoxDecoration(
                              color: isNavigating
                                  ? Colors.red
                                  : AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (isNavigating
                                              ? Colors.red
                                              : AppColors.primary)
                                          .withValues(alpha: 0.3),
                                  blurRadius: 8.r,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isNavigating ? Icons.close : Icons.navigation,
                              color: Colors.white,
                              size: 20.r,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
          ],
        ),
      ),
    );
  }
}
