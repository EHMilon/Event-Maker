import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/views/service_provider_flow/services/add_event_view.dart';
import 'package:event_maker/views/service_provider_flow/services/add_screens_binding.dart';
import 'package:event_maker/views/service_provider_flow/services/add_service_view.dart';
import 'package:event_maker/views/service_provider_flow/services/add_training_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable bottom sheet for selecting add options (Services, Events, Trainings)
/// Can be triggered from anywhere using AddOptionsBottomSheet.show(context)
class AddOptionsBottomSheet extends StatelessWidget {
  const AddOptionsBottomSheet({super.key});

  static void show(BuildContext context) {
    Get.bottomSheet(_buildBottomSheetContent());
  }

  static Widget _buildBottomSheetContent() {
    return Container(
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
            'selectCategory'.tr,
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 20.h),
          _buildOptionItem(
            icon: Icons.miscellaneous_services,
            title: 'services'.tr,
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
            title: 'events'.tr,
            onTap: () {
              Get.back();
              Get.to(() => const AddEventView(), binding: AddScreensBinding());
            },
          ),
          _buildOptionItem(
            icon: Icons.school,
            title: 'trainings'.tr,
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
    );
  }

  static Widget _buildOptionItem({
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

  @override
  Widget build(BuildContext context) {
    // This widget is meant to be shown via show() static method
    // Not used directly in the widget tree
    return const SizedBox.shrink();
  }
}
