import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../widgets/primary_text_button.dart';
import 'auth_controller.dart';

class GetStartedView extends GetView {
  const GetStartedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/get_started.png',
              fit: BoxFit.cover,
            ),
          ),
          // Get Started Button at bottom
          Positioned(
            left: 24.w,
            right: 24.w,
            bottom: 50.h,
            child: PrimaryTextButton(
              text: "GET STARTED",
              onPressed: controller.onGetStarted,
              icon: Icon(Icons.arrow_forward, color: Colors.white, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }
}
