import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/views/customer_flow/map/map_results_controller.dart';
import 'package:event_maker/views/customer_flow/services/service_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapResultsView extends GetView<MapResultsController> {
  const MapResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          Obx(() => GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(24.4539, 54.3773),
              zoom: 13.0,
            ),
            markers: controller.markers.toSet(),
            polylines: {
              Polyline(
                polylineId: const PolylineId('route_line'),
                points: controller.polylinePoints,
                color: AppColors.black,
                width: 3,
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          )),

          // Back Button
          Positioned(
            top: 50.h,
            left: 20.w,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.black,
                  size: 24.r,
                ),
              ),
            ),
          ),

          // Bottom Selected Service Card
          Positioned(
            bottom: 30.h,
            left: 20.w,
            right: 20.w,
            child: Obx(() {
              final service = controller.selectedService.value;
              if (service == null) return const SizedBox.shrink();
              return _buildSelectedServiceCard(service);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedServiceCard(ServiceModel service) {
    return GestureDetector(
      onTap: () => Get.to(() => ServiceDetailView(service: service)),
      child: Container(
        height: 100.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.all(10.r),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.r),
                child: Image.network(
                  service.images.isNotEmpty ? service.images.first : '',
                  width: 80.w,
                  height: 80.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.image_not_supported,
                    size: 40.r,
                    color: AppColors.grey,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 5.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      service.title,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14.r,
                          color: AppColors.grey,
                        ),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            service.location,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: AppColors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(Icons.star, size: 16.r, color: Colors.amber),
                        SizedBox(width: 4.w),
                        Text(
                          service.rating.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 6.w),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            child: Text(
                              service.provider.role,
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Text(
                            '${service.basePrice?.toStringAsFixed(2) ?? '0.00'} ${service.priceUnit}',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


