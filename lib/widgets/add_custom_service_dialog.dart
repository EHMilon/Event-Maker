import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';

/// Simple dialog for adding a custom option to a dropdown
/// Shows one text field to enter the custom value
class AddCustomServiceDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final Function(String value) onSave;

  const AddCustomServiceDialog({
    super.key,
    required this.title,
    required this.hintText,
    required this.onSave,
  });

  @override
  State<AddCustomServiceDialog> createState() => _AddCustomServiceDialogState();

  /// Show the dialog as a centered popup
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String hintText,
    required Function(String value) onSave,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AddCustomServiceDialog(
        title: title,
        hintText: hintText,
        onSave: onSave,
      ),
    );
  }
}

class _AddCustomServiceDialogState extends State<AddCustomServiceDialog> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                // IconButton(
                //   onPressed: () => Navigator.pop(context),
                //   icon: Icon(Icons.close, color: AppColors.textSecondary),
                // ),
              ],
            ),
            SizedBox(height: 20.h),

            // Text Field
            TextField(
              controller: _textController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.grey.withOpacity(0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.lightGrey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.lightGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              ),
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 24.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.lightGrey.withOpacity(0.3),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleSave() {
    final value = _textController.text.trim();
    if (value.isEmpty) {
      Get.snackbar('Error', 'Please enter a value');
      return;
    }
    widget.onSave(value);
    Navigator.pop(context);
  }
}
