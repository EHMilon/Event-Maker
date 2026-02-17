import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/data/models/service_model.dart';
import 'package:event_maker/shared/widgets/add_options_bottom_sheet.dart';
import 'package:event_maker/views/service_provider_flow/services/service_detail_view.dart';
import 'package:event_maker/views/service_provider_flow/services/services_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ServicesView extends GetView<ServicesController> {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddOptionsBottomSheet.show(context),
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, size: 28.r),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: 20.h),
              _buildSearchRow(),
              SizedBox(height: 20.h),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      'Services',
      style: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.searchController,
            onChanged: controller.search,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              hintText: 'Search...',
              hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
              prefixIcon: Icon(Icons.search, color: AppColors.primary, size: 24.r),
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: AppColors.borderLight),
              ),
            ),
          ),
        ),
        
      ],
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (controller.isLoading.value) {
        return ListView.separated(
          itemCount: 4,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            return Skeletonizer(
              enabled: true,
              child: Container(
                height: 100.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            );
          },
        );
      }

      final services = controller.filteredServices;
      if (services.isEmpty) {
        return Center(
          child: Text(
            'No services found',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
          ),
        );
      }

      return ListView.separated(
        itemCount: services.length,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final service = services[index];
          return ServiceProviderServiceTile(
            service: service,
            onTap: () => Get.to(() => ServiceDetailView(service: service)),
          );
        },
      );
    });
  }
}

class ServiceProviderServiceTile extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const ServiceProviderServiceTile({
    super.key,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = service.images.isNotEmpty ? service.images.first : '';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: imagePath.isNotEmpty
                    ? Image.asset(
                        imagePath,
                        width: 80.w,
                        height: 80.w,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 80.w,
                        height: 80.w,
                        color: AppColors.lightGrey,
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppColors.grey,
                          size: 28.r,
                        ),
                      ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      service.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
