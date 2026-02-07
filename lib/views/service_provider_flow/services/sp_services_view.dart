import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/shared/widgets/sp_service_card.dart';
import 'package:event_maker/views/service_provider_flow/services/sp_services_controller.dart';
import 'package:event_maker/views/services/service_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:event_maker/views/service_provider_flow/services/add_service_view.dart';
import 'package:event_maker/views/service_provider_flow/services/add_event_view.dart';
import 'package:event_maker/views/service_provider_flow/services/add_training_view.dart';
import 'package:event_maker/views/service_provider_flow/services/add_screens_binding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SPServicesView extends GetView<SPServicesController> {
  const SPServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Text(
                'Services',
                style: GoogleFonts.inter(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 24.h),
              // Search and Add Button
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.05),
                        ),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: GoogleFonts.inter(
                            color: AppColors.textSecondary.withOpacity(0.5),
                            fontSize: 16.sp,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.textSecondary.withOpacity(0.5),
                            size: 22.r,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () => _showAddOptions(context),
                    child: Container(
                      height: 50.h,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 20.r),
                          SizedBox(width: 4.w),
                          Text(
                            'Add',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              // Services List
              Expanded(
                child: Obx(() {
                  return RefreshIndicator(
                    onRefresh: () async => controller.refreshServices(),
                    child: Skeletonizer(
                      enabled: controller.isLoading.value,
                      child: ListView.builder(
                        itemCount: controller.isLoading.value
                            ? 5
                            : controller.services.length,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        itemBuilder: (context, index) {
                          if (controller.isLoading.value) {
                            return SpServiceCard(
                              imagePath: '',
                              title: 'Skeleton Service Title Goes Here',
                              dateTime: '10th Jan - Fri - 4:00 PM',
                              onTap: () {},
                            );
                          }
                          final service = controller.services[index];
                          return SpServiceCard(
                            imagePath: service.images.isNotEmpty
                                ? service.images.first
                                : '',
                            title: service.title,
                            dateTime:
                                '10th Jan - Fri - 4:00 PM', // Mock date format
                            onTap: () {
                              Get.to(
                                () => ServiceDetailView(
                                  service: service,
                                  showEditButton:
                                      true, // Passing flag to show edit button
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Category',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 20.h),
            _buildOptionItem(
              icon: Icons.miscellaneous_services,
              title: 'Services',
              onTap: () {
                Get.back();
                Get.to(
                  () => const AddServiceView(),
                  binding: AddScreensBinding(),
                );
              },
            ),
            _buildOptionItem(
              icon: Icons.event,
              title: 'Events',
              onTap: () {
                Get.back();
                Get.to(
                  () => const AddEventView(),
                  binding: AddScreensBinding(),
                );
              },
            ),
            _buildOptionItem(
              icon: Icons.school,
              title: 'Trainings',
              onTap: () {
                Get.back();
                Get.to(
                  () => const AddTrainingView(),
                  binding: AddScreensBinding(),
                );
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24.r),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }
}
