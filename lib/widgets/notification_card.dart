import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationCard extends StatelessWidget {
  final String name;
  final String action;
  final String detail;
  final String timeAgo;
  final VoidCallback onTap;
  final String avatarAsset;

  const NotificationCard({
    super.key,
    required this.name,
    required this.action,
    required this.detail,
    required this.timeAgo,
    required this.onTap,
    required this.avatarAsset,
  });

  /// Check if the avatar is a network URL
  bool get isNetworkImage =>
      avatarAsset.isNotEmpty &&
      (avatarAsset.startsWith('http://') || avatarAsset.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFF0F0F0), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 52.h,
              width: 52.h,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: avatarAsset.isEmpty
                      ? const Icon(Icons.image, color: Colors.white, size: 24)
                      : isNetworkImage
                          ? Image.network(
                              avatarAsset,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image, color: Colors.white, size: 24),
                            )
                          : Image.asset(
                              avatarAsset,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image, color: Colors.white, size: 24),
                            ),
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '$name ',
                                style: GoogleFonts.inter(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: action,
                                style: GoogleFonts.inter(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF8A8A8A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8.w),
                        child: Text(
                          timeAgo,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF8A8A8A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    detail,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8A8A8A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
