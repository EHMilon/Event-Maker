import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'user_type_controller.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/primary_text_button.dart';

class UserTypeView extends GetView<UserTypeController> {
  const UserTypeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 40.h),
            Image.asset('assets/images/icon.png', height: 40.h),
            SizedBox(height: 20.h),
            Text(
              AppStrings.selectUserType,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111111),
                
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              AppStrings.joinNowToStreamline,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF414141),),
            ),

            SizedBox(height: 40.h),

            // Selection Section
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.w,
                  ), // Increased padding to bring the border closer to the image content
                  child: Column(
                    children: [
                      _imageButton('customer', 'assets/images/as_customer.png'),
                      SizedBox(height: 24.h),
                      _imageButton(
                        'provider',
                        'assets/images/as_service_provider.png',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Continue Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: PrimaryTextButton(
                text: AppStrings.continueText,
                onPressed: controller.onContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageButton(String type, String imagePath) {
    return GestureDetector(
      onTap: () => controller.selectType(type),
      child: Obx(() {
        final isSelected = controller.selectedType.value == type;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 3.w,
            ),
          ),
          // We use Clip.antiAlias to make sure the image follows the border radius
          // If the image asset itself has white space around the "card" graphic,
          // that is where the spacing is coming from.
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset(
              imagePath,
              height: 150,
              // fit:
            ),
          ),
        );
      }),
    );
  }
}
