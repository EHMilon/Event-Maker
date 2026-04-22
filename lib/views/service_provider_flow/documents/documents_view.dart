import 'package:event_maker/app_routes.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/models/document_model.dart';
import 'package:event_maker/views/service_provider_flow/documents/documents_controller.dart';
import 'package:event_maker/views/service_provider_flow/documents/view_edit_document_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';

class DocumentsView extends GetView<DocumentsController> {
  const DocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'documents'.tr,
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.spAddDocument),
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: Text(
                'add'.tr,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        // Error state
        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState();
        }

        // Loading state
        if (controller.isLoading.value) {
          return _buildLoadingSkeleton();
        }

        // Empty state
        if (controller.documents.isEmpty) {
          return _buildEmptyState();
        }

        // Loaded state
        return RefreshIndicator(
          onRefresh: () => controller.fetchDocuments(),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            itemCount: controller.documents.length,
            itemBuilder: (context, index) {
              final doc = controller.documents[index];
              return _buildDocumentCard(doc);
            },
          ),
        );
      }),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        itemCount: 5,
        itemBuilder: (context, index) {
          return _buildSkeletonCard();
        },
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F5),
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14.h, width: 150.w, color: Colors.grey[300]),
                SizedBox(height: 8.h),
                Container(height: 12.h, width: 80.w, color: Colors.grey[300]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(
              controller.errorMessage.value,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => controller.fetchDocuments(),
              icon: const Icon(Icons.refresh),
              label: Text('retry'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 64.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'noDocuments'.tr,
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'noDocumentsSubtitle'.tr,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.spAddDocument),
              icon: const Icon(Icons.add),
              label: Text('addDocument'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDocumentDetail(DocumentModel doc) {
    Get.to(
      () => ViewEditDocumentView(
        isEdit: false,
        document: doc,
      ),
    );
  }

  Widget _buildDocumentCard(DocumentModel doc) {
    final dateFormatter = DateFormat('MMM dd, yyyy');

    return GestureDetector(
      onTap: () => _openDocumentDetail(doc),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Document icon based on type
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F5),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                doc.isPdf ? Icons.picture_as_pdf : Icons.description_outlined,
                color: doc.isPdf ? Colors.red.shade400 : AppColors.primary,
                size: 24,
              ),
            ),
            SizedBox(width: 16.w),
            // Document details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          doc.title,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${doc.fileExtension} • ${dateFormatter.format(doc.createdAt)}',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Delete button
            // Obx(
            //   () => controller.isDeleting.value
            //       ? const SizedBox(
            //           width: 24,
            //           height: 24,
            //           child: CircularProgressIndicator(strokeWidth: 2),
            //         )
            //       : IconButton(
            //           icon: const Icon(Icons.delete_outline),
            //           color: Colors.red.shade400,
            //           onPressed: () => controller.confirmDelete(doc),
            //         ),
            // ),
          ],
        ),
      ),
    );
  }
}
