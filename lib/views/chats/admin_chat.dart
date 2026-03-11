import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:event_maker/core/themes/app_colors.dart';

/// TODO: Integrate AdminChatView with real admin chat backend API
/// This screen is opened when service provider taps on an admin chat item.
class AdminChatView extends StatelessWidget {
  const AdminChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          'admin'.tr,
          style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 20.sp, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      // TODO: Replace placeholder with pixel-perfect Figma-based admin chat UI
      body: Center(
        child: Text(
          'Admin chat screen',
          style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14.sp, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}
