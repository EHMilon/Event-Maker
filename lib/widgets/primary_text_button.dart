import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';

/// A reusable primary text button widget.
class PrimaryTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Color? backgroundColor;
  final bool isLoading;

  const PrimaryTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              else ...[
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (icon != null) ...[SizedBox(width: 8.w), icon!],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
