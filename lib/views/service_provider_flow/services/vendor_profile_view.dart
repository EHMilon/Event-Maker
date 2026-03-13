import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/data/models/vendor_profile_model.dart';
import 'package:event_maker/shared/widgets/review_card.dart';
import 'package:event_maker/shared/widgets/services_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:event_maker/views/service_provider_flow/services_details/service_detail_view.dart'
    as sp;

class VendorProfileView extends StatelessWidget {
  final VendorProfileModel vendor;

  const VendorProfileView({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        // Main Stack to allow fixed elements (buttons) and a scrollable CustomScrollView
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none, // Allows children to paint outside
                  children: [
                    // Banner Image (behind everything else in this stack)
                    SizedBox(
                      height: 200.h,
                      width: double.infinity,
                      child: vendor.bannerUrl != null
                          ? (vendor.bannerUrl!.startsWith('http')
                                ? Image.network(
                                    vendor.bannerUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    vendor.bannerUrl!,
                                    fit: BoxFit.cover,
                                  ))
                          : Container(
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                    ),
                    // Gradient Overlay (on top of banner image, but below profile)
                    Container(
                      height: 200.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Profile Image (on top of banner and gradient in this stack)
                    Positioned(
                      top: 150
                          .h, // Position at 200.h (banner bottom) - 50.h (half profile height)
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 100.w,
                          height: 100.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            image: DecorationImage(
                              image:
                                  vendor.provider.imageUrl.startsWith(
                                        'http://',
                                      ) ||
                                      vendor.provider.imageUrl.startsWith(
                                        'https://',
                                      )
                                  ? NetworkImage(vendor.provider.imageUrl)
                                  : AssetImage(vendor.provider.imageUrl)
                                        as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Spacer for content below profile (to push content down)
                    SizedBox(height: 250.h), // Banner (200) + Half Profile (50)
                  ],
                ),
              ),
              // Actual content starts here
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      // This SizedBox ensures the content starts *after* the bottom half of the profile image
                      // It aligns the content properly relative to the profile picture's bottom edge.
                      Text(
                        vendor.name,
                        style: GoogleFonts.inter(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/icons/star_fill.svg",
                            height: 20.h,
                            width: 20.w,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '4.9', // Dummy for now, should come from data
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '(3,657)',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32.h),

                      // Certifications
                      _buildSectionTitle('Certifications'),
                      SizedBox(height: 16.h),
                      ...?vendor.certifications?.map(
                        (cert) => Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cert,
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Institution Name', // Placeholder if not in data
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    color: AppColors.darkGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (vendor.certifications == null ||
                          vendor.certifications!.isEmpty)
                        Text(
                          'No certifications listed',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                          ),
                        ),

                      SizedBox(height: 18.h),

                      // Bio
                      _buildSectionTitle('Bio'),
                      SizedBox(height: 12.h),
                      Text(
                        vendor.bio ?? 'No bio available',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.darkGrey,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 32.h),

                      // Vendor's Services
                      _buildSectionTitle('${vendor.name}\'s Services'),
                      SizedBox(height: 16.h),
                      SizedBox(
                        height: 230.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: vendor.services?.length ?? 0,
                          itemBuilder: (context, index) {
                            final service = vendor.services![index];
                            return ServicesCard(
                              imagePath: service.images.isNotEmpty
                                  ? service.images.first
                                  : '',
                              title: service.title,
                              location: service.location,
                              price: service.basePrice?.toString() ?? '0',
                              rating: service.rating?.toString() ?? '0',
                              isBookmarked: service.isBookmarked,
                              onTap: () {
                                Get.to(
                                  () => sp.ServiceDetailView(
                                    service: service,
                                    showEditButton: true,
                                    hideActionButtons: true,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      if (vendor.services == null || vendor.services!.isEmpty)
                        Text(
                          'No services listed',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                          ),
                        ),

                      SizedBox(height: 32.h),

                      // Reviews
                      _buildSectionTitle('Reviews'),
                      SizedBox(height: 16.h),
                      SizedBox(
                        height: 120.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: vendor.reviews?.length ?? 0,
                          itemBuilder: (context, index) {
                            final review = vendor.reviews![index];
                            return ReviewCard(review: review);
                          },
                        ),
                      ),
                      if (vendor.reviews == null || vendor.reviews!.isEmpty)
                        Text(
                          'No reviews yet',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                          ),
                        ),

                      SizedBox(height: 50.h),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Back button
          Positioned(
            top: 40.h,
            left: 16.w,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.arrow_back, color: Colors.black, size: 20.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 20.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
