import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/data/models/service_model.dart';
import 'package:event_maker/views/customer_flow/map/map_results_controller.dart';
import 'package:event_maker/views/services/service_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;

class MapResultsView extends GetView<MapResultsController> {
  const MapResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Flutter Map
          FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(24.4539, 54.3773),
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
                userAgentPackageName: 'com.example.event_maker',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: controller.polylinePoints,
                    strokeWidth: 3.0,
                    color: AppColors.black,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // Center red marker
                  const Marker(
                    point: LatLng(24.4450, 54.3780),
                    child: Icon(
                      Icons.location_on,
                      color: AppColors.error,
                      size: 40,
                    ),
                  ),
                  // Dynamic markers from mock services
                  ...controller.mockServices.map((service) {
                    final point =
                        controller.serviceLocations[service.id] ??
                        const LatLng(0, 0);
                    return _buildServiceMarker(
                      point: point,
                      service: service,
                      isBlue:
                          service.id ==
                          '1', // Blue for elite photography as in design
                    );
                  }),
                ],
              ),
            ],
          ),

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

  Marker _buildServiceMarker({
    required LatLng point,
    required ServiceModel service,
    required bool isBlue,
  }) {
    return Marker(
      point: point,
      width: 150.w,
      height: 60.h,
      child: GestureDetector(
        onTap: () => controller.onMarkerTap(service),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Bubble style info window
            Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isBlue ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: isBlue
                    ? Border.all(color: AppColors.white, width: 2)
                    : null,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: Image.network(
                      service.images.isNotEmpty ? service.images.first : '',
                      width: 30.w,
                      height: 30.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.image_not_supported,
                        size: 20.r,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        service.title,
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: isBlue ? AppColors.white : AppColors.black,
                        ),
                      ),
                      Text(
                        '${service.basePrice} ${service.priceUnit}',
                        style: GoogleFonts.inter(
                          fontSize: 9.sp,
                          color: isBlue ? AppColors.lightGrey : AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Triangle pointer at the bottom of the bubble
            CustomPaint(
              size: Size(15.w, 10.h),
              painter: TrianglePainter(
                color: isBlue ? AppColors.primary : AppColors.white,
              ),
            ),
          ],
        ),
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
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14.r,
                          color: AppColors.grey,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            service.location,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: AppColors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.star, size: 16.r, color: Colors.amber),
                        SizedBox(width: 4.w),
                        Text(
                          service.rating.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 10.w),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
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
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 15.w),
                          child: Text(
                            '${service.basePrice?.toStringAsFixed(2) ?? '0.00'} ${service.priceUnit}',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
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

class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
