import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable avatar widget that handles:
/// - Network images (URLs from backend)
/// - Local file images (from image picker)
/// - Placeholder when no image available
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final File? localFile;
  final double radius;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.localFile,
    this.radius = 50,
  });

  @override
  Widget build(BuildContext context) {
    // Show placeholder if no image available
    if (localFile == null && (imageUrl == null || imageUrl!.isEmpty)) {
      return CircleAvatar(
        radius: radius.r,
        backgroundColor: Colors.grey.withOpacity(0.2),
        child: Icon(
          Icons.person,
          size: radius.r * 1.2,
          color: Colors.grey.withOpacity(0.5),
        ),
      );
    }

    final ImageProvider? imageProvider = _getImageProvider();

    if (imageProvider == null) {
      return CircleAvatar(
        radius: radius.r,
        backgroundColor: Colors.grey.withOpacity(0.2),
        child: Icon(
          Icons.person,
          size: radius.r * 1.2,
          color: Colors.grey.withOpacity(0.5),
        ),
      );
    }

    return CircleAvatar(
      radius: radius.r,
      backgroundImage: imageProvider,
      onBackgroundImageError: (exception, stackTrace) {
        debugPrint('Error loading avatar image: $exception');
      },
    );
  }

  ImageProvider? _getImageProvider() {
    // Priority 1: Local file from image picker (most recent selection)
    if (localFile != null) {
      return FileImage(localFile!);
    }

    // Priority 2: Network image from backend
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://')) {
        return NetworkImage(imageUrl!);
      }
    }

    return null;
  }
}
