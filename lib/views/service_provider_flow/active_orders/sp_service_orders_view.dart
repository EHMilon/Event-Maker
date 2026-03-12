import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/views/service_provider_flow/services/service_detail_view.dart';
import 'package:event_maker/data/models/service_model.dart';

class SPServiceOrdersView extends StatelessWidget {
  final String serviceTitle;
  final int orderCount;
  const SPServiceOrdersView({
    super.key,
    required this.serviceTitle,
    this.orderCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFBFE),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Text(
          'Orders',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 9.w,
            mainAxisSpacing: 12.h,
            mainAxisExtent: 240.h,
          ),
          itemCount: orderCount,
          itemBuilder: (context, index) {
            return _buildOrderCard(index);
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(int index) {
    return GestureDetector(
      onTap: () {
        // Mocking ServiceModel from order details to reuse ServiceDetailView
        final mockService = ServiceModel(
          id: 'mock_id_$index',
          title: 'Elite Event Photography',
          description:
              'Capturing your special moments with artistic precision and creativity. We specialize in event photography with over 8 years of experience documenting weddings, corporate events, and celebrations.',
          images: ['https://picsum.photos/id/${index + 50}/300/200'],
          type: ServiceType.photography,
          provider: ServiceProvider(
            name: 'Jenny Smith',
            role: 'Caterer',
            imageUrl:
                'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000&auto=format&fit=crop',
            isVerified: true,
          ),
          location:
              'Airport Rd - Al Manhal - W14 02 - Abu Dhabi - United Arab Emirates',
          rating: 4.8,
          reviewCount: 120,
          basePrice: 46,
        );
        Get.to(() => ServiceDetailView(service: mockService, isOrder: true));
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFF1F1F5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: Image.network(
                'https://picsum.photos/id/${index + 50}/300/200',
                height: 110.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Title
                  Text(
                    serviceTitle,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  // Time and Date
                  Row(
                    children: [
                      SvgPicture.asset("assets/icons/service.svg"),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          '8PM - 11PM, 21 Nov',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  // Divider
                  const Divider(height: 1, color: Color(0xFFF1F1F5)),
                  SizedBox(height: 10.h),
                  // Customer Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14.r,
                        backgroundImage: const NetworkImage(
                            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000&auto=format&fit=crop'),
                            
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jenny Smith',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Jenny@gmail.com',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
