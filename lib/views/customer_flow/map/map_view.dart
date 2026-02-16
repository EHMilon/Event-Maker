import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/views/customer_flow/map/map_controller.dart';
import 'package:event_maker/views/customer_flow/map/widgets/sub_category_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MapView extends GetView<MapController> {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        // elevation: 0,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: AppColors.black, size: 24.r),
        //   onPressed: () => Get.back(),
        // ),
        title: Text(
          'My Location',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(
        () => Skeletonizer(
          enabled: controller.isLoading.value,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      // Search Location
                      _buildLabel('Search Location'),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        height: 56.h,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.lightGrey),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: AppColors.grey,
                              size: 24.r,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: TextField(
                                onChanged: (value) =>
                                    controller.locationSearch.value = value,
                                decoration: InputDecoration(
                                  hintText: 'UAE',
                                  hintStyle: GoogleFonts.inter(
                                    color: AppColors.black,
                                    fontSize: 14.sp,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      // Select Main Category
                      _buildLabel('Categories'),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        height: 56.h,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.lightGrey),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.selectedMainCategory.value,
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.grey,
                            ),
                            items: controller.mainCategories.map((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: GoogleFonts.inter(
                                    color: AppColors.black,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              if (newValue != null) {
                                controller.selectedMainCategory.value =
                                    newValue;
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      // Select Sub Categories Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLabel('Sub Categories'),
                          TextButton(
                            onPressed: () => controller.selectAll(),
                            child: Text(
                              'Select All',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: AppColors.grey,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      // Sub Categories Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 16.h,
                          crossAxisSpacing: 16.w,
                          childAspectRatio: 0.65, // Increased height
                        ),
                        itemCount: controller.subCategories.length,
                        itemBuilder: (context, index) {
                          final sub = controller.subCategories[index];
                          final name = sub['name'] as String;
                          final icon = sub['icon'] as String;
                          return Obx(() {
                            final isSelected = controller.selectedSubCategories
                                .contains(name);
                            return SubCategoryCard(
                              name: name,
                              icon: icon,
                              isSelected: isSelected,
                              onTap: () => controller.toggleSubCategory(name),
                            );
                          });
                        },
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
              // Search Button
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: () => controller.search(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Search',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.black,
      ),
    );
  }
}
