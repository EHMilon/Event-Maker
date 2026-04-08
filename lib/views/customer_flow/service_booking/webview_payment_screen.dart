import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:event_maker/constants/app_colors.dart';

/// WebView-based payment screen for handling Stripe/PayPal checkout.
///
/// This screen displays the payment page inside the app and monitors
/// for payment success/cancel by detecting URL changes.
class WebViewPaymentScreen extends StatefulWidget {
  final String checkoutUrl;
  final int bookingId;
  final String paymentMethod; // 'Stripe' or 'PayPal'

  const WebViewPaymentScreen({
    super.key,
    required this.checkoutUrl,
    required this.bookingId,
    required this.paymentMethod,
  });

  @override
  State<WebViewPaymentScreen> createState() => _WebViewPaymentScreenState();
}

class _WebViewPaymentScreenState extends State<WebViewPaymentScreen> {
  late InAppWebViewController _webViewController;
  bool _isLoading = true;
  double _loadingProgress = 0;
  String _currentUrl = '';
  bool _hasNavigated = false; // Prevent multiple navigation attempts

  // URL patterns to detect payment completion
  // Stripe success URLs typically contain these patterns
  static const List<String> _successPatterns = [
    'success=true',
    'payment=success',
    'status=success',
    'result=success',
    'success',
    'thank_you',
    'confirmation',
    'order-confirmation',
    'payment-complete',
  ];

  // Stripe cancel URLs typically contain these patterns
  static const List<String> _cancelPatterns = [
    'cancel=true',
    'status=cancel',
    'cancelled',
    'canceled',
    'payment-cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          '${widget.paymentMethod} Payment',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.black),
          onPressed: () => _showCancelDialog(),
        ),
        actions: [
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Loading progress bar
          if (_isLoading)
            LinearProgressIndicator(
              value: _loadingProgress,
              backgroundColor: AppColors.lightGrey,
              color: AppColors.primary,
              minHeight: 2,
            ),

          // WebView
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.checkoutUrl)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                supportZoom: true,
                useShouldOverrideUrlLoading: true,
                useShouldInterceptRequest: true,
                allowFileAccess: true, // Allow file access for local backend
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStart: (controller, url) {
                if (!mounted) return;
                if (url != null) {
                  setState(() {
                    _currentUrl = url.toString();
                    _isLoading = true;
                  });
                  _checkPaymentStatus(url.toString());
                }
              },
              onLoadStop: (controller, url) {
                if (!mounted) return;
                setState(() {
                  _isLoading = false;
                  _loadingProgress = 1.0;
                });
                if (url != null) {
                  _checkPaymentStatus(url.toString());
                }
              },
              onProgressChanged: (controller, progress) {
                if (!mounted) return;
                setState(() {
                  _loadingProgress = progress / 100;
                });
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final url = navigationAction.request.url?.toString() ?? '';
                if (!mounted) return NavigationActionPolicy.ALLOW;
                setState(() => _currentUrl = url);
                _checkPaymentStatus(url);
                return NavigationActionPolicy.ALLOW;
              },
              onReceivedError: (controller, request, error) {
                debugPrint('WebView Error: ${error.description}');
              },
            ),
          ),

          // Bottom info bar
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withValues(alpha: 0.3),
              border: Border(top: BorderSide(color: AppColors.lightGrey)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 16.r,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Secure payment powered by ${widget.paymentMethod}',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
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

  /// Checks the current URL for payment success or cancel patterns.
  void _checkPaymentStatus(String url) {
    // Prevent multiple navigation attempts
    if (_hasNavigated) return;

    final lowerUrl = url.toLowerCase();

    // Check for success patterns
    for (final pattern in _successPatterns) {
      if (lowerUrl.contains(pattern)) {
        _handlePaymentSuccess();
        return;
      }
    }

    // Check for cancel patterns
    for (final pattern in _cancelPatterns) {
      if (lowerUrl.contains(pattern)) {
        _handlePaymentCancel();
        return;
      }
    }
  }

  /// Handles successful payment detection.
  void _handlePaymentSuccess() {
    if (_hasNavigated) return;
    _hasNavigated = true;

    debugPrint('Payment SUCCESS detected!');

    // Navigate to confirmation screen
    Get.offNamed(
      '/payment-confirmation',
      arguments: {
        'booking_id': widget.bookingId,
        'payment_method': widget.paymentMethod,
        'success_message': 'Payment completed successfully!',
      },
    );
  }

  /// Handles payment cancellation.
  void _handlePaymentCancel() {
    if (_hasNavigated) return;
    _hasNavigated = true;

    debugPrint('Payment CANCELLED detected!');

    Get.back();
    Get.snackbar(
      'Payment Cancelled',
      'Your payment was cancelled. You can try again later.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }

  /// Shows a dialog to confirm cancellation.
  void _showCancelDialog() {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Cancel Payment?',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel this payment? You can complete it later from your bookings.',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Continue Payment',
              style: GoogleFonts.inter(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              _handlePaymentCancel();
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
