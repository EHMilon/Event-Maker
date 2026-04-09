import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/services/api_result.dart';
import 'package:event_maker/services/review_repository.dart';
import 'package:event_maker/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Helper widget to build vendor logo with error handling
Widget _buildVendorLogo(String? vendorLogo, String vendorName) {
  // If no logo provided, show initials
  if (vendorLogo == null || vendorLogo.isEmpty) {
    return _buildVendorInitials(vendorName);
  }

  // Get full URL for relative paths
  final imageUrl = ApiConstant.getFullMediaUrl(vendorLogo);

  // If it's a network image
  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to initials on error
          return _buildVendorInitials(vendorName);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }

  // If it's an asset image
  try {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildVendorInitials(vendorName);
        },
      ),
    );
  } catch (e) {
    return _buildVendorInitials(vendorName);
  }
}

/// Build vendor initials fallback widget
Widget _buildVendorInitials(String vendorName) {
  final initials = vendorName.isNotEmpty
      ? vendorName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('').toUpperCase()
      : 'V';

  return Center(
    child: Text(
      initials.length > 2 ? initials.substring(0, 2) : initials,
      style: GoogleFonts.inter(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
  );
}

class AddReviewView extends StatefulWidget {
  const AddReviewView({super.key});

  @override
  State<AddReviewView> createState() => _AddReviewViewState();
}

class _AddReviewViewState extends State<AddReviewView> {
  final TextEditingController _reviewController = TextEditingController();
  final ReviewRepository _reviewRepository = ReviewRepository();
  
  int _rating = 0;
  int? _serviceId;
  int? _existingReviewId;
  bool _isLoading = false;
  bool _isCheckingExisting = true;
  String? _errorMessage;
  DateTime? _canUpdateUntil;

  @override
  void initState() {
    super.initState();
    _loadExistingReview();
  }

  /// Fetch existing review when view loads
  Future<void> _loadExistingReview() async {
    final args = Get.arguments;
    final serviceId = (args is Map<String, dynamic> ? args['serviceId'] : null) as int?;
    
    if (serviceId == null) {
      setState(() {
        _isCheckingExisting = false;
        _errorMessage = 'Invalid service ID';
      });
      return;
    }

    _serviceId = serviceId;

    final result = await _reviewRepository.getReviewDetail(serviceId);
    
    if (mounted) {
      setState(() {
        _isCheckingExisting = false;
      });

      switch (result) {
        case Success<Map<String, dynamic>>(data: final data):
          // Check if we got actual review data
          if (data.isNotEmpty && data['review_id'] != null) {
            setState(() {
              _existingReviewId = data['review_id'] as int?;
              _rating = (data['rating'] as num?)?.toInt() ?? 0;
              _reviewController.text = (data['comment'] as String?) ?? '';
              
              // Parse can_update_until if available
              final canUpdateStr = data['can_update_until'] as String?;
              if (canUpdateStr != null) {
                _canUpdateUntil = DateTime.tryParse(canUpdateStr);
              }
            });
            
          }
        case Error<Map<String, dynamic>>(message: final message):
          // No existing review - that's fine, user can create new one
          Log.d('No existing review found: $message');
        case Loading<Map<String, dynamic>>():
          break;
      }
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      Get.snackbar(
        'Error',
        'Please select a rating',
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please write a review',
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
      return;
    }

    if (_serviceId == null) {
      Get.snackbar(
        'Error',
        'Invalid service ID',
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final Result<Map<String, dynamic>> result;
    
    // Check if we're updating or creating
    if (_existingReviewId != null) {
      // Update existing review
      result = await _reviewRepository.updateReview(
        serviceId: _serviceId!,
        rating: _rating,
        comment: _reviewController.text.trim(),
      );
    } else {
      // Create new review
      result = await _reviewRepository.submitReview(
        serviceId: _serviceId!,
        rating: _rating,
        comment: _reviewController.text.trim(),
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      switch (result) {
        case Success<Map<String, dynamic>>(data: final data):
          Get.back();
          Get.snackbar(
            'Success',
            _existingReviewId != null 
                ? 'Review updated successfully' 
                : 'Review submitted successfully',
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            colorText: AppColors.primary,
          );
        case Error<Map<String, dynamic>>(message: final message):
          Get.snackbar(
            'Error',
            message,
            backgroundColor: Colors.red.withValues(alpha: 0.1),
            colorText: Colors.red,
          );
        case Loading<Map<String, dynamic>>():
          break;
      }
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get vendor data from arguments if available
    // Using safe navigation to handle null arguments
    final args = Get.arguments;
    final vendorName = (args is Map<String, dynamic> ? args['vendorName'] : null) as String? ?? 'Vendor';
    final vendorLogo = (args is Map<String, dynamic> ? args['vendorLogo'] : null) as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          _existingReviewId != null ? 'Update Review' : 'Add a review',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Vendor Logo
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _buildVendorLogo(vendorLogo, vendorName),
                  ),

                  SizedBox(height: 16.h),

                  // Vendor Name
                  Text(
                    vendorName,
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // Star Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final isSelected = index < _rating;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                        child: SvgPicture.asset(
                          'assets/icons/star_fill.svg',
                          width: 30.r,
                          height: 30.r,
                          colorFilter: ColorFilter.mode(
                            isSelected ? Colors.orange : AppColors.lightGrey,
                            BlendMode.srcIn,
                          ),
                          semanticsLabel: 'Rating star ${index + 1}',
                        ),
                      );
                    }),
                  ),

                  SizedBox(height: 32.h),

                  // Question
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _existingReviewId != null 
                          ? 'Update your review'
                          : 'What did you enjoy the most?',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Review Text Field
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: TextField(
                      controller: _reviewController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText:
                            'Any special requirements or notes for the service provider...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Submit button
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: _isLoading || _isCheckingExisting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _existingReviewId != null ? 'Update Review' : 'Submit',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
