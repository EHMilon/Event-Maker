import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../constants/app_colors.dart';
import '../../../models/customer_payment_history_model.dart';
import '../../profile/profile_controller.dart';

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  final ProfileController controller = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    controller.fetchCustomerPaymentHistory(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'myTransactions'.tr,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Obx(() {
        final payments = controller.customerPaymentTransactions;
        final isLoading = controller.isCustomerPaymentLoading.value;

        if (isLoading && payments.isEmpty) {
          return Skeletonizer(
            enabled: true,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              itemCount: 5,
              separatorBuilder: (context, index) =>
                  Divider(height: 32.h, color: Colors.grey[100]),
              itemBuilder: (context, index) {
                return _buildTransactionItemSkeleton();
              },
            ),
          );
        }

        if (payments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64.sp,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 16.h),
                Text(
                  'No transactions yet',
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey[400]),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Your payment history will appear here',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[300]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshCustomerPayments(),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            itemCount: payments.length,
            separatorBuilder: (context, index) =>
                Divider(height: 32.h, color: Colors.grey[100]),
            itemBuilder: (context, index) {
              final payment = payments[index];
              return _buildTransactionItem(payment);
            },
          ),
        );
      }),
    );
  }

  Widget _buildTransactionItem(CustomerPaymentTransaction payment) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                payment.title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                payment.bookingCode,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              payment.displayTime,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[400]),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Text(
                  payment.amount,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: _getAmountColor(payment.status),
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  payment.currency,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionItemSkeleton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 120.w, height: 14.sp, color: Colors.grey[300]),
            SizedBox(height: 8.h),
            Container(width: 80.w, height: 12.sp, color: Colors.grey[300]),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(width: 60.w, height: 12.sp, color: Colors.grey[300]),
            SizedBox(height: 8.h),
            Container(width: 70.w, height: 16.sp, color: Colors.grey[300]),
          ],
        ),
      ],
    );
  }

  Widget _buildMethodBadge(String method) {
    final color = _getMethodColor(method);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        method.toUpperCase(),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Color _getAmountColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.primary;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  Color _getMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'stripe':
        return Colors.purple;
      case 'paypal':
        return Colors.blue;
      case 'card':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
