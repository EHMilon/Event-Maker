import 'package:event_maker/views/customer_flow/map/map_results_binding.dart';
import 'package:event_maker/views/customer_flow/map/map_results_view.dart';
import 'package:event_maker/widgets/services_card.dart';
import 'package:event_maker/views/customer_flow/services/service_detail_view.dart';
import 'package:event_maker/views/customer_flow/services/services_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ServicesView extends GetView<ServicesController> {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    // If controller is not registered (e.g. reused in another tab), ensure it exists.
    // However, usually Binding handles this.

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Services',
          style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined, color: Colors.black),
            onPressed: () => Get.to(() => const MapResultsView(), binding: MapResultsBinding(), transition: Transition.fadeIn),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Skeletonizer(
              enabled: true,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return ServicesCard(
                    imagePath: 'assets/images/cooking.png', // Placeholder for skeleton
                    title: 'Service Title',
                    location: 'Location',
                    price: '100',
                    rating: '4.5',
                    isBookmarked: false,
                    onTap: () {},
                  );
                },
              ),
            );
          }

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 16.w, mainAxisSpacing: 16.h),
            itemCount: controller.services.length,
            itemBuilder: (context, index) {
              final service = controller.services[index];
              return ServicesCard(
                imagePath: service.images.isNotEmpty ? service.images.first : '',
                title: service.title,
                location: service.location,
                price: '${service.basePrice?.toInt() ?? 0} ${service.priceUnit}',
                rating: service.rating?.toString() ?? 'N/A',
                isBookmarked: service.isBookmarked,
                onTap: () {
                  Get.to(() => ServiceDetailView(service: service));
                },
              );
            },
          );
        }),
      ),
    );
  }
}
