import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/views/customer_flow/map/map_search_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Map Search View - Interactive map for location-based service search
class MapSearchView extends GetView<MapSearchController> {
  const MapSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MapSearchController>()) {
      Get.put(MapSearchController());
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          _buildMap(),
          _buildCenterPin(),
          _buildBackButton(),
          _buildCurrentLocationButton(),
          _buildBottomSheet(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Obx(() => GoogleMap(
          initialCameraPosition: controller.cameraPosition.value,
          onMapCreated: controller.onMapCreated,
          onCameraMove: controller.onCameraMove,
          onCameraIdle: controller.onCameraIdle,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: true,
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          tiltGesturesEnabled: true,
          rotateGesturesEnabled: true,
          mapType: MapType.normal,
        ));
  }

  Widget _buildCenterPin() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20.w,
            height: 10.h,
            decoration: BoxDecoration(
              color: AppColors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(height: 4.h),
          Icon(Icons.location_on, size: 48.r, color: AppColors.primary),
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 50.h,
      left: 20.w,
      child: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.1), blurRadius: 10.r, offset: const Offset(0, 2))],
          ),
          child: Icon(Icons.arrow_back_ios_new, size: 20.r, color: AppColors.black),
        ),
      ),
    );
  }

  Widget _buildCurrentLocationButton() {
    return Positioned(
      top: 50.h,
      right: 20.w,
      child: GestureDetector(
        onTap: controller.goToCurrentLocation,
        child: Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.1), blurRadius: 10.r, offset: const Offset(0, 2))],
          ),
          child: Obx(() => controller.isGettingCurrentLocation.value
              ? SizedBox(width: 20.r, height: 20.r, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)))
              : Icon(Icons.my_location, size: 20.r, color: AppColors.primary)),
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), topRight: Radius.circular(24.r)),
          boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.1), blurRadius: 20.r, offset: const Offset(0, -5))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(color: AppColors.grey300, borderRadius: BorderRadius.circular(2.r)),
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocationDisplay(),
                  SizedBox(height: 20.h),
                  _buildCategoryFilter(),
                  SizedBox(height: 16.h),
                  _buildSubCategoryFilter(),
                  SizedBox(height: 16.h),
                  _buildSearchRadiusSlider(),
                  SizedBox(height: 24.h),
                  _buildSearchButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDisplay() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.location_on, color: AppColors.primary, size: 20.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Selected Location', style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.textSecondary)),
                SizedBox(height: 4.h),
                Obx(() => Text(
                      controller.selectedAddress.value.isNotEmpty ? controller.selectedAddress.value : 'Move map to select location',
                      style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )),
              ],
            ),
          ),
          Obx(() => controller.isGettingCurrentLocation.value
              ? SizedBox(width: 16.r, height: 16.r, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)))
              : Icon(Icons.check_circle, color: AppColors.success, size: 20.r)),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        SizedBox(height: 8.h),
        Obx(() => Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColors.borderLight)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedMainCategory.value,
                  isExpanded: true,
                  hint: Text('Select Category', style: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.grey)),
                  icon: Icon(Icons.keyboard_arrow_down, color: AppColors.grey, size: 24.r),
                  items: controller.mainCategories.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.textPrimary)),
                    );
                  }).toList(),
                  onChanged: controller.setMainCategory,
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildSubCategoryFilter() {
    return Obx(() => controller.selectedMainCategory.value != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sub Category', style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColors.borderLight)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedSubCategory.value,
                    isExpanded: true,
                    hint: Text('Select Sub Category (Optional)', style: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.grey)),
                    icon: Icon(Icons.keyboard_arrow_down, color: AppColors.grey, size: 24.r),
                    items: [
                      const DropdownMenuItem<String>(value: null, child: Text('All Subcategories')),
                      ...controller.subCategories.map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value, style: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.textPrimary)));
                      }),
                    ],
                    onChanged: controller.setSubCategory,
                  ),
                ),
              ),
            ],
          )
        : const SizedBox.shrink());
  }

  Widget _buildSearchRadiusSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Search Radius', style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Obx(() => Text('${controller.searchRadius.value.toStringAsFixed(0)} km', style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.primary))),
          ],
        ),
        SizedBox(height: 8.h),
        Obx(() => Slider(
              value: controller.searchRadius.value,
              min: 1,
              max: 50,
              divisions: 49,
              label: '${controller.searchRadius.value.toStringAsFixed(0)} km',
              activeColor: AppColors.primary,
              inactiveColor: AppColors.lightGrey,
              onChanged: (value) => controller.setSearchRadius(value),
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('1 km', style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.grey)),
            Text('50 km', style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: Obx(() => ElevatedButton(
            onPressed: controller.isSearching.value ? null : controller.searchNearbyServices,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              elevation: 0,
            ),
            child: controller.isSearching.value
                ? SizedBox(width: 24.r, height: 24.r, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.white)))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 24.r),
                      SizedBox(width: 8.w),
                      Text('Search Nearby Services', style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                    ],
                  ),
          )),
    );
  }
}
