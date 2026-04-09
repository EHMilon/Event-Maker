import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/models/certification_model.dart';
import 'package:event_maker/services/api_exception.dart';
import 'package:event_maker/services/certification_repository.dart';
import 'package:event_maker/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// View for displaying provider certificates in a list with expandable details
/// API: api/providers/provider-certificates?provider_id={id}
class ViewCertificate extends StatefulWidget {
  /// Provider ID to fetch certificates for
  final int providerId;

  const ViewCertificate({
    super.key,
    required this.providerId,
  });

  @override
  State<ViewCertificate> createState() => _ViewCertificateState();
}

class _ViewCertificateState extends State<ViewCertificate> {
  final CertificationRepository _repository = CertificationRepository();
  List<CertificationModel> _certificates = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCertificates();
  }

  /// Fetch certificates from API
  Future<void> _fetchCertificates() async {
    Log.d('ViewCertificate: Fetching certificates for provider ${widget.providerId}');
    
    if (widget.providerId <= 0) {
      Log.e('ViewCertificate: Invalid providerId: ${widget.providerId}');
      setState(() {
        _errorMessage = 'Invalid provider ID';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _repository.fetchProviderCertifications(
        widget.providerId,
      );
      Log.d('ViewCertificate: Received ${response.data.length} certificates');
      setState(() {
        _certificates = response.data;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      Log.e('ViewCertificate: ApiException - ${e.message}');
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      Log.e('ViewCertificate: Unexpected error - $e');
      Log.e('ViewCertificate: StackTrace - $stackTrace');
      setState(() {
        _errorMessage = 'Failed to load certificates: $e';
        _isLoading = false;
      });
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
          'View Certificates',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  /// Build main body based on state
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_certificates.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _certificates.length,
      itemBuilder: (context, index) {
        return _CertificateCard(
          certificate: _certificates[index],
        );
      },
    );
  }

  /// Build loading state
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.r,
            color: Colors.red.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            _errorMessage!,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _fetchCertificates,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Build empty state when no certificates available
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified_outlined,
            size: 64.r,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            'No certificates found',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual certificate card with expandable details
class _CertificateCard extends StatefulWidget {
  final CertificationModel certificate;

  const _CertificateCard({
    required this.certificate,
  });

  @override
  State<_CertificateCard> createState() => _CertificateCardState();
}

class _CertificateCardState extends State<_CertificateCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final cert = widget.certificate;

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          // Certificate Image (Always visible)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              width: double.infinity,
              height: 180.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(12.r),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(12.r),
                ),
                child: _buildCertificateImage(cert),
              ),
            ),
          ),

          // Expandable Details Section
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(12.r),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Document Title
                        _buildInfoRow(
                          label: 'Document Title',
                          value: cert.title,
                          icon: Icons.description_outlined,
                        ),
                        SizedBox(height: 16.h),

                        // Institute
                        _buildInfoRow(
                          label: 'Institute',
                          value: cert.institute,
                          icon: Icons.school_outlined,
                        ),
                        SizedBox(height: 16.h),

                        // Passing Year
                        _buildInfoRow(
                          label: 'Passing Year',
                          value: cert.formattedIssueDate,
                          icon: Icons.calendar_today_outlined,
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Expand/Collapse Indicator Button
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: _isExpanded ? Colors.grey.shade50 : Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isExpanded ? 'Show Less' : 'Show Details',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 20.r,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build certificate image widget (handles network/asset images)
  Widget _buildCertificateImage(CertificationModel cert) {
    // Use ApiConstant helper to get full media URL
    final String imageUrl = ApiConstant.getFullMediaUrl(cert.file);

    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.fitHeight,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey.shade200,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder();
        },
      );
    } else {
      // Fallback to asset image
      return Image.asset(
        cert.file.isNotEmpty ? cert.file : 'assets/images/certificate.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder();
        },
      );
    }
  }

  /// Build error placeholder for failed image loads
  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 48.r,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 8.h),
            Text(
              'Certificate unavailable',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build info row for certificate details
  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            size: 20.r,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value.isNotEmpty ? value : 'N/A',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
