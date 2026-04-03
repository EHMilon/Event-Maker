import 'dart:io';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/models/document_model.dart';
import 'package:event_maker/views/service_provider_flow/documents/documents_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewEditDocumentView extends StatefulWidget {
  final bool isEdit;
  final DocumentModel? document;

  const ViewEditDocumentView({super.key, this.isEdit = false, this.document});

  @override
  State<ViewEditDocumentView> createState() => _ViewEditDocumentViewState();
}

class _ViewEditDocumentViewState extends State<ViewEditDocumentView> {
  final DocumentsController controller = Get.find<DocumentsController>();

  @override
  void initState() {
    super.initState();
    // Initialize controller fields after first frame to avoid setState during build
    if (widget.document != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.prepareEdit(widget.document!);
      });
    }
  }

  @override
  void dispose() {
    // Don't call clearFields here - it triggers setState during dispose
    // Fields are cleared when preparing a new edit or going back
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            controller.clearFields();
            Get.back();
          },
        ),
        title: Text(
          widget.isEdit ? 'editDocument'.tr : 'viewDocument'.tr,
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Document Preview Area
                  GestureDetector(
                    onTap: widget.isEdit ? () => controller.pickDocument() : null,
                    child: Obx(
                      () => Container(
                        width: double.infinity,
                        height: 250.h,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.lightGrey,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: _buildDocumentPreview(),
                      ),
                    ),
                  ),
                  if (widget.isEdit) ...[
                    SizedBox(height: 8.h),
                    Center(
                      child: Text(
                        'tapToChangeFile'.tr,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 32.h),

                  // Document details in view mode
                  if (!widget.isEdit) ...[
                    _buildDetailRow('status'.tr, widget.document?.status ?? ''),
                    if (widget.document?.createdAt != null)
                      _buildDetailRow(
                        'createdAt'.tr,
                        _formatDate(widget.document!.createdAt),
                      ),
                    if (widget.document?.updatedAt != null)
                      _buildDetailRow(
                        'updatedAt'.tr,
                        _formatDate(widget.document!.updatedAt),
                      ),
                    SizedBox(height: 24.h),
                  ],

                  // Title Field (editable in edit mode)
                  _buildInputField(
                    'documentTitle'.tr,
                    'enterDocumentTitle'.tr,
                    controller.titleController,
                    readOnly: !widget.isEdit,
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),

          // Action Buttons - Fixed at bottom
          widget.isEdit ? _buildEditActions() : _buildViewActions(),
        ],
      ),
    );
  }

  Widget _buildDocumentPreview() {
    // If a new file is selected (edit mode)
    if (controller.selectedFile.value != null) {
      return _buildFilePreview(
        controller.selectedFile.value!,
        isLocalFile: true,
      );
    }

    // If viewing existing document
    if (widget.document != null && widget.document!.file.isNotEmpty) {
      if (widget.document!.isPdf) {
        return _buildPdfPreview(widget.document!.file);
      } else if (widget.document!.isImage) {
        return _buildImagePreview(widget.document!.file);
      } else {
        return _buildGenericFilePreview(widget.document!.file);
      }
    }

    // Empty state
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_upload_outlined,
          size: 40.sp,
          color: AppColors.textSecondary.withValues(alpha: 0.5),
        ),
        SizedBox(height: 8.h),
        Text(
          widget.isEdit ? 'upload'.tr : 'noDocumentPreview'.tr,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        if (widget.isEdit)
          Text(
            'PDF, DOC, DOCX, PNG, JPG',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }

  Widget _buildFilePreview(dynamic file, {bool isLocalFile = false}) {
    final String fileName = isLocalFile
        ? (file.path as String).split('/').last
        : (file as String).split('/').last;
    final bool isPdf = fileName.toLowerCase().endsWith('.pdf');
    final bool isImage = fileName.toLowerCase().contains(
      RegExp(r'\.(png|jpg|jpeg)$'),
    );

    if (isImage) {
      if (isLocalFile) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.file(file as File, fit: BoxFit.contain),
        );
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.network(
            controller.getDocumentUrl(file as String),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                _buildErrorPlaceholder('Image not available'),
          ),
        );
      }
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
            size: 64.sp,
            color: isPdf ? Colors.red : AppColors.primary,
          ),
          SizedBox(height: 12.h),
          Text(
            fileName,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          if (isPdf)
            Text(
              'PDF Document',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      );
    }
  }

  Widget _buildImagePreview(String filePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Image.network(
        controller.getDocumentUrl(filePath),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            _buildErrorPlaceholder('Image preview not available'),
      ),
    );
  }

  Widget _buildPdfPreview(String filePath) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.picture_as_pdf, size: 80.sp, color: Colors.red),
        SizedBox(height: 16.h),
        Text(
          widget.document?.title ?? 'Document',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'PDF Document',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 16.h),
        OutlinedButton.icon(
          onPressed: () => _openFile(filePath),
          icon: const Icon(Icons.open_in_new),
          label: Text('openDocument'.tr),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenericFilePreview(String filePath) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.description_outlined, size: 80.sp, color: AppColors.primary),
        SizedBox(height: 16.h),
        Text(
          widget.document?.title ?? 'Document',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        OutlinedButton.icon(
          onPressed: () => _openFile(filePath),
          icon: const Icon(Icons.open_in_new),
          label: Text('viewDocument'.tr),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorPlaceholder(String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 48.sp,
          color: Colors.red.withValues(alpha: 0.5),
        ),
        SizedBox(height: 8.h),
        Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController textController, {
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: textController,
          readOnly: readOnly,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
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
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            filled: !readOnly,
            fillColor: readOnly ? AppColors.backgroundLight : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildViewActions() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: () {
            // Navigate to edit mode
            Get.back();
            Get.to(
              () => ViewEditDocumentView(isEdit: true, document: widget.document),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            'edit'.tr,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditActions() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: Obx(
          () => ElevatedButton(
            onPressed: controller.isUploading.value
                ? null
                : () => controller.updateDocument(
                    widget.document!.id,
                    controller.titleController.text,
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: controller.isUploading.value
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : Text(
                    'update'.tr,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _openFile(String filePath) {
    final url = controller.getDocumentUrl(filePath);
    Get.snackbar(
      'info'.tr,
      'Opening document: $url',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
