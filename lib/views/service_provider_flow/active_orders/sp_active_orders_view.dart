import 'package:event_maker/shared/widgets/order_card.dart';
import 'package:event_maker/views/service_provider_flow/active_orders/sp_service_orders_view.dart';
import 'package:event_maker/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SPActiveOrdersView extends StatelessWidget {
  const SPActiveOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> titles = [
      'Catering services for home event',
      'Catering services for home event',
      'Outdoor party catering services',
      'Corporate inhouse event managment',
      'Birthday party catering',
      'Wedding reception setup',
    ];
    final List<int> badges = [2, 2, 5, 1, 3, 4];

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
          'Active Orders',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              children: List.generate(
                titles.length,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: OrderCard(
                    title: titles[index % titles.length],
                    imageUrl: 'https://picsum.photos/id/${index + 40}/120/120',
                    badgeCount: badges[index % badges.length],
                    onTap: () => Get.to(
                      () => SPServiceOrdersView(
                        serviceTitle: titles[index % titles.length],
                        orderCount: badges[index % badges.length],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
