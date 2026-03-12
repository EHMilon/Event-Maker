import 'package:event_maker/core/routes/app_routes.dart';
import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/shared/widgets/review_card.dart';
import 'package:event_maker/shared/widgets/services_card.dart';
import 'package:event_maker/views/service_provider_flow/profile/profile_controller.dart';
import 'package:event_maker/views/service_provider_flow/services/service_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceProviderProfileView extends GetView<ProfileController> {
  const ServiceProviderProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundLight,
          elevation: 0,
          titleSpacing: 24.w,
          title: Text(
            'myProfile'.tr,
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: SvgPicture.asset(
                'assets/images/setting_fill.svg',
                width: 24.r,
                height: 24.r,
                colorFilter: const ColorFilter.mode(
                  AppColors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
              onSelected: (value) {
                if (value == 'settings') {
                  Get.toNamed(AppRoutes.profile);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'settings', child: Text('settings'.tr)),
              ],
            ),
          ],
        ),
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      SizedBox(height: 16.h),
                      Center(
                        child: Container(
                          padding: EdgeInsets.all(3.r),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2.w,
                            ),
                          ),
                          child: Obx(
                            () => CircleAvatar(
                              radius: 50.r,
                              backgroundImage:
                                  controller.profileImage.value.startsWith(
                                    'http',
                                  )
                                  ? NetworkImage(controller.profileImage.value)
                                  : AssetImage(controller.profileImage.value)
                                        as ImageProvider,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Obx(
                        () => Text(
                          controller.userName.value,
                          style: GoogleFonts.inter(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset("assets/icons/star_fill.svg", height: 18.h, width: 18.w,),
                          SizedBox(width: 4.w),
                          Obx(
                            () => Text(
                              controller.rating.value.toString(),
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Obx(
                            () => Text(
                              '(${controller.reviewCount.value})',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  height: 68.h,
                  child: Container(
                    color: AppColors.backgroundLight,
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Center(
                      child: TabBar(
                        
                        // dividerColor: Colors.transparent,
                        dividerHeight: 0,
                        splashFactory: NoSplash.splashFactory,
                        tabAlignment: TabAlignment.center,
                        isScrollable: true,
                        indicatorColor: AppColors.primary,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        labelStyle: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        tabs: [
                          Tab(text: 'about'.tr.toUpperCase()),
                          Tab(text: 'reviews'.tr.toUpperCase()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(children: [_buildAboutTab(), _buildReviewsTab()]
          ),
        ),
        
      ),
    );
  }

  Widget _buildAboutTab() {
    return Obx(
      () => ListView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        children: [
          SizedBox(height: 16.h),
          _buildSectionTitle('certifications'.tr),
          SizedBox(height: 16.h),
          ...controller.certifications
              .map(
                (cert) => Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: _buildCertificationItem(
                    cert['title'] ?? '',
                    cert['date'] ?? '',
                    cert['school'] ?? '',
                  ),
                ),
              )
              .toList(),
          SizedBox(height: 8.h),
          _buildSectionTitle('bio'.tr),
          SizedBox(height: 12.h),
          Text(
            controller.bio.value,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              height: 1.5,
              fontWeight: FontWeight.w500
            ),
          ),
          SizedBox(height: 16.h),
          _buildSectionTitle('myServices'.tr),
          SizedBox(height: 16.h),
          SizedBox(
            height: 250.h,
            child: Obx(
              () => ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.providerServices.length,
                itemBuilder: (context, index) {
                  final service = controller.providerServices[index];
                  return ServicesCard(
                    imagePath: service.images.first,
                    title: service.title,
                    location: service.location,
                    price: service.basePrice?.toString() ?? '0',
                    rating: service.rating?.toString() ?? '0',
                    isBookmarked: service.isBookmarked,
                    onTap: () {
                      Get.to(
                        () => ServiceDetailView(
                          service: service,
                          showEditButton: true,
                        ),
                      );
                    },
                  );
                }, 
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return Obx(
      () => ListView.builder(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.all(24.w),
        itemCount: controller.providerReviews.length,
        itemBuilder: (context, index) {
          final review = controller.providerReviews[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: ReviewCard(review: review, useFullWidth: true),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildCertificationItem(String title, String date, String school) {  
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          date,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          school,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate({required this.child, required this.height});

  final Widget child;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
