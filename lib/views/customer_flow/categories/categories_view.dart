import 'package:event_maker/app_routes.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/views/customer_flow/home/customer_home_controller.dart';
import 'package:event_maker/views/customer_flow/home/widgets/category_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoriesView extends GetView<HomeController> {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'categories'.tr,
          style: GoogleFonts.inter(
            fontSize: 22.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w).copyWith(bottom: 80.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),
            Text(
              'Main Categories',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 20.h),
            // Main Categories Dropdown
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              height: 56.h,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.lightGrey),
              ),
              child: DropdownButtonHideUnderline(
                child: Obx(
                  () => DropdownButton<String>(
                    value: controller.selectedMainCategory.value,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.grey,
                    ),
                    items: controller.mainCategories.map((String value) {
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
                    onChanged: (String? newValue) async {
                      if (newValue != null) {
                        await controller.setMainCategory(newValue);
                      }
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            // Sub Categories Section
            Text(
              'Sub Categories',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 16.h),
            // Sub Categories
            Obx(() {
              final subCategories = controller.currentSubCategories;
              final selected = controller.selectedSubCategory.value;
              return Wrap(
                children: subCategories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  return Padding(
                    padding: EdgeInsets.all(6.w),
                    child: CategoryItem(
                      label: category,
                      isSelected: selected == category,
                      onTap: () {
                        controller.selectSubCategory(category);
                      },
                      index: index,
                    ),
                  );
                }).toList(),
              );
            }),
            SizedBox(height: 24.h),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () async {
              final selectedCategory = controller.selectedSubCategory.value;
              controller.selectedSubCategory.value = null;
              Get.toNamed(
                AppRoutes.categoryServices,
                arguments: {
                  'categoryType': controller.selectedMainCategory.value,
                  'categoryName':
                      selectedCategory ?? controller.selectedMainCategory.value,
                },
              );
            },
            child: Text(
              'Search',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
