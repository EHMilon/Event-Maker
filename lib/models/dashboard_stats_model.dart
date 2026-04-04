class DashboardStats {
  final String totalEarnings;
  final int totalRequests;
  final int completedOrders;
  final int pendingOrders;
  final String totalBalance;
  final String earningsChange;
  final String requestsChange;
  final String completedChange;
  final String pendingChange;
  final bool isEarningsUp;
  final bool isRequestsUp;
  final bool isCompletedUp;
  final bool isPendingUp;

  DashboardStats({
    required this.totalEarnings,
    required this.totalRequests,
    required this.completedOrders,
    required this.pendingOrders,
    required this.totalBalance,
    required this.earningsChange,
    required this.requestsChange,
    required this.completedChange,
    required this.pendingChange,
    required this.isEarningsUp,
    required this.isRequestsUp,
    required this.isCompletedUp,
    required this.isPendingUp,
  });

  factory DashboardStats.empty() {
    return DashboardStats(
      totalEarnings: "0 AED",
      totalRequests: 0,
      completedOrders: 0,
      pendingOrders: 0,
      totalBalance: "0 AED",
      earningsChange: "0%",
      requestsChange: "0%",
      completedChange: "0%",
      pendingChange: "0%",
      isEarningsUp: true,
      isRequestsUp: true,
      isCompletedUp: true,
      isPendingUp: true,
    );
  }

  // To facilitate backend integration later
  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalEarnings: json['total_earnings'] ?? "0 AED",
      totalRequests: json['total_requests'] ?? 0,
      completedOrders: json['completed_orders'] ?? 0,
      pendingOrders: json['pending_orders'] ?? 0,
      totalBalance: json['total_balance'] ?? "0 AED",
      earningsChange: json['earnings_change'] ?? "0%",
      requestsChange: json['requests_change'] ?? "0%",
      completedChange: json['completed_change'] ?? "0%",
      pendingChange: json['pending_change'] ?? "0%",
      isEarningsUp: json['is_earnings_up'] ?? true,
      isRequestsUp: json['is_requests_up'] ?? true,
      isCompletedUp: json['is_completed_up'] ?? true,
      isPendingUp: json['is_pending_up'] ?? true,
    );
  }
}
