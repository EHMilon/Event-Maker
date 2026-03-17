import 'package:event_maker/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Color scheme for sub-category items
/// Cycles through 3 color schemes based on index
class _CategoryColorScheme {
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;

  const _CategoryColorScheme({
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
  });
}

class CategoryItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;

  // Color schemes that cycle through items (item 4 == item 1)
  static const List<_CategoryColorScheme> _colorSchemes = [
    // Item 1: Blue theme
    _CategoryColorScheme(
      textColor: Color(0xFF0F449A),
      backgroundColor: Color(0xFFE2EDFF),
      borderColor: Color(0xFFD0E0FB),
    ),
    // Item 2: Purple theme
    _CategoryColorScheme(
      textColor: Color(0xFF54098D),
      backgroundColor: Color(0xFFF5E8FF),
      borderColor: Color(0xFFF0DCFF),
    ),
    // Item 3: Green theme
    _CategoryColorScheme(
      textColor: Color(0xFF008759),
      backgroundColor: Color(0xFFD9FFF2),
      borderColor: Color(0xFFC5FFEB),
    ),
  ];

  const CategoryItem({
    super.key,
    required this.label,
    this.isSelected = false,
    required this.onTap,
    this.index = 0,
  });

  /// Get color scheme based on index (cycles every 3 items)
  _CategoryColorScheme get _colorScheme =>
      _colorSchemes[index % _colorSchemes.length];

  @override
  Widget build(BuildContext context) {
    final colorScheme = _colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5669FF) : colorScheme.backgroundColor,
          borderRadius: BorderRadius.circular(25.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF5669FF) : colorScheme.borderColor,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF5669FF).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.white : colorScheme.textColor,
          ),
        ),
      ),
    );
  }
}
