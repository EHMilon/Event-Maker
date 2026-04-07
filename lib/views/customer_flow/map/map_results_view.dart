import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/views/customer_flow/map/map_results_controller.dart';
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
          // Google Map - Full interactive map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _getInitialCenter(),
              zoom: 13.0,
            ),
            markers: _buildMarkers(),
            zoomControlsEnabled: true,
            mapToolbarEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            tiltGesturesEnabled: true,
            rotateGesturesEnabled: true,
            mapType: MapType.normal,
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              // Map created callback if needed
            },
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

          // Location Info Cards (when availability locations are shown)
          if (controller.availabilityLocations.isNotEmpty)
            Positioned(
              bottom: 30.h,
              left: 20.w,
              right: 20.w,
              child: _buildAvailabilityInfoCard(),
            ),
        ],
      ),
    );
  }

  /// Build markers for the map
  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = {};

    if (controller.availabilityLocations.isNotEmpty) {
      // Show availability location markers
      for (int i = 0; i < controller.availabilityLocations.length; i++) {
        final location = controller.availabilityLocations[i];
        final position = LatLng(location.latitude, location.longitude);

        markers.add(
          Marker(
            markerId: MarkerId('availability_$i'),
            position: position,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              i == 0 ? BitmapDescriptor.hueRed : BitmapDescriptor.hueBlue,
            ),
            infoWindow: InfoWindow(
              title: location.address,
              snippet: '${location.days} • ${location.time}',
            ),
          ),
        );
      }
    } else {
      // Show mock service markers
      for (int i = 0; i < controller.mockServices.length; i++) {
        final service = controller.mockServices[i];
        final point = controller.serviceLocations[service.id];
        if (point != null) {
          markers.add(
            Marker(
              markerId: MarkerId('service_${service.id}'),
              position: point,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                service.id == '1'
                    ? BitmapDescriptor.hueBlue
                    : BitmapDescriptor.hueRed,
              ),
              infoWindow: InfoWindow(
                title: service.title,
                snippet: '${service.basePrice} ${service.priceUnit}',
              ),
              onTap: () => controller.onMarkerTap(service),
            ),
          );
        }
      }
    }

    return markers;
  }

  /// Build availability info card
  Widget _buildAvailabilityInfoCard() {
    return Container(
      height: 120.h,
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
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.availabilityLocations.length,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        itemBuilder: (context, index) {
          final location = controller.availabilityLocations[index];
          final isFirst = index == 0;

          return Container(
            width: 200.w,
            margin: EdgeInsets.only(right: 12.w),
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: isFirst
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.lightGrey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isFirst ? AppColors.primary : AppColors.borderLight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16.r,
                      color: isFirst ? AppColors.primary : AppColors.grey,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        location.address,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                if (location.days.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12.r,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          location.days,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                if (location.time.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12.r,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        location.time,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Get initial center based on availability locations or default
LatLng _getInitialCenter() {
  final controller = Get.find<MapResultsController>();

  if (controller.availabilityLocations.isNotEmpty) {
    // Center on first availability location
    final firstLocation = controller.availabilityLocations.first;
    return LatLng(firstLocation.latitude, firstLocation.longitude);
  }

  // Default center (UAE)
  return const LatLng(24.4539, 54.3773);
}
