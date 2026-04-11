import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';

class DynamicDropdownField<T> extends StatefulWidget {
  final List<T> items;
  final List<dynamic> selectedItems;
  final String label;
  final String hintText;
  final String Function(T) itemBuilder;
  final Function(dynamic) onSelected;
  final Function(dynamic) onRemoved;
  final Function() onAddPressed;
  final RxBool isAdding;
  final TextEditingController addController;
  final VoidCallback onSaveAdd;
  final VoidCallback onCancelAdd;
  final bool enabled;

  const DynamicDropdownField({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.label,
    required this.hintText,
    required this.itemBuilder,
    required this.onSelected,
    required this.onRemoved,
    required this.onAddPressed,
    required this.isAdding,
    required this.addController,
    required this.onSaveAdd,
    required this.onCancelAdd,
    this.enabled = true,
  });

  @override
  State<DynamicDropdownField<T>> createState() => _DynamicDropdownFieldState<T>();
}

class _DynamicDropdownFieldState<T> extends State<DynamicDropdownField<T>> {
  bool _isExpanded = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _toggleDropdown() {
    if (!widget.enabled) return;
    if (_isExpanded) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isExpanded = true;
    });
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isExpanded = false;
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 0.h),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12.r),
            color: Colors.white,
            child: Container(
              constraints: BoxConstraints(maxHeight: 400.h),
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
                      Obx(() => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...widget.items.map((item) {
                            final isSelected = widget.selectedItems.contains(item);
                            return ListTile(
                              title: Text(
                                widget.itemBuilder(item),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                              onTap: () {
                                widget.onSelected(item);
                                _closeDropdown();
                              },
                            );
                          }),
                          // Selected custom items that are not in the main items list
                          ...widget.selectedItems
                              .where((e) => !widget.items.contains(e))
                              .map((item) {
                            return ListTile(
                              title: Text(
                                item.toString(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.close,
                                    size: 18.r, color: AppColors.error),
                                onPressed: () {
                                  widget.onRemoved(item);
                                },
                              ),
                              onTap: () {
                                widget.onSelected(item);
                                _closeDropdown();
                              },
                            );
                          }),
                        ],
                      )),
                      
                      // Add custom service item
                      Obx(() => widget.isAdding.value 
                        ? Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Column(
                              children: [
                                TextField(
                                  controller: widget.addController,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    hintText: 'Type Here',
                                    hintStyle: TextStyle(color: AppColors.grey.withOpacity(0.5)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                      borderSide: BorderSide(color: AppColors.lightGrey),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: widget.onCancelAdd,
                                      style: TextButton.styleFrom(
                                        backgroundColor: AppColors.lightGrey.withOpacity(0.3),
                                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                      ),
                                      child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                                    ),
                                    SizedBox(width: 8.w),
                                    ElevatedButton(
                                      onPressed: () {
                                        widget.onSaveAdd();
                                        _closeDropdown();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                      ),
                                      child: Text('Save', style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : InkWell(
                            onTap: widget.onAddPressed,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                              decoration: BoxDecoration(
                                color: AppColors.grey100, // Darker/Grey background for the last option
                                border: Border(top: BorderSide(color: AppColors.lightGrey.withOpacity(0.5))),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.add_box_outlined, color: AppColors.textSecondary, size: 25.r),
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
                border: Border.all(color: _isExpanded ? AppColors.primary : AppColors.lightGrey),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: widget.selectedItems.isEmpty
                        ? Text(
                            widget.hintText,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.grey.withOpacity(0.5),
                            ),
                          )
                        : Obx(() {
                            if (widget.selectedItems.isEmpty) {
                              return Text(
                                widget.hintText,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.grey.withOpacity(0.5),
                                ),
                              );
                            }
                            final item = widget.selectedItems.last;
                            return Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item is T 
                                        ? widget.itemBuilder(item) 
                                        : item.toString(),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => widget.onRemoved(item),
                                  child: Icon(Icons.close, size: 18.r, color: AppColors.textSecondary),
                                ),
                                SizedBox(width: 8.w),
                              ],
                            );
                          }),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
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
    super.dispose();
  }
}
