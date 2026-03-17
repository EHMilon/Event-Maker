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
        padding: EdgeInsets.symmetric(horizontal: 20.w),
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
                child: DropdownButton<String>(
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
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      controller.selectedMainCategory.value = newValue;
                    }
                  },
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
            // Sub Categories - horizontal scroll like home screen
            Obx(() {
              final subCategories = controller.currentSubCategories;
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Wrap(
                  children: subCategories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value;
                    return Padding(
                      padding: EdgeInsets.all(6.w),
                      child: CategoryItem(
                        label: category,
                        onTap: () {},
                        index: index,
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
