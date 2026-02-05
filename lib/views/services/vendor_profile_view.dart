import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/data/models/service_model.dart';
import 'package:event_maker/shared/widgets/review_card.dart';
import 'package:event_maker/shared/widgets/services_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class VendorProfileView extends StatelessWidget {
  const VendorProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final ServiceProvider? vendor = Get.arguments;

    if (vendor == null) {
      return const Scaffold(body: Center(child: Text('No vendor data found')));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Banner and Profile Header
          SliverAppBar(
            expandedHeight: 280.h,
            leading: Padding(
              padding: EdgeInsets.only(left: 16.w, top: 8.h),
              child: GestureDetector(
                onTap: () => Get.back(),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 20.r,
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 16.w, top: 8.h),
                child: PopupMenuButton<String>(
                  icon: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.black,
                      size: 20.r,
                    ),
                  ),
                  onSelected: (value) {
                    if (value == 'review') {
                      Get.snackbar(
                        'Review',
                        'Leave a review feature coming soon',
                      );
                    } else if (value == 'report') {
                      Get.snackbar('Report', 'Report feature coming soon');
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'review',
                      child: Text('Leave a Review', style: GoogleFonts.inter()),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'report',
                      child: Text(
                        'Spam & Report',
                        style: GoogleFonts.inter(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  vendor.bannerUrl != null
                      ? (vendor.bannerUrl!.startsWith('http')
                            ? Image.network(
                                vendor.bannerUrl!,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(vendor.bannerUrl!, fit: BoxFit.cover))
                      : Container(color: AppColors.primary.withOpacity(0.2)),
                  // Gradient Overlay
                  Container(
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
                  // Profile image overlapping
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Container(
                          width: 100.w,
                          height: 100.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            image: DecorationImage(
                              image: vendor.imageUrl.startsWith('http')
                                  ? NetworkImage(vendor.imageUrl)
                                  : AssetImage(vendor.imageUrl)
                                        as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    vendor.name,
                    style: GoogleFonts.inter(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20.r),
                      SizedBox(width: 4.w),
                      Text(
                        '4.9', // Dummy for now, should come from data
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '(3,657)',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),

                  // Certifications
                  _buildSectionTitle('Certifications'),
                  SizedBox(height: 16.h),
                  ...?vendor.certifications
                      ?.map(
                        (cert) => Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cert,
                                style: GoogleFonts.inter(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Institution Name', // Placeholder if not in data
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  if (vendor.certifications == null ||
                      vendor.certifications!.isEmpty)
                    Text(
                      'No certifications listed',
                      style: GoogleFonts.inter(color: AppColors.textSecondary),
                    ),

                  SizedBox(height: 32.h),

                  // Bio
                  _buildSectionTitle('Bio'),
                  SizedBox(height: 12.h),
                  Text(
                    vendor.bio ?? 'No bio available',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
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
                          onTap: () {
                            // Navigate back to detail or show another detail
                            Get.snackbar(
                              'Service',
                              'Navigating to ${service.title}',
                            );
                          },
                        );
                      },
                    ),
                  ),
                  if (vendor.services == null || vendor.services!.isEmpty)
                    Text(
                      'No services listed',
                      style: GoogleFonts.inter(color: AppColors.textSecondary),
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
                      style: GoogleFonts.inter(color: AppColors.textSecondary),
                    ),

                  SizedBox(height: 50.h),
                ],
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
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
