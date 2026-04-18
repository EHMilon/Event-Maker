import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';

enum DropdownMode { single, multi }

class DropdownManager {
  static final DropdownManager _instance = DropdownManager._internal();
  factory DropdownManager() => _instance;
  DropdownManager._internal();

  VoidCallback? _activeCloseCallback;

  void setActive(VoidCallback? onClose) {
    if (_activeCloseCallback != onClose) {
      _activeCloseCallback?.call();
      _activeCloseCallback = onClose;
    }
  }

  void clear(VoidCallback? onClose) {
    if (_activeCloseCallback == onClose) {
      _activeCloseCallback = null;
    }
  }
}

class UnifiedDropdownField<T> extends StatefulWidget {
  final T? value;
  final String label;
  final String hint;
  final List<T> items;
  final String Function(T) itemLabel;
  final Function(T?)? onSingleSelect;
  final List<dynamic>? selectedItems;
  final Function(dynamic)? onMultiSelect;
  final Function(dynamic)? onRemoveItem;
  final VoidCallback? onAddCustom;
  final RxBool? isAdding;
  final TextEditingController? addController;
  final VoidCallback? onSaveAdd;
  final VoidCallback? onCancelAdd;
  final bool enabled;
  final DropdownMode mode;

  const UnifiedDropdownField({
    super.key,
    this.value,
    required this.label,
    required this.hint,
    required this.items,
    required this.itemLabel,
    this.onSingleSelect,
    this.selectedItems,
    this.onMultiSelect,
    this.onRemoveItem,
    this.onAddCustom,
    this.isAdding,
    this.addController,
    this.onSaveAdd,
    this.onCancelAdd,
    this.enabled = true,
    this.mode = DropdownMode.single,
  });

  @override
  State<UnifiedDropdownField<T>> createState() =>
      _UnifiedDropdownFieldState<T>();
}

class _UnifiedDropdownFieldState<T> extends State<UnifiedDropdownField<T>> {
  bool _isExpanded = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  late final VoidCallback _closeCallback;

  @override
  void initState() {
    super.initState();
    _closeCallback = () {
      if (mounted) {
        _closeDropdown();
      }
    };
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;
    if (_isExpanded) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    DropdownManager().setActive(_closeCallback);
    if (!mounted) return;

    // Small delay to ensure any keyboard hiding animation is finished and layout is stable
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
      setState(() {
        _isExpanded = true;
      });
      // Help scrolling by unfocusing any active text field
      FocusScope.of(context).unfocus();
    });
  }

  void _closeDropdown() {
    DropdownManager().clear(_closeCallback);
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isExpanded = false;
    });
  }

  void _selectSingleItem(T item) {
    widget.onSingleSelect?.call(item);
    _closeDropdown();
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return OverlayEntry(builder: (_) => const SizedBox.shrink());
    }

    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);
    var screenHeight = MediaQuery.of(context).size.height;
    var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    var availableHeightBelow =
        screenHeight - offset.dy - size.height - keyboardHeight - 20.h;
    var dropdownHeight = 180.h;

    // Check if dropdown should show above or below
    bool showAbove =
        availableHeightBelow < dropdownHeight && offset.dy > dropdownHeight;
    double topOffset = showAbove
        ? offset.dy - dropdownHeight + 25.h
        : offset.dy + size.height + 4.h;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Invisible full-screen detector to close dropdown on outside tap
          // Uses PointerEvent to allow scroll gestures to pass through
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (event) {
                // Close dropdown on any pointer down outside the dropdown
                _closeDropdown();
              },
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            width: size.width,
            left: offset.dx,
            top: topOffset,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12.r),
              color: Colors.white,
              child: Container(
                constraints: BoxConstraints(maxHeight: dropdownHeight),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...widget.items.map((item) {
                          final bool isSelected;
                          if (widget.mode == DropdownMode.single) {
                            isSelected = item == widget.value;
                          } else {
                            isSelected =
                                widget.selectedItems?.contains(item) ?? false;
                          }
                          return ListTile(
                            title: Text(
                              widget.itemLabel(item),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check, color: AppColors.primary)
                                : null,
                            onTap: () {
                              if (widget.mode == DropdownMode.single) {
                                _selectSingleItem(item);
                              } else {
                                // For multi-select, call the callback with the item (Enum or String)
                                widget.onMultiSelect?.call(item);
                                // Automatically hide on selection
                                _closeDropdown();
                              }
                            },
                          );
                        }),
                        if (widget.mode == DropdownMode.multi &&
                            widget.onAddCustom != null)
                          InkWell(
                            onTap: () {
                              _closeDropdown();
                              widget.onAddCustom?.call();
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                vertical: 16.h,
                                horizontal: 16.w,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.grey100,
                                border: Border(
                                  top: BorderSide(
                                    color: AppColors.lightGrey
                                        .withOpacity(0.5),
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add_box_outlined,
                                    color: AppColors.textSecondary,
                                    size: 25.r,
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    'Add your custom service',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayText() {
    if (widget.mode == DropdownMode.single) {
      if (widget.value != null) {
        return widget.itemLabel(widget.value as T);
      }
      return widget.hint;
    } else {
      if (widget.selectedItems != null && widget.selectedItems!.isNotEmpty) {
        return widget.selectedItems!
            .map((item) {
              if (item is T) {
                return widget.itemLabel(item);
              }
              // Special handling for ServiceAs enum labels appearing as strings
              if (item.toString().contains('ServiceAs.')) {
                try {
                  return item.toString().split('.').last;
                } catch (_) {}
              }
              return item.toString();
            })
            .join(', ');
      }
      return widget.hint;
    }
  }

  bool _hasSelection() {
    if (widget.mode == DropdownMode.single) {
      return widget.value != null;
    }
    return widget.selectedItems != null && widget.selectedItems!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: _toggleDropdown,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: _isExpanded ? AppColors.primary : AppColors.lightGrey,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _hasSelection()
                        ? Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _getDisplayText(),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.mode == DropdownMode.multi &&
                                  widget.onRemoveItem != null &&
                                  _hasSelection())
                                GestureDetector(
                                  onTap: () {
                                    final lastItem = widget.selectedItems!.last;
                                    widget.onRemoveItem?.call(lastItem);
                                    if (mounted) setState(() {});
                                  },
                                  child: Icon(
                                    Icons.close,
                                    size: 18.r,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              if (widget.mode == DropdownMode.multi &&
                                  widget.onRemoveItem != null &&
                                  _hasSelection())
                                SizedBox(width: 8.w),
                            ],
                          )
                        : Text(
                            _getDisplayText(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.grey.withOpacity(0.5),
                            ),
                          ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    DropdownManager().clear(_closeCallback);
    super.dispose();
  }
}
