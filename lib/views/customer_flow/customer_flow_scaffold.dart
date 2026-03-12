import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/views/customer_flow/customer_flow_controller.dart';
import 'package:event_maker/views/customer_flow/home/home_view.dart';
import 'package:event_maker/views/customer_flow/map/map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:event_maker/views/service_provider_flow/profile/profile_view.dart';
import 'package:event_maker/views/customer_flow/requests/customer_requests_view.dart';
import 'package:event_maker/views/chats/chat_view.dart';

class CustomerFlowScaffold extends GetView<CustomerFlowController> {
  const CustomerFlowScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeView(),
      const MapView(),
      const ChatView(isServiceProvider: false),
      const CustomerRequestsView(),
      const ProfileView(),
    ];

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.selectedIndex.value,
          children: pages,
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
          ),
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/home.svg',
                height: 24.h,
                colorFilter: ColorFilter.mode(
                  controller.selectedIndex.value == 0
                      ? AppColors.primary
                      : AppColors.grey500,
                  BlendMode.srcIn,
                ),
              ),
              label: 'home'.tr,
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/map.svg',
                height: 24.h,
                colorFilter: ColorFilter.mode(
                  controller.selectedIndex.value == 1
                      ? AppColors.primary
                      : AppColors.grey500,
                  BlendMode.srcIn,
                ),
              ),
              label: 'map'.tr,
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/chat.svg',
                height: 24.h,
                colorFilter: ColorFilter.mode(
                  controller.selectedIndex.value == 2
                      ? AppColors.primary
                      : AppColors.grey,
                  BlendMode.srcIn,
                ),
              ),
              label: 'chats'.tr,
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/booking.svg',
                height: 24.h,
                colorFilter: ColorFilter.mode(
                  controller.selectedIndex.value == 3
                      ? AppColors.primary
                      : AppColors.grey,
                  BlendMode.srcIn,
                ),
              ),
              label: 'bookings'.tr,
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/profile.svg',
                height: 24.h,
                colorFilter: ColorFilter.mode(
                  controller.selectedIndex.value == 4
                      ? AppColors.primary
                      : AppColors.grey,
                  BlendMode.srcIn,
                ),
              ),
              label: 'profile'.tr,
            ),
          ],
        ),
      ),
    );
  }
}
