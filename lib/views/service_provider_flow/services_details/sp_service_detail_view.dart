import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/views/service_provider_flow/services_details/service_detail_view.dart';
import 'package:event_maker/views/service_provider_flow/services_details/sp_service_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// Service Provider's Service Detail View
/// Wraps the existing ServiceDetailView with loading and error states
/// Fetches service detail from API using service ID
class SPServiceDetailView extends GetView<SPServicedetailController> {
  const SPServiceDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        );
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: IconButton(
              icon: CircleAvatar(
                backgroundColor: AppColors.lightGrey,
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.black,
                  size: 20.r,
                ),
              ),
              onPressed: () => Get.back(),
            ),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.r,
                  color: AppColors.error,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Error',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: controller.fetchServiceDetail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      final service = controller.service.value;
      if (service == null) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: Center(
            child: Text('Service not found'),
          ),
        );
      }

      return ServiceDetailView(
        service: service,
        showEditButton: true,
      );
    });
  }
}
