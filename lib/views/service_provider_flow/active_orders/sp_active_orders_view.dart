import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:event_maker/core/themes/app_colors.dart';

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
          style: GoogleFonts.inter(fontSize: 20.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            children: List.generate(
              titles.length,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _buildOrderCard(index, titles, badges),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(int index, List<String> titles, List<int> badges) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network('https://picsum.photos/id/${index + 40}/120/120', width: 64.w, height: 64.h, fit: BoxFit.cover),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              titles[index % titles.length],
              style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.4),
            ),
          ),
          Container(
            height: 24.h,
            width: 24.h,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Color(0xFFB485FF), shape: BoxShape.circle),
            child: Text(
              '${badges[index % badges.length]}',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
