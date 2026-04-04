// NOTE: This file is deprecated. Admin chat functionality is now handled
// through ChatDetailView with isAdminChat flag.
// This file can be removed once route configuration is updated.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/app_routes.dart';

/// AdminChatView is deprecated. Use ChatDetailView with isAdminChat flag instead.
/// This screen redirects to ChatDetailView for admin chat functionality.
@Deprecated('Use ChatDetailView with isAdminChat flag instead')
class AdminChatView extends StatelessWidget {
  const AdminChatView({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to ChatDetailView with admin context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offNamed(
        AppRoutes.chatDetail,
        arguments: {
          'id': 'admin-1',
          'name': 'EventMaker Admin',
          'image': 'assets/images/person.jpg',
          'isAdmin': true,
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
