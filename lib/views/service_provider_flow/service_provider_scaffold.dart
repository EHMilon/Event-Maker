import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/views/service_provider_flow/home/sp_home_view.dart';
import 'package:event_maker/views/service_provider_flow/service_provider_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:event_maker/views/profile/profile_view.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceProviderScaffold extends GetView<ServiceProviderController> {
  const ServiceProviderScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const SPHomeView(),
      const Center(child: Text('Requests')),
      const Center(child: Text('Services')),
      const ProfileView(),
    ];

    return Scaffold(
      body: Obx(
        () => IndexedStack(index: controller.selectedIndex, children: pages),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: controller.selectedIndex,
            onTap: controller.changeIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: const Color(0xFFB0B0C3),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
            items: [
              _buildBottomNavItem(
                iconPath: 'assets/icons/home.svg',
                label: 'Home',
                index: 0,
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/notification.svg',
                      height: 24.h,
                      colorFilter: ColorFilter.mode(
                        controller.selectedIndex == 1
                            ? AppColors.primary
                            : const Color(0xFFB0B0C3),
                        BlendMode.srcIn,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        height: 8.h,
                        width: 8.h,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                label: 'Requests',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.settings_outlined,
                  size: 24.h,
                  color: controller.selectedIndex == 2
                      ? AppColors.primary
                      : const Color(0xFFB0B0C3),
                ),
                label: 'Services',
              ),
              _buildBottomNavItem(
                iconPath: 'assets/icons/profile.svg',
                label: 'Profile',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem({
    required String iconPath,
    required String label,
    required int index,
  }) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: EdgeInsets.only(bottom: 4.h),
        child: SvgPicture.asset(
          iconPath,
          height: 24.h,
          colorFilter: ColorFilter.mode(
            controller.selectedIndex == index
                ? AppColors.primary
                : const Color(0xFFB0B0C3),
            BlendMode.srcIn,
          ),
        ),
      ),
      label: label,
    );
  }
}
