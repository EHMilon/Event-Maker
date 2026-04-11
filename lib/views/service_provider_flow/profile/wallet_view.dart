import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/models/wallet_model.dart';
import 'package:event_maker/views/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WalletView extends GetView<ProfileController> {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch wallet history on first build if empty
    _fetchOnFirstBuild();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'myWallet'.tr,
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Obx(
        () => Skeletonizer(
          enabled:
              controller.isWalletLoading.value &&
              controller.walletTransactions.isEmpty,
          child: RefreshIndicator(
            onRefresh: controller.refreshWallet,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 18.h),
                // Earnings Section
                _buildEarningsSection(),
                SizedBox(height: 18.h),
                // Withdraw Button
                _buildWithdrawButton(),
                SizedBox(height: 18.h),
                // Transactions Header
                _buildTransactionsHeader(),
                SizedBox(height: 16.h),
                // Transactions List
                Expanded(child: _buildTransactionsList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Fetches wallet history on first build if empty
  void _fetchOnFirstBuild() {
    if (controller.walletTransactions.isEmpty &&
        !controller.isWalletLoading.value) {
      controller.fetchWalletHistory();
    }
  }

  /// Builds the earnings display section
  Widget _buildEarningsSection() {
    return Center(
      child: Column(
        children: [
          Text(
            'totalEarnings'.tr,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                controller.walletBalance.value,
                style: GoogleFonts.inter(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'AED',
                style: GoogleFonts.inter(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          // Show pending balance if any
          if (controller.walletSummary.value != null &&
              controller.walletSummary.value!.pendingBalance != '0.00') ...[
            SizedBox(height: 8.h),
            Text(
              'Pending: ${controller.walletSummary.value!.pendingBalance} AED',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the withdraw button
  Widget _buildWithdrawButton() {
    return Obx(
      () => Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: controller.isWithdrawalLoading.value ||
                    controller.isStripeConnectLoading.value
                ? null
                : () => _handleWithdrawTap(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: controller.isWithdrawalLoading.value ||
                    controller.isStripeConnectLoading.value
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'withdraw'.tr,
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

  /// Handles withdraw button tap
  Future<void> _handleWithdrawTap() async {
    // Check if wallet has balance
    final availableBalance =
        controller.walletSummary.value?.availableBalanceAmount ?? 0.0;
    if (availableBalance <= 0) {
      Get.snackbar(
        'error'.tr,
        'insufficientFunds'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    // Check withdrawal flow
    final action = await controller.checkWithdrawalFlow();

    switch (action) {
      case WithdrawalAction.showConnectivityError:
      case WithdrawalAction.showError:
        // Error already shown by controller
        break;

      case WithdrawalAction.openStripeOnboarding:
        // Show dialog to complete Stripe onboarding first
        _showStripeOnboardingDialog();
        break;

      case WithdrawalAction.stripeNotReady:
        // Show dialog that Stripe is not ready for payouts
        _showStripeNotReadyDialog();
        break;

      case WithdrawalAction.showWithdrawalDialog:
        // Show withdrawal amount input dialog
        _showWithdrawalDialog(availableBalance);
        break;
    }
  }

  /// Shows dialog for Stripe onboarding
  void _showStripeOnboardingDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'setupStripeAccount'.tr,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'stripeOnboardingRequired'.tr,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.openStripeOnboarding();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'setupNow'.tr,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows dialog when Stripe is not ready for payouts
  void _showStripeNotReadyDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'payoutsNotAvailable'.tr,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'stripePayoutsNotEnabled'.tr,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'ok'.tr,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows withdrawal amount input dialog
  void _showWithdrawalDialog(double availableBalance) {
    final amountController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'withdrawFunds'.tr,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${'availableBalance'.tr}: $availableBalance AED',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'amount'.tr,
                hintText: '0.00',
                suffixText: 'AED',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            // Quick amount buttons
            Row(
              children: [
                _buildQuickAmountButton(amountController, availableBalance, 0.25),
                SizedBox(width: 8.w),
                _buildQuickAmountButton(amountController, availableBalance, 0.50),
                SizedBox(width: 8.w),
                _buildQuickAmountButton(amountController, availableBalance, 1.0),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                Get.snackbar(
                  'error'.tr,
                  'invalidAmount'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.error,
                  colorText: Colors.white,
                );
                return;
              }
              if (amount > availableBalance) {
                Get.snackbar(
                  'error'.tr,
                  'insufficientFunds'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.error,
                  colorText: Colors.white,
                );
                return;
              }

              Get.back();

              // Request withdrawal
              await controller.requestWithdrawal(amount);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'withdraw'.tr,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds quick amount selection button
  Widget _buildQuickAmountButton(
    TextEditingController amountController,
    double availableBalance,
    double fraction,
  ) {
    final amount = (availableBalance * fraction).toStringAsFixed(2);
    return Expanded(
      child: OutlinedButton(
        onPressed: () => amountController.text = amount,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Text(
          fraction == 1.0 ? 'All' : '${(fraction * 100).toInt()}%',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  /// Builds the transactions header
  Widget _buildTransactionsHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'transactions'.tr,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          // Show total count if available
          if (controller.walletSummary.value != null)
            Text(
              '${controller.walletTransactions.length} transactions',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the transactions list with real wallet data
  Widget _buildTransactionsList() {
    // Show empty state if no transactions
    if (!controller.isWalletLoading.value &&
        controller.walletTransactions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount:
          controller.isWalletLoading.value &&
              controller.walletTransactions.isEmpty
          ? 5 // Skeleton items
          : controller.walletTransactions.length +
                (controller.hasMoreWalletTransactions
                    ? 1
                    : 0), // +1 for loading indicator
      separatorBuilder: (context, index) =>
          Divider(height: 1.h, color: AppColors.lightGrey.withOpacity(0.5)),
      itemBuilder: (context, index) {
        // Loading indicator at the end
        if (index == controller.walletTransactions.length) {
          _loadMoreIfNeeded();
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16.h),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          );
        }

        // Skeleton loading
        if (controller.isWalletLoading.value &&
            controller.walletTransactions.isEmpty) {
          return _buildSkeletonTransaction();
        }

        final transaction = controller.walletTransactions[index];
        return _buildTransactionItem(transaction);
      },
    );
  }

  /// Builds a single transaction item
  Widget _buildTransactionItem(WalletTransaction transaction) {
    // Use displayTime which handles both relative time strings and ISO datetime
    final formattedDate = transaction.displayTime;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transaction type icon
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: transaction.isCredit
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              transaction.isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: transaction.isCredit ? AppColors.success : AppColors.error,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.customer?.name ?? 'Customer',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                // SizedBox(height: 2.h),
                // Text(
                //   transaction.description ??
                //       (transaction.isCredit
                //           ? 'Provider earning'
                //           : 'Withdrawal'),
                //   style: GoogleFonts.inter(
                //     fontSize: 12.sp,
                //     fontWeight: FontWeight.w400,
                //     color: AppColors.textSecondary,
                //   ),
                // ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    // Booking code if available
                    if (transaction.bookingCode != null) ...[
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            transaction.bookingCode!,
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Date
              Text(
                formattedDate,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Text(
                    transaction.isCredit ? '+' : '-',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: transaction.isCredit
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                  Text(
                    transaction.amount,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: transaction.isCredit
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    transaction.currency,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds skeleton transaction item for loading state
  Widget _buildSkeletonTransaction() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BoneMock(width: 44.w, height: 44.h, borderRadius: 12.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BoneMock(width: 120.w, height: 14.h, borderRadius: 4.r),
                SizedBox(height: 6.h),
                BoneMock(width: 80.w, height: 12.h, borderRadius: 4.r),
                SizedBox(height: 8.h),
                BoneMock(width: 60.w, height: 12.h, borderRadius: 4.r),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              BoneMock(width: 60.w, height: 16.h, borderRadius: 4.r),
              SizedBox(height: 6.h),
              BoneMock(width: 50.w, height: 12.h, borderRadius: 4.r),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds empty state when no transactions
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64.sp,
            color: AppColors.lightGrey,
          ),
          SizedBox(height: 16.h),
          Text(
            'No transactions yet',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your earning transactions will appear here',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Gets color for transaction status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
        return AppColors.success;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Loads more transactions when reaching the end
  void _loadMoreIfNeeded() {
    if (controller.hasMoreWalletTransactions &&
        !controller.isWalletLoading.value) {
      // Defer the pagination call to avoid "setState called during build" error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadMoreWalletTransactions();
      });
    }
  }
}

/// Simple bone mock widget for skeleton loading
class BoneMock extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const BoneMock({
    super.key,
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
