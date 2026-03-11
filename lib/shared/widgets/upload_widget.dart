import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/themes/app_colors.dart';

class UploadWidget extends StatefulWidget {
  final String? imagePath;
  final Function(String?) onImageSelected;

  const UploadWidget({
    super.key,
    this.imagePath,
    required this.onImageSelected,
  });

  @override
  State<UploadWidget> createState() => _UploadWidgetState();
}

class _UploadWidgetState extends State<UploadWidget> {
  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _selectedImagePath = widget.imagePath;
  }

  bool _isPickingImage = false;
  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    _isPickingImage = true;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
        widget.onImageSelected(image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    } finally {
      _isPickingImage = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage =
        _selectedImagePath != null && _selectedImagePath!.isNotEmpty;

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 180.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: hasImage ? AppColors.primary : Colors.grey.shade300,
            width: hasImage ? 2 : 1,
            style: BorderStyle.solid,
          ),
        ),
        child: hasImage ? _buildImagePreview() : _buildUploadPlaceholder(),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(11.r),
          child: Image.file(File(_selectedImagePath!), fit: BoxFit.cover),
        ),
        Positioned(
          top: 8.h,
          right: 8.w,
          child: Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.edit, color: Colors.white, size: 18.r),
          ),
        ),
        Positioned(
          bottom: 8.h,
          right: 8.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt, color: Colors.white, size: 14.r),
                SizedBox(width: 4.w),
                Text(
                  'Change',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_upload_outlined, size: 40.sp, color: Colors.grey[400]),
        SizedBox(height: 12.h),
        Text(
          'Upload',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'JPG, PNG or JPEG',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
        ),
      ],
    );
  }
}
