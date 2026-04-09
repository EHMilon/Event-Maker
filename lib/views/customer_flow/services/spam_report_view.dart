import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/services/api_service.dart';
import 'package:event_maker/services/api_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SpamReportView extends StatefulWidget {
  const SpamReportView({
    super.key,
    required this.providerId,
  });

  final int providerId;

  @override
  State<SpamReportView> createState() => _SpamReportViewState();
}

class _SpamReportViewState extends State<SpamReportView> {
  final TextEditingController _detailsController = TextEditingController();
  final List<String> _selectedReasons = [];
  bool _isLoading = false;

  final List<String> _reportReasons = [
    'Scam',
    'Pretending to be someone',
    'Did not appeared on time',
    'Harassment',
    'Hate Speech',
    'Verbal Abuse',
    'Other',
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  void _toggleReason(String reason) {
    setState(() {
      if (_selectedReasons.contains(reason)) {
        _selectedReasons.remove(reason);
      } else {
        _selectedReasons.add(reason);
      }
    });
  }

  Future<void> _submitReport() async {
    if (_selectedReasons.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one reason',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    if (_detailsController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please provide additional details so we can process your report.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final issue = _selectedReasons.join(', ');

      final response = await ApiService().submitProviderReport(
        providerId: widget.providerId,
        issue: issue,
        tellUsMore: _detailsController.text.trim(),
      );

      if (response['success'] == true) {
        Get.back();
        Get.snackbar(
          'Success',
          response['message'] ?? 'Report submitted successfully',
          backgroundColor: AppColors.primary.withOpacity(0.1),
          colorText: AppColors.primary,
        );
      }
    } on ApiException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit report. Please try again.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Spam & Report',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Report an issue section
                  Text(
                    'Report an issue',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Reason chips
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _reportReasons.map((reason) {
                      final isSelected = _selectedReasons.contains(reason);
                      return GestureDetector(
                        onTap: () => _toggleReason(reason),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            reason,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 32.h),

                  // Tell us more section
                  Text(
                    'Tell us more',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Details text field
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey200),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: TextField(
                      controller: _detailsController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Please explain your reason in more detail',
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

                  SizedBox(height: 24.h),

                  // Privacy notice
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'We won\'t let the person know who reported them.\nIf someone is in immediate danger, call local emergency services. Don\'t wait.',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: AppColors.darkGrey,
                        height: 1.5,
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
              onPressed: _isLoading ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
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
