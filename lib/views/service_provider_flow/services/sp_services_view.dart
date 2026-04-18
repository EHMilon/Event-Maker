import 'package:event_maker/app_routes.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/widgets/request_card.dart';
import 'package:event_maker/views/service_provider_flow/add_service/add_service_view.dart';
import 'package:event_maker/views/service_provider_flow/add_service/add_screens_binding.dart';
import 'package:event_maker/views/service_provider_flow/services/sp_services_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:google_fonts/google_fonts.dart';

/// Services view for Service Provider to manage their services
/// Shows list of services with ability to add, edit, and view details
class ServicesView extends GetView<SPServicesController> {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        titleSpacing: 24.w,
        title: Text(
          'myServices'.tr,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchAndAddBar(context),
              SizedBox(height: 20.h),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndAddBar(BuildContext context) {
    return Row(
      children: [
        // Search TextField
        Expanded(
          child: Container(
            height: 50.h,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: TextField(
              controller: controller.searchTextController,
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'searchServices'.tr,
                hintStyle: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary.withOpacity(0.6),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.primary,
                  size: 20.r,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // Add Button (Icon + Text)
        InkWell(
          onTap: () async {
            final result = await Get.to(
              () => const AddServiceView(),
              binding: AddScreensBinding(),
            );
            if (result == true) {
              controller.refreshServices();
            }
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            height: 50.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: AppColors.white, size: 20.r),
                SizedBox(width: 4.w),
                Text(
                  'add'.tr,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildShimmerLoading();
      }

      final services = controller.filteredServices;
      if (services.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: controller.refreshServices,
        color: AppColors.primary,
        child: ListView.separated(
          padding: EdgeInsets.only(bottom: 20.h),
          itemCount: services.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final service = services[index];
            return RequestCard(
              image: ApiConstant.getFullMediaUrl(service.coverImage),
              date: service.createdAt,
              title: service.title,
              subtitle: '',
              showMoreButton: true,
              onTap: () {
                Get.toNamed(
                  AppRoutes.spServiceDetail,
                  arguments: {'serviceId': service.id},
                );
              },
              onMoreTap: () =>
                  _showServiceOptions(context, service.id, service.title),
            );
          },
        ),
      );
    });
  }

  Widget _buildShimmerLoading() {
    return ListView.separated(
      itemCount: 4,
      padding: EdgeInsets.zero,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return Skeletonizer(
          enabled: true,
          child: Container(
            height: 110.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: ListTile(
              leading: Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              title: Container(
                height: 16.h,
                width: 100.w,
                color: AppColors.lightGrey,
              ),
              subtitle: Container(
                height: 12.h,
                width: 150.w,
                color: AppColors.lightGrey,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final isSearching = controller.searchQuery.isNotEmpty;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.inventory_2_outlined,
            size: 64.r,
            color: AppColors.grey.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            isSearching ? 'noServicesFound'.tr : 'noServicesYet'.tr,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            isSearching ? '' : 'tapToAddService'.tr,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showServiceOptions(
    BuildContext context,
    int serviceId,
    String serviceTitle,
  ) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text('delete'.tr, style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  await _confirmDelete(serviceId, serviceTitle);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(int serviceId, String serviceTitle) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('deleteService'.tr),
        content: Text(
          'deleteServiceConfirmation'.trParams({'title': serviceTitle}),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('delete'.tr, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await controller.deleteServiceApi(serviceId);
        Get.snackbar('success'.tr, 'serviceDeletedSuccessfully'.tr);
      } catch (e) {
        Get.snackbar('error'.tr, 'failedToDeleteService'.tr);
      }
    }
  }
}
