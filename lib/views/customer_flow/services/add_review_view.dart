import 'package:event_maker/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AddReviewView extends StatefulWidget {
  const AddReviewView({super.key});

  @override
  State<AddReviewView> createState() => _AddReviewViewState();
}

class _AddReviewViewState extends State<AddReviewView> {
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_rating == 0) {
      Get.snackbar(
        'Error',
        'Please select a rating',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please write a review',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    // TODO: Implement backend integration for submitting review
    Get.back();
    Get.snackbar(
      'Success',
      'Review submitted successfully',
      backgroundColor: AppColors.primary.withOpacity(0.1),
      colorText: AppColors.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get vendor data from arguments if available
    final vendorName = Get.arguments?['vendorName'] ?? 'Artcell';
    final vendorLogo = Get.arguments?['vendorLogo'];

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
          'Add a review',
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
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: vendorLogo != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: vendorLogo.startsWith('http')
                                ? Image.network(vendorLogo, fit: BoxFit.cover)
                                : Image.asset(vendorLogo, fit: BoxFit.cover),
                          )
                        : Center(
                            child: Text(
                              'ARTCELL',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
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
                          color: isSelected
                              ? Colors.orange
                              : AppColors.lightGrey,
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
                      'What did you enjoy the most?',
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
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Submit',
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
