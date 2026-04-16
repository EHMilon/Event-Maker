import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

class SearchableUnifiedDropdownField<T> extends StatefulWidget {
  final String label;
  final String hint;
  final List<T> items;
  final String Function(T) itemLabel;
  final Function(T?)? onSingleSelect;
  final List<dynamic>? selectedItems;
  final Function(T)? onMultiSelect;
  final Function(T)? onRemoveItem;
  final bool enabled;
  final bool isMulti;

  const SearchableUnifiedDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.itemLabel,
    this.onSingleSelect,
    this.selectedItems,
    this.onMultiSelect,
    this.onRemoveItem,
    this.enabled = true,
    this.isMulti = false,
  });

  @override
  State<SearchableUnifiedDropdownField<T>> createState() =>
      _SearchableUnifiedDropdownFieldState<T>();
}

class _SearchableUnifiedDropdownFieldState<T>
    extends State<SearchableUnifiedDropdownField<T>> {
  final TextEditingController _controller = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    // Use post-frame callback for initial text setup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateTextFieldText();
    });
  }

  @override
  void didUpdateWidget(covariant SearchableUnifiedDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedItems != widget.selectedItems) {
      // Use post-frame callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateTextFieldText();
      });
    }
  }

  void _updateTextFieldText() {
    if (!mounted) return;

    String newText = '';
    if (widget.selectedItems != null && widget.selectedItems!.isNotEmpty) {
      if (widget.isMulti) {
        newText = widget.selectedItems!
            .map((item) => item is T ? widget.itemLabel(item) : item.toString())
            .join(', ');
      } else {
        final lastItem = widget.selectedItems!.last;
        newText = lastItem is T
            ? widget.itemLabel(lastItem)
            : lastItem.toString();
      }
    }

    if (_controller.text != newText) {
      _controller.text = newText;
      // Preserve selection if focused
      if (_focusNode.hasFocus) {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      }
    }
  }

  void _onFocusChange() {
    if (!mounted) return;

    if (_focusNode.hasFocus) {
      _openOverlay();
    } else {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_focusNode.hasFocus) {
          _closeOverlay();
          _updateTextFieldText();
        }
      });
    }
  }

  void _toggleOverlay() {
    if (!mounted) return;

    if (_isMenuOpen) {
      _focusNode.unfocus();
      _closeOverlay();
    } else {
      _focusNode.requestFocus();
      _openOverlay();
    }
  }

  void _openOverlay() {
    if (_overlayEntry != null || !mounted) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isMenuOpen = true;
    });
  }

  void _closeOverlay() {
    if (_overlayEntry == null) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isMenuOpen = false;
      });
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null)
      return OverlayEntry(builder: (_) => const SizedBox.shrink());

    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);
    var screenHeight = MediaQuery.of(context).size.height;
    var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    var availableHeightBelow =
        screenHeight - offset.dy - size.height - keyboardHeight - 20.h;
    var dropdownHeight = 250.h;

    // Check if dropdown should show above or below
    bool showAbove =
        availableHeightBelow < dropdownHeight && offset.dy > dropdownHeight;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(
            0,
            showAbove ? -dropdownHeight - 4.h : size.height - 25.h,
          ),
          child: TapRegion(
            onTapOutside: (event) {
              if (mounted) {
                _focusNode.unfocus();
                _closeOverlay();
              }
            },
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
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.lightGrey.withOpacity(0.5),
                  ),
                ),
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, child) {
                    final String input = value.text.toLowerCase();

                    final List<T> filteredItems =
                        input.isEmpty || _isCurrentTextMatchingSelection()
                        ? widget.items
                        : widget.items.where((item) {
                            return widget
                                .itemLabel(item)
                                .toLowerCase()
                                .contains(input);
                          }).toList();

                    if (filteredItems.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Text(
                          'No results found',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14.sp,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final T item = filteredItems[index];
                        final String label = widget.itemLabel(item);
                        final bool isSelected =
                            widget.selectedItems?.contains(item) ?? false;

                        return ListTile(
                          dense: true,
                          title: Text(
                            label,
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
                              ? Icon(
                                  Icons.check,
                                  color: AppColors.primary,
                                  size: 18.r,
                                )
                              : null,
                          onTap: () {
                            if (widget.isMulti) {
                              if (isSelected) {
                                widget.onRemoveItem?.call(item);
                              } else {
                                widget.onMultiSelect?.call(item);
                              }
                              // State update will trigger didUpdateWidget -> _updateTextFieldText
                              _focusNode.unfocus();
                              _closeOverlay();
                            } else {
                              widget.onSingleSelect?.call(item);
                              _controller.text = label;
                              _focusNode.unfocus();
                              _closeOverlay();
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isCurrentTextMatchingSelection() {
    if (widget.selectedItems == null || widget.selectedItems!.isEmpty)
      return false;
    final String currentSelectionText = widget.selectedItems!
        .map((item) => item is T ? widget.itemLabel(item) : item.toString())
        .join(', ');
    return _controller.text == currentSelectionText;
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
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: AppColors.grey.withOpacity(0.5),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              filled: true,
              fillColor: Colors.white,
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
                borderSide: BorderSide(color: AppColors.primary),
              ),
              suffixIcon: GestureDetector(
                onTap: _toggleOverlay,
                child: Icon(
                  _isMenuOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                  size: 24.r,
                ),
              ),
            ),
            style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
            onTap: () {
              if (!_isMenuOpen) _openOverlay();
            },
            onChanged: (val) {
              if (!_isMenuOpen) _openOverlay();
              if (mounted) setState(() {});
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }
}
