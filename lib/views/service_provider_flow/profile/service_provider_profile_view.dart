import 'package:event_maker/app_routes.dart';
import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/models/service_provider_profile_model.dart';
import 'package:event_maker/models/service_provider_review_model.dart';
import 'package:event_maker/widgets/services_card.dart';
import 'package:event_maker/widgets/user_avatar.dart';
import 'package:event_maker/views/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceProviderProfileView extends StatefulWidget {
  const ServiceProviderProfileView({super.key});

  @override
  State<ServiceProviderProfileView> createState() =>
      _ServiceProviderProfileViewState();
}

class _ServiceProviderProfileViewState extends State<ServiceProviderProfileView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final controller = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
    _loadProfileData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh profile data when app resumes (user returns to this screen)
    if (state == AppLifecycleState.resumed) {
      _loadProfileData();
    }
  }

  Future<void> _loadProfileData() async {
    await controller.fetchAllProviderData();
  }

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
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => Get.toNamed(AppRoutes.spProfile),
              icon: SvgPicture.asset(
                'assets/images/setting_fill.svg',
                width: 24.r,
                height: 24.r,
                colorFilter: const ColorFilter.mode(
                  AppColors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
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
                            () => UserAvatar(
                              imageUrl: controller.profileImage.value,
                              localFile: controller.selectedProfileImage.value,
                              radius: 50,
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
                          SvgPicture.asset(
                            "assets/icons/star_fill.svg",
                            height: 18.h,
                            width: 18.w,
                          ),
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
          body: TabBarView(children: [_buildAboutTab(), _buildReviewsTab()]),
        ),
      ),
    );
  }

  Widget _buildAboutTab() {
    return Obx(() {
      final profile = controller.providerProfile.value;
      final isLoading = controller.isProfileLoading.value;
      final error = controller.profileError.value;

      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (error.isNotEmpty && profile == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'errorLoadingProfile'.tr,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => controller.fetchProviderProfile(),
                child: Text('retry'.tr),
              ),
            ],
          ),
        );
      }

      if (profile == null) {
        return Center(
          child: Text(
            'noProfileData'.tr,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        );
      }

      return ListView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        children: [
          SizedBox(height: 16.h),
          _buildSectionTitle('certifications'.tr),
          SizedBox(height: 16.h),
          if (profile.certificates.isNotEmpty)
            ...profile.certificates.map(
              (cert) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _buildApiCertificationItem(cert),
              ),
            )
          else
            Text(
              'noCertificates'.tr,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          SizedBox(height: 8.h),
          _buildSectionTitle('bio'.tr),
          SizedBox(height: 12.h),
          Text(
            profile.bio.isNotEmpty ? profile.bio : 'noBio'.tr,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16.h),
          _buildSectionTitle('myServices'.tr),
          SizedBox(height: 16.h),
          SizedBox(
            height: 250.h,
            child: profile.approvedServices.isNotEmpty
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: profile.approvedServices.length,
                    itemBuilder: (context, index) {
                      final service = profile.approvedServices[index];
                      return ServicesCard(
                        imagePath: ApiConstant.getFullMediaUrl(
                          service.coverImage,
                        ),
                        title: service.title,
                        location: service.firstAddress ?? '',
                        price: service.startingPrice,
                        rating: service.ratingValue.toString(),
                        isBookmarked: false,
                        onTap: () {},
                      );
                    },
                  )
                : Center(
                    child: Text(
                      'noServices'.tr,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
          ),
          SizedBox(height: 16.h),
        ],
      );
    });
  }

  Widget _buildReviewsTab() {
    return Obx(() {
      final apiReviews = controller.providerApiReviews;
      final isLoading = controller.isReviewsLoading.value;
      final error = controller.reviewsError.value;

      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (error.isNotEmpty && apiReviews.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'errorLoadingReviews'.tr,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => controller.fetchProviderReviews(),
                child: Text('retry'.tr),
              ),
            ],
          ),
        );
      }

      if (apiReviews.isEmpty) {
        return Center(
          child: Text(
            'noReviews'.tr,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        );
      }

      return ListView.builder(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.all(24.w),
        itemCount: apiReviews.length,
        itemBuilder: (context, index) {
          final review = apiReviews[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: _buildApiReviewCard(review),
          );
        },
      );
    });
  }

  /// Build review card from API model - Matches design: Avatar, Name, 5-star rating, Date, Comment
  Widget _buildApiReviewCard(ServiceProviderReview review) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24.r,
                backgroundImage: review.customer.fullAvatarUrl != null
                    ? NetworkImage(review.customer.fullAvatarUrl!)
                    : null,
                child: review.customer.fullAvatarUrl == null
                    ? Text(
                        review.customer.name.isNotEmpty
                            ? review.customer.name[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 12.w),
              // Name and Rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.customer.name,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    // 5-star rating row
                    Row(
                      children: List.generate(5, (index) {
                        return SvgPicture.asset(
                          "assets/icons/star_fill.svg",
                          height: 18.h,
                          width: 18.w,
                          colorFilter: ColorFilter.mode(
                            index < review.rating
                                ? Colors.amber
                                : AppColors.grey300,
                            BlendMode.srcIn,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              // Date
              Text(
                review.createdAt,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Comment
          Text(
            review.comment,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
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

  Widget _buildApiCertificationItem(ProviderCertificate cert) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                cert.title,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          cert.institute,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          'Issued: ${cert.issueDate}',
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
